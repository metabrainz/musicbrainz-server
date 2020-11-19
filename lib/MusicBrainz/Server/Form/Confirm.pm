package MusicBrainz::Server::Form::Confirm;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
has '+name' => ( default => 'confirm' );

has_field 'cancel' => ( type => 'Submit' );
has_field 'submit' => ( type => 'Submit' );

sub edit_field_names { () }

1;
