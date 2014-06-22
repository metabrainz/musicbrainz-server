package MusicBrainz::Server::Form::Field::Time;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_time );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_time(shift) },
        message => l('This is not a valid time.'),
    }
]);

1;
