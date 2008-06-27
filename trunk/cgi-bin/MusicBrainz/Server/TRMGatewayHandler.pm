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

package MusicBrainz::Server::TRMGatewayHandler;

use MusicBrainz::Server::LogFile qw( lprint lprintf );
use Apache::Constants qw( :http M_POST OK );

use constant REQ_CONTENT_TYPE => "application/octet-stream";
use constant REQ_BODY_SIZE => 566;
use constant RESP_CONTENT_TYPE => "application/octet-stream";
use constant CMD_GET_GUID => "N";
use constant CMD_DISCONNECT => "E";

sub handler
{
	my $r = shift;

	$r->method_number == M_POST
		or return fail($r);

	my $type = $r->header_in("Content-Type");
	defined($type) && $type eq REQ_CONTENT_TYPE
		or return fail($r);

	my $length = $r->header_in("Content-Length");
	defined($length) && $length == REQ_BODY_SIZE
		or return fail($r);

	my $body;
    $r->read($body, $length);
	length($body) == REQ_BODY_SIZE
		or return fail($r);

	if (substr($body, 0, 1) eq CMD_DISCONNECT)
	{
		lprint "TRMGatewayHandler", "Sigserver disconnect request discarded";
		$r->status(HTTP_OK);
		$r->send_http_header(RESP_CONTENT_TYPE);
		# No body
		OK;
	}

	unless (substr($body, 0, 1) eq CMD_GET_GUID)
	{
		lprintf "TRMGatewayHandler", "Ignoring unknown sigserver request, command = 0x%02X",
			ord(substr($body, 0, 1));
		fail($r);
	}

	# And now, the super-fast TRM lookup algorithm...
	my $bytes = "";
	$bytes .= chr(rand 256) for 1..64;
	substr($bytes, 27, 1) = "L";

	$r->status(HTTP_OK);
	$r->send_http_header(RESP_CONTENT_TYPE);
	$r->print($bytes);

	OK;
}

sub server_error
{
	my $r = shift;
	my $msg = shift;
	$r->status(HTTP_INTERNAL_SERVER_ERROR);
	$r->send_http_header("text/plain");

	$r->print($msg || "Unspecified internal server error\n")
		unless $r->header_only;

	OK;
}

sub fail
{
	my $r = shift;
	$r->status(HTTP_NOT_ACCEPTABLE);
	$r->send_http_header("text/plain");

	my $t = REQ_CONTENT_TYPE;
	my $n = REQ_BODY_SIZE;
	$r->print("The TRM gateway handler only accepts POSTs of $t, $n bytes\n")
		unless $r->header_only;

	OK;
}

1;
# eof TRMGatewayHandler.pm
