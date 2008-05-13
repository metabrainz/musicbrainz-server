#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

package MusicBrainz::Server::TRMGateway;

sub new
{
	my ($class, $host, $port) = @_;

	use IO::Socket::INET;
	my $sock = IO::Socket::INET->new(
		PeerAddr => $host,
		PeerPort => $port,
		Proto => 'tcp',
    ) or die $!;
	binmode $sock;
	$sock->autoflush(1);

	bless {
		SOCK	=> $sock,
	}, $class;
}

sub DESTROY
{
	my $self = shift;

	$self->_send_disconnect
		unless $self->has_disconnected;
}

sub _send_disconnect
{
	my $self = shift;

	my $sock = $self->{SOCK};
	my $msg = "E" . ("\0" x 565);
	print $sock $msg;

	close $sock;
}

sub has_disconnected
{
	my $self = shift;
	my $sock = $self->{SOCK};

	my $r = '';
	vec($r, fileno($sock), 1) = 1;
	select($r, undef, undef, 0);
	vec($r, fileno($sock), 1) or return;

	eof $sock;
}

sub request
{
	my ($self, $request) = @_;
	length($request) == 566 or die;

	my $sock = $self->{SOCK};
	print $sock $request;

	local $/ = \64;
	my $response = <$sock>;
	length($response) == 64 or die "Expected 64 bytes, got ".length($response);

	$response;
}

sub _raw_to_bytes
{
	my $self = shift;
	my $t = shift;
	$t =~ s/...(.)/$1/g;
	$t;
}

sub _bytes_to_guid
{
	my $self = shift;
	my $t = shift;
	$t = lc unpack "H*", $t;
	$t =~ s/^(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})$/$1-$2-$3-$4-$5/;
	$t;
}

sub request_as_bytes
{
	my $self = shift;
	my $response = $self->request(@_);
	$self->_raw_to_bytes($response);
}

sub request_as_text
{
	my $self = shift;
	my $response = $self->request(@_);
	$self->_bytes_to_guid($self->_raw_to_bytes($response));
}

1;
# eof TRMGateway.pm
