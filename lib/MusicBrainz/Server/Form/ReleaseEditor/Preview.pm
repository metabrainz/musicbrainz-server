package MusicBrainz::Server::Form::ReleaseEditor::Preview;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.associations' => ( type => 'Repeatable',  num_when_empty => 0 );
has_field 'mediums.associations.id' => ( type => 'Integer' );
has_field 'mediums.associations.addnew' => (
    type => 'Select',
    options => [
        { value => 1 }, # Add new recording
        { value => 2 }, # Use recording'
    ],
);

1;
