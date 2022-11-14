package MusicBrainz::Server::Entity::Event;

use Moose;
use MusicBrainz::Server::Entity::PartialDate;
use MusicBrainz::Server::Entity::Types;

extends 'MusicBrainz::Server::Entity::CentralEntity';
with 'MusicBrainz::Server::Entity::Role::Taggable';
with 'MusicBrainz::Server::Entity::Role::Annotation';
with 'MusicBrainz::Server::Entity::Role::DatePeriod';
with 'MusicBrainz::Server::Entity::Role::Rating';
with 'MusicBrainz::Server::Entity::Role::Review';
with 'MusicBrainz::Server::Entity::Role::Comment';
with 'MusicBrainz::Server::Entity::Role::Type' => { model => 'EventType' };

use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Object Str );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json non_empty );
use MusicBrainz::Server::Entity::Util::JSON qw( add_linked_entity to_json_object );
use MusicBrainz::Server::Types qw( Time );
use List::AllUtils qw( uniq_by );

sub entity_type { 'event' }

has 'setlist' => (
    is => 'rw',
    isa => 'Str'
);

has 'cancelled' => (
    is => 'rw',
    isa => 'Bool',
);

has 'time' => (
    is => 'rw',
    isa => Time,
    coerce => 1,
);

sub formatted_time
{
    my ($self) = @_;
    return $self->time ? $self->time->strftime('%H:%M') : undef;
}

has 'performers' => (
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
        add_performer => 'push',
        all_performers => 'elements',
    }
);

has 'places' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => ArrayRef[
        Dict[
            credit => Str,
            entity => Object
        ]
    ],
    default => sub { [] },
    handles => {
        add_place => 'push',
        all_places => 'elements',
    }
);

has 'areas' => (
    traits => [ 'Array' ],
    is => 'ro',
    isa => ArrayRef[
        Dict[
            credit => Str,
            entity => Object
        ]
    ],
    default => sub { [] },
    handles => {
        add_area => 'push',
        all_areas => 'elements',
    }
);

sub related_series {
    my $self = shift;
    return uniq_by { $_->id }
    map {
        $_->entity1
    } grep {
        $_->link && $_->link->type && $_->link->type->entity1_type eq 'series'
    } $self->all_relationships;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my @related_series = $self->related_series;
    add_linked_entity('series', $_->id, $_) for @related_series;

    my $setlist = $self->setlist;

    return {
        %{ $self->$orig },
        areas => [map +{
            credit => $_->{credit},
            entity => to_json_object($_->{entity}),
        }, $self->all_areas],
        cancelled => boolean_to_json($self->cancelled),
        performers => [map +{
            credit => $_->{credit},
            entity => to_json_object($_->{entity}),
            roles => $_->{roles},
        }, $self->all_performers],
        places => [map +{
            credit => $_->{credit},
            entity => to_json_object($_->{entity}),
        }, $self->all_places],
        related_series => [map { $_->id } @related_series],
        (non_empty($setlist) ? (setlist => $setlist) : ()),
        time => $self->formatted_time,
    };
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
