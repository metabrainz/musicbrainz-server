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

# Try to preload
eval 'require Cache::Memcached';

use Carp qw( carp );

use constant CACHE_TIMER => 0;

our $cache;

# Cache::Memcached can't handle spaces in keys, so we URI-encode them
require URI::Escape;
*_encode_key = \&URI::Escape::uri_escape;

sub _new
{
	return $cache if $cache;

	eval {
		require Cache::Memcached;
		$cache = Cache::Memcached->new(&DBDefs::CACHE_OPTIONS);
	} or do {
		warn "Failed to create cache: $@"
			if $@ ne "";
	};

	$cache;
}

sub get
{
	my ($class, $key, @args) = @_;
	my $timer = MusicBrainz::Server::CacheTimer->new("get", $key, @args) if CACHE_TIMER;
	my $r = eval { $class->_get($key, @args) };
	warn "Warning: Cache GET $key failed: $@\n" if $@;
	$r;
}

sub _get
{
	my ($class, $key, @args) = @_;

	my $cache = $class->_new
		or return undef;

	my $data = $cache->get(_encode_key($key), @args);
	if (not defined $data)
	{
		carp "Cache MISS on $key" if &DBDefs::CACHE_DEBUG;
		return undef;
	}

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
	my ($class, $key, @args) = @_;
	my $timer = MusicBrainz::Server::CacheTimer->new("set", $key, @args) if CACHE_TIMER;
	my $r = eval { $class->_set("set", $key, @args) };
	warn "Warning: Cache SET $key failed: $@\n" if $@;
	$r;
}

sub add
{
	my ($class, $key, @args) = @_;
	my $timer = MusicBrainz::Server::CacheTimer->new("add", $key, @args) if CACHE_TIMER;
	my $r = eval { $class->_set("add", $key, @args) };
	warn "Warning: Cache ADD $key failed: $@\n" if $@;
	$r;
}

sub replace
{
	my ($class, $key, @args) = @_;
	my $timer = MusicBrainz::Server::CacheTimer->new("replace", $key, @args) if CACHE_TIMER;
	my $r = eval { $class->_set("replace", $key, @args) };
	warn "Warning: Cache REPLACE $key failed: $@\n" if $@;
	$r;
}

sub _set
{
	my ($class, $method, $key, $data, @opts) = @_;
	my $cache = $class->_new
		or return undef;

	if (&DBDefs::CACHE_DEBUG)
	{
		my $METHOD = uc $method;

		#use Data::Dumper;
		#local $Data::Dumper::Terse = 1;
		#my $d = Data::Dumper->Dump([ $data ],[ 'd' ]);
		#carp "Cache HIT ($d) on $key";

		if (not defined $data)
		{
			carp "Cache $METHOD (undef) on $key";
		} elsif (not ref $data) {
			carp "Cache $METHOD ($data) on $key";
		} elsif (ref($data) eq "REF") {
			carp "Cache $METHOD (\\$$data) on $key";
		} else {
			carp "Cache $METHOD ($data) on $key";
		}
	}

	$opts[0] = &DBDefs::CACHE_DEFAULT_EXPIRES
		if not defined $opts[0];
	$cache->$method(_encode_key($key), $data, @opts);
}

sub delete
{
	my ($class, $key, $time) = @_;
	my $timer = MusicBrainz::Server::CacheTimer->new("delete", $key, $time) if CACHE_TIMER;
	$time = &DBDefs::CACHE_DEFAULT_DELETE unless defined $time;
	my $cache = $class->_new
		or return undef;
	carp "Cache DELETE $key $time" if &DBDefs::CACHE_DEBUG;
	eval { $cache->delete(_encode_key($key), $time) };
	warn "Cache delete $key failed: $@\n" if $@;
}

=pod

This module implements a Cache::Cache layer for MusicBrainz.  The layer implementing
the cache (e.g. File, MemCached, etc) is not known to the caller.  This layer
supports get / set / add / replace / delete.

=cut

package MusicBrainz::Server::CacheTimer;

use Time::HiRes qw( gettimeofday tv_interval );
use MusicBrainz::Server::LogFile qw( lprint lprintf );

sub new
{
	my $class = shift;
	bless {
		t => [ gettimeofday ],
		c0 => [ caller(0) ],
		c1 => [ caller(1) ],
		args => [ @_ ],
	}, $class;
}

sub DESTROY
{
	my $self = shift;
	my $t = tv_interval($self->{t});
	my $c0 = $self->{c0};
	my @args = @{ $self->{args} };

	my $msg = sprintf "Cache: %8.4fs (%s) from %s line %d\n",
		$t,
		join(" ", @args),
		$c0->[1], $c0->[2];

	lprint "cache", $msg;
}

1;
# eof Cache.pm
