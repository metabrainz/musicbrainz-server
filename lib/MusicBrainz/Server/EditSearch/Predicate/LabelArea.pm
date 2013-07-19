package MusicBrainz::Server::EditSearch::Predicate::LabelArea;
use Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';
with 'MusicBrainz::Server::EditSearch::Role::AreaSearch' => { type => 'label' };

has name => (
    is => 'rw',
);

1;
