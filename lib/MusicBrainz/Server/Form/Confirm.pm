package MusicBrainz::Server::Form::Confirm;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
has '+name' => ( default => 'confirm' );

sub edit_field_names { () }

1;
