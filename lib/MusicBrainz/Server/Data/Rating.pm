package MusicBrainz::Server::Data::Rating;

use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use aliased 'Fey::Literal::Function';
use Sql;
use MusicBrainz::Server::Data::Utils qw( placeholders query_to_list );
use MusicBrainz::Server::Entity::Rating;

extends 'MusicBrainz::Server::Data::FeyEntity';
with 'MusicBrainz::Server::Data::Role::Joined' => {
    -excludes => '_build__join_column'
};

method _dbh { $self->c->raw_dbh }

method _build__join_column
{
    $self->table->column($self->parent->table->name)
}

method find_by_entity_id ($id)
{
    my $query = $self->_select
        ->where($self->_join_column, '=', $id)
        ->order_by($self->table->column('rating'), 'DESC')
        ->order_by($self->table->column('editor'));

    return query_to_list($self->c->raw_dbh, sub {
        my $row = $_[0];
        return MusicBrainz::Server::Entity::Rating->new(
            editor_id => $row->{editor},
            rating => $row->{rating},
        );
    }, $query->sql($self->sql->dbh), $query->bind_params);
}

method load_user_ratings ($user_id, @objs)
{
    my %id_to_obj = map { $_->id => $_ } @objs;
    my @ids = keys %id_to_obj;
    return unless @ids;

    my $query = Fey::SQL->new_select
        ->select($self->_join_column->alias('id'),
                 $self->table->column('rating'))
        ->from($self->table)
        ->where($self->table->column('editor'), '=', $user_id)
        ->where($self->_join_column, 'IN', @ids);

    $self->sql->select($query->sql($self->sql->dbh), $query->bind_params);
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $id_to_obj{$row->{id}};
        $obj->user_rating($row->{rating});
    }
    $self->sql->finish;
}

method _update_aggregate_rating ($entity_id)
{
    my $sql = Sql->new($self->c->dbh);

    # Update the aggregate rating
    my $query = Fey::SQL->new_select
        ->select(Function->new('count', $self->table->column('rating')),
                 Function->new('sum', $self->table->column('rating')))
        ->from($self->table)
        ->where($self->_join_column, '=', $entity_id)
        ->group_by($self->_join_column);

    my $row = $self->sql->select_single_row_array(
        $query->sql($self->sql->dbh), $query->bind_params);

    my ($rating_count, $rating_sum) = defined $row ? @$row : (undef, undef);
    my $rating_avg = ($rating_count
                          ? int($rating_sum / $rating_count + 0.5)
                          : undef);

    my $meta = $self->parent->metadata_table;
    $query = Fey::SQL->new_update
        ->update($meta)
        ->set($meta->column('ratingcount'), $rating_count)
        ->set($meta->column('rating'), $rating_avg)
        ->where($meta->column('id'), '=', $entity_id);

    $sql->do($query->sql($sql->dbh), $query->bind_params);

    return ($rating_count, $rating_sum);
}

method merge ($new_id, @old_ids)
{
    # Remove duplicate joins (ie, rows with entities from @old_ids and
    # tagged by editors that already tagged $new_id)
    my $subq = Fey::SQL->new_select
        ->select($self->table->column('editor'))
        ->from($self->table)
        ->where($self->_join_column, '=', $new_id);

    my $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->_join_column, 'IN', @old_ids)
        ->where($self->table->column('editor'), 'IN', $subq);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

    # Move all remaining joins to the new entity
    $query = Fey::SQL->new_update
        ->update($self->table)
        ->set($self->_join_column, $new_id)
        ->where($self->_join_column, 'IN', @old_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

    # Update the aggregate rating
    $self->_update_aggregate_rating($new_id);

    return 1;
}

method delete (@entity_ids)
{
    my $query = Fey::SQL->new_delete
        ->from($self->table)
        ->where($self->_join_column, 'IN', @entity_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);
    return 1;
}

method update ($user_id, $entity_id, $rating)
{
    my ($rating_count, $rating_sum, $rating_avg, $query);

    my $sql = Sql->new($self->c->dbh);
    Sql::run_in_transaction(sub
    {
        # Check if user has already rated this entity
        $query = Fey::SQL->new_select
            ->select($self->table->column('rating'))
            ->from($self->table)
            ->where($self->_join_column, '=', $entity_id)
            ->where($self->table->column('editor'), '=', $user_id);

        my $whetherrated = $self->sql->select_single_value(
            $query->sql($self->sql->dbh), $query->bind_params);

        if (defined $whetherrated) {
            # Already rated - so update
            if ($rating) {
                $query = Fey::SQL->new_update
                    ->update($self->table)
                    ->set($self->table->column('rating'), $rating)
                    ->where($self->_join_column, '=', $entity_id)
                    ->where($self->table->column('editor'), '=', $user_id);
            }
            else {
                $query = Fey::SQL->new_delete
                    ->from($self->table)
                    ->where($self->_join_column, '=', $entity_id)
                    ->where($self->table->column('editor'), '=', $user_id);
            }
        }
        elsif ($rating) {
            # Not rated - so insert raw rating value, unless rating = 0
            $query = Fey::SQL->new_insert
                ->into($self->table)
                ->values(
                    rating                    => $rating,
                    editor                    => $user_id,
                    $self->_join_column->name => $entity_id
                );
        }

        $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

        # Update the aggregate rating
        ($rating_count, $rating_sum) = $self->_update_aggregate_rating($entity_id);

    }, $sql, $self->sql);

    return ($rating_avg, $rating_count);
}

__PACKAGE__->meta->make_immutable;

=head1 NAME

MusicBrainz::Server::Data::Rating

=head1 METHODS

=head2 delete(@entity_ids)

Delete ratings from the RAWDATA database for entities from @entity_ids.

=head2 update($user_id, $entity_id, $rating)

Update rating for entity $entity_id by editor $user_id to $rating.

Note: this function starts it's own DB transaction.

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2008 Aurelien Mino
Copyright (C) 2007 Sharon Myrtle Paradesi

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

