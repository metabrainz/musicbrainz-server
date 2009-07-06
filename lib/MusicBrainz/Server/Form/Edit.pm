package MusicBrainz::Server::Form::Edit;
use HTML::FormHandler::Moose::Role;

has_field 'edit_note' => (
    type => 'TextArea',
    label => 'Edit note:',
);

1;
