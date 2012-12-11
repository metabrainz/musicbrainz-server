package MusicBrainz::Server::Data::LinkAttributeType;

use Moose;
use namespace::autoclean;
use Sql;
use Encode;
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

sub _table
{
    return 'link_attribute_type';
}

sub _columns
{
    return 'id, parent, child_order, gid, name, description, root';
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

sub get_tree
{
    my ($self) = @_;

    $self->sql->select('SELECT ' .$self->_columns . ' FROM ' . $self->_table . '
                  ORDER BY child_order, id');
    my %id_to_obj;
    my @objs;
    while (1) {
        my $row = $self->sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $id_to_obj{$obj->id} = $obj;
        push @objs, $obj;
    }
    $self->sql->finish;

    my $root = MusicBrainz::Server::Entity::LinkAttributeType->new;
    foreach my $obj (@objs) {
        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
        $parent->add_child($obj);
    }

    return $root;
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
