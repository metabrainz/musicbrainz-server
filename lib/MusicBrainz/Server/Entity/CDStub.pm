package MusicBrainz::Server::Entity::CDStub;

use Moose;
use MusicBrainz::Server::Entity::Barcode;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Types qw( DateTime );

use namespace::autoclean;

extends 'MusicBrainz::Server::Entity';

has 'discid' => (
    is => 'rw',
    isa => 'Str'
);

has 'title' => (
    is => 'rw',
    isa => 'Str'
);

has 'artist' => (
    is => 'rw',
    isa => 'Str'
);

has 'date_added' => (
    is => 'rw',
    isa => DateTime,
    coerce => 1
);

has 'last_modified' => (
    is => 'rw',
    isa => DateTime,
    coerce => 1
);

has 'lookup_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'modify_count' => (
    is => 'rw',
    isa => 'Int'
);

has 'source' => (
    is => 'rw',
    isa => 'Int'
);

has 'track_count' => (
    is => 'rw',
    isa => 'Int'
);


has 'barcode' => (
    is => 'rw',
    isa => 'Barcode',
    lazy => 1,
    default => sub { MusicBrainz::Server::Entity::Barcode->new() },
);

has 'comment' => (
    is => 'rw',
    isa => 'Str'
);

has 'tracks' => (
    is => 'rw',
    isa => 'ArrayRef[MusicBrainz::Server::Entity::CDStubTrack]',
    lazy => 1,
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_tracks => 'elements',
        add_track => 'push',
        clear_tracks => 'clear'
    }
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Robert Kaye

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
