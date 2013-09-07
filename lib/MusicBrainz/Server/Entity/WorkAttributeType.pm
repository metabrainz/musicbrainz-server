package MusicBrainz::Server::Entity::WorkAttributeType;
use Moose;

extends 'MusicBrainz::Server::Entity';

has name => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

has comment => (
    isa => 'Str',
    is => 'ro',
    required => 1
);

__PACKAGE__->meta->make_immutable;
1;
