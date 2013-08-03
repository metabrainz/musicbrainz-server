package MusicBrainz::Server::Form::Field::Coordinates;
use MusicBrainz::Server::Translation qw( l );
use HTML::FormHandler::Moose;

extends 'HTML::FormHandler::Field::Compound';

has_field 'latitude' => (
    type => '+HTML::FormHandler::Field::Float',
    range_start => -90,
    range_end => 90,
    size => 9,
    precision => 6,
);

has_field 'longitude' => (
    type => '+HTML::FormHandler::Field::Float',
    range_start => -180,
    range_end => 180,
    size => 9,
    precision => 6,
);

1;
