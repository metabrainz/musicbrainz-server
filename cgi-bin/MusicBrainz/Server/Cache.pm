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

use strict;

package MusicBrainz::Server::Cache;

use Carp qw( carp );

our $cache;

# Preload if possible
$cache = _new();

if ($cache and &DBDefs::CACHE_DEBUG)
{
	my @keys = $cache->get_keys;
	printf STDERR "Starting cache with %d entries\n", 0+@keys;
}

sub _new
{
	return $cache if $cache;

	eval {
		require Cache::SizeAwareFileCache;
		require Storable;
		Storable->import(qw( freeze thaw ));
		$cache = Cache::SizeAwareFileCache->new(&DBDefs::CACHE_OPTIONS);
	} or do {
		warn "Failed to create cache: $@"
			if $@ ne "";
	};

	$cache;
}

sub get
{
	my ($class, $key, @args) = @_;

	my $cache = $class->_new
		or return undef;

	my $data = $cache->get($key, @args);
	if (not $data)
	{
		carp "Cache MISS on $key" if &DBDefs::CACHE_DEBUG;
		return undef;
	}

	$data = thaw($data);
	if (&DBDefs::CACHE_DEBUG)
	{
		#use Data::Dumper;
		#local $Data::Dumper::Terse = 1;
		#my $d = Data::Dumper->Dump([ $data ],[ 'd' ]);
		#carp "Cache HIT ($d) on $key";

		if (not defined $data)
		{
			carp "Cache HIT (undef) on $key";
		} elsif (not ref $data) {
			carp "Cache HIT ($data) on $key";
		} elsif (ref($data) eq "REF") {
			carp "Cache HIT (\\$$data) on $key";
		} else {
			carp "Cache HIT ($data) on $key";
		}
	}
	$data;
}

sub set
{
	my ($class, $key, $data, @opts) = @_;
	my $cache = $class->_new
		or return undef;

	if (&DBDefs::CACHE_DEBUG)
	{
		#use Data::Dumper;
		#local $Data::Dumper::Terse = 1;
		#my $d = Data::Dumper->Dump([ $data ],[ 'd' ]);
		#carp "Cache HIT ($d) on $key";

		if (not defined $data)
		{
			carp "Cache SET (undef) on $key";
		} elsif (not ref $data) {
			carp "Cache SET ($data) on $key";
		} elsif (ref($data) eq "REF") {
			carp "Cache SET (\\$$data) on $key";
		} else {
			carp "Cache SET ($data) on $key";
		}
	}

	$data = freeze($data);
	$cache->set($key, $data, @opts);
}

sub remove
{
	my ($class, $key) = @_;
	my $cache = $class->_new
		or return undef;
	carp "Cache REMOVE $key" if &DBDefs::CACHE_DEBUG;
	$cache->remove($key);
}

# Only for debugging
sub get_keys
{
	my $class = shift;
	my $cache = $class->_new
		or return;
	$cache->get_keys(@_);
}

=pod

This module implements a Cache::Cache layer for MusicBrainz.  The layer implementing
the cache (e.g. File, MemCached, etc) is not known to the caller.  This layer only
supports get / set / remove / get_keys so far.

=cut

1;
# eof Cache.pm
