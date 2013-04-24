package MusicBrainz::Server::Entity::Track;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Editable';

has 'recording_id' => (
    is => 'rw',
    isa => 'Int',
    clearer => 'clear_recording_id'
);

has 'recording' => (
    is => 'rw',
    isa => 'Recording',
    clearer => 'clear_recording'
);

has 'medium_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'medium' => (
    is => 'rw',
    isa => 'Medium'
);

has 'position' => (
    is => 'rw',
    isa => 'Int'
);

has 'number' => (
    is => 'rw',
    isa => 'Str'
);

has 'name' => (
    is => 'rw',
    isa => 'Str'
);

has 'artist_credit_id' => (
    is => 'rw',
    isa => 'Int'
);

has 'length' => (
    is => 'rw',
    isa => 'Maybe[Int]'
);

has 'artist_credit' => (
    is => 'rw',
    isa => 'ArtistCredit'
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
