package MusicBrainz::Server::Form::Merge;
use HTML::FormHandler::Moose;
use namespace::autoclean;
use MusicBrainz::Server::Translation 'l';

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw() }

has '+name' => ( default => 'merge' );

has_field 'target' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    required_message => l('Please pick which work you want the others merged into.')
);

has_field 'merging' => (
    type => 'Repeatable',
    required => 1
);

has_field 'merging.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

1;
