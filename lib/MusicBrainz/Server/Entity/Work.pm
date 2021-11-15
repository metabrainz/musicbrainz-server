package MusicBrainz::Server::Entity::Work;

use List::AllUtils qw( sort_by );
use Moose;
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array to_json_object );
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
        attributes => to_json_array([$self->sorted_attributes]),
        languages => to_json_array($self->languages),
        iswcs => to_json_array($self->iswcs),
        artists => to_json_array($self->artists),
        writers => [map +{
            credit => $_->{credit},
            entity => to_json_object($_->{entity}),
            roles => $_->{roles},
        }, $self->all_writers],
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
