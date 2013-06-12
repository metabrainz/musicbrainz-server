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
        is_valid_iso_3166_1
        is_valid_iso_3166_2
        is_valid_iso_3166_3
        encode_entities
        normalise_strings
    )
}

use strict;
use Encode qw( decode encode );
use Date::Calc qw( check_date Delta_YMD );
use Carp qw( carp cluck croak );
use Text::Unaccent qw( unac_string_utf16 );

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

sub is_valid_isrc
{
    my $isrc = $_[0];
    return $isrc =~ /[A-Z]{2}[A-Z0-9]{3}[0-9]{7}/;
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
        # Normalise to lower case
        my $t = lc $_;

        # Remove leading and trailing space
        $t =~ s/\A\s+//;
        $t =~ s/\s+\z//;

        # Compress whitespace
        $t =~ s/\s+/ /g;

        # So-called smart quotes; in reality, a backtick and an acute accent.
        # Also double-quotes and angled double quotes.
        $t =~ tr/\x{0060}\x{00B4}"\x{00AB}\x{00BB}/'/;

        # Unaccent what's left
        decode("utf-16", unaccent_utf16(encode("utf-16", $t)));
    } @_;

    wantarray ? @r : $r[-1];
}

1;
# eof Validation.pm
