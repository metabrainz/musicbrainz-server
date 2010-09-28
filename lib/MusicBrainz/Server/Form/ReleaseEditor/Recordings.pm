package MusicBrainz::Server::Form::ReleaseEditor::Recordings;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'preview_mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'preview_mediums.associations' => ( type => 'Repeatable',  num_when_empty => 0 );
has_field 'preview_mediums.associations.gid' => ( type => 'Hidden' );

1;
