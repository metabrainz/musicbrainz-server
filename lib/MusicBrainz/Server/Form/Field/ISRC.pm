package MusicBrainz::Server::Form::Field::ISRC;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_isrc );

extends 'HTML::FormHandler::Field::Text';

has '+minlength' => ( default => 12 );
has '+maxlength' => ( default => 12 );

apply ([
    {
        check => sub { is_valid_isrc(shift) },
        message => l('This is not a valid ISRC.'),
    }
]);

1;
