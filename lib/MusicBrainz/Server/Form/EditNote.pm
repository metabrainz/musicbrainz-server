package MusicBrainz::Server::Form::EditNote;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'add-edit-note' );

has_field 'text' => (
    type => 'Text',
    required => 1
);

__PACKAGE__->meta->make_immutable;
no Moose;
1;
