package MusicBrainz::Server::Form::Field::Comment;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Text';

require Text::Trim;

apply ([
    {
        transform => sub {
            my $text = shift;
            $text =~ s/^\((.+)\)$/$1/;
            return Text::Trim::trim($text);
        }
    }
]);

1;
