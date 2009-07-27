package MusicBrainz::Server::Form::Search::Results;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'results' );

has_field 'selected_id' => (
    type => 'Integer',
    required => 1,
);

1;
