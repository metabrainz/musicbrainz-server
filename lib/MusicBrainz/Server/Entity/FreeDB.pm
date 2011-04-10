package MusicBrainz::Server::Entity::FreeDB;

use Moose;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity';

has discid => (
    is => 'ro',
    isa => 'Str',
);

has 'category' => (
    is => 'rw',
    isa => 'Str'
);

has tracks => (
    is => 'ro',
);

has title => (
    isa => 'Str',
    is => 'ro',
);

has artist => (
    isa => 'Str',
    is => 'ro',
);

has track_count => (
    isa => 'Int',
    is => 'ro',
);

has year => (
    is => 'ro'
);

has looks_like_va => (
    isa => 'Bool',
    is => 'ro',
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
