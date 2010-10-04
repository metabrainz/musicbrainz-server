package MusicBrainz::Server::Form::CDStub;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';

has_field 'title' => (
    required => 1,
    type => 'Text',
);

has_field 'comment' => (
    type => 'Text',
);

has_field 'barcode' => (
    type => '+MusicBrainz::Server::Form::Field::Barcode'
);

has_field 'artist' => (
    type => 'Text',
);

has_field 'tracks' => (
    type => 'Repeatable'
);

has_field 'tracks.title' => (
    type => 'Text',
    required => 1
);

has_field 'tracks.artist' => (
    type => 'Text',
);

has_field 'single_artist' => (
    type => 'Checkbox'
);

1;
