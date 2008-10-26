package MusicBrainz::Server::AddRelease::State;

use strict;
use warnings;

sub new
{
    my ($class, $c, $system) = @_;
    bless {
        c      => $c,
        system => $system
    }, $class;
}

1;
