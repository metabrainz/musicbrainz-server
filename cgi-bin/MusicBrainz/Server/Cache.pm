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

package MusicBrainz::Server::Cache;

our $cache;

# Preload if possible
$cache = _new();

sub _new
{
	return $cache if $cache;

	eval {
		require Cache::SizeAwareFileCache;
		require Storable;
		Storable->import(qw( freeze thaw ));
		$cache = Cache::SizeAwareFileCache->new({
			# standard options
			auto_purge_interval	=> '10 min',
			default_expires		=> '1 hour',
			# file options
			cache_root			=> &DBDefs::CACHE_DIR,
			directory_umask		=> 0077,
			# sizeaware options
			max_size			=> 100_000,
		});
	} or do {
		warn "Failed to create cache: $@"
			if $@ ne "";
	};

	$cache;
}

sub get
{
	my $class = shift;
	my $cache = $class->_new
		or return undef;
	my $data = $cache->get(@_)
		or return undef;
	$data = thaw($data);
	$data;
}

sub set
{
	my ($class, $key, $data, @opts) = @_;
	my $cache = $class->_new
		or return undef;
	$data = freeze($data);
	$cache->set($key, $data, @opts);
}

=pod

This module implements a Cache::Cache layer for MusicBrainz.  The layer implementing
the cache (e.g. File, MemCached, etc) is not known to the caller.  This layer only
supports get / set so far.

=cut

1;
# eof Cache.pm
