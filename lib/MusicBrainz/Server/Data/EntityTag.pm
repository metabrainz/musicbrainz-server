package MusicBrainz::Server::Data::EntityTag;
use Moose;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Entity::AggregatedTag;
use MusicBrainz::Server::Entity::UserTag;
use MusicBrainz::Server::Entity::Tag;
use Sql;

has [qw( c parent )] => (
    isa => 'Object',
    is => 'ro'
);

has [qw( tag_table type )] => (
    isa => 'Str',
    is => 'ro'
);

sub find_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    $limit ||= -1;
    $offset ||= 0;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ?" .
                "ORDER BY entity_tag.count DESC, tag.name OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row($_[0]) },
        $query, $entity_id, $offset);
}

sub find_top_tags
{
    my ($self, $entity_id, $limit, $offset) = @_;
    my $query = "SELECT tag.name, entity_tag.count FROM " . $self->tag_table . " entity_tag " .
                "JOIN tag ON tag.id = entity_tag.tag " .
                "WHERE " . $self->type . " = ? " .
                "ORDER BY entity_tag.count DESC, tag.name LIMIT ?";
    return query_to_list($self->c->dbh, sub { $self->_new_from_row($_[0]) },
                         $query, $entity_id, $limit);
}

sub _new_from_row
{
    my ($self, $row) = @_;
    MusicBrainz::Server::Entity::AggregatedTag->new(
        count => $row->{count},
        tag => MusicBrainz::Server::Entity::Tag->new(
            name => $row->{name},
        ),
    );
}

sub delete
{
    my ($self, @entity_ids) = @_;
    my $sql = Sql->new($self->c->dbh);
    $sql->do("
        DELETE FROM " . $self->tag_table . "
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    my $raw_sql = Sql->new($self->c->raw_dbh);
    $raw_sql->do("
        DELETE FROM " . $self->tag_table . "_raw
        WHERE " . $self->type . " IN (" . placeholders(@entity_ids) . ")",
        @entity_ids);
    return 1;
}

# TODO this is a copy of old MB::S::Tag, update it to handle multiple old IDs
sub _merge
{
    my ($self, $new_entity_id, $old_entity_id) = @_;

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = $self->tag_table . '_raw';

    my $sql = Sql->new($self->c->dbh);
    my $raw_sql = Sql->new($self->c->raw_dbh);

    # Load the tag ids for both entities
    my $old_tag_ids = $sql->select_single_column_array("
        SELECT tag
          FROM $assoc_table
         WHERE $entity_type = ?", $old_entity_id);

    my $new_tag_ids = $sql->select_single_column_array("
        SELECT tag
          FROM $assoc_table
         WHERE $entity_type = ?", $new_entity_id);
    my %new_tag_ids = map { $_ => 1 } @$new_tag_ids;

    foreach my $tag_id (@$old_tag_ids)
    {
        # If both entities share the tag, move the individual raw tags
        if ($new_tag_ids{$tag_id})
        {
            my $count = 0;

            # Load the editor ids for this tag and both entities
            # TODO: move this outside of this loop, to avoid multiple queries
            my $old_editor_ids = $raw_sql->select_single_column_array("
                SELECT editor
                  FROM $assoc_table_raw
                 WHERE $entity_type = ? AND tag = ?", $old_entity_id, $tag_id);

            my $new_editor_ids = $raw_sql->select_single_column_array("
                SELECT editor
                  FROM $assoc_table_raw
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $tag_id);
            my %new_editor_ids = map { $_ => 1 } @$new_editor_ids;

            foreach my $editor_id (@$old_editor_ids)
            {
                # If the raw tag doesn't exist for the target entity, move it
                if (!$new_editor_ids{$editor_id})
                {
                    $raw_sql->do("
                        UPDATE $assoc_table_raw
                           SET $entity_type = ?
                         WHERE $entity_type = ?
                           AND tag = ?
                           AND editor = ?", $new_entity_id, $old_entity_id, $tag_id, $editor_id);
                    $count++;
                }
            }

            # Update the aggregated tag count for moved raw tags
            if ($count)
            {
                $sql->do("
                    UPDATE $assoc_table
                       SET count = count + ?
                     WHERE $entity_type = ? AND tag = ?", $count, $new_entity_id, $tag_id);
            }

        }
        # If the tag doesn't exist for the target entity, move it
        else
        {
            $sql->do("
                UPDATE $assoc_table
                   SET $entity_type = ?
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $old_entity_id, $tag_id);
            $raw_sql->do("
                UPDATE $assoc_table_raw
                   SET $entity_type = ?
                 WHERE $entity_type = ? AND tag = ?", $new_entity_id, $old_entity_id, $tag_id);
        }
    }

    # Delete unused tags
    $sql->do("DELETE FROM $assoc_table WHERE $entity_type = ?", $old_entity_id);
    $raw_sql->do("DELETE FROM $assoc_table_raw WHERE $entity_type = ?", $old_entity_id);
}

sub merge
{
    my ($self, $new_id, @old_ids) = @_;

    foreach my $old_id (@old_ids) {
        $self->_merge($new_id, $old_id);
    }
    return 1;
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
        # remove non-word characters
        $_ =~ s/[^\p{IsWord}-]+/ /sg;
        # combine multiple spaces into one
        $_ =~ s/\s+/ /sg;
        # remove leading and trailing whitespace
        $_ =~ s/^\s*(.*?)\s*$/$1/;
        $_;
    } split ',', $input;

    # make sure the list contains only unique tags
    return uniq(@tags);
}

sub update
{
    my ($self, $user_id, $entity_id, $input) = @_;

    my (@new_tags, @old_tags, $count);

    my $entity_type = $self->type;
    my $assoc_table = $self->tag_table;
    my $assoc_table_raw = $self->tag_table . '_raw';

    my $sql = Sql->new($self->c->dbh);
    my $raw_sql = Sql->new($self->c->raw_dbh);

    @new_tags = $self->parse_tags($input);

    Sql::run_in_transaction(sub {

        # Load the existing raw tag ids for this entity

        my %old_tag_info;
        my @old_tags;
        my $old_tag_ids = $raw_sql->select_single_column_array("
            SELECT tag
              FROM $assoc_table_raw
             WHERE $entity_type = ?
               AND editor = ?", $entity_id, $user_id);
        if (scalar(@$old_tag_ids)) {
            # Load the corresponding tag strings from the main server
            #
            @old_tags = $sql->select("SELECT id, name FROM tag
                                      WHERE id IN (" . placeholders(@$old_tag_ids) . ")",
                                      @$old_tag_ids);
            # Create a lookup friendly hash from the old tags
            if (@old_tags) {
                while (my $row = $sql->next_row_ref()) {
                    $old_tag_info{$row->[1]} = $row->[0];
                }
                $sql->finish();
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
                $sql->select_single_value("SELECT id FROM tag WHERE name = ?", $tag);
            };
            if ($@) {
                my $err = $@;
                next if $err =~ /unicode/i;
                die $err;
            }
            if (!defined $tag_id) {
                $tag_id = $sql->select_single_value("INSERT INTO tag (name) VALUES (?) RETURNING id", $tag);
            }

            # Add raw tag associations
            $raw_sql->do("INSERT INTO $assoc_table_raw ($entity_type, tag, editor) VALUES (?, ?, ?)", $entity_id, $tag_id, $user_id);

            # Look for the association in the aggregate tags
            $count = $sql->select_single_value("SELECT count
                                                   FROM $assoc_table
                                                  WHERE $entity_type = ?
                                                    AND tag = ?", $entity_id, $tag_id);

            # if not found, add it
            if (!$count) {
                $sql->do("INSERT INTO $assoc_table ($entity_type, tag, count) VALUES (?, ?, 1)", $entity_id, $tag_id);
            }
            else {
                # Otherwise increment the refcount
                $sql->do("UPDATE $assoc_table SET count = count + 1 WHERE $entity_type = ? AND tag = ?", $entity_id, $tag_id);
            }

            # With this tag taken care of remove it from the list
            delete $old_tag_info{$tag};
        }

        # For any of the old tags that were not affected, remove them since the user doesn't seem to want them anymore
        foreach my $tag (keys %old_tag_info) {
            # Lookup tag id for current tag
            my $tag_id = $sql->select_single_value("SELECT tag.id FROM tag WHERE tag.name = ?", $tag);
            die "Cannot load tag" if (!$tag_id);

            # Remove the raw tag association
            $raw_sql->do("DELETE FROM $assoc_table_raw
                                WHERE $entity_type = ?
                                  AND tag = ?
                                  AND editor = ?", $entity_id, $tag_id, $user_id);

            # Decrement the count for this tag
            $count = $sql->select_single_value("SELECT count
                                                FROM $assoc_table
                                               WHERE $entity_type = ?
                                                 AND tag = ?", $entity_id, $tag_id);

            if (defined $count && $count > 1) {
                # Decrement the refcount
                $sql->do("UPDATE $assoc_table SET count = count - 1
                           WHERE $entity_type = ?
                             AND tag = ?", $entity_id, $tag_id);
            }
            else {
                # if count goes to zero, remove the association
                $sql->do("DELETE FROM $assoc_table
                           WHERE $entity_type = ?
                             AND tag = ?", $entity_id, $tag_id);
            }
        }

    }, $sql, $raw_sql);
}

sub find_user_tags
{
    my ($self, $user_id, $entity_id) = @_;

    my $type = $self->type;
    my $table = $self->tag_table . '_raw';
    my $query = "SELECT tag FROM $table WHERE editor = ? AND $type = ?";

    my @tags = query_to_list($self->c->raw_dbh, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id => $row->{tag},
            editor_id => $user_id,
        );
    }, $query, $user_id, $entity_id);

    $self->c->model('Tag')->load(@tags);

    return @tags;
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
                 ORDER BY tt.count DESC, name.name, " . $self->parent->_id_column . "
                 OFFSET ?";
    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub {
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
