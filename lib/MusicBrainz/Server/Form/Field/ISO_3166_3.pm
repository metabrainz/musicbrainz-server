package MusicBrainz::Server::Form::Field::ISO_3166_3;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_iso_3166_3 );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_iso_3166_3(shift) },
        message => sub { l('This is not a valid ISO 3166-3 code') },
    }
]);

1;
