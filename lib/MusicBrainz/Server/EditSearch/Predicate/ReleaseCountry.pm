package MusicBrainz::Server::EditSearch::Predicate::ReleaseCountry;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';
with 'MusicBrainz::Server::EditSearch::Predicate::Role::EntityArea' => {
    type => 'release',
    column => 'country',
    extra_join => { 'table' => 'release_country' }
};

1;
