package MusicBrainz::Server::Entity::Tree::Work;
use Moose;

has work => (
    is => 'rw',
    predicate => 'work_set',
);

has aliases => (
    is => 'rw',
    predicate => 'aliases_set',
);

has iswcs => (
    is => 'rw',
    predicate => 'iswcs_set',
);

has annotation => (
    is => 'rw',
    predicate => 'annotation_set'
);

1;
