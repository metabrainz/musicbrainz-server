package MusicBrainz::Server::Data::Role::Attribute;
use Moose::Role;
use namespace::autoclean;
use MusicBrainz::Server::Data::Utils qw( hash_to_row );

sub insert { }
around insert => sub {
    my ($orig, $self, $values) = @_;

    my $row = $self->_hash_to_row($values);
    $row->{id} = $self->sql->select_single_value("SELECT nextval('".$self->_table."_id_seq')");
    $self->sql->insert_row($self->_table, $row);
    return $self->_entity_class->new( id => $row->{id} );
};

sub update { }
around update => sub {
    my ($orig, $self, $id, $values) = @_;

    my $row = $self->_hash_to_row($values);
    if (%$row) {
        $self->sql->update_row($self->_table, $row, { id => $id });
    }
};

sub delete { }
around delete => sub {
    my ($orig, $self, $id) = @_;

    $self->sql->do('DELETE FROM '.$self->_table.' WHERE id = ?', $id);
};

sub _hash_to_row {
    my ($self, $values) = @_;

    return hash_to_row($values, {
        parent          => 'parent_id',
        child_order     => 'child_order',
        name            => 'name',
        description     => 'description',
    });
}

no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
