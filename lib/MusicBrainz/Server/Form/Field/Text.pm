package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Data::Utils;

extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub { MusicBrainz::Server::Data::Utils::trim(shift) }
    }
]);

1;
