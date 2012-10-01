package MusicBrainz::Server::Form::Field::Integer;
use Moose;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler::Field::Integer';

apply([
    {
        transform => sub {
            my $value = shift;
            return 0 + $value;
        },
        message => '',
    }
]);

1;
