package MusicBrainz::Server::EditSearch::Predicate::ReleaseCountry;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';
with 'MusicBrainz::Server::EditSearch::Role::CountrySearch' => { type => 'release' };

1;
