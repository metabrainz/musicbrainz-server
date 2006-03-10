#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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
#   $Id$
#____________________________________________________________________________

use 5.008;
no warnings qw( portable );

package MusicBrainz;

require Exporter;
{ our @ISA = qw( Exporter ); our @EXPORT_OK = qw( encode_entities ) }

use strict;
use DBDefs;
use MusicBrainz::Server::Cache;
use MusicBrainz::Server::Replication ':replication_type';
use Carp qw( carp cluck croak );
use Encode qw( decode );
use Text::Unaccent qw( unac_string );
use Date::Calc qw( check_date Delta_YMD );

sub new
{
    my $class = shift;
    bless {}, ref($class) || $class;
}

################################################################################
# Database connect / disconnect
################################################################################

sub Login
{
	my ($this, %opts) = @_;

	my $db = $opts{'db'};

	{
		last if $db;

		$db = $MusicBrainz::db;
		last if $db;

		{
			$INC{'Apache.pm'} or last;
			my $r = Apache->request or last;
			$db = $r->dir_config->get("MBDatabase");
		}
		last if $db;
	}

	$db = (&DBDefs::REPLICATION_TYPE == RT_SLAVE ? "READONLY" : "READWRITE")
		if not defined $db;

	if (not ref($db) and $db =~ /,/)
	{
		our %round_robin;
		my $arr = ($round_robin{$db} ||= [ split /,/, $db ]);
		$db = shift @$arr;
		push @$arr, $db;
	}

	unless (ref $db)
	{
		$db = MusicBrainz::Server::Database->get($db)
			or croak "No such database '$db'";
	}

   require DBI;
   $this->{DBH} = DBI->connect($db->dbi_args);
   return 0 if (!$this->{DBH});

	# Naughty!  Might break in future.  If it does just do the two "SET"
	# commands every time, like we used to before this was added.
	my $tied = tied %{ $this->{DBH} };
	if (not $tied->{'_mb_prepared_connection_'})
	{
		require Sql;
		my $sql = Sql->new($this->{DBH});

		$sql->AutoCommit(1);
		$sql->Do("SET TIME ZONE 'UTC'");
		$sql->AutoCommit(1);
		$sql->Do("SET CLIENT_ENCODING = 'UNICODE'");

		$tied->{'_mb_prepared_connection_'} = 1;
	}

   return 1;
}

# Logout and DESTROY are pointless under Apache::DBI (since ->disconnect does
# nothing).  But it does do something under normal DBI (e.g. under cron).

sub Logout
{
   my ($this) = @_;

   $this->{DBH}->disconnect() if ($this->{DBH});
}

sub DESTROY
{
    shift()->Logout;
}

################################################################################
# Validation and sanitisation section
################################################################################

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

	$t =~ /\A([^\x00-\x1F]*)\z/;
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
	if (0+$day)
	{
		return sprintf('%04d-%02d-%02d', $year, $month, $day);
	}
	elsif (0+$month)
	{
		return sprintf('%04d-%02d', $year, $month);
	}
	elsif (0+$year)
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

	return 1 if $year eq '' and $month eq '' and $day eq '';

	return IsValidDate($year, $month, $day);
}

# Dave's obscure date checker
sub IsValidDate
{
	my ($y, $m, $d) = @_;

	defined() or $_ = "" for ($y, $m, $d);
	MusicBrainz::TrimInPlace($y, $m, $d);
	$_ eq "" or MusicBrainz::IsNonNegInteger($_) or return
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

    return 1 unless IsValidDate($y1, $m1, $d1) and IsValidDate($y2, $m2, $d2);

    ($m1, $m2, $d1, $d2) = (1, 1, 1, 1) if ($m1 eq '' || $m2 eq '');
    ($d1, $d2) = (1, 1) if ($d1 eq '' || $d2 eq '');

    my ($days) = Date::Calc::Delta_Days($y1, $m1, $d1, $y2, $m2, $d2);

    return 0 if ($days < 0);
    return 1;
}

sub NormaliseSortText
{
	lc decode('utf-8', unac_string('UTF-8', shift));
}
*NormalizeSortText = \&NormaliseSortText;

sub normalize
{
    my $t = $_[0];
    $t =~ s/[^\w\d ]/ /g;
    $t =~ s/ +/ /g;
    $t;
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
# eof MusicBrainz.pm
