package MusicBrainz::Server::Form::ReleaseEditor::Preview;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'preview_mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'preview_mediums.associations' => ( type => 'Repeatable',  num_when_empty => 0 );
has_field 'preview_mediums.associations.id' => ( type => 'Integer' );
has_field 'preview_mediums.associations.addnew' => (
    type => 'Select',
    options => [
        { value => 1 }, # Add new recording
        { value => 2 }, # Use recording'
    ],
);

1;
