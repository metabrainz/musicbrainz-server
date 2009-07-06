package MusicBrainz::Server::Form::Confirm;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Edit';
has '+name' => ( default => 'confirm' );

1;
