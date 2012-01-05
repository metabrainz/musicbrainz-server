package MusicBrainz::Server::EditSearch::Predicate::ArtistCountry;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';
with 'MusicBrainz::Server::EditSearch::Role::CountrySearch' => { type => 'artist' };

1;
