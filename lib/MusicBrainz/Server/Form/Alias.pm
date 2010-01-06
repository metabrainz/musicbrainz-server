package MusicBrainz::Server::Form::Alias;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Edit';

has '+name' => ( default => 'edit-alias' );

has_field 'alias' => (
    type => 'Text',
    required => 1
);

sub edit_field_names { qw(alias) }

1;
