package MusicBrainz::Server::Form::Field::ISRC;
use HTML::FormHandler::Moose;

use MusicBrainz::Server::Translation qw( l ln );
use MusicBrainz::Server::Validation qw( is_valid_isrc is_not_tunecore );

extends 'HTML::FormHandler::Field::Text';

has '+minlength' => ( default => 12 );
has '+maxlength' => ( default => 12 );

apply ([
    {
        check => sub { is_valid_isrc(shift) },
        message => l('This is not a valid ISRC'),
    },
    {
        check => sub { is_not_tunecore(shift) },
        message => l('This is not a valid ISRC; codes beginning "TC" are TuneCore IDs which should not be put into the ISRC field. Please put this code into the annotation for the recording instead.'),
    }
]);

1;
