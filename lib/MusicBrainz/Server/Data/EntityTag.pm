package MusicBrainz::Server::Data::EntityTag;
use Moose;
use Method::Signatures::Simple;
use namespace::autoclean;

use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Data::Utils qw(
    placeholders
    query_to_list
    query_to_list_limited
);
use MusicBrainz::Server::Entity::AggregatedTag;
use MusicBrainz::Server::Entity::UserTag;
use MusicBrainz::Server::Entity::Tag;
use MusicBrainz::Schema qw( schema );
use Sql;
use aliased 'Fey::Literal::Function';

with 'MusicBrainz::Server::Data::Role::Context' => {
    -excludes => '_dbh'
};
with 'MusicBrainz::Server::Data::Role::Joined' => {
    -excludes => '_build__join_column'
};

has [qw( _join_column _raw_join_column )] => (
    is         => 'ro',
    lazy_build => 1
);

has [qw( rw_table raw_table )] => (
    required => 1,
    is       => 'ro',
);

method _dbh { $self->c->raw_dbh }

method _build__join_column
{
    $self->rw_table->column($self->parent->table->name)
}

method _build__raw_join_column
{
    $self->raw_table->column($self->parent->table->name)
}

method find_tags ($entity_id, $limit, $offset)
{
    $offset ||= 0;
    my $tag_table = schema->table('tag');
    my $query = Fey::SQL->new_select
        ->select($tag_table->column('name'), $self->rw_table->column('count'))
        ->from($self->rw_table, $tag_table)
        ->where($self->_join_column, '=', $entity_id)
        ->order_by($self->rw_table->column('count'), 'DESC')
        ->order_by($tag_table->column('name'))
        ->limit($limit);

    return query_to_list_limited(
        $self->c->dbh, $offset, $limit, sub { $self->_new_from_row($_[0]) },
        $query->sql($self->c->dbh), $query->bind_params);
}

method find_tag_count ($entity_id)
{
    my $query = Fey::SQL->new_select
        ->select(Function->new('count', '*'))
        ->from($self->rw_table)
        ->where($self->_join_column, '=', $entity_id);

    return Sql->new($self->c->dbh)->select_single_value($query->sql($self->c->dbh), $query->bind_params);
}

method find_top_tags ($entity_id, $limit)
{
    my ($tags, $hits) = $self->find_tags($entity_id, $limit, 0);
    return @$tags;
}

method _new_from_row ($row)
{
    return MusicBrainz::Server::Entity::AggregatedTag->new(
        count => $row->{count},
        tag   => MusicBrainz::Server::Entity::Tag->new(
            name => $row->{name},
        ),
    );
}

method delete (@entity_ids)
{
    my $sql = Sql->new($self->c->dbh);

    my $query = Fey::SQL->new_delete
        ->from($self->rw_table)
        ->where($self->_join_column, 'IN', @entity_ids);

    $sql->do($query->sql($self->c->dbh), $query->bind_params);

    $query = Fey::SQL->new_delete
        ->from($self->raw_table)
        ->where($self->_raw_join_column, 'IN', @entity_ids);

    $self->sql->do($query->sql($self->sql->dbh), $query->bind_params);

    return 1;
}

# TODO this is a copy of old MB::S::Tag, update it to handle multiple old IDs
method _merge ($new_entity_id, $old_entity_id)
{
    my $sql     = Sql->new($self->c->dbh);
    my $raw_sql = Sql->new($self->c->raw_dbh);
    my $query;

    # Load the tag ids for both entities
    $query = Fey::SQL->new_select
        ->select($self->rw_table->column('tag'))
        ->from($self->rw_table)
        ->where($self->_join_column, '=', $old_entity_id);

    my $old_tag_ids = $sql->select_single_column_array(
        $query->sql($self->c->dbh), $query->bind_params);

    $query = Fey::SQL->new_select
        ->select($self->rw_table->column('tag'))
        ->from($self->rw_table)
        ->where($self->_join_column, '=', $new_entity_id);

    my $new_tag_ids = $sql->select_single_column_array(
        $query->sql($self->c->dbh), $query->bind_params);

    my %new_tag_ids = map { $_ => 1 } @$new_tag_ids;

    foreach my $tag_id (@$old_tag_ids)
    {
        # If both entities share the tag, move the individual raw tags
        if ($new_tag_ids{$tag_id})
        {
            my $count = 0;

            # Load the editor ids for this tag and both entities
            # TODO: move this outside of this loop, to avoid multiple queries
            $query = Fey::SQL->new_select
                ->select($self->raw_table->column('editor'))
                ->from($self->raw_table)
                ->where($self->_raw_join_column, '=', $old_entity_id)
                ->where($self->raw_table->column('tag'), '=', $tag_id);

            my $old_editor_ids = $raw_sql->select_single_column_array(
                $query->sql($raw_sql->dbh), $query->bind_params);

            $query = Fey::SQL->new_select
                ->select($self->raw_table->column('editor'))
                ->from($self->raw_table)
                ->where($self->_raw_join_column, '=', $new_entity_id)
                ->where($self->raw_table->column('tag'), '=', $tag_id);

            my $new_editor_ids = $raw_sql->select_single_column_array(
                $query->sql($raw_sql->dbh), $query->bind_params);

            my %new_editor_ids = map { $_ => 1 } @$new_editor_ids;

            foreach my $editor_id (@$old_editor_ids)
            {
                # If the raw tag doesn't exist for the target entity, move it
                if (!$new_editor_ids{$editor_id})
                {
                    $query = Fey::SQL->new_update
                        ->update($self->raw_table)
                        ->set($self->_raw_join_column, $new_entity_id)
                        ->where($self->_raw_join_column, '=', $old_entity_id)
                        ->where($self->raw_table->column('tag'), '=', $tag_id)
                        ->where($self->raw_table->column('editor'), '=', $editor_id);

                    $raw_sql->do($query->sql($raw_sql->dbh), $query->bind_params);
                    $count++;
                }
            }

            # Update the aggregated tag count for moved raw tags
            if ($count)
            {
                my $count_col = $self->rw_table->column('count');
                $query = Fey::SQL->new_update
                    ->update($self->rw_table)
                    ->set($count_col, Fey::Literal::Term->new($count_col, '+', $count))
                    ->where($self->_join_column, '=', $new_entity_id)
                    ->where($self->rw_table->column('tag'), '=', $tag_id);

                $sql->do($query->sql($sql->dbh), $query->bind_params);
            }

        }
        # If the tag doesn't exist for the target entity, move it
        else
        {
            $query = Fey::SQL->new_update
                ->update($self->rw_table)
                ->set($self->_join_column, $new_entity_id)
                ->where($self->_join_column, '=', $old_entity_id)
                ->where($self->rw_table->column('tag'), '=', $tag_id);

            $sql->do($query->sql($sql->dbh), $query->bind_params);

            $query = Fey::SQL->new_update
                ->update($self->raw_table)
                ->set($self->_raw_join_column, $new_entity_id)
                ->where($self->_raw_join_column, '=', $old_entity_id)
                ->where($self->raw_table->column('tag'), '=', $tag_id);

            $raw_sql->do($query->sql($raw_sql->dbh), $query->bind_params);
        }
    }

    # Delete unused tags
    $query = Fey::SQL->new_delete
        ->from($self->rw_table)
        ->where($self->_join_column, '=', $old_entity_id);

    $sql->do($query->sql($sql->dbh), $query->bind_params);

    $query = Fey::SQL->new_delete
        ->from($self->raw_table)
        ->where($self->_raw_join_column, '=', $old_entity_id);

    $raw_sql->do($query->sql($raw_sql->dbh), $query->bind_params);
}

method merge ($new_id, @old_ids)
{
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

method parse_tags ($input)
{
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

method update ($user_id, $entity_id, $input)
{
    my (@new_tags, @old_tags, $count);

    my $sql       = Sql->new($self->c->dbh);
    my $raw_sql   = Sql->new($self->c->raw_dbh);
    my $tag_table = schema->table('tag');
    my $query;

    @new_tags = $self->parse_tags($input);

    Sql::run_in_transaction(sub {

        # Load the existing raw tag ids for this entity

        my %old_tag_info;
        my @old_tags;
        $query = Fey::SQL->new_select
            ->select($self->raw_table->column('tag'))
            ->from($self->raw_table)
            ->where($self->_raw_join_column, '=', $entity_id)
            ->where($self->raw_table->column('editor'), '=', $user_id);

        my $old_tag_ids = $raw_sql->select_single_column_array(
            $query->sql($raw_sql->dbh), $query->bind_params);

        if (scalar(@$old_tag_ids)) {
            # Load the corresponding tag strings from the main server
            #
            $query = Fey::SQL->new_select
                ->select(map { $tag_table->column($_) } qw( id name ))
                ->from($tag_table)
                ->where($tag_table->column('id'), 'IN', @$old_tag_ids);

            @old_tags = $sql->select($query->sql($sql->dbh), $query->bind_params);

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
                $query = Fey::SQL->new_select
                    ->select($tag_table->column('id'))->from($tag_table)
                    ->where($tag_table->column('name'), '=', $tag);

                $sql->select_single_value($query->sql($sql->dbh), $query->bind_params);
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
            $query = Fey::SQL->new_insert
                    ->into($self->raw_table)
                    ->values(
                        $self->_join_column->name => $entity_id,
                        tag                       => $tag_id,
                        editor                    => $user_id
                    );

            $raw_sql->do($query->sql($raw_sql->dbh), $query->bind_params);

            # Look for the association in the aggregate tags
            $query = Fey::SQL->new_select
                ->select($self->rw_table->column('count'))
                ->from($self->rw_table)
                ->where($self->_join_column, '=', $entity_id)
                ->where($self->rw_table->column('tag'), '=', $tag_id);

            $count = $sql->select_single_value(
                $query->sql($sql->dbh), $query->bind_params);

            # if not found, add it
            if (!$count) {
                $query = Fey::SQL->new_insert
                    ->into($self->rw_table)
                    ->values(
                        $self->_join_column->name => $entity_id,
                        tag                       => $tag_id,
                        count                     => 1
                    );
            }
            else {
                # Otherwise increment the refcount
                my $count_col = $self->rw_table->column('count');
                $query = Fey::SQL->new_update
                    ->update($self->rw_table)
                    ->set($count_col, Fey::Literal::Term->new($count_col, '+', '1'))
                    ->where($self->_join_column, '=', $entity_id)
                    ->where($self->rw_table->column('tag'), '=', $tag_id);
            }

            $sql->do($query->sql($sql->dbh), $query->bind_params);

            # With this tag taken care of remove it from the list
            delete $old_tag_info{$tag};
        }

        # For any of the old tags that were not affected, remove them since the user doesn't seem to want them anymore
        foreach my $tag (keys %old_tag_info) {
            # Lookup tag id for current tag
            $query = Fey::SQL->new_select
                ->select($tag_table->column('id'))->from($tag_table)
                ->where($tag_table->column('name'), '=', $tag);

            my $tag_id = $sql->select_single_value($query->sql($sql->dbh), $query->bind_params);
            die "Cannot load tag" if (!$tag_id);

            # Remove the raw tag association
            $query = Fey::SQL->new_delete
                ->from($self->raw_table)
                ->where($self->_raw_join_column, '=', $entity_id)
                ->where($self->raw_table->column('tag'), '=', $tag_id)
                ->where($self->raw_table->column('editor'), '=', $user_id);

            $raw_sql->do($query->sql($raw_sql->dbh), $query->bind_params);

            # Decrement the count for this tag
            $query = Fey::SQL->new_select
                ->select($self->rw_table->column('count'))
                ->from($self->rw_table)
                ->where($self->_join_column, '=', $entity_id)
                ->where($self->rw_table->column('tag'), '=', $tag_id);

            $count = $sql->select_single_value(
                $query->sql($sql->dbh), $query->bind_params);

            if (defined $count && $count > 1) {
                # Decrement the refcount
                my $count_col = $self->rw_table->column('count');
                $query = Fey::SQL->new_update
                    ->update($self->rw_table)
                    ->set($count_col, Fey::Literal::Term->new($count_col, '-', '1'))
                    ->where($self->_join_column, '=', $entity_id)
                    ->where($self->rw_table->column('tag'), '=', $tag_id);
            }
            else {
                # if count goes to zero, remove the association
                $query = Fey::SQL->new_delete
                    ->from($self->rw_table)
                    ->where($self->_join_column, '=', $entity_id)
                    ->where($self->rw_table->column('tag'), '=', $tag_id);
            }
            $sql->do($query->sql($sql->dbh), $query->bind_params);
        }

    }, $sql, $raw_sql);
}

method find_user_tags ($user_id, $entity_id)
{
    my $query = Fey::SQL->new_select
        ->select($self->raw_table->column('tag'))
        ->from($self->raw_table)
        ->where($self->raw_table->column('editor'), '=', $user_id)
        ->where($self->_raw_join_column, '=', $entity_id);

    my @tags = query_to_list($self->c->raw_dbh, sub {
        my $row = shift;
        return MusicBrainz::Server::Entity::UserTag->new(
            tag_id    => $row->{tag},
            editor_id => $user_id,
        );
    }, $query->sql($self->c->raw_dbh), $query->bind_params);

    $self->c->model('Tag')->load(@tags);

    return @tags;
}

method find_entities ($tag_id, $limit, $offset)
{
    my $type = $self->type;

    my $query = $self->parent->_select
        ->select($self->rw_table->column('count')->alias('tt_count'))
        ->from($self->parent->table, $self->rw_table)
        ->where($self->rw_table->column('tag'), '=', $tag_id)
        ->order_by($self->rw_table->column('count'), 'DESC')
        ->order_by(Function->new('musicbrainz_collate', $self->parent->name_columns->{name}))
        ->limit(undef, $offset || 0);

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
        $query->sql($self->c->dbh), $query->bind_params);
}

__PACKAGE__->meta->make_immutable;

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
