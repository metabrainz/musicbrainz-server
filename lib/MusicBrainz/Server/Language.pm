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

package MusicBrainz::Server::Language;

use base qw( TableBase );
use Carp;
use Encode qw( decode );

# id / id - see TableBase
# name / name - see TableBase
sub iso_code_3t { $_[0]{isocode_3t} }
sub iso_code_3b { $_[0]{isocode_3b} }
sub iso_code_2  { $_[0]{isocode_2} }

sub _id_cache_key
{
	my ($class, $id) = @_;
	"language-id-" . int($id);
}

sub _GetAllCacheKey
{
	"language-all";
}

# Fetch a Language given its primary key.  Returns either a single Language
# object, or undef.

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $key = $self->_id_cache_key($id);
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->SetDBH($self->GetDBH) if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($self->GetDBH);

	$obj = $self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM language WHERE id = ?",
			$id,
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{DBH} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	$obj->SetDBH($self->GetDBH) if $obj;

	return $obj;
}

# Return the list of all language objects, ordered by (English) name.
# Optionally you can also specify "minimum_frequency = $n".	 This can be used
# to retrieve just the "most common" languages.

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
		@$obj = grep { $_->{frequency} >= $minfreq or $_->{id} == $include  } @$obj
			if defined $minfreq;
		$_->SetDBH($self->GetDBH) for @$obj;
		return @$obj;
	}

	my $sql = Sql->new($self->GetDBH);

	# TODO fix sorting (case-insensitive, etc)
	my @list = map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM language ORDER BY name",
			),
		};

	# We can't store DBH in the cache...
	delete $_->{DBH} for @list;
	MusicBrainz::Server::Cache->set($key, \@list);
	$_->SetDBH($self->GetDBH) for @list;

	@list = grep { $_->{frequency} >= $minfreq or $_->{id} == $include } @list
		if defined $minfreq;
	return @list;
}

# Get language by ISO code.	 Always returns either a single Language object,
# or undef.

sub newFromISOCode3T { my $class = shift; return $class->_newFromISOCode("isocode_3t", @_) }
sub newFromISOCode3B { my $class = shift; return $class->_newFromISOCode("isocode_3b", @_) }
sub newFromISOCode2	 { my $class = shift; return $class->_newFromISOCode("isocode_2",  @_) }

sub _newFromISOCode
{
	my $self = shift;
	my $column = shift;
	$self = $self->new(shift) if not ref $self;
	my $value = shift;

	no warnings 'uninitialized';
	return undef if $value eq "";

	# TODO avoid fetching the whole list every time
	for my $lang ($self->All)
	{
		return $lang if $lang->{$column} eq $value;
	}

	return undef;
}

################################################################################

# Given a script and an array of text strings (e.g. track names), try to guess
# what language it might be in.	 Return either a Language object, or undef.

our $guesser;

sub GuessFromTextAndScript
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $textlist = shift;
	my $script = shift;

	$guesser ||= eval {
		require Language::Guess;
		return Language::Guess->new(
			modeldir => &DBDefs::MB_SERVER_ROOT . "/data/language-guess",
		);
	} or print(STDERR "Error: $@\n"), return undef;

	my $line = decode "utf-8", join "\n", @$textlist;
	my $lang = $guesser->simple_guess($line);
	$lang or return undef;

	my ($code) = <<EOF =~ /^ (\w+) \s+ $lang $/mix;

# The *.train files
sqi	albanian
ara	arabic
aze	azeri
ben	bengali
bul	bulgarian
ceb	cebuano
hrv	croatian
ces	czech
dan	danish
nld	dutch
eng	english
est	estonian
	farsi
fin	finnish
fra	french
deu	german
hau	hausa
haw	hawaiian
hin	hindi
hun	hungarian
isl	icelandic
ind	indonesian
ita	italian
kaz	kazakh
tlh	klingon
	kyrgyz
lat	latin
lav	latvian
lit	lithuanian
mkd	macedonian
mon	mongolian
nep	nepali
nor	norwegian
	pashto
cpe	pidgin
	pig_latin
pol	polish
por	portuguese
ron	romanian
rus	russian
srp	serbian
slk	slovak
slv	slovene
som	somali
spa	spanish
swa	swahili
swe	swedish
tgl	tagalog
tur	turkish
ukr	ukrainian
ukr	ukranian
urd	urdu
uzb	uzbek
vie	vietnamese
cym	welsh

# The non-trained scripts
kor	korean
ell	greek
jpn	japanese
zho	chinese

EOF
	$code or return undef;

	return $self->newFromISOCode3T($code);
}


################################################################################

#
# UI support code
#


# Same interface as All(), but returns a list of languages as [ id, name ]
# including the "Don't know" language.
#

sub Menu
{
	my @languages = All(@_);
	
	my @menu = map {
		[ $_->id(), $_->name() ]
	} @languages;

	unshift @menu, [ '', "I don't know" ];

	return @menu;
}

1;
# eof Language.pm
