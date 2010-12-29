package MusicBrainz::Server::Form::Field::Barcode;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation;

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => (
    default => 255
);

1;
