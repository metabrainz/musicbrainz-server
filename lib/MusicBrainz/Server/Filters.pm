package MusicBrainz::Server::Filters;

use strict;
use warnings;

use MusicBrainz::Server::Track;
use Text::WikiFormat;

sub release_date
{
    my $date = shift;

    my ($y, $m, $d) = split /-/, $date;

    my $str = "";

    $str .= $y     if ($y && 0 + $y);
    $str .= "-".$m if ($m && 0 + $m);
    $str .= "-".$d if ($d && 0 + $d);

    return $str;
}

sub format_time
{
    my $ms = shift;
    return MusicBrainz::Server::Track::FormatTrackLength($ms);
}

sub format_wikitext
{
    my ($text) = @_;

    return '' unless $text;

    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;
    return Text::WikiFormat::format($text, {}, {
        prefix => "http://wiki.musicbrainz.org/",
        extended => 1,
        absolute_links => 1,
        implicit_links => 0
    });
}

1;
