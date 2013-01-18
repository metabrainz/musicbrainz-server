package MusicBrainz::Server::Form::Confirm;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
has '+name' => ( default => 'confirm' );

has_field 'revision_id' => (
    type => 'Integer',
    required => 1
);

sub edit_field_names { () }

1;
