package MusicBrainz::Server::Form::Field::DiscID;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_discid );

extends 'HTML::FormHandler::Field::Text';

apply([
    {
        check => sub { is_valid_discid(shift) },
        message => sub { l('This is not a valid disc ID') }
    }
]);

1;
