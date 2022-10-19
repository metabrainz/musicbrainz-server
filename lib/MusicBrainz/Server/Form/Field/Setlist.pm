package MusicBrainz::Server::Form::Field::Setlist;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_setlist );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_setlist(shift) },
        message => sub { l('Please ensure all lines start with @, * or #, followed by a space.') },
    }
]);

1;
