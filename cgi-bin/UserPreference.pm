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
		$name =~ s[\s*/\s*][ / ]g;

		push @posix_zones, [ $_, $offset ? "$offset $name" : $name ];
	};

	# Find files using the shell.  This is to avoid loading File::Find,
	# which seems to be a "fat" module.
	if (open(my $pipe, "-|", "find", $tzdir."/posix", "-print0"))
	{
		local $/ = chr(0);
		while(defined(my $found = <$pipe>))
		{
			chomp $found;
			local $_ = $found;
			lstat $_;
			&$sub($found);
		}
		close $pipe;
	}

	push @allowed_timezones, sort { $a->[1] cmp $b->[1] } @posix_zones;
}

sub allowed_timezones { @allowed_timezones }

sub allowed_amazon_stores { &DBDefs::AWS_ASSOCIATE_ID(), "use the same store as the cover art" }

{
	# From http://www.google.com/language_tools?hl=en , and google.com added
	# since it didn't seem to be in that list.
	our @allowed_google_domains = qw(
www.google.ae
www.google.as
www.google.at
www.google.az
www.google.be
www.google.bi
www.google.ca
www.google.cd
www.google.cg
www.google.ch
www.google.ci
www.google.cl
www.google.co.cr
www.google.co.hu
www.google.co.il
www.google.co.in
www.google.co.je
www.google.co.jp
www.google.co.kr
www.google.co.ls
www.google.co.nz
www.google.co.th
www.google.co.uk
www.google.co.ve
www.google.com
www.google.com.ag
www.google.com.ar
www.google.com.au
www.google.com.br
www.google.com.co
www.google.com.cu
www.google.com.do
www.google.com.ec
www.google.com.fj
www.google.com.gi
www.google.com.gr
www.google.com.hk
www.google.com.ly
www.google.com.mt
www.google.com.mx
www.google.com.my
www.google.com.na
www.google.com.nf
www.google.com.ni
www.google.com.np
www.google.com.pa
www.google.com.pe
www.google.com.ph
www.google.com.pk
www.google.com.pr
www.google.com.py
www.google.com.ru
www.google.com.sg
www.google.com.sv
www.google.com.tr
www.google.com.tw
www.google.com.ua
www.google.com.uy
www.google.com.vc
www.google.com.vn
www.google.de
www.google.dj
www.google.dk
www.google.es
www.google.fi
www.google.fm
www.google.fr
www.google.gg
www.google.gl
www.google.gm
www.google.hn
www.google.ie
www.google.it
www.google.kz
www.google.li
www.google.lt
www.google.lu
www.google.lv
www.google.ms
www.google.mu
www.google.mw
www.google.nl
www.google.off.ai
www.google.pl
www.google.pn
www.google.pt
www.google.ro
www.google.rw
www.google.se
www.google.sh
www.google.sk
www.google.sm
www.google.td
www.google.tt
www.google.uz
www.google.vg
	);
	sub allowed_google_domains { @allowed_google_domains }
}

################################################################################
# Set up the list of valid preferences
################################################################################

our %prefs = ();

# Alphabetical order please
addpref('autofix_open', "remember", sub { check_in([qw( remember 1 0 )], @_) });
addpref('css_noentityicons', 0, \&check_bool);
addpref('css_nosmallfonts', 0, \&check_bool);
addpref('datetimeformat', $allowed_datetime_formats[0], \&check_datetimeformat);
addpref('default_country', 0, sub { check_int(0,undef,@_) });
addpref('google_domain', "www.google.com", \&check_google_domain);
addpref('JSCollapse', '1', \&check_bool);
addpref('JSDebug', '0', \&check_bool);
addpref('JSDiff', '1', \&check_bool);
addpref('JSMoveFocus', '1', \&check_bool);
addpref('mail_notes_if_i_noted', 1, \&check_bool);
addpref('mail_notes_if_i_voted', 1, \&check_bool);
addpref('mail_on_first_no_vote', 1, \&check_bool);
addpref('mod_add_album_inline', 0, \&check_bool);
addpref('mod_add_album_link', 0, \&check_bool);
addpref('mods_per_page', 10, sub { check_int(1,25,@_) });
addpref('navbar_mod_show_select_page', 0, \&check_bool);
addpref('nosidebar', 0, \&check_bool);
addpref('show_ratings', 1, \&check_bool);
addpref('no_sidebar_panels', 0, \&check_bool);
addpref('release_show_annotationlinks', 0, \&check_bool);
addpref('release_show_relationshipslinks', 0, \&check_bool);
addpref('releases_show_compact', 50, sub { check_int(1,100,@_) });
addpref('remove_recent_link_on_add', 1, \&check_bool);
addpref('reveal_address_when_mailing', 0, \&check_bool);
addpref('sendcopy_when_mailing', 0, \&check_bool);
addpref('show_amazon_coverart', 1, \&check_bool);
addpref('sidebar_panel_search', 1, \&check_bool);
addpref('sidebar_panel_sites', 1, \&check_bool);
addpref('sidebar_panel_stats', 1, \&check_bool);
addpref('sidebar_panel_topmods', 1, \&check_bool);
addpref('sidebar_panel_user', 1, \&check_bool);
addpref('sitemenu_heavy', 0, \&check_bool);
addpref('show_inline_mods', 0, \&check_bool);
addpref('show_inline_mods_random', 0, \&check_bool);
addpref('subscriptions_public', 1, \&check_bool);
addpref('tags_public', 1, \&check_bool);
addpref('ratings_public', 1, \&check_bool);
addpref('timezone', 'UTC', \&check_timezone);
addpref('topmenu_submenu_types', 'both', sub { check_in([qw( both dropdownonly staticonly )], @_) });
addpref('topmenu_dropdown_trigger', 'mouseover', sub { check_in([qw( mouseover click )], @_) });
addpref('use_amazon_store', 'amazon.com', \&check_amazon_store);
addpref('vote_abs_default', 0, \&check_bool);
addpref('auto_subscribe', 0, \&check_bool);
addpref('email_notify_release', 1, \&check_bool);

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

sub check_amazon_store
{
	my $value = shift;

	$_ eq $value and return $value
		for allowed_amazon_stores();
	undef;
}

sub check_google_domain
{
	my $value = shift;

	$_ eq $value and return $value
		for allowed_google_domains();
	undef;
}

sub check_in
{
	my ($values, $value) = @_;
	$_ eq $value and return $value
		for @$values;
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

	require UserStuff;
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

	require UserStuff;
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

	require UserStuff;
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

	require UserStuff;
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

################################################################################
# get another user's preference
################################################################################

sub get_for_user
{
	my ($key, $user) = @_;
	my $info = $prefs{$key}
		or carp("UserPreference::get called with invalid key '$key'"), return undef;

	my $sql = Sql->new($user->{DBH});
	my $value = $sql->SelectSingleValue(
		"SELECT value FROM moderator_preference WHERE moderator = ? AND name = ?",
		$user->GetId,
		$key,
	);

	defined($value) or return $info->{DEFAULT};
	$value;
}

1;
# eof UserPreference.pm
