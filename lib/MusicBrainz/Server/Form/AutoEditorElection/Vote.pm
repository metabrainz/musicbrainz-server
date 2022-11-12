package MusicBrainz::Server::Form::AutoEditorElection::Vote;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'vote' );

has_field 'vote' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
);

1;
