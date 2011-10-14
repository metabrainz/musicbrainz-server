package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

require Text::Trim;

apply ([
    {
        transform => sub {
            my $text = shift;
            $text =~ s/[^[:print:]]//g;
            $text =~ s/\s+/ /g;
            return Text::Trim::trim($text);
        }
    }
]);

1;
