package MusicBrainz::Server::Form::Field::GID;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_guid );

extends 'HTML::FormHandler::Field::Text';

apply([
    {
        check => sub { is_guid(shift) },
        message => sub { l('This is not a valid MBID') }
    }
]);

1;
