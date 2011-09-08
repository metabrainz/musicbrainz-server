package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

apply ([
    {
        transform => sub {
            my $text = shift;
            $text =~ s/[^[:print:]]//g;
            $text =~ s/\s+/ /g;
            $text =~ s/\s*(.*)\s*/$1/g;
            return $text;
        }
    }
]);

1;
