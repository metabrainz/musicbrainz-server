package MusicBrainz::Server::Filters;

use strict;
use warnings;

use Encode;
use Locale::Language;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Validation qw( encode_entities );
use Text::WikiFormat;
use Try::Tiny;
use URI::Escape;

require Encode::Detect;

use Sub::Exporter -setup => {
    exports => [qw( format_editnote )]
};

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

# get the xsd type for a date (rdfa stuff)
sub date_xsd_type
{
    my $date = shift;
    if($date =~ /^[\d-]+$/){
	
	my ($y, $m, $d) = split /-/, $date;

	return 'xsd:date' if ($y && 0 + $y && $m && 0 + $m && $d && 0 + $d);
	return 'xsd:gYearMonth' if ($y && 0 + $y && $m && 0 + $m);
	return 'xsd:gYear' if ($y);
    }

}

sub format_length
{
    my $ms = shift;
    return MusicBrainz::Server::Track::FormatTrackLength($ms);
}

# format duration as xsd:duration (rdfa stuff)
sub format_length_xsd
{
    my $ms = shift;
    return MusicBrainz::Server::Track::FormatXSDTrackLength($ms);
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
    return decode(
        'utf-8',
        Text::WikiFormat::format(
            encode('utf-8' => $text), {}, {
                prefix => "http://wiki.musicbrainz.org/",
                extended => 1,
                absolute_links => 1,
                implicit_links => 0
            })
      );
}

sub _display_trimmed {
    my $url = shift;

    # shorten url's that are longer 50 characters
    my $encoded_url = encode_entities($url);
    my $display_url = length($encoded_url) > 50
        ? substr($encoded_url, 0, 48) . "&#8230;"
        : $encoded_url;

    $encoded_url = "http://$encoded_url"
        unless $encoded_url =~ m{^http://};

    return qq{<a href="$encoded_url">$display_url</a>};
}

sub normalise_url {
    my $url = shift;
    # The regular expression in format_editnote is not clever enough to handle
    # percent encoded parenthesis.

    $url =~ s/%28/\(/g;
    $url =~ s/%29/\)/g;

    return $url;
}

sub format_editnote
{
    my ($html) = @_;

    my $is_url = 1;
    my $server = &DBDefs::WEB_SERVER;

    # Pre-pass the edit note to attempt to normalise any URLs
    $html =~ s{(http://[^\s]+)}{normalise_url($1)}eg;

    # Encode < and >
    $html =~ s/</&lt;/g;
    $html =~ s/>/&gt;/g;

    # The following taken from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    $html =~ s{
    \b
    (                       # Capture 1: entire matched URL
      (?:
        https?://               # http or https protocol
        |                       #   or
        www\d{0,3}[.]           # "www.", "www1.", "www2." … "www999."
        |                           #   or
        [a-z0-9.\-]+[.][a-z]{2,4}/  # looks like domain name followed by a slash
      )
      (?:                       # One or more:
        [^\s()<>]+                  # Run of non-space, non-()<>
        |                           #   or
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
      )+
      (?:                       # End with:
        \(([^\s()<>]+|(\([^\s()<>]+\)))*\)  # balanced parens, up to 2 levels
        |                               #   or
        [^\s`!()\[\]{};:'".,<>?«»“”‘’]        # not a space or one of these punct chars
      )
    )
    }{_display_trimmed($1, $2, $3, $4)}egsxi;

    $html =~ s[\b(?:mod(?:eration)? #?|edit[#:\s]+|edit id[#:\s]+|change[#:\s]+)(\d+)\b]
         [<a href="http://$server/edit/$1">edit #$1</a>]gi;

    # links to wikidocs
    $html =~ s/doc:(\w[\/\w]*)(``)*/<a href="\/doc\/$1">$1<\/a>/gi;
    $html =~ s/\[(\p{IsUpper}[\/\w]*)\]/<a href="\/doc\/$1">$1<\/a>/g;

    $html =~ s/<\/?p[^>]*>//g;
    $html =~ s/<br[^>]*\/?>//g;
    $html =~ s/'''([^']+.*?)'''/<strong>$1<\/strong>/g;
    $html =~ s/''(.*?)''/<em>$1<\/em>/g;
    $html =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

    return $html;
}

sub uri_decode
{
    my $uri = decode('Detect', uri_unescape(shift));
}

sub language
{
    return code2language(shift);
}

sub locale
{
    my $locale_name = shift or return '';
    try {
        my $locale = DateTime::Locale->load($locale_name);
        return $locale->name
    }
    catch {
        return;
    }
}

1;
