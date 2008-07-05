package MusicBrainz::Server::Filters;

use strict;
use warnings;

use MusicBrainz::Server::DateTime;

sub date
{
    my $date = shift;
    return MusicBrainz::Server::DateTime::format_datetime($date);
}

sub release_date
{
    my $date = shift;

    my ($y, $m, $d) = split /-/, $date;

    my $str = "";

    $str .= $y if (0 + $y);
    $str .= "-".$m if (0 + $m);
    $str .= "-".$d if (0 + $d);

    return $str;
}

1;
