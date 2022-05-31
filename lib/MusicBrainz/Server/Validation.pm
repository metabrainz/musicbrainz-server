package MusicBrainz::Server::Validation;

use List::AllUtils qw( any );

require Exporter;
{
    our @ISA = qw( Exporter );
    our @EXPORT_OK = qw(
        unaccent_utf16
        is_integer
        is_non_negative_integer
        is_positive_integer
        is_database_row_id
        is_database_bigint_id
        is_guid
        trim_in_place
        is_valid_iswc
        format_iswc
        is_valid_ipi
        format_ipi
        is_valid_isni
        format_isni
        is_valid_url
        is_freedb_id
        is_valid_discid
        is_valid_barcode
        is_valid_ean
        is_valid_isrc
        format_isrc
        is_valid_time
        is_valid_setlist
        is_valid_iso_3166_1
        is_valid_iso_3166_2
        is_valid_iso_3166_3
        is_valid_partial_date
        is_valid_edit_note
        encode_entities
        normalise_strings
        is_nat
        validate_coordinates
    )
}

use strict;
use Carp qw( carp );
use List::AllUtils qw( any );
use Encode qw( decode encode );
use Scalar::Util qw( looks_like_number );
use Text::Unaccent::PurePerl qw( unac_string_utf16 );
use MusicBrainz::Server::Constants qw( $MAX_POSTGRES_INT $MAX_POSTGRES_BIGINT );
use utf8;

sub unaccent_utf16 ($)
{
    my $str = shift;
    return ( defined $str ? unac_string_utf16(''.$str) : '' );
}

################################################################################
# Validation and sanitisation section
################################################################################

sub is_integer
{
    my $t = shift;
    defined($t) and not ref($t) and $t =~ /\A(-?[0-9]{1,20})\z/;
}

sub is_non_negative_integer {
    my $t = shift;
    is_integer($t) and $t >= 0;
}

sub is_positive_integer
{
    my $t = shift;
    is_integer($t) and $t > 0;
}

# Converted to JavaScript at root/static/scripts/common/utility/isDatabaseRowId.js
sub is_database_row_id {
    my $t = shift;

    is_positive_integer($t) and $t <= $MAX_POSTGRES_INT;
}

sub is_database_bigint_id {
    my $t = shift;

    is_positive_integer($t) and $t <= $MAX_POSTGRES_BIGINT;
}

sub is_guid
{
    my $t = $_[0];
    defined($t) and not ref($t) or return undef;
    length($t) == 36 or return undef;

    $t =~ /[^0-]/ or return undef;

    $t = lc $t;
    $t =~ /\A(
        [0-9a-f]{8}
        - [0-9a-f]{4}
        - [0-9a-f]{4}
        - [0-9a-f]{4}
        - [0-9a-f]{12}
        )\z/x or return undef;
    $_[0] = $1;
    1;
}

sub trim_in_place
{
    carp 'Uninitialized value passed to trim_in_place'
        if any { not defined } @_;
    for (@_)
    {
        $_ = '' if not defined;
        # TODO decode, trim, encode?
        s/\A\s+//;
        s/\s+\z//;
        s/\s+/ /g;
    }
}

sub is_valid_iswc
{
    my $iswc = shift;
    $iswc =~ s/\s//g;
    return $iswc =~ /^T-?[0-9]{3}\.?[0-9]{3}\.?[0-9]{3}[-.]?[0-9]$/;
}

sub format_iswc
{
    my $iswc = shift;
    $iswc =~ s/\s//g;
    $iswc =~ s/^T-?([0-9]{3})\.?([0-9]{3})\.?([0-9]{3})[-.]?([0-9])/T-$1.$2.$3-$4/;
    return $iswc;
}

sub is_valid_ipi
{
    my $ipi = shift;
    return $ipi =~ /^[0-9]{11}$/;
}

sub format_ipi
{
    my $ipi = shift;
    return $ipi unless $ipi =~ /^[0-9\s.]{5,}$/;
    $ipi =~ s/[\s.]//g;
    return sprintf('%011.0f', $ipi)
}

sub is_valid_isni
{
    my $isni = shift;
    $isni =~ s/[\s\.-]//g;
    return $isni =~ /^[0-9]{15}[0-9X]$/;
}

sub format_isni {
    shift =~ s/[\s\.]//gr
}

sub is_valid_url
{
    my ($url) = @_;
    return if $url =~ /\s/;

    require URI;
    my $u = eval { URI->new($url) }
        or return 0;

    return 0 if $u->scheme eq '';
    return 0 if $u->can('authority') && !($u->authority =~ /\./);
    return 1;
}

sub is_freedb_id {
    my $id = shift;
    return lc($id) =~ /^[a-f0-9]{8}$/;
}

sub is_valid_discid
{
    my $discid = shift;
    return $discid =~ /^[A-Za-z0-9._-]{27}-/;
}

sub is_valid_barcode
{
    my $barcode = shift;
    return $barcode =~ /^[0-9]+$/;
}

sub is_valid_ean
{
    my $ean = shift;
    my $length = length($ean);
    if ($length == 8 || $length == 12 || $length == 13 || $length == 14 || $length == 17 || $length == 18) {
        my $sum = 0;
        for (my $i = 2; $i <= $length; $i++) {
                $sum += substr($ean, $length - $i, 1) * ($i % 2 == 1 ? 1 : 3);
        }
        return ((10 - $sum % 10) % 10) == substr($ean, $length - 1, 1);
    }
    return 0;
}

sub format_isrc
{
    my $isrc = shift;
    $isrc =~ s/[\s-]//g;
    return uc $isrc;
}

sub is_valid_isrc
{
    my $isrc = $_[0];
    return $isrc =~ /^[A-Z]{2}[A-Z0-9]{3}[0-9]{7}$/;
}

sub is_valid_time
{
    my $time = shift;
    return $time =~ /^([01][0-9]|2[0-3]):[0-5][0-9]$/;
}

sub is_valid_setlist
{
    my $setlist = shift;
    my @invalid_lines = grep { $_ !~ /^([@#*] |\s*$)/ } split('\r\n', $setlist); return @invalid_lines ? 0 : 1;
}

sub is_valid_iso_3166_1
{
    my $iso_3166_1 = shift;
    return $iso_3166_1 =~ /^[A-Z]{2}$/;
}

sub is_valid_iso_3166_2
{
    my $iso_3166_2 = shift;
    return $iso_3166_2 =~ /^[A-Z]{2}-[A-Z0-9]+$/;
}

sub is_valid_iso_3166_3
{
    my $iso_3166_3 = shift;
    return $iso_3166_3 =~ /^[A-Z]{4}$/;
}

sub is_valid_partial_date
{
    my ($year, $month, $day) = @_;

    if (defined $month) {
        return 0 unless is_positive_integer($month) && $month <= 12;
    }

    if (defined $day) {
        return 0 unless is_positive_integer($day) && $day <= 31;
    }

    if (defined $month && $day) {
        return 0 if $day > 29 && $month == 2;
        return 0 if $day > 30 && any { $_ == $month } (4, 6, 9, 11);
    }

    if (defined $year) {
        return 0 unless is_integer($year);
    }

    if (defined $year && $month && $day
        && $month == 2 && $day == 29)
    {
        return 0 unless $year % 4 == 0;
        return 0 if $year % 100 == 0 && $year % 400 != 0;
    }

    if (defined $year && $month && $day) {
        # XXX retain legacy behaviour for now:
        # partial dates with year <= 0 are OK, but complete dates are not (don't ask)
        return 0 unless $year > 0;
    }

    return 1;
}

# Keep in sync with invalidEditNote in static/scripts/release-editor/init.js
sub is_valid_edit_note
{
    my $edit_note = shift;

    # An edit note with only spaces and / or punctuation is useless
    return 0 if $edit_note =~ /^[[:space:][:punct:]]+$/;

    # An edit note with just one ASCII character is useless
    # A one-character Japanese note (for example) might be useful, so limited to ASCII 
    return 0 if $edit_note =~ /^[[:ascii:]]$/;

    return 1;
}

################################################################################
# Our own Mason "escape" handler
################################################################################

# HTML-encoding, but only on the listed "unsafe" characters.  Specifically,
# don't (incorrectly) encode top-bit-set characters as &Atilde; and the like.

# Hmmm.  For some reason HTML::Entities just wasn't kicking in here like it is
# meant to - it just left the string untouched.  So, since we only need a nice
# simple, fixed, substitution, we'll do it ourselves.  Ugh.

my %ent = ( '>' =>  '&gt;', '<' => '&lt;', q/"/ => '&quot;', q/'/ => '&#39;', '&' => '&amp;');
sub encode_entities
{
    my $t = $_[0];
    $t =~ s/([<>"'&])/$ent{$1}/go;
    $t;
}

sub normalise_strings
{
    my @r = map {
        my $t = $_;

        # Using lc() on U+0130 LATIN CAPITAL LETTER I WITH DOT ABOVE turns it into U+0069 LATIN SMALL LETTER I
        # and U+0307 COMBINING DOT ABOVE which causes problems later, so remove that before using lc().
        # U+0131 LATIN SMALL LETTER DOTLESS I is not handled by the unaccent code, so replace that too while we're at it.
        $t =~ tr/\x{0130}\x{0131}/i/;

        # Normalise to lower case
        $t = lc $t;

        # Remove leading and trailing space
        $t =~ s/\A\s+//;
        $t =~ s/\s+\z//;

        # Compress whitespace
        $t =~ s/\s+/ /g;

        # Quotation marks and apostrophes
        # 0060 grave accent, 00B4 acute accent, 00AB <<, 00BB >>, 02BB modifier letter turned comma (for Hawaiian)
        # 05F3 hebrew geresh, 05F4 hebrew gershayim
        # 2018 left single quote, 2019 right single quote, 201A low-9 single quote, 201B high-reversed-9 single quote
        # 201C left double quote, 201D right double quote, 201E low-9 double quote, 201F high-reversed-9 double quote
        # 2032 prime, 2033 double prime, 2039 <, 203A >
        $t =~ tr/"\x{0060}\x{00B4}\x{00AB}\x{00BB}\x{02BB}\x{05F3}\x{05F4}\x{2018}-\x{201F}\x{2032}\x{2033}\x{2039}\x{203A}/'/;

        # Dashes
        # 05BE Hebrew maqaf, 2010 hyphen, 2012 figure dash, 2013 en-dash, 2014 em-dash, 2015 horizontal bar, 2212 minus
        $t =~ tr/\x{05BE}\x{2010}\x{2012}\x{2013}\x{2014}\x{2015}\x{2212}/-/;

        # Horizontal three-dots ellipses
        # 2026 horizontal ellipsis,
        # 22EF midline horizontal ellipsis
        $t =~ s/[\x{2026}\x{22EF}]/.../g;

        # Unaccent what's left
        decode('utf-16', unaccent_utf16(encode('utf-16', $t)));
    } @_;

    wantarray ? @r : $r[-1];
}

sub is_nat {
    my $n = shift;
    return looks_like_number($n) && int($n) == $n && $n >= 0;
}

sub degree {
    my ($degrees, $dir) = @_;
    return dms($degrees, 0, 0, $dir);
}

sub dms {
    my ($degrees, $minutes, $seconds, $dir) = @_;
    $degrees =~ s/,/./;
    $minutes =~ s/,/./;
    $seconds =~ s/,/./;

    return
        # Anything over 4 decimal points is more than enough precision.
        # Google Maps uses 6, so it seems like a good thing to set the max at.
        sprintf('%.6f', ((0+$degrees) + ((0+$minutes) * 60 + (0+$seconds)) / 3600) * direction($dir))
        + 0; # remove trailing zeroes (MBS-7438)
}

my %DIRECTIONS = ( n => 1, s => -1, e => 1, w => -1 );
sub direction { $DIRECTIONS{lc(shift() // '')} // 1 }

sub swap {
    my ($direction_lat, $direction_long, $lat, $long) = @_;

    $direction_lat //= 'n';
    $direction_long //= 'e';

    # We expect lat/long, but can support long/lat
    if (lc $direction_lat eq 'e' || lc $direction_lat eq 'w' ||
        lc $direction_long eq 'n' || lc $direction_long eq 's') {
        return ($long, $lat);
    }
    else {
        return ($lat, $long);
    }
}

sub validate_coordinates {
    my $coordinates = shift;

    if ($coordinates =~ /^\s*$/) {
        return undef;
    }

    my $separators = '\s?,?\s?';
    my $number_part = q{[0-9]+(?:[\.,][0-9]+)?};

    $coordinates =~ tr/　．０-９/ .0-9/; # replace fullwidth characters with normal ASCII
    $coordinates =~ s/(北|南)緯\s*(${number_part})度\s*(${number_part})分\s*(${number_part})秒${separators}(東|西)経\s*(${number_part})度\s*(${number_part})分\s*(${number_part})秒/$2° $3' $4" $1, $6° $7' $8" $5/;
    $coordinates =~ tr/北南東西/NSEW/; # replace CJK direction characters

    my $degree_markers = q{°d};
    my $minute_markers = q{′'};
    my $second_markers = q{"″};

    my $decimalPart = '([+\-]?'.$number_part.')\s?['. $degree_markers .']?\s?([NSEW]?)';
    if ($coordinates =~ /^${decimalPart}${separators}${decimalPart}$/i) {
        my ($lat, $long) = swap($2, $4, degree($1, $2), degree($3, $4));
        return {
            latitude => $lat,
            longitude => $long
        };
    }

    my $dmsPart = '(?:([+\-]?'.$number_part.')[:'.$degree_markers.']\s?' .
                  '('.$number_part.')[:'.$minute_markers.']\s?' .
                  '(?:('.$number_part.')['.$second_markers.']?)?\s?([NSEW]?))';
    if ($coordinates =~ /^${dmsPart}${separators}${dmsPart}$/i) {
        my ($lat, $long) = swap($4, $8, dms($1, $2, $3 // 0, $4), dms($5, $6, $7 // 0, $8));

        return {
            latitude  => $lat,
            longitude => $long
        };
    }

    return undef;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2000 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
