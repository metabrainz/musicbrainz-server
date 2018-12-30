package MusicBrainz::Server::Filters;

use utf8;

use strict;
use warnings;

use Digest::MD5 qw( md5_hex );
use Encode;
use MusicBrainz::Server::Track;
use MusicBrainz::Server::Validation qw( encode_entities );
use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );
use Text::Trim qw( trim );
use Text::WikiFormat;
use Try::Tiny;
use URI::Escape;

use Sub::Exporter -setup => {
    exports => [qw( format_editnote format_setlist format_wikitext )]
};

sub format_length
{
    my $ms = shift;
    return MusicBrainz::Server::Track::FormatTrackLength($ms);
}

sub format_setlist {
    my ($text) = @_;

    # Encode < and >
    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;

    # Lines starting with @ are artists
    $text =~ s/^@ ([^\r\n]*)/format_setlist_artist($1)/meg;

    # Lines starting with * are works
    $text =~ s/^\* ([^\r\n]*)/format_setlist_work($1)/meg;

    # Lines starting with # are comments
    $text =~ s/^# ([^\r\n]*)/<span class=\"comment\">$1<\/span>/mg;

    # Fix newlines
    $text =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

    return $text;
}

sub format_setlist_artist {
    my ($line) = @_;

    $line =~ s/
      \[
      ([0-9a-f]{8} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{12})(?:\|([^\]]+))?\]
    /_make_link("artist",$1,$2)/eixg;

    $line = "<b>Artist: $line</b>";

    return $line;
}

sub format_setlist_work {
    my ($line) = @_;

    $line =~ s/
      \[
      ([0-9a-f]{8} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{12})(?:\|([^\]]+))?\]
    /_make_link("work",$1,$2)/eixg;

    return $line;
}

sub format_wikitext
{
    my ($text) = @_;

    return '' unless $text;

    $text =~ s/</&lt;/g;
    $text =~ s/>/&gt;/g;

    my $entity_names = join('|', entities_with('mbid', take => 'url'));
    # MBS-2437: Expand MBID entity links
    $text =~ s/
      \[
      ($entity_names):
      ([0-9a-f]{8} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{4} -
       [0-9a-f]{12})(?:\|([^\]]+))?\]
    /_make_link($1,$2,$3)/eixg;

    return decode(
        'utf-8',
        Text::WikiFormat::format(
            encode('utf-8' => $text), {}, {
                prefix => "//wiki.musicbrainz.org/",
                extended => 1,
                nofollow_extended => 1,
                absolute_links => 1,
                implicit_links => 0
            })
      );
}

sub _make_link
{
    my ($type, $mbid, $content) = @_;
    $content //= "$type:$mbid";
    return "<a href=\"/$type/$mbid\">$content</a>"
}

sub encode_square_brackets
{
    my $t = $_[0];
    my %ent = ( '[' =>  '&#91;', ']' => '&#93;' );
    $t =~ s/([\[\]])/$ent{$1}/g;
    $t;
}

sub _display_trimmed {
    my $url = shift;

    my $encoded_url = encode_square_brackets(encode_entities($url));

    # shorten url's that are longer 50 characters
    my $display_url = length($url) > 50
        ? encode_square_brackets(encode_entities(substr($url, 0, 48))) . "&#8230;"
        : $encoded_url;

    $encoded_url = "http://$encoded_url"
        unless $encoded_url =~ m{^(?:https?:)?//};

    return qq{<a href="$encoded_url" rel="nofollow">$display_url</a>};
}

sub normalise_url {
    # The regular expression in format_editnote is not clever enough to handle
    # percent encoded parenthesis.

    shift =~ s/%28/\(/gr
          =~ s/%29/\)/gr
}

sub format_editnote
{
    my ($html) = @_;

    my $is_url = 1;
    my $server = DBDefs->WEB_SERVER;

    # Pre-pass the edit note to attempt to normalise any URLs
    $html =~ s{(https?://[^\s]+)}{normalise_url($1)}eg;

    # Encode < and >
    $html =~ s/</&lt;/g;
    $html =~ s/>/&gt;/g;

    # The following taken from http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    $html =~ s{
    # Match the start of the edit note entirely, or ensure that the proceeding
    # character is not a : (as we don't want to match foo://bar.com as
    # foo:<a..>).
    (?:^|(?<!:))
    (                                    # Capture 1: entire matched URL
      (?:
        (?:https?:)?//               # http or https protocol
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

    $html =~ s[\b(?:mod(?:eration)? #?|edit[#:\h]+|edit id[#:\h]+|change[#:\h]+)(\d+)\b]
         [<a href="//$server/edit/$1">edit #$1</a>]gi;

    # links to wikidocs
    # (only safe because \w doesn't match any of the HTML reserved characters)
    $html =~ s/doc:(\w[\/\w]*)(``)*/<a href="\/doc\/$1">$1<\/a>/gi;
    $html =~ s/\[(\p{IsUpper}[\/\w]*)\]/<a href="\/doc\/$1">$1<\/a>/g;

    $html =~ s/<\/?p[^>]*>//g;
    $html =~ s/<br[^>]*\/?>//g;
    $html =~ s/'''([^']+.*?)'''/<strong>$1<\/strong>/g;
    $html =~ s/''(.*?)''/<em>$1<\/em>/g;
    $html =~ s/(\015\012|\012\015|\012|\015)/<br\/>/g;

    return $html;
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

sub gravatar {
    my $email = shift;
    return sprintf '//gravatar.com/avatar/%s?d=mm', md5_hex(lc(trim($email)));
}

sub _amazon_https {
    my $url = shift;
    $url =~ s,http://ec[x4]\.images-amazon\.com/,https://images-na.ssl-images-amazon.com/,;
    return $url;
}

sub _generic_https {
    my $url = shift;
    # list only those sites that support https
    $url =~ s,http://(www\.ozon\.ru|(?:[^.\/]+\.)?archive\.org)/,https://$1/,;
    return $url;
}

sub coverart_https {
    my $url = shift;
    $url = _amazon_https($url);
    $url = _generic_https($url);
    return $url;
}

1;
