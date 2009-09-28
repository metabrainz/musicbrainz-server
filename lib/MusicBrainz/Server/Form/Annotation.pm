package MusicBrainz::Server::Form::Annotation;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => (default => 'edit-annotation');

has_field 'text' => (
    type     => 'Text',
    required => 1,
);

has_field 'changelog' => (type => 'Text');

__PACKAGE__->meta->make_immutable;
no Moose;
1;
