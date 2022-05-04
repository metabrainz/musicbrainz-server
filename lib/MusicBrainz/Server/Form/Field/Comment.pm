package MusicBrainz::Server::Form::Field::Comment;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils;

extends 'HTML::FormHandler::Field::Text';

has '+maxlength' => ( default => 255 );
has '+not_nullable' => ( default => 1 );
has '+validate_when_empty' => (
    default => 1
);

apply ([
    {
        transform => sub { MusicBrainz::Server::Data::Utils::trim_comment(shift) }
    }
]);

1;
