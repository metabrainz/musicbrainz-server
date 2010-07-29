package MusicBrainz::Server::Form::ReleaseEditor::EditNote;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'editnote'   => ( type => 'TextArea'    );

1;
