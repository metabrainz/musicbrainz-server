package MusicBrainz::Server::Filters;

use strict;
use warnings;

use Locale::Language;
use MusicBrainz::Server::Track;
use URI::Escape;
use Encode;
use Text::WikiFormat;
use MusicBrainz::Server::Validation qw( encode_entities );
use Try::Tiny;

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

sub format_editnote
{
    my ($text) = @_;

    my $is_url = 1;
    my $server = &DBDefs::WEB_SERVER;

    my $html = join "", map {

        # shorten url's that are longer 50 characters
        my $encurl = encode_entities($_);
        my $shorturl = $encurl;
        if (length($_) > 50)
        {
            $shorturl = substr($_, 0, 48);
            $shorturl = encode_entities($shorturl);
            $shorturl .= "&#8230;";
        }
        ($is_url = not $is_url)
            ? qq[<a href="$encurl" title="$encurl">$shorturl</a>]
            : $encurl;
    } split /
        (
         # Something that looks like the start of a URL
         \b
         (?:https?|ftp)
         :\/\/
         .*?
         
         # Stop at one of these sequences:
         (?=
          \z # end of string
          | \s # any space
          | [,\.!\?](?:\s|\z) # punctuation then space or end
          | [\x29"'>] # any of these characters "
          )
         )
         /six, $text, -1;

    $html =~ s[\b(?:mod(?:eration)? #?|edit[#:\s]+|edit id[#:\s]+|change[#:\s]+)(\d+)\b]
         [<a href="http://$server/edit/$1">edit #$1</a>]gi;

    # links to wikidocs
    $html =~ s/doc:(\w[\/\w]*)(``)*/<a href="\/doc\/$1">$1<\/a>/gi;
    $html =~ s/\[(\p{IsUpper}[\/\w]*)\]/<a href="\/doc\/$1">$1<\/a>/g;

    $html =~ s/<\/?p[^>]*>//g;
    $html =~ s/<br[^>]*\/?>//g;
    $html =~ s/&#39;&#39;&#39;(.*?)&#39;&#39;&#39;/<strong>$1<\/strong>/g;
    $html =~ s/&#39;&#39;(.*?)&#39;&#39;/<em>$1<\/em>/g;
    $html =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

    return $html;
}

sub uri_decode
{
    my ($uri) = @_;
    my $dec = decode('utf-8', uri_unescape($uri));
    Encode::_utf8_on($dec);
    return $dec;
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
