package MusicBrainz::Server::Data::MediumFormat;

use Moose;
use MusicBrainz::Server::Entity::MediumFormat;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'mf' };
with 'MusicBrainz::Server::Data::Role::SelectAll';

sub _table
{
    return 'medium_format';
}

sub _columns
{
    return 'id, name, year, parent AS parent_id, child_order';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::MediumFormat';
}

sub load
{
    my ($self, @media) = @_;
    load_subobjects($self, 'format', @media);
}

sub get_tree
{
    my ($self) = @_;

    my $sql = Sql->new($self->c->dbh);
    $sql->select('SELECT '  .$self->_columns . ' FROM ' . $self->_table . '
                  ORDER BY child_order, id');
    my %id_to_obj;
    my @objs;
    while (1) {
        my $row = $sql->next_row_hash_ref or last;
        my $obj = $self->_new_from_row($row);
        $id_to_obj{$obj->id} = $obj;
        push @objs, $obj;
    }
    $sql->finish;

    my $root = MusicBrainz::Server::Entity::MediumFormat->new;
    foreach my $obj (@objs) {
        my $parent = $obj->parent_id ? $id_to_obj{$obj->parent_id} : $root;
        $parent->add_child($obj);
    }

    return $root;
}

sub _hash_to_row
{
    my ($self, $values) = @_;

    return hash_to_row($values, {
        name            => 'name',
        parent          => 'parent_id',
        child_order     => 'child_order',
        year            => 'year',
    });
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
