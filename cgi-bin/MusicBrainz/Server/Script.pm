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

package MusicBrainz::Server::Script;

use base qw( TableBase );
use Carp;
use Encode qw( decode );

# GetId / SetId - see TableBase
# GetName / SetName - see TableBase
sub GetISOCode		{ $_[0]{isocode} }
sub GetISONumber	{ $_[0]{isonumber} }

sub _GetIdCacheKey
{
	my ($class, $id) = @_;
	"script-id-" . int($id);
}

sub _GetAllCacheKey
{
	"script-all";
}

# Fetch a Script given its primary key.  Returns either a single Script
# object, or undef.

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $key = $self->_GetIdCacheKey($id);
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->{DBH} = $self->{DBH} if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($self->{DBH});

	$obj = $self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM script WHERE id = ?",
			$id,
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{DBH} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	$obj->{DBH} = $self->{DBH} if $obj;

	return $obj;
}

# Return the list of all script objects, ordered by (English) name.
# Optionally you can also specify "minimum_frequency = $n".  This can be used
# to retrieve just the "most common" scripts.

sub All
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my %opts = @_;
	my $minfreq = $opts{'minimum_frequency'};
	my $include = $opts{'include'};

	my $key = $self->_GetAllCacheKey;
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		@$obj = grep { $_->{frequency} >= $minfreq or $_->{id} == $include } @$obj
			if defined $minfreq;
		$_->{DBH} = $self->{DBH} for @$obj;
		return @$obj;
	}

	my $sql = Sql->new($self->{DBH});

	# TODO fix sorting (case-insensitive, etc)
	my @list = map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM script ORDER BY name",
			),
		};

	# We can't store DBH in the cache...
	delete $_->{DBH} for @list;
	MusicBrainz::Server::Cache->set($key, \@list);
	$_->{DBH} = $self->{DBH} for @list;

	@list = grep { $_->{frequency} >= $minfreq or $_->{id} == $include } @list
		if defined $minfreq;
	return @list;
}

# Get script by ISO code.  Always returns either a single Script object,
# or undef.

sub newFromISOCode   { my $class = shift; return $class->_newFromISOCode("isocode", @_) }
sub newFromISONumber { my $class = shift; return $class->_newFromISOCode("isonumber", @_) }

sub _newFromISOCode
{
	my $self = shift;
	my $column = shift;
	$self = $self->new(shift) if not ref $self;
	my $value = shift;

	no warnings 'uninitialized';
	return undef if $value eq "";

	# TODO avoid fetching the whole list every time
	for my $script ($self->All)
	{
		return $script if $script->{$column} eq $value;
	}

	return undef;
}

################################################################################

# Given an array of text strings (e.g. track names), try to guess what script
# it might be in.  Return either a Script object, or undef.

sub GuessFromText
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $textlist = shift;

	my $alltext = join "\n",
		map { decode "utf-8", $_ }
		@$textlist;

	use Unicode::UCD qw( charscript );
	my %t;
	for my $c ($alltext =~ /(\w)/g)
	{
		my $s = charscript(ord($c));
		++$t{$s} if $s;
	}

	my $max = 0; my $ans = "";
	while (my ($script, $score) = each %t)
	{
		$max = $score, $ans = $script if $score > $max;
	}
	$ans or return undef;

	my ($code) = <<EOF =~ /^$ans=(\w+)/m;
Arabic=Arab
Armenian=Armn
Bengali=Beng
Bopomofo=Bopo
Buhid=Buhd
Canadian_aboriginal=Cans
Cherokee=Cher
Cyrillic=Cyrl
Devanagari=Deva
Ethiopic=Ethi
Georgian=Geor
Greek=Grek
Gujarati=Gujr
Gurmukhi=Guru
Han=Hani/Hans/Hant
Hangul=Hang
Hanunoo=Hano
Hebrew=Hebr
Hiragana=Hira
# Inherited=?
Kannada=Knda
Katakana=Kana
Khmer=Khmr
Lao=Laoo
Latin=Latn
Malayalam=Mlym
Mongolian=Mong
Myanmar=Mymr
Ogham=Ogam
Oriya=Orya
Runic=Runr
Sinhala=Sinh
Syriac=Syrc
Tagalog=Tglg
Tagbanwa=Tagb
Tamil=Taml
Telugu=Telu
Thaana=Thaa
Thai=Thai
Tibetan=Tibt
EOF

	$code or return undef;
	return $self->newFromISOCode($code);
}


################################################################################

#
# UI support code
#


# Same interface as All(), but returns a list of scripts as [ id, name ]
# including the "Don't know" script.
#

sub Menu
{
	my @scripts = All(@_);
	
	my @menu = map {
		[ $_->GetId(), $_->GetName() ]
	} @scripts;

	unshift @menu, [ '', "I don't know" ];

	return @menu;
}

1;
# eof Script.pm
