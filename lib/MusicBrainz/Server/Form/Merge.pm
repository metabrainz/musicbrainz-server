package MusicBrainz::Server::Form::Merge;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw() }

has '+name' => ( default => 'merge' );

has_field 'target' => (
    type => 'Integer',
    required => 1
);

1;
