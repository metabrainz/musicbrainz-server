package MusicBrainz::Server::Form::ReleaseEditor::Recordings;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'rec_mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'rec_mediums.tracklist_id' => ( type => 'Integer' );
has_field 'rec_mediums.associations' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'rec_mediums.associations.gid' => ( type => 'Hidden' );

1;
