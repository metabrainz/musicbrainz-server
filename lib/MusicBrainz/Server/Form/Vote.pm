package MusicBrainz::Server::Form::Vote;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'enter-vote' );

has_field 'vote' => (
    type => 'Repeatable',
    required => 1,
);

has_field 'vote.edit_id' => (
    type => 'Integer',
    required => 1,
);

has_field 'vote.vote' => (
    type => 'Integer',
);

has_field 'vote.edit_note' => (
    type => 'Text',
);

1;
