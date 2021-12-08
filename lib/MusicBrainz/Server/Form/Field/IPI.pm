package MusicBrainz::Server::Form::Field::IPI;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_ipi format_ipi );

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub { return format_ipi(shift) },
        message => sub { l('This is not a valid IPI.') },
    },
    {
        check => sub { is_valid_ipi(shift) },
        message => sub { l('This is not a valid IPI.') },
    }
]);

1;
