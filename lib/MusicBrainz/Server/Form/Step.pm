package MusicBrainz::Server::Form::Step;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has '+html_prefix' => ( default => 0 );
has 'skip' => ( isa => 'Bool',  is => 'rw', default => 0 );

has_field 'wizard_session_id' => ( type => 'Hidden' );
has_field 'cancel' => ( type => 'Submit' );
has_field 'previous' => ( type => 'Submit' );
has_field 'next' => ( type => 'Submit' );
has_field 'save' => ( type => 'Submit' );

1;
