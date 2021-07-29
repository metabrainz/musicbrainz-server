package MusicBrainz::Server::Data::EntityTag;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Data::Utils qw(
    boolean_to_json
    placeholders
);
use MusicBrainz::Server::Entity::AggregatedTag;
use MusicBrainz::Server::Entity::UserTag;
use MusicBrainz::Server::Entity::Tag;
use Sql;

with 'MusicBrainz::Server::Data::Role::QueryToList';
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

    my $query = "SELECT tag.name, entity_tag.count,
                        tag.id AS tag_id, genre.id AS genre_id
                 FROM " . $self->tag_table . " entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 LEFT JOIN genre ON tag.name = genre.name
                 WHERE " . $self->type . " = ?
                 ORDER BY entity_tag.count DESC, tag.name COLLATE musicbrainz";

    $self->query_to_list($query, [$entity_id]);
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
    my ($self, $entity_id, $limit) = @_;
    my $query = "
        SELECT name, count, tag_id, genre_id FROM ((
            SELECT tag.name, entity_tag.count,
                tag.id AS tag_id, genre.id AS genre_id
            FROM " . $self->tag_table . " entity_tag
            JOIN tag ON tag.id = entity_tag.tag
            JOIN genre ON tag.name = genre.name
            WHERE " .  $self->type . " = ?
            ORDER BY entity_tag.count DESC, tag.name COLLATE musicbrainz
            LIMIT ?
        ) UNION (
            SELECT tag.name, entity_tag.count,
                tag.id AS tag_id, NULL AS genre_id
            FROM " . $self->tag_table . " entity_tag
            JOIN tag ON tag.id = entity_tag.tag
            WHERE " .  $self->type . " = ?   
            AND NOT EXISTS (
                SELECT 1 FROM genre
                WHERE genre.name = tag.name
            )  
            ORDER BY entity_tag.count DESC, tag.name COLLATE musicbrainz
            LIMIT ?       
        )) top_tags
        ORDER BY count DESC, name COLLATE musicbrainz";
    $self->query_to_list($query, [$entity_id, $limit, $entity_id, $limit]);
}

sub find_tags_for_entities
{
    my ($self, @ids) = @_;

    return unless scalar @ids;

    my $query = "SELECT tag.id AS tag_id, tag.name, entity_tag.count,
                        entity_tag." . $self->type . " AS entity
                 FROM " . $self->tag_table . " entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 WHERE " . $self->type . " IN (" . placeholders(@ids) . ")
                 ORDER BY entity_tag.count DESC, tag.name COLLATE musicbrainz";

    $self->query_to_list($query, \@ids);
}

sub find_user_tags_for_entities
{
    my ($self, $user_id, @ids) = @_;

    return unless scalar @ids;

    my $type = $self->type;
    my $table = $self->tag_table . '_raw';
    my $query = "SELECT entity_tag.tag AS tag_id, $type AS entity,
                        tag.name AS tag_name, is_upvote
                 FROM $table entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 WHERE editor = ?
                 AND $type IN (" . placeholders(@ids) . ")
                 ORDER BY tag.name COLLATE musicbrainz";

    $self->query_to_list($query, [$user_id, @ids], sub {
        my ($model, $row) = @_;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag_id},
            tag => MusicBrainz::Server::Entity::Tag->new(
                id => $row->{tag_id},
                name => $row->{tag_name},
            ),
            editor_id => $user_id,
            entity_id => $row->{entity},
            is_upvote => $row->{is_upvote},
        );
    });
}

sub find_genres_for_entities
{
    my ($self, @ids) = @_;

    return unless scalar @ids;

    my $query = "SELECT tag.id AS tag_id, tag.name, entity_tag.count,
                        entity_tag." . $self->type . " AS entity, genre.id AS genre_id
                 FROM " . $self->tag_table . " entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 JOIN genre ON tag.name = genre.name
                 WHERE " . $self->type . " IN (" . placeholders(@ids) . ")
                 ORDER BY tag.name COLLATE musicbrainz";

    my @tags = $self->query_to_list($query, \@ids);

    $self->c->model('Genre')->load(map { $_->tag } @tags);

    return @tags;
}

sub find_user_genres_for_entities
{
    my ($self, $user_id, @ids) = @_;

    return unless scalar @ids;

    my $type = $self->type;
    my $table = $self->tag_table . '_raw';
    my $query = "SELECT entity_tag.tag AS tag_id, $type AS entity,
                        tag.name AS tag_name, genre.id AS genre_id,
                        is_upvote
                 FROM $table entity_tag
                 JOIN tag ON tag.id = entity_tag.tag
                 JOIN genre ON tag.name = genre.name
                 WHERE editor = ?
                 AND $type IN (" . placeholders(@ids) . ")
                 ORDER BY tag.name COLLATE musicbrainz";

    my @tags = $self->query_to_list($query, [$user_id, @ids], sub {
        my ($model, $row) = @_;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag_id},
            tag => MusicBrainz::Server::Entity::Tag->new(
                genre_id => $row->{genre_id},
                id => $row->{tag_id},
                name => $row->{tag_name},
            ),
            editor_id => $user_id,
            entity_id => $row->{entity},
            is_upvote => $row->{is_upvote},
        );
    });

    $self->c->model('Genre')->load(map { $_->tag } @tags);

    return @tags;
}

sub _new_from_row
{
    my ($self, $row) = @_;

    my %init = (
        count => $row->{count},
        tag => MusicBrainz::Server::Entity::Tag->new(
            genre_id => $row->{genre_id},
            id => $row->{tag_id},
            name => $row->{name},
        ),
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

sub merge {
    my ($self, $new_id, @old_ids) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = $self->tag_table . '_raw';
    my @ids = ($new_id, @old_ids);

    # FIXME: Due to the way DISTINCT ON works, if two entities have different
    # votes for the same tag by the same editor, the vote that remains on the
    # merge target is arbitrary. (ORDER BY doesn't work within the sub-select.)
    $self->c->sql->do(<<~"EOSQL", \@ids, $new_id);
        WITH deleted_tags AS (
            DELETE FROM $assoc_table_raw
            WHERE $entity_type = any(?)
            RETURNING editor, tag, is_upvote
        )
        INSERT INTO $assoc_table_raw ($entity_type, editor, tag, is_upvote)
            SELECT ?, s.editor, s.tag, s.is_upvote
            FROM (SELECT DISTINCT ON (editor, tag) editor, tag, is_upvote FROM deleted_tags) s
        EOSQL

    $self->c->sql->do(
        "DELETE FROM $assoc_table WHERE $entity_type = any(?)",
        \@ids
    );

    my $tags = $self->c->sql->select_single_column_array(
        "SELECT DISTINCT tag FROM $assoc_table_raw WHERE $entity_type = ?",
        $new_id
    );

    for my $tag_id (@{$tags}) {
        $self->c->sql->do(
            "INSERT INTO $assoc_table ($entity_type, tag, count) VALUES (?, ?, 0)",
            $new_id, $tag_id
        );
        $self->_update_count($new_id, $tag_id);
    }

    return;
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

    $result->{deleted} = boolean_to_json($was_deleted);
    return $result;
}

sub find_user_tags {
    my ($self, $user_id, $entity_id) = @_;

    my $type = $self->type;
    my $table = $self->tag_table;
    my $table_raw = "${table}_raw";

    my $query = qq{
        SELECT tag AS tag_id, tag.name AS tag_name, genre.id AS genre_id, is_upvote,
               count AS aggregate_count FROM $table_raw
        JOIN $table USING (tag, $type)
        JOIN tag ON tag.id = $table.tag
        LEFT JOIN genre ON genre.name = tag.name
        WHERE editor = ? AND $type = ?
        ORDER BY tag.name COLLATE musicbrainz
    };

    $self->query_to_list($query, [$user_id, $entity_id], sub {
        my ($model, $row) = @_;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag => MusicBrainz::Server::Entity::Tag->new(
                genre_id => $row->{genre_id},
                name => $row->{tag_name},
                id => $row->{tag_id}
            ),
            tag_id => $row->{tag_id},
            editor_id => $user_id,
            is_upvote => $row->{is_upvote},
            aggregate_count => $row->{aggregate_count},
        );
    });
}

sub find_entities
{
    my ($self, $tag_id, $limit, $offset) = @_;
    my $type = $self->type;
    my $ordering_condition = $type eq 'artist'
        ? 'sort_name COLLATE musicbrainz'
        : 'name COLLATE musicbrainz';
    my $tag_table = $self->tag_table;
    my $query = "SELECT tt.count AS tt_count, " . $self->parent->_columns . "
                 FROM " . $self->parent->_table . "
                     JOIN $tag_table tt ON " . $self->parent->_id_column . " = tt.$type
                 WHERE tag = ?
                 AND tt.count > 0
                 ORDER BY tt.count DESC, $ordering_condition, " . $self->parent->_id_column;
    $self->query_to_list_limited($query, [$tag_id], $limit, $offset, sub {
        my ($model, $row) = @_;

        my $entity = $model->parent->_new_from_row($row);
        return MusicBrainz::Server::Entity::AggregatedTag->new(
            count => $row->{tt_count},
            entity_id => $entity->id,
            entity => $entity,
        );
    });
}

sub find_editor_entities
{
    my ($self, $editor_id, $tag_id, $show_downvoted, $limit, $offset) = @_;

    my $type = $self->type;
    my $tag_table = $self->tag_table . '_raw';
    my $is_upvote = $show_downvoted ? 0 : 1;

    my $query = "SELECT " . $self->parent->_columns . "
                 FROM " . $self->parent->_table . "
                     JOIN $tag_table ttr ON " . $self->parent->_id_column . " = ttr.$type
                 WHERE editor = ? AND tag = ? AND is_upvote = ?
                 ORDER BY name COLLATE musicbrainz, " . $self->parent->_id_column;
    $self->query_to_list_limited($query, [$editor_id, $tag_id, $is_upvote], $limit, $offset, sub {
        my ($model, $row) = @_;

        my $entity = $model->parent->_new_from_row($row);
        return MusicBrainz::Server::Entity::UserTag->new(
            entity_id => $entity->id,
            entity => $entity,
        );
    });
}

no Moose;
1;

=head1 NAME

MusicBrainz::Server::Data::EntityTag

=head1 METHODS

=head2 delete(@entity_ids)

Delete tags for entities from @entity_ids.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Oliver Charles
Copyright (C) 2007,2009 Lukas Lalinsky
Copyright (C) 2007 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
