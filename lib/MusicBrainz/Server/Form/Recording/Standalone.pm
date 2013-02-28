package MusicBrainz::Server::Form::Recording::Standalone;
use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form::Recording';
use MusicBrainz::Server::Translation qw( N_l );

has_field '+edit_note' => (
    required => 1,
    required_message => N_l('You must provide an edit note when adding a standalone recording'),
);

1;
