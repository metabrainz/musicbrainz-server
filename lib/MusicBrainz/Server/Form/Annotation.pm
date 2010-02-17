package MusicBrainz::Server::Form::Annotation;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => (default => 'edit-annotation');

has_field 'text' => (
    type     => 'Text',
);

has_field 'changelog' => (type => 'Text');

sub edit_field_names { qw( text changelog ) }

__PACKAGE__->meta->make_immutable;
no Moose;
1;
