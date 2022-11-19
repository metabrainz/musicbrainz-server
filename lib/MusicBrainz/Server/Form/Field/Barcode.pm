package MusicBrainz::Server::Form::Field::Barcode;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation;

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => (
    default => 255
);

1;
