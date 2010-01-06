package MusicBrainz::Server::Form::URL;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Edit';

has '+name' => ( default => 'edit-url' );

has_field 'url' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
    required => 1
);

has_field 'description' => (
    type => 'Text'
);

__PACKAGE__->meta->make_immutable;
1;
