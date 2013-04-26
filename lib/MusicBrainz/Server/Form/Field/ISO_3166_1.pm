package MusicBrainz::Server::Form::Field::ISO_3166_1;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_iso_3166_1 );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        check => sub { is_valid_iso_3166_1(shift) },
        message => l('This is not a valid ISO 3166-1 code'),
    }
]);

1;
