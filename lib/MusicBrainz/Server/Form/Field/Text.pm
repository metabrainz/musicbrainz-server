package MusicBrainz::Server::Form::Field::Text;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

use Text::Trim qw( trim );

apply ([
    {
        transform => sub {
            my $text = shift;
            $text =~ s/[^[:print:]]//g;
            $text =~ s/\s+/ /g;
            return trim($text);
        }
    }
]);

1;
