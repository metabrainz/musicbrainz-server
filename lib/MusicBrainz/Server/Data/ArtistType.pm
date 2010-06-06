package MusicBrainz::Server::Data::ArtistType;
use Moose;
use Method::Signatures::Simple;

use MusicBrainz::Schema qw( schema );

extends 'MusicBrainz::Server::Data::FeyEntity';
with
    'MusicBrainz::Server::Data::Role::EntityCache' => { prefix => 'at' },
    'MusicBrainz::Server::Data::Role::SelectAll',
    'MusicBrainz::Server::Data::Role::Subobject' => { prefix => 'type' };

method _build_table  { schema->table('artist_type') }
method _entity_class { 'MusicBrainz::Server::Entity::ArtistType' }

method _column_mapping
{
    return { map { $_ => $_ } qw( id name ) }
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
