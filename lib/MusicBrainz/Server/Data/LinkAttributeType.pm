package MusicBrainz::Server::Data::LinkAttributeType;

use Moose;
use namespace::autoclean;
use Sql;
use Encode;
use List::MoreUtils qw( uniq );
use MusicBrainz::Server::Entity::LinkType;
use MusicBrainz::Server::Entity::LinkAttributeType;
use MusicBrainz::Server::Data::Utils qw(
    load_subobjects
    hash_to_row
    generate_gid
    placeholders
);

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'linkattrtype' };
with 'MusicBrainz::Server::Data::Role::OptionsTree';

sub _table
{
    return 'link_attribute_type';
}

sub _columns
{
    return 'id, parent, child_order, gid, name, description, root, ' .
           'COALESCE(
                (SELECT true FROM link_text_attribute_type
                 WHERE attribute_type = link_attribute_type.id),
                false
            ) AS free_text';
}

sub _column_mapping
{
    return {
        id          => 'id',
        gid         => 'gid',
        parent_id   => 'parent',
        root_id     => 'root',
        child_order => 'child_order',
        name        => 'name',
        description => 'description',
        free_text   => 'free_text',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::LinkAttributeType';
}

sub load
{
    my ($self, @objs) = @_;

    load_subobjects($self, 'type', @objs);
}

sub find_root
{
    my ($self, $id) = @_;

    my $query = 'SELECT root FROM ' . $self->_table . ' WHERE id = ?';
    return $self->sql->select_single_value($query, $id);
}

sub insert
{
    my ($self, $values) = @_;

    my $row = $self->_hash_to_row($values);
    $row->{id} = $self->sql->select_single_value("SELECT nextval('link_attribute_type_id_seq')");
    $row->{gid} = $values->{gid} || generate_gid();
    $row->{root} = $row->{parent} ? $self->find_root($row->{parent}) : $row->{id};
    $self->sql->insert_row('link_attribute_type', $row);
    return $self->_entity_class->new( id => $row->{id}, gid => $row->{gid} );
}

sub _update_root
{
    my ($self, $sql, $parent, $root) = @_;
    my $ids = $self->sql->select_single_column_array('SELECT id FROM link_attribute_type
                                             WHERE parent = ?', $parent);
    if (@$ids) {
        $self->sql->do('UPDATE link_attribute_type SET root = ?
                  WHERE id IN ('.placeholders(@$ids).')', $root, @$ids);
        foreach my $id (@$ids) {
            $self->_update_root($sql, $id, $root);
        }
    }
}

sub update
{
    my ($self, $id, $values) = @_;

    my $row = $self->_hash_to_row($values);
    if (%$row) {
        if ($row->{parent}) {
            $row->{root} = $self->find_root($row->{parent});
            $self->_update_root($self->sql, $id, $row->{root});
        }
        $self->sql->update_row('link_attribute_type', $row, { id => $id });
    }
}

sub delete
{
    my ($self, $id) = @_;

    $self->sql->do('DELETE FROM link_attribute_type WHERE id = ?', $id);
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    return hash_to_row($values, {
        parent          => 'parent_id',
        child_order      => 'child_order',
        name            => 'name',
        description     => 'description',
    });
}

sub get_by_gid
{
    my ($self, $gid) = @_;
    my @result = values %{$self->_get_by_keys("gid", $gid)};
    if (scalar(@result)) {
        return $result[0];
    }
    else {
        return undef;
    }
}

sub in_use
{
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM link_attribute WHERE link_attribute.attribute_type = ?',
        $id);
}

sub merge_instrument_attributes {
    my ($self, $target_id, @source_ids) = @_;

    my ($target, @sources) = @{
        $self->sql->select_single_column_array(
            'WITH id_mapping AS (
                SELECT link_attribute_type.id AS attribute_id, instrument.id AS entity_id
                  FROM instrument
                  JOIN link_attribute_type ON link_attribute_type.gid = instrument.gid
            )
            SELECT attribute_id FROM id_mapping WHERE entity_id = ? OR entity_id = any(?)
            ORDER BY entity_id = ? DESC', $target_id, \@source_ids, $target_id
        );
    };
    my $new_links = $self->sql->select_list_of_hashes('
        SELECT link.id AS id, link_type AS link_type_id,
               begin_date_year, begin_date_month, begin_date_day,
               end_date_year, end_date_month, end_date_day, ended,
               array_agg(CASE
                   WHEN link_attribute.attribute_type = any(?)
                   THEN ?
                   ELSE link_attribute.attribute_type
                   END) attributes,
               link_type.entity_type0, link_type.entity_type1
          FROM link
          JOIN link_attribute ON link_attribute.link = link.id
          JOIN link_type ON link.link_type = link_type.id
          WHERE link.id IN (
              SELECT link from link_attribute where attribute_type = any(?)
          )
      GROUP BY link.id, link_type,
               begin_date_year, begin_date_month, begin_date_day,
               end_date_year, end_date_month, end_date_day, ended,
               entity_type0, entity_type1',
        \@sources, $target, \@sources);

    my @old_link_ids;
    for my $new_link (@$new_links) {
        my $old_link_id = delete $new_link->{id};
        push(@old_link_ids, $old_link_id);
        my $entity_type0 = delete $new_link->{entity_type0};
        my $entity_type1 = delete $new_link->{entity_type1};
        for my $date_type (qw( begin_date end_date )) {
            $new_link->{$date_type} = {
                year => delete $new_link->{$date_type . '_year'},
                month => delete $new_link->{$date_type . '_month'},
                day => delete $new_link->{$date_type . '_day'},
            };
        }
        $new_link->{attributes} = [uniq(@{ $new_link->{attributes} })];
        my $new_link_id = $self->c->model('Link')->find_or_insert($new_link);
        $self->sql->do("UPDATE l_${entity_type0}_${entity_type1} SET link = ? WHERE link = ?",
                       $new_link_id, $old_link_id);
    }

    # Constraint triggers run at the end of the transaction, so these must be done manually.
    $self->sql->do('DELETE FROM link_attribute_credit WHERE link = any(?)', \@old_link_ids);
    $self->sql->do('DELETE FROM link_attribute WHERE link = any(?)', \@old_link_ids);
    $self->sql->do('DELETE FROM link WHERE id = any(?)', \@old_link_ids);

    $self->c->model('Link')->_delete_from_cache(@old_link_ids);
}

# The entries in the memcached store for 'Link' objects also have all attributes
# loaded. Thus changing an attribute should clear all of these link objects.
for my $method (qw( delete update )) {
    before $method => sub {
        my ($self, $id) = @_;
        $self->c->model('Link')->_delete_from_cache(
            @{ $self->sql->select_single_column_array(
                'SELECT id FROM link
                 JOIN link_attribute la ON link.id = la.link
                 WHERE la.attribute_type = ?',
                $id
            ) }
        );
    };
}

sub text_attribute_types {
    my ($self) = @_;

    return $self->get_tree('WHERE id IN (SELECT attribute_type FROM link_text_attribute_type)');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

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
