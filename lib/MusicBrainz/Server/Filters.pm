package MusicBrainz::Server::Filters;

use strict;
use warnings;

use Locale::Language;
use MusicBrainz::Server::Track;
use URI::Escape;
use Encode qw( decode );
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

sub format_length
{
    my $ms = shift;
    return MusicBrainz::Server::Track::FormatTrackLength($ms);
}

sub format_distance
{
    my $ms = shift;
    return "0 s" if (!$ms);
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

sub uri_decode
{
    my ($uri) = @_;
    return decode('utf-8', uri_unescape($uri));
}

sub language
{
    return code2language(shift);
}

1;
