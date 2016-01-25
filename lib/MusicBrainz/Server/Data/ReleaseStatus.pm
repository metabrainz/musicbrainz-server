package MusicBrainz::Server::Data::ReleaseStatus;

use Moose;
use namespace::autoclean;
use MusicBrainz::Server::Entity::ReleaseStatus;
use MusicBrainz::Server::Data::Utils qw( load_subobjects );

extends 'MusicBrainz::Server::Data::Entity';
with 'MusicBrainz::Server::Data::Role::EntityCache';
with 'MusicBrainz::Server::Data::Role::SelectAll';
with 'MusicBrainz::Server::Data::Role::OptionsTree';
with 'MusicBrainz::Server::Data::Role::Attribute';

sub _type { 'release_status' }

sub _table
{
    return 'release_status';
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::ReleaseStatus';
}

sub load
{
    my ($self, @objs) = @_;
    load_subobjects($self, 'status', @objs);
}

sub find_by_name
{
    my ($self, $name) = @_;
    my $row = $self->sql->select_single_row_hash(
        'SELECT ' . $self->_columns . ' FROM ' . $self->_table . '
          WHERE lower(name) = lower(?)', $name);
    return $row ? $self->_new_from_row($row) : undef;
}

sub in_use {
    my ($self, $id) = @_;
    return $self->sql->select_single_value(
        'SELECT 1 FROM release WHERE status = ? LIMIT 1',
        $id);
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
