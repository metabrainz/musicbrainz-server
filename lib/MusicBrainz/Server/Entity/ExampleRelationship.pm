package MusicBrainz::Server::Entity::ExampleRelationship;
use Moose;

has name => (
    isa => 'Str',
    required => 1,
    is => 'ro'
);

has published => (
    isa => 'Bool',
    is => 'ro',
    required => 1
);

has relationship => (
    is => 'ro',
    required => 1
);

1;
