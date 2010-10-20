package MusicBrainz::Server::Form::ReleaseEditor::Tracklist;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.id' => ( type => 'Integer' );
has_field 'mediums.name' => ( type => 'Text' );
has_field 'mediums.deleted' => ( type => 'Checkbox' );
has_field 'mediums.format_id' => ( type => 'Select' );
has_field 'mediums.position' => ( type => 'Integer' );
has_field 'mediums.tracklist' => ( type => 'Compound' );
has_field 'mediums.tracklist.id' => ( type => 'Integer' );

sub options_mediums_format_id { shift->_select_all('MediumFormat') }

1;
