package MusicBrainz::Server::Entity::ReleaseEvent;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Entity::Types;

has date => (
    is => 'ro',
    isa => 'PartialDate'
);

has country_id => (
    is => 'ro',
    isa => 'Maybe[Int]'
);

has country => (
    is => 'rw',
    isa => 'Maybe[Area]'
);

sub TO_JSON {
    my ($self) = @_;

    return {
        date    => $self->date ? $self->date->TO_JSON : undef,
        country => defined($self->country) ? $self->country->TO_JSON : undef,
    };
}

1;
