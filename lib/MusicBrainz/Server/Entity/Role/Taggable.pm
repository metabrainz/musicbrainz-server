package MusicBrainz::Server::Entity::Role::Taggable;
use Moose::Role;

use MusicBrainz::Server::Entity::Types;

has 'tags' => (
    is => 'rw',
    isa => 'ArrayRef[AggregatedTag]',
    traits => [ 'Array' ],
    handles => {
        all_tags => 'elements',
        add_tag => 'push',
        clear_tags => 'clear'
    }
);

has 'user_tags' => (
    is => 'rw',
    isa => 'ArrayRef[UserTag]',
    traits => [ 'Array' ],
    handles => {
        all_user_tags => 'elements',
        add_user_tag => 'push',
        clear_user_tags => 'clear'
    }
);

1;

=head1 NAME

MusicBrainz::Server::Entity::Role::Taggable

=head1 ATTRIBUTES

=head2 tags

Aggregated collection of all user's tags.

=head2 user_tags

User's tags.

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
