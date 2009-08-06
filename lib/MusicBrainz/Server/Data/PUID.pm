package MusicBrainz::Server::Data::PUID;

use Moose;

extends 'MusicBrainz::Server::Data::Entity';

sub _table
{
    return 'puid JOIN clientversion ON puid.version = clientversion.id';
}

sub _columns
{
    return 'puid.id, puid.puid, clientversion.version';
}

sub _column_mapping
{
    return {
        id             => 'id',
        puid           => 'puid',
        client_version => 'version',
    };
}

sub _entity_class
{
    return 'MusicBrainz::Server::Entity::PUID';
}

sub _id_column
{
    return 'puid.id';
}

sub get_by_puid
{
    my ($self, $puid) = @_;
    my @result = values %{$self->_get_by_keys("puid.puid", $puid)};
    return $result[0];
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
