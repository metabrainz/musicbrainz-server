#!/usr/bin/perl -w
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

use strict;

use UserStuff;

package UserPreference;

use Carp qw( carp );

################################################################################
# These subs are called from outside of this module.
################################################################################

our @allowed_datetime_formats = (
	'%Y-%m-%d %H:%M:%S %Z',
	'%c',
	'%x %X',
	'%X %x',
	'%A %B %e %Y, %H:%M',
	'%d %B %Y %H:%M:%S',
	'%a %b %e %Y, %H:%M',
	'%d %b %Y %H:%M:%S',
	'%d/%m/%Y %H:%M:%S',
	'%m/%d/%Y %H:%M:%S',
	'%d.%m.%Y %H:%M:%S',
	'%m.%d.%Y %H:%M:%S',
);

sub allowed_datetime_formats { @allowed_datetime_formats }

our @allowed_timezones = (
	[ "IDLW12"			=> "-1200 International Date Line West" ],
	#[ "NT"	=> "-1100 Nome" ],
	[ "HAST10HADT"		=> "-1000 Hawaii-Aleutian" ],
	[ "AKST9AKDT"		=> "-0900 Alaska" ],
	[ "PST8PDT"			=> "-0800 Pacific" ],
	[ "MST7MDT"			=> "-0700 Mountain" ],
	[ "CST6CDT"			=> "-0600 Central" ],
	[ "EST5EDT"			=> "-0500 Eastern" ],
	[ "AST4ADT"			=> "-0400 Atlantic" ],
	[ "NST03:30NDT"		=> "-0330 Newfoundland" ],
	[ "GST3GDT"			=> "-0300 Greenland" ],
	[ "AZOT2AZOST"		=> "-0200 Azores" ],
	[ "WAT1WAST"		=> "-0100 West Africa" ],
	[ "WET0WEST"		=> "+0000 Western European" ],
	[ "UTC"				=> "+0000 Universal Coordinated" ],
	[ "GMT0BST"			=> "+0000 Greenwich Mean (UK)" ],
	[ "CET-1CEST"		=> "+0100 Central European" ],
	[ "EET-2EEST"		=> "+0200 Eastern European" ],
	#[ "BT"				=> "+0300 Baghdad, USSR Zone 2" ],
	#[ "IT"				=> "+0330 Iran" ],
	#[ "ZP4"			=> "+0400 USSR Zone 3" ],
	#[ "ZP5"			=> "+0500 USSR Zone 4" ],
	[ "IST-05:30IDT"	=> "+0530 Indian" ],
	#[ "ZP6"			=> "+0600 USSR Zone 5" ],
	#[ "ZP7"			=> "+0700 USSR Zone 6" ],
	#[ "JT"				=> "+0730 Java" ],
	[ "AWST-8AWDT"		=> "+0800 Western Australian" ],
	#[ "CCT"			=> "+0800 China Coast, USSR Zone 7" ],
	[ "KST-9KDT"		=> "+0900 Korean" ],
	[ "JST-9JDT"		=> "+0900 Japan, USSR Zone 8" ],
	[ "ACST-09:30ACDT"	=> "+0930 Central Australian" ],
	[ "AEST-10AEDT"		=> "+1000 Eastern Australian" ],
	[ "Australia/Melbourne" => "+1100 Australia/Melbourne" ],
	[ "IDLE-12"			=> "+1200 International Date Line East" ],
	[ "NZST-12NZDT"		=> "+1200 New Zealand" ],
);

# Seed the allowed timezones list with files found in
# /usr/share/zoneinfo/posix - there must be an official way to do this!
{
	my $tzdir = "/usr/share/zoneinfo";

	my @posix_zones;
	my $sub = sub {
		-f $_ or return;
		s/^\Q$tzdir\E\///;

		my $offset = ""; # " ????";
		(my $name = $_) =~ tr/_/ /;
		$name =~ s/^posix\///;
		$name =~ s/\bEtc\b/etc/g;
		$name =~ s[\s*/\s*][ / ]g;

		push @posix_zones, [ $_, $offset ? "$offset $name" : $name ];
	};

	use File::Find qw( find );
	find({ wanted => $sub, no_chdir => 1 }, "$tzdir/posix")
		if -d $tzdir;
	push @allowed_timezones, sort { $a->[1] cmp $b->[1] } @posix_zones;
}

sub allowed_timezones { @allowed_timezones }

################################################################################
# Set up the list of valid preferences
################################################################################

our %prefs = ();

# Alphabetical order please
addpref('datetimeformat', $allowed_datetime_formats[0], \&check_datetimeformat);
addpref('default_country', 0, sub { check_int(0,undef,@_) });
addpref('JSMoveFocus', '1', \&check_bool);
addpref('mod_add_album_inline', 0, \&check_bool);
addpref('mod_add_album_link', 0, \&check_bool);
addpref('mods_per_page', 10, sub { check_int(1,25,@_) });
addpref('navbar_mod_show_select_page', 0, \&check_bool);
addpref('nosidebar', 0, \&check_bool);
addpref('no_sidebar_panels', 0, \&check_bool);
addpref('releases_show_compact', 50, sub { check_int(1,100,@_) });
addpref('reveal_address_when_mailing', 0, \&check_bool);
addpref('sidebar_panel_search', 1, \&check_bool);
addpref('sidebar_panel_stats', 1, \&check_bool);
addpref('sidebar_panel_topmods', 1, \&check_bool);
addpref('sitemenu_heavy', 0, \&check_bool);
addpref('timezone', 'UTC', \&check_timezone);
addpref('vote_abs_default', 1, \&check_bool);
addpref('vote_show_novote', 0, \&check_bool);

sub addpref
{
	my ($key, $defaultvalue, $checksub) = @_;

	defined($checksub->($defaultvalue))
		or warn "Default value '$defaultvalue' for preference '$key' is not valid";

	$prefs{$key} = {
		KEY		=> $key,
		DEFAULT	=> $defaultvalue,
		CHECK	=> $checksub,
	};
}

sub defaults_as_hashref
{
	+{
		map {
			($_->{KEY} => $_->{DEFAULT})
		} values %prefs
	};
}

sub valid_keys { keys %prefs }

################################################################################
# Value checkers.
# Each checker returns either 'undef' if the given value is not valid, or
# the value (or some normalised version of it) if it is vald.
################################################################################

sub check_bool { $_[0] ? 1 : 0 }

sub check_int
{
	my ($min, $max, $value) = @_;
	$value =~ /\A(\d+)\z/ or return undef;
	$value = 0+$1;
	return undef if defined $min and $value < $min;
	return undef if defined $max and $value > $max;
	$value;
}

sub check_datetimeformat
{
	my $value = shift;
	$_ eq $value and return $value
		for @allowed_datetime_formats;
	undef;
}

sub check_timezone
{
	my $value = shift;
	$_->[0] eq $value and return $value
		for @allowed_timezones;
	undef;
}

################################################################################
# get, set, load, save
################################################################################

sub get
{
	my ($key) = @_;
	my $info = $prefs{$key}
		or carp("UserPreference::get called with invalid key '$key'"), return undef;

	my $s = UserStuff->GetSession;
	my $value = $s->{"PREF_$key"};
	defined($value) or return $info->{DEFAULT};
	$value;
}

sub set
{
	my ($key, $value) = @_;
	my $info = $prefs{$key}
		or carp("UserPreference::set called with invalid key '$key'"), return;
	my $newvalue = $info->{CHECK}->($value);
	defined $newvalue
		or carp("UserPreference::set called with invalid value '$value' for key '$key'"), return;

	my $s = UserStuff->GetSession;
	tied %$s
		or carp("UserPreference::set called, but %session is not tied"), return;

	$s->{"PREF_$key"} = $newvalue;
}

sub LoadForUser
{
	my ($user) = @_;

	my $uid = $user->GetId
		or return;

	my $s = UserStuff->GetSession;
	tied %$s
		or carp("UserPreference::LoadFromUser called, but %session is not tied"), return;

	my $sql = Sql->new($user->{DBH});
	my $rows = $sql->SelectListOfLists(
		"SELECT name, value FROM moderator_preference WHERE moderator = ?",
		$uid,
	);

	for (@$rows)
	{
		my ($key, $value) = @$_;

		my $info = $prefs{$key}
			or warn("Moderator #$uid has invalid saved preference '$key'"), next;
		my $newvalue = $info->{CHECK}->($value);
		defined $newvalue
			or warn("Moderator #$uid has invalid saved value '$value' for preference '$key'"), next;

		$s->{"PREF_$key"} = $newvalue;
	}
}

sub SaveForUser
{
	my ($user) = @_;

	my $uid = $user->GetId
		or return;

	my $s = UserStuff->GetSession;
	tied %$s
		or carp("UserPreference::SaveForUser called, but %session is not tied"), return;

	my $sql = Sql->new($user->{DBH});
	my $wrap_transaction = $sql->{DBH}{AutoCommit};
	
	eval {
		$sql->Begin if $wrap_transaction;
		$sql->Do("DELETE FROM moderator_preference WHERE moderator = ?", $uid);

		while (my ($key, $value) = each %$s)
		{
			$key =~ s/^PREF_// or next;
			$sql->Do(
				"INSERT INTO moderator_preference (moderator, name, value) VALUES (?, ?, ?)",
				$uid, $key, $value,
			);
		}

		$sql->Commit if $wrap_transaction;
		1;
	} or do {
		my $e = $@;
		$sql->Rollback if $wrap_transaction;
		die $e;
	};
}

1;
# eof UserPreference.pm
