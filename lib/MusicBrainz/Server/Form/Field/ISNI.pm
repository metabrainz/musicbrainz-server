package MusicBrainz::Server::Form::Field::ISNI;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Validation qw( is_valid_isni format_isni );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub { return format_isni(shift) },
        message => 'This is not a valid ISNI',
    },
    {
        check => sub { is_valid_isni(shift) },
        message => 'This is not a valid ISNI',
    }
]);

1;
