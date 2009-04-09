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
{ our @ISA = qw( Exporter ); our @EXPORT_OK = qw( encode_entities unaccent ) }

use strict;
use Encode qw( decode encode );
use Text::Unaccent qw( unac_string );
use Date::Calc qw( check_date Delta_YMD );
use Carp qw( carp cluck croak );

#TODO: Do we still need this?
#sub new
#{
#    my $class = shift;
#    bless {}, ref($class) || $class;
#}

################################################################################
# Validation and sanitisation section
################################################################################

sub IsNonEmptyString
{
	my $t = shift;
	defined($t) and $t ne "";
}


sub IsNonNegInteger
{
	my $t = shift;
	defined($t) and not ref($t) and $t =~ /\A(\d{1,20})\z/;
}

sub IsSingleLineString
{
	my $t = shift;
	defined($t) and not ref($t) or return undef;

	use Encode qw( decode FB_CROAK );
	my $s = eval { decode("utf-8", $t, FB_CROAK) };
	return undef if $@;

	$s =~ /\A([^\x00-\x1F]*)\z/;
}

sub IsGUID
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

sub TrimInPlace
{
	carp "Uninitialized value passed to TrimInPlace"
		if grep { not defined } @_;
	for (@_)
	{
		$_ = "" if not defined;
		# TODO decode, trim, encode?
		s/\A\s+//;
		s/\s+\z//;
		s/\s+/ /;
	}
}

# Create a date string if the parameters are valid, or return undef.
# For inserting dates into the database.
sub MakeDBDateStr
{
	my ($year, $month, $day) = @_;

	# initialize undef values to ''
	defined or $_ = '' foreach $year, $month, $day;

	return undef if $year eq '' and $month eq '' and $day eq '';

	return sprintf('%04d-%02d-%02d', $year, $month, $day)
		if IsValidDate($year, $month, $day);

	return undef;
}

sub MakeDisplayDateStr
{
	my $str = shift;

	return '' unless defined $str and $str ne '';

	my ($year, $month, $day) = split m/-/, $str;

	# disable warning when $day, $month or $year are non-numeric
	no warnings 'numeric';
	if (defined $day && 0+$day)
	{
		return sprintf('%04d-%02d-%02d', $year, $month, $day);
	}
	elsif (defined $month && 0+$month)
	{
		return sprintf('%04d-%02d', $year, $month);
	}
	elsif (defined $year && 0+$year)
	{
		return sprintf('%04d', $year);
	}
	else
	{
		return '';
	}
}

sub IsValidDateOrEmpty
{
	my ($year, $month, $day) = @_;

	return (wantarray ? ('', '', '') : 1) if $year eq '' and $month eq '' and $day eq '';

	return IsValidDate($year, $month, $day);
}

# Dave's obscure date checker
sub IsValidDate
{
	my ($y, $m, $d) = @_;

	defined() or $_ = "" for ($y, $m, $d);
	MusicBrainz::Server::Validation::TrimInPlace($y, $m, $d);
	$_ eq "" or MusicBrainz::Server::Validation::IsNonNegInteger($_) or return
		for ($y, $m, $d);

	# All valid dates have a year
	return unless $y ne "" and $y >= 1000 and $y <= 2100;

	# Month is either missing ...
	$d = "", goto OK if $m eq "";
	# ... or must be valid
	return unless $m >= 1 and $m <= 12;

	# Day is either missing ...
	goto OK if $d eq "";
	# ... or must be valid
	return unless check_date($y, $m, $d);

OK:
	return (wantarray ? ($y, $m, $d) : 1);
}

sub IsDateEarlierThan
{
    my ($y1, $m1, $d1, $y2, $m2, $d2) = @_;

    return unless IsValidDate($y1, $m1, $d1) and IsValidDate($y2, $m2, $d2);

    ($m1, $m2, $d1, $d2) = (1, 1, 1, 1) if ($m1 eq '' || $m2 eq '');
    ($d1, $d2) = (1, 1) if ($d1 eq '' || $d2 eq '');

    my ($days) = Date::Calc::Delta_Days($y1, $m1, $d1, $y2, $m2, $d2);

    return $days > 0;
}

sub IsValidLabelCode
{
	my $t = shift;
	defined($t) and not ref($t) and $t =~ /\A(\d{1,5})\z/;
}

sub MakeDisplayLabelCode
{
	my $labelcode = shift;
	return sprintf("LC-%05d", $labelcode)
}

sub IsValidBarcode
{
	my $barcode = shift;
	return $barcode =~ /[^0-9]/;
}

sub IsValidEAN
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

# This wrapper will prevent us from having the stupid patched version of the Text::Unaccent library
# which in turn will make the mb_server install process simpler.
sub unaccent($) 
{
    my $str = shift;

    return ( defined $str ? unac_string('UTF-8', ''.$str) : '' );
}

sub NormaliseSortText
{
	lc decode('utf-8', unaccent(shift));
}
*NormalizeSortText = \&NormaliseSortText;

sub normalize
{
    my $t = $_[0];                 # utf8-bytes
    $t = decode "utf-8", $t;       # turn into string
    $t =~ s/[^\p{IsAlpha}]+/ /g;   # turn non-alpha to space
    $t =~ s/\s+/ /g;               # squish
    $t = encode "utf-8", $t;       # turn back into utf8-bytes
    $t;
}

sub OrdinalNumberSuffix
{
	my ($d, $n);
 	$n = shift;
	$d = int(($n % 100) / 10);
	return "th" if ($d == 1);
	$d = $n % 10;
	return "st" if ($d == 1);
	return "nd" if ($d == 2);
	return "rd" if ($d == 3);
	return "th";
}

# Append some data to a file.  Create the file if necessary.

use Fcntl 'LOCK_EX';
sub SimpleLog
{
	my ($file, $data) = @_;
	return if $data eq "";
	open(my $fh, ">>", $file) or return;
	flock($fh, LOCK_EX) or return;
	print $fh $data or return;
	close $fh;
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
	${ $_[0] } =~ s/([<>"'&])/$ent{$1}/go, return
		if not defined wantarray;
	my $t = $_[0];
	$t =~ s/([<>"'&])/$ent{$1}/go;
	$t;
}

1;
# eof Validation.pm
