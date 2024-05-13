package MusicBrainz::Server::Form::Field::LabelCode;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::Field::Integer';

apply(
    [
        {
            check   => sub { $_[0] > 0 && $_[0] < 1000000 },
            message => sub {
                my ( $value, $field ) = @_;
                return l('Label codes must be greater than 0 and 6 digits at most');
            },
        },
    ],
);

1;
