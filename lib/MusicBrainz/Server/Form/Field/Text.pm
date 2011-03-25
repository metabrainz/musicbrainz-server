package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field';

apply ([
    {
        transform => sub {
            my $text = shift;
            $text =~ s/[^[:print:]]//g;
            $text =~ s/\s+/ /g;
            return $text;
        }
    }
]);

1;
