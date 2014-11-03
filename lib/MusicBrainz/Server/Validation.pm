#!/usr/local/perl58/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id: MusicBrainz.pm 8398 2006-08-13 01:45:27Z nikki $
#____________________________________________________________________________

use 5.008;
no warnings qw( portable );

package MusicBrainz::Server::Validation;

require Exporter;
{
    our @ISA = qw( Exporter );
    our @EXPORT_OK = qw(
        unaccent_utf16
        is_positive_integer
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
        is_valid_iso_3166_1
        is_valid_iso_3166_2
        is_valid_iso_3166_3
        is_valid_partial_date
        encode_entities
        normalise_strings
        is_nat
        validate_coordinates
    )
}

use strict;
use Carp qw( carp cluck croak );
use Date::Calc qw( check_date );
use Encode qw( decode encode );
use Scalar::Util qw( looks_like_number );
use Text::Unaccent qw( unac_string_utf16 );
use utf8;

sub unaccent_utf16 ($)
{
    my $str = shift;
    return ( defined $str ? unac_string_utf16(''.$str) : '' );
}

################################################################################
# Validation and sanitisation section
################################################################################

sub is_positive_integer
{
    my $t = shift;
    defined($t) and not ref($t) and $t =~ /\A(\d{1,20})\z/;
}

sub is_guid
{
    my $t = $_[0];
    defined($t) and not ref($t) or return undef;
    length($t) eq 36 or return undef;

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
    carp "Uninitialized value passed to trim_in_place"
        if grep { not defined } @_;
    for (@_)
    {
        $_ = "" if not defined;
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
    return $iswc =~ /^T-?\d{3}\.?\d{3}\.?\d{3}[-.]?\d$/;
}

sub format_iswc
{
    my $iswc = shift;
    $iswc =~ s/\s//g;
    $iswc =~ s/^T-?(\d{3})\.?(\d{3})\.?(\d{3})[-.]?(\d)/T-$1.$2.$3-$4/;
    return $iswc;
}

sub is_valid_ipi
{
    my $ipi = shift;
    return $ipi =~ /^\d{11}$/;
}

sub format_ipi
{
    my $ipi = shift;
    return $ipi unless $ipi =~ /^[\d\s.]{9,}$/;
    $ipi =~ s/[\s.]//g;
    return sprintf("%011.0f", $ipi)
}

sub is_valid_isni
{
    my $isni = shift;
    $isni =~ s/[\s\.-]//g;
    return $isni =~ /^\d{15}[\dX]$/;
}

sub format_isni
{
    my $isni = shift;
    $isni =~ s/[\s\.]//g;
    return $isni;
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

    # anything partial cannot be checked, and is therefore considered valid.
    return 1 unless (defined $year && $month && $day);

    return 1 if check_date($year, $month, $day);

    return 0;
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
        # 05BE Hebrew maqaf, 2010 hyphen, 2012 figure dash, 2013 en-dash, 2212 minus
        $t =~ tr/\x{05BE}\x{2010}\x{2012}\x{2013}\x{2212}/-/;

        # Unaccent what's left
        decode("utf-16", unaccent_utf16(encode("utf-16", $t)));
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
        sprintf("%.6f", ((0+$degrees) + ((0+$minutes) * 60 + (0+$seconds)) / 3600) * direction($dir))
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
    my $number_part = q{\d+(?:[\.,]\d+|)};

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
# eof Validation.pm
