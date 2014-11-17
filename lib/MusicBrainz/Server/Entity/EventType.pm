package MusicBrainz::Server::Entity::EventType;

use Moose;
use MusicBrainz::Server::Translation::Attributes qw( lp );

extends 'MusicBrainz::Server::Entity';

with 'MusicBrainz::Server::Entity::Role::OptionsTree' => {
    type => 'EventType',
};

has name => (
    is => 'rw',
    isa => 'Str',
);

sub l_name {
    my $self = shift;
    return lp($self->name, 'event_type')
}

has description => (
    is => 'rw',
    isa => 'Str',
);

sub l_description {
    my $self = shift;
    return lp($self->description, 'event_type');
}

sub to_json_hash {
    my $self = shift;

    return {
        id => +$self->id,
        name => $self->l_name,
        entityType => $self->entity_type,
        parentID => $self->parent_id,
        childOrder => +$self->child_order,
        description => $self->l_description,
    };
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

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
