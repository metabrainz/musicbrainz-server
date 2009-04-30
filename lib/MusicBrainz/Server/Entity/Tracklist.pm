package MusicBrainz::Server::Entity::Tracklist;

use Moose;
use MooseX::AttributeHelpers;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::Entity';
with 'MusicBrainz::Server::Entity::Editable';

has 'track_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'tracks' => (
    is => 'rw',
    isa => 'ArrayRef[Track]',
    lazy => 1,
    default => sub { [] },
    metaclass => 'Collection::Array',
    provides => {
        push => 'add_track',
        clear => 'clear_tracks',
    }
);

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
