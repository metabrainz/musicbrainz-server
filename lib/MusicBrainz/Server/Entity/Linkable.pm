package MusicBrainz::Server::Entity::Linkable;

use Moose::Role;
use MooseX::AttributeHelpers;
use MusicBrainz::Server::Entity::Types;

has 'relationships' => (
    is => 'rw',
    isa => 'ArrayRef[Relationship]',
    default => sub { [] },
    lazy => 1,
    metaclass => 'Collection::Array',
    provides => {
        elements => 'all_relationships',
        push => 'add_relationship',
        clear => 'clear_relationships'
    }
);

1;

=head1 NAME

MusicBrainz::Server::Entity::Linkable

=head1 ATTRIBUTES

=head2 relationships

List of relationships.

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
