package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'name' => (
    type => 'Text',
    required => 1
);

sub edit_field_names { qw(name) }

1;
