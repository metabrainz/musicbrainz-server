package MusicBrainz::Server::Form::Field::ISRC;
use strict;
use warnings;

use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Validation qw( is_valid_isrc format_isrc );

extends 'HTML::FormHandler::Field::Text';

has '+minlength' => ( default => 12 );

apply ([
    {
        transform => sub { return format_isrc(shift) },
        message => sub { l('This is not a valid ISRC') },
    },
    {
        check => sub { is_valid_isrc(shift) },
        message => sub { l('This is not a valid ISRC.') },
    }
]);

1;
