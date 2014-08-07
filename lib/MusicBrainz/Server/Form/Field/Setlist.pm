package MusicBrainz::Server::Form::Field::Setlist;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_setlist );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_setlist(shift) },
        message => l('Please ensure all lines start with @, * or #.'),
    }
]);

1;
