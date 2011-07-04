package MusicBrainz::Server::EditSearch::Predicate::Editor;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

has name => (
    is => 'rw',
);

1;
