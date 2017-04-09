package MusicBrainz::Server::Entity;

use Moose;
use MusicBrainz::Server::Data::Utils qw( ref_to_type );

with 'MusicBrainz::Server::Entity::Role::LinkedEntities';

has 'id' => (
    is => 'rw',
    isa => 'Int'
);

sub TO_JSON {
    my ($self) = @_;

    my $entity_type = ref_to_type($self);

    return {
        entityType => $entity_type,
        id => $self->id,
        $self->can('name') ? (name => $self->name) : (),
        $self->can('unaccented_name') ? (unaccentedName => $self->unaccented_name) : (),
    };
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
