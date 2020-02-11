package MusicBrainz::Server::Entity::Work;

use List::UtilsBy qw( sort_by );
use Moose;
use MusicBrainz::Server::Entity::Types;
use aliased 'MusicBrainz::Server::Entity::WorkAttribute';

extends 'MusicBrainz::Server::Entity::CoreEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Linkable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::LastUpdate';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'WorkType' };

use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Object Str );

sub entity_type { 'work' }

has languages => (
    traits => ['Array'],
    is => 'ro',
    isa => 'ArrayRef[WorkLanguage]',
    default => sub { [] },
    handles => {
        add_language => 'push',
        all_languages => 'elements',
    },
);

has 'artists' => (
    traits => [ 'Array' ],
    is => 'ro',
    default => sub { [] },
    handles => {
        add_artist => 'push',
        all_artists => 'elements',
    }
);

has 'writers' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => ArrayRef[
        Dict[
            credit => Str,
            roles => ArrayRef[Str],
            entity => Object
        ]
    ],
    default => sub { [] },
    handles => {
        add_writer => 'push',
        all_writers => 'elements',
    }
);

has 'iswcs' => (
    is => 'ro',
    isa => 'ArrayRef',
    traits => [ 'Array' ],
    default => sub { [] },
    handles => {
        all_iswcs => 'elements',
        add_iswc => 'push'
    }
);

has attributes => (
    is => 'ro',
    isa => ArrayRef[WorkAttribute],
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        all_attributes => 'elements',
        add_attribute => 'push'
    }
);

sub sorted_attributes {
    my $self = shift;
    sort_by { $_->type->l_name } sort_by { $_->l_value } $self->all_attributes;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    for my $attr ($self->all_attributes) {
        if (my $type = $attr->type) {
            $self->link_entity('work_attribute_type', $type->id, $type);
        }
    }

    return {
        %{ $self->$orig },
        attributes => [map { $_->TO_JSON } $self->sorted_attributes],
        languages => [map { $_->TO_JSON } $self->all_languages],
        iswcs => [map { $_->TO_JSON } $self->all_iswcs],
        artists => [map { $_->TO_JSON } $self->all_artists],
        writers => [map +{
            credit => $_->{credit},
            entity => $_->{entity},
            roles => $_->{roles},
        }, $self->all_writers],
    };
};

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
