package MusicBrainz::Server::Data::EntityTag;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Entity::AggregatedTag;
use MusicBrainz::Server::Entity::UserTag;
use MusicBrainz::Server::Entity::Tag;
use Sql;

with 'MusicBrainz::Server::Data::Role::Sql';

has parent => (
    does => 'MusicBrainz::Server::Data::Role::Tag',
    is => 'ro',
    weak_ref => 1
);

has [qw( tag_table type )] => (
    isa => 'Str',
    is => 'ro'
);

sub find_tags {
    my ($self, $entity_id) = @_;

    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ?" .
                "ORDER BY entity_tag.count DESC, musicbrainz_collate(tag.name)";

    return query_to_list($self->c->sql, sub { $self->_new_from_row($_[0]) },
                         $query, $entity_id);
}

sub find_tag_count
{
    my ($self, $entity_id) = @_;
    my $query = "SELECT count(*) FROM " . $self->tag_table . " entity_tag " .
                "WHERE " . $self->type . " = ? ";

    return $self->sql->select_single_value($query, $entity_id);
}

sub find_top_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ? " .
                "ORDER BY entity_tag.count DESC, musicbrainz_collate(tag.name) LIMIT ?";
    return query_to_list($self->c->sql, sub { $self->_new_from_row($_[0]) },
                         $query, $entity_id, $limit);
}

sub find_tags_for_entities
{
    my ($self, @ids) = @_;

    return unless scalar @ids;

    my $query = "SELECT tag.name, entity_tag.count,
                        entity_tag.".$self->type." AS entity
                 FROM " . $self->tag_table . " entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 WHERE " . $self->type . " IN (" . placeholders(@ids) . ")
                 ORDER BY entity_tag.count DESC, musicbrainz_collate(tag.name)";

    return query_to_list(
        $self->c->sql, sub {
            $self->_new_from_row($_[0]);
        }, $query, @ids);
}

sub find_user_tags_for_entities
{
    my ($self, $user_id, @ids) = @_;

    return unless scalar @ids;

    my $type = $self->type;
    my $table = $self->tag_table . '_raw';
    my $query = "SELECT tag, $type AS entity, is_upvote
                 FROM $table
                 WHERE editor = ?
                 AND $type IN (" . placeholders(@ids) . ")";

    my @tags = query_to_list($self->c->sql, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag},
            editor_id => $user_id,
            entity_id => $row->{entity},
            is_upvote => $row->{is_upvote},
        );
    }, $query, $user_id, @ids);

    $self->c->model('Tag')->load(@tags);

    return sort { $a->tag->name cmp $b->tag->name } @tags;
}

sub _new_from_row
{
    my ($self, $row) = @_;

    my %init = (
        count => $row->{count},
        tag => MusicBrainz::Server::Entity::Tag->new( name => $row->{name} ),
    );

    $init{entity_id} = $row->{entity} if $row->{entity};

    MusicBrainz::Server::Entity::AggregatedTag->new(\%init);
}

sub delete
{
    my ($self, @entity_ids) = @_;
    $self->sql->do("
        DELETE FROM " . $self->tag_table . "
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    $self->c->sql->do("
        DELETE FROM " . $self->tag_table . "_raw
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    return 1;
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = $self->tag_table . '_raw';
    my @ids = ($new_id, @old_ids);

    $self->c->sql->do(
        "INSERT INTO $assoc_table_raw ($entity_type, editor, tag)
             SELECT ?, s.editor, s.tag
               FROM (SELECT DISTINCT editor, tag FROM delete_tags('$entity_type', ?)) s",
        $new_id, \@ids
    );

    my @tags = @{
        $self->c->sql->select_list_of_hashes(
            "SELECT tag, count(tag) AS count
               FROM $assoc_table_raw
              WHERE $entity_type = ?
           GROUP BY tag",
            $new_id
        )
    };

    $self->c->sql->do(
        "DELETE FROM $assoc_table WHERE $entity_type IN (" . placeholders(@ids) . ")",
        @ids
    );

    if (@tags) {
        $self->c->sql->do(
            "INSERT INTO $assoc_table ($entity_type, tag, count)
             VALUES " . join(',', ("(?, ?, ?)") x @tags),
            map { ($new_id, $_->{tag}, $_->{count}) } @tags
        );
    }
}

sub clear {
    my ($self, $editor_id) = @_;

    my $entity_type = $self->type;
    my $table = $self->tag_table . '_raw';

    for my $row (@{
        $self->sql->select_list_of_hashes(
            "SELECT $entity_type, t.name AS tag FROM $table
             JOIN tag t ON t.id = $table.tag
             WHERE editor = ?",
            $editor_id
        )
    }) {
        $self->withdraw($editor_id, $row->{$entity_type}, $row->{tag});
    }
}

sub _update_count {
    my ($self, $entity_id, $tag_id) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = "${assoc_table}_raw";

    return $self->sql->select_single_value(
        qq{
            UPDATE $assoc_table SET count = (
                SELECT sum(CASE WHEN is_upvote THEN 1 ELSE -1 END)
                  FROM $assoc_table_raw
                 WHERE $entity_type = \$1 AND tag = \$2
                 GROUP BY $entity_type, tag
            )
            WHERE $entity_type = \$1 AND tag = \$2
            RETURNING count
        },
        $entity_id, $tag_id
    );
}

sub _vote {
    my ($self, $user_id, $entity_id, $tag_name, $is_upvote) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = "${assoc_table}_raw";
    my $new_vote = $is_upvote ? 1 : -1;
    my $result = {tag => $tag_name, vote => $new_vote};

    Sql::run_in_transaction(sub {
        # Lock the entity being tagged to prevent concurrency issues
        $self->parent->get_by_id_locked($entity_id);

        my $sql = $self->sql;
        my $tag_id = $sql->select_single_value('SELECT id FROM tag WHERE name = ?', $tag_name);

        if (!defined $tag_id) {
            $tag_id = $sql->select_single_value('INSERT INTO tag (name) VALUES (?) RETURNING id', $tag_name);
        }

        # Add raw tag associations, checking for an existing vote first
        my $existing_vote = $sql->select_single_value(
            "SELECT is_upvote FROM $assoc_table_raw WHERE $entity_type = ? AND tag = ? AND editor = ?",
            $entity_id, $tag_id, $user_id
        );

        if (defined $existing_vote) {
            $sql->do(
                "UPDATE $assoc_table_raw SET is_upvote = ? WHERE $entity_type = ? AND tag = ? AND editor = ?",
                $is_upvote, $entity_id, $tag_id, $user_id
            );
        } else {
            $sql->do(
                "INSERT INTO $assoc_table_raw ($entity_type, tag, editor, is_upvote) VALUES (?, ?, ?, ?)",
                $entity_id, $tag_id, $user_id, $is_upvote
            );
        }

        # Look for the association in the aggregate tags
        my $aggregate_exists = $sql->select_single_value(
            "SELECT 1 FROM $assoc_table WHERE $entity_type = ? AND tag = ?", $entity_id, $tag_id
        );
        my $new_count = $new_vote;

        if (defined $aggregate_exists) {
            # If found, adjust the vote tally
            $new_count = $self->_update_count($entity_id, $tag_id);
        } else {
            # Otherwise add it
            $sql->do(
                "INSERT INTO $assoc_table ($entity_type, tag, count) VALUES (?, ?, ?)",
                $entity_id, $tag_id, $new_vote
            );
        }

        $result->{count} = $new_count;
    }, $self->c->sql);

    return $result;
}

sub upvote {
    shift->_vote(@_, 1);
}

sub downvote {
    shift->_vote(@_, 0);
}

sub withdraw {
    my ($self, $user_id, $entity_id, $tag_name) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = "${assoc_table}_raw";
    my $result = {tag => $tag_name, vote => 0};
    my $was_deleted;

    Sql::run_in_transaction(sub {
        my $sql = $self->sql;
        my $tag_id = $sql->select_single_value('SELECT id FROM tag WHERE name = ?', $tag_name);

        unless ($tag_id) {
            $was_deleted = 1;
            return;
        }

        # Remove the raw tag association
        my $deleted = $sql->select_single_value(
            "DELETE FROM $assoc_table_raw WHERE $entity_type = ? AND tag = ? AND editor = ? RETURNING 1",
            $entity_id, $tag_id, $user_id
        );

        unless ($deleted) {
            $was_deleted = 1;
            return;
        }

        # Delete if no raw votes are left
        $was_deleted = $self->sql->select_single_value(
            qq{
                DELETE FROM $assoc_table
                 WHERE $entity_type = \$1
                   AND tag = \$2
                   AND tag NOT IN (SELECT tag FROM $assoc_table_raw WHERE $entity_type = \$1)
                RETURNING 1
            },
            $entity_id, $tag_id
        );

        unless ($was_deleted) {
            # Adjust the vote tally
            $result->{count} = $self->_update_count($entity_id, $tag_id);
        }
    }, $self->c->sql);

    $result->{deleted} = $was_deleted ? \1 : \0;
    return $result;
}

sub find_user_tags {
    my ($self, $user_id, $entity_id) = @_;

    my $type = $self->type;
    my $table = $self->tag_table;
    my $table_raw = "${table}_raw";

    my $query = qq{
        SELECT tag, is_upvote, count AS aggregate_count FROM $table_raw
        JOIN $table USING (tag, $type)
        WHERE editor = ? AND $type = ?
    };

    my @tags = query_to_list($self->c->sql, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag},
            editor_id => $user_id,
            is_upvote => $row->{is_upvote},
            aggregate_count => $row->{aggregate_count},
        );
    }, $query, $user_id, $entity_id);

    $self->c->model('Tag')->load(@tags);

    return sort { $a->tag->name cmp $b->tag->name } grep { $_->tag } @tags;
}

sub find_entities
{
    my ($self, $tag_id, $limit, $offset) = @_;
    my $type = $self->type;
    my $tag_table = $self->tag_table;
    my $query = "SELECT tt.count AS tt_count, " . $self->parent->_columns . "
                 FROM " . $self->parent->_table . "
                     JOIN $tag_table tt ON " . $self->parent->_id_column . " = tt.$type
                 WHERE tag = ?
                 ORDER BY tt.count DESC, musicbrainz_collate(name), " . $self->parent->_id_column . "
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub {
            my $row = $_[0];
            my $entity = $self->parent->_new_from_row($row);
            return MusicBrainz::Server::Entity::AggregatedTag->new(
                count => $row->{tt_count},
                entity_id => $entity->id,
                entity => $entity,
            );
        },
        $query, $tag_id, $offset || 0);
}

sub find_editor_entities
{
    my ($self, $editor_id, $tag_id, $limit, $offset) = @_;

    my $type = $self->type;
    my $tag_table = $self->tag_table;

    my @tags = @{ $self->c->sql->select_single_column_array(
        'SELECT ' . $type . ' FROM ' . $type . '_tag_raw
          WHERE editor = ? AND tag = ?',
        $editor_id, $tag_id) };

    my $objs = $self->parent->get_by_ids_sorted_by_name(@tags);
    return @$objs;
}

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::EntityTag

=head1 METHODS

=head2 delete(@entity_ids)

Delete tags for entities from @entity_ids.

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles
Copyright (C) 2007,2009 Lukas Lalinsky
Copyright (C) 2007 Robert Kaye

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
