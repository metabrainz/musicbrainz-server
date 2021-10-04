package MusicBrainz::Server::Data::Rating;

use Moose;
use namespace::autoclean;
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders );
use MusicBrainz::Server::Entity::Rating;

extends 'MusicBrainz::Server::Data::Entity';

has 'type' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has 'parent' => (
    does => 'MusicBrainz::Server::Data::Role::Rating',
    is => 'rw',
    required => 1,
    weak_ref => 1
);

sub find_editor_ratings {
    my ($self, $editor_id, $own_ratings, $limit, $offset) = @_;

    my $table = $self->type . '_rating_raw';
    my $type = $self->type;
    my $query = "
      SELECT $type AS entity, rating
      FROM $table rating
      JOIN $type entity ON entity.id = rating.${type}
      WHERE editor = ?
      ORDER BY rating DESC, name COLLATE musicbrainz ASC";

    my ($rows, $hits) = $self->query_to_list_limited(
        $query,
        [$editor_id],
        $limit,
        $offset,
        sub { $_[1] },
    );
    my $entities = $self->parent->get_by_ids(map { $_->{entity} } @$rows);

    my $results = [
        map {
            my $entity = $entities->{ $_->{entity} };
            if ($own_ratings) {
                $entity->user_rating($_->{rating});
            }
            else {
                $entity->rating($_->{rating});
                $entity->rating_count(1);
            }

            $entity;
        } @$rows
    ];

    return ($results, $hits);
}

sub find_by_entity_id
{
    my ($self, $id) = @_;

    my $type = $self->type;
    my $query = "
        SELECT editor, rating FROM ${type}_rating_raw
        WHERE $type = ? ORDER BY rating DESC, editor";

    $self->query_to_list($query, [$id], sub {
        my ($model, $row) = @_;

        MusicBrainz::Server::Entity::Rating->new(
            editor_id => $row->{editor},
            rating => $row->{rating},
        );
    });
}

sub load_user_ratings
{
    my ($self, $user_id, @objs) = @_;

    my %id_to_obj = map { $_->id => $_ } @objs;
    my @ids = keys %id_to_obj;
    return unless @ids;

    my $type = $self->type;
    my $query = "
        SELECT $type AS id, rating FROM ${type}_rating_raw
        WHERE editor = ? AND $type IN (".placeholders(@ids).')';

    for my $row (@{ $self->sql->select_list_of_hashes($query, $user_id, @ids) }) {
        my $obj = $id_to_obj{$row->{id}};
        $obj->user_rating($row->{rating});
    }
}

sub _update_aggregate_rating
{
    my ($self, $entity_id) = @_;

    my $type = $self->type;
    my $table = $type . '_meta';
    my $table_raw = $type . '_rating_raw';

    # Update the aggregate rating
    my $row = $self->c->sql->select_single_row_array("
        SELECT count(rating), sum(rating)
        FROM $table_raw WHERE $type = ?
        GROUP BY $type", $entity_id);

    my ($rating_count, $rating_sum) = defined $row ? @$row : (undef, undef);

    my $rating_avg = ($rating_count ? int($rating_sum / $rating_count + 0.5) : undef);
    $self->c->sql->do("UPDATE $table SET rating_count = ?, rating = ?
              WHERE id = ?", $rating_count, $rating_avg, $entity_id);

    return ($rating_count, $rating_sum);
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    my $type = $self->type;
    my $table = $type . '_meta';
    my $table_raw = $type . '_rating_raw';

    my $ratings = $self->c->sql->do(
        "INSERT INTO $table_raw (editor, rating, $type)
             SELECT editor, max(rating), ?
               FROM delete_ratings(?, ?)
           GROUP BY editor",
        $new_id, $type, [ $new_id, @old_ids ]
    );

    # Update the aggregate rating
    $self->_update_aggregate_rating($new_id);

    return 1;
}

sub delete
{
    my ($self, @entity_ids) = @_;
    $self->c->sql->do('
        DELETE FROM ' . $self->type . '_rating_raw
        WHERE ' . $self->type . ' IN (' . placeholders(@entity_ids) . ')',
        @entity_ids);
    return 1;
}

sub clear {
    my ($self, $editor_id) = @_;
    my $type = $self->type;
    my $table = $type . '_rating_raw';
    for my $entity_id (@{
        $self->c->sql->select_single_column_array(
            "DELETE FROM $table WHERE editor = ?
             RETURNING $type",
            $editor_id
        )
    }) {
        $self->_update_aggregate_rating($entity_id);
    }
}

sub update
{
    my ($self, $user_id, $entity_id, $rating) = @_;

    my ($rating_count, $rating_sum);

    my $sql = $self->c->sql;
    Sql::run_in_transaction(sub {

        my $type = $self->type;
        my $table = $type . '_meta';
        my $table_raw = $type . '_rating_raw';

        # Check if user has already rated this entity
        my $whetherrated = $sql->select_single_value("
            SELECT rating FROM $table_raw
            WHERE $type = ? AND editor = ?", $entity_id, $user_id);
        if (defined $whetherrated) {
            # Already rated - so update
            if ($rating) {
                $sql->do("UPDATE $table_raw SET rating = ?
                              WHERE $type = ? AND editor = ?",
                              $rating, $entity_id, $user_id);
            }
            else {
                $sql->do("DELETE FROM $table_raw
                              WHERE $type = ? AND editor = ?",
                              $entity_id, $user_id);
            }
        }
        elsif ($rating) {
            # Not rated - so insert raw rating value, unless rating = 0
            $sql->do("INSERT INTO $table_raw (rating, $type, editor)
                          VALUES (?, ?, ?)", $rating, $entity_id, $user_id);
        }

        # Update the aggregate rating
        ($rating_count, $rating_sum) = $self->_update_aggregate_rating($entity_id);

    }, $self->c->sql);

    return ($rating_sum, $rating_count);
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;

=head1 NAME

MusicBrainz::Server::Data::Rating

=head1 METHODS

=head2 delete(@entity_ids)

Delete ratings from the database for entities from @entity_ids.

=head2 update($user_id, $entity_id, $rating)

Update rating for entity $entity_id by editor $user_id to $rating.

Note: this function starts it's own DB transaction.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2008 Aurelien Mino
Copyright (C) 2007 Sharon Myrtle Paradesi

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
