#!/usr/bin/perl
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
#   This module by Dave Evans, July 2007.
#____________________________________________________________________________

use warnings;
use strict;

=pod

	use MusicBrainz::Server::RateLimit;

	$key = "whatever ...";

	# Simple interface

	# undef on error, otherwise boolean
	$over_limit = MusicBrainz::Server::RateLimit->simple_test($key);

	# empty list on error, otherwise (over_limit, rate, limit, period)
	@r = MusicBrainz::Server::RateLimit->simple_test($key);

	# Overloaded OO interface

	$t = MusicBrainz::Server::RateLimit->test("some key");

	# $t is either undef (on error), or
	# an object with the following properties:
	
	$t->over_limit; # boolean
	$t->rate; # current rate of this key
	$t->limit; # limit rate of this key
	$t->period; # in seconds

	$t->msg; # something like "10.2, limit is 10.0 per 30 seconds"
	         # might be useful for debugging, or maybe for a message
		 # to show the user

	$t; # overloaded in boolean context as $t->over_limit

	if (my $t = MusicBrainz::Server::RateLimit->test("some key")
	{
		die "Slow down!  " . $t->msg;
	}

=cut

package MusicBrainz::Server::RateLimit;

require IO::Socket::INET;

{
	my $last_server = '';
	my $last_socket;

	sub get_socket
	{
		my ($class, $server) = @_;
		return $last_socket
			if $server eq $last_server
			and $last_socket;
		close $last_socket if $last_socket;

		$last_server = $server;
		$last_socket = IO::Socket::INET->new(
			Proto		=> 'udp',
			PeerAddr	=> $server,
		);
	}

	sub force_close
	{
		close $last_socket if $last_socket;
		$last_socket = undef;
	}
}

our $id = 0;

sub simple_test
{
	my ($class, $key) = @_;

	my $server = &DBDefs::RATELIMIT_SERVER;
	defined($server) or return;
	my $sock = $class->get_socket($server);

	{ use integer; ++$id; $id &= 0xFFFF }

	my $request = "$id over_limit $key";
	my $r;

	$r = send($sock, $request, 0);
	if (not defined $r)
	{
		# Send error
		return;
	}

	my $rv = '';
	vec($rv, fileno($sock), 1) = 1;
	select($rv, undef, undef, 0.1);

	if (not vec($rv, fileno($sock), 1))
	{
		# Timeout
		return;
	}

	my $data;
	$r = recv($sock, $data, 1000, 0);
	if (not defined $r)
	{
		# Receive error
		return;
	}

	unless ($data =~ s/\A($id) //)
	{
		force_close();
		return;
	}

	if ($data =~ /^ok ([YN]) ([\d.]+) ([\d.]+) (\d+)$/)
	{
		my ($over_limit, $rate, $limit, $period) = ($1 eq "Y", $2, $3, $4);
		return(wantarray ? ($over_limit, $rate, $limit, $period) : $over_limit);
	}

	return;
}

sub test
{
	my $class = shift;
	my @r = $class->simple_test(@_)
		or return undef;
	my $tc = $class->test_class;
	return $tc->new(@r);
}

sub test_class { "MusicBrainz::Server::RateLimit::TestResult" }

package MusicBrainz::Server::RateLimit::TestResult;

sub new
{
	my ($class, $over_limit, $rate, $limit, $period) = @_;
	bless {
		over_limit	=> $over_limit,
		rate		=> $rate,
		limit		=> $limit,
		period		=> $period,
	}, $class;
}

use overload
	'bool' => 'over_limit',
	;

sub over_limit	{ $_[0]{over_limit} }
sub rate		{ $_[0]{rate} }
sub limit		{ $_[0]{limit} }
sub period		{ $_[0]{period} }

sub msg
{
	sprintf "%.1f, limit is %.1f per %d seconds",
		$_[0]->rate,
		$_[0]->limit,
		$_[0]->period,
		;
}

1;
# eof RateLimit.pm
