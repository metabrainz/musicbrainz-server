package MusicBrainz::Server::EditSearch::Predicate::LabelCountry;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';
with 'MusicBrainz::Server::EditSearch::Role::CountrySearch' => { type => 'label' };

1;
