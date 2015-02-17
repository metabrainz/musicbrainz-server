package MusicBrainz::Server::Data::EntityTag;
use Moose;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
    trim
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

sub find_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    $offset ||= 0;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ?" .
                "ORDER BY entity_tag.count DESC, musicbrainz_collate(tag.name) OFFSET ?";
    return query_to_list_limited(
        $self->c->sql, $offset, $limit, sub { $self->_new_from_row($_[0]) },
        $query, $entity_id, $offset);
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
    my $query = "SELECT tag, $type AS entity
                 FROM $table
                 WHERE editor = ?
                 AND $type IN (" . placeholders(@ids) . ")";

    my @tags = query_to_list($self->c->sql, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag},
            editor_id => $user_id,
            entity_id => $row->{entity},
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

# Algorithm for updating tags
# update:
#  - parse tag string into tag list
#     - separate by comma, trim whitespace
#  - load existing tags for user/entity from raw tables into a hash

#  - for each tag in tag list:
#        is tag in existing tag list?
#           yes, remove from existing tag list, continue
#        find tag string in tag table, if not found, add it
#        add tag assoc to raw tables
#        find tag assoc in aggregate tables.
#        if not found
#            add it
#        else
#            increment count in aggregate table
#
#    for each tag remaining in existing tag list:
#        remove raw tag assoc
#        decrement aggregate tag
#        if aggregate tag count == 0: remove aggregate tag assoc.

sub parse_tags
{
    my ($self, $input) = @_;

    my @tags = grep {
        $_ = trim($_);
        $_ = lc($_);
    } split ',', $input;

    # make sure the list contains only unique tags
    return uniq(@tags);
}

sub clear {
    my ($self, $editor_id) = @_;

    my $entity_type = $self->type;
    my $table = $self->tag_table . '_raw';

    for my $entity_id (@{
        $self->sql->select_single_column_array(
            "SELECT $entity_type FROM $table WHERE editor = ?",
            $editor_id
        )
    }) {
        $self->update($editor_id, $entity_id, '');
    }
}

sub update
{
    my ($self, $user_id, $entity_id, $input) = @_;

    my (@new_tags, @old_tags, $count);

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = $self->tag_table . '_raw';

    @new_tags = $self->parse_tags($input);

    Sql::run_in_transaction(sub {
        # Lock the entity being tagged to prevent concurrency issues
        $self->parent->get_by_id_locked($entity_id);

        # Load the existing raw tag ids for this entity
        my %old_tag_info;
        my @old_tags;
        my $old_tag_ids = $self->sql->select_single_column_array("
            SELECT tag
              FROM $assoc_table_raw
             WHERE $entity_type = ?
               AND editor = ?", $entity_id, $user_id);
        if (scalar(@$old_tag_ids)) {
            # Load the corresponding tag strings from the main server
            #
            for my $row (@{
                $self->sql->select_list_of_lists(
                    "SELECT id, name FROM tag
                     WHERE id IN (" . placeholders(@$old_tag_ids) . ")",
                    @$old_tag_ids
                )
            }) {
                # Create a lookup friendly hash from the old tags
                $old_tag_info{$row->[1]} = $row->[0];
            }
        }

        # Now loop over the new tags
        foreach my $tag (@new_tags) {
            # if a new tag already exists, remove it from the old tag list and we're done for this tag
            if (exists $old_tag_info{$tag}) {
                delete $old_tag_info{$tag};
                next;
            }

            # Lookup tag id for current tag, checking for UNICODE
            my $tag_id = eval {
                $self->sql->select_single_value("SELECT id FROM tag WHERE name = ?", $tag);
            };
            if ($@) {
                my $err = $@;
                next if $err =~ /unicode/i;
                die $err;
            }
            if (!defined $tag_id) {
                $tag_id = $self->sql->select_single_value("INSERT INTO tag (name) VALUES (?) RETURNING id", $tag);
            }

            # Add raw tag associations
            $self->sql->do("INSERT INTO $assoc_table_raw ($entity_type, tag, editor) VALUES (?, ?, ?)", $entity_id, $tag_id, $user_id);

            # Look for the association in the aggregate tags
            $count = $self->sql->select_single_value("SELECT count
                                                   FROM $assoc_table
                                                  WHERE $entity_type = ?
                                                    AND tag = ?", $entity_id, $tag_id);

            # if not found, add it
            if (!$count) {
                $self->sql->do("INSERT INTO $assoc_table ($entity_type, tag, count) VALUES (?, ?, 1)", $entity_id, $tag_id);
            }
            else {
                # Otherwise increment the refcount
                $self->sql->do("UPDATE $assoc_table SET count = count + 1 WHERE $entity_type = ? AND tag = ?", $entity_id, $tag_id);
            }

            # With this tag taken care of remove it from the list
            delete $old_tag_info{$tag};
        }

        # For any of the old tags that were not affected, remove them since the user doesn't seem to want them anymore
        foreach my $tag (keys %old_tag_info) {
            # Lookup tag id for current tag
            my $tag_id = $self->sql->select_single_value("SELECT tag.id FROM tag WHERE tag.name = ?", $tag);
            die "Cannot load tag" if (!$tag_id);

            # Remove the raw tag association
            $self->sql->do("DELETE FROM $assoc_table_raw
                                WHERE $entity_type = ?
                                  AND tag = ?
                                  AND editor = ?", $entity_id, $tag_id, $user_id);

            # Decrement the count for this tag
            $count = $self->sql->select_single_value("SELECT count
                                                FROM $assoc_table
                                               WHERE $entity_type = ?
                                                 AND tag = ?", $entity_id, $tag_id);

            if (defined $count && $count > 1) {
                # Decrement the refcount
                $self->sql->do("UPDATE $assoc_table SET count = count - 1
                           WHERE $entity_type = ?
                             AND tag = ?", $entity_id, $tag_id);
            }
            else {
                # if count goes to zero, remove the association
                $self->sql->do("DELETE FROM $assoc_table
                           WHERE $entity_type = ?
                             AND tag = ?", $entity_id, $tag_id);
            }
        }

    }, $self->c->sql);
}

sub find_user_tags
{
    my ($self, $user_id, $entity_id) = @_;

    my $type = $self->type;
    my $table = $self->tag_table . '_raw';
    my $query = "SELECT tag FROM $table WHERE editor = ? AND $type = ?";

    my @tags = query_to_list($self->c->sql, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag},
            editor_id => $user_id,
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
