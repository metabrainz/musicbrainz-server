package MusicBrainz::Server::Entity::Collection;
use Moose;

use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CoreEntity';

has 'editor' => (
    is => 'ro',
    isa => 'Editor',
);

has 'editor_id' => (
    is => 'ro',
    isa => 'Int',
);

has 'public' => (
    is => 'rw',
    isa => 'Bool'
);

has 'description' => (
    is => 'rw',
    isa => 'Str'
);

has release_count => (
    is => 'rw',
    isa => 'Int',
    predicate => 'loaded_release_count'
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2010 Sean Burke

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
