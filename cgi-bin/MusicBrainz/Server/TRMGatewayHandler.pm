#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;

package MusicBrainz::Server::TRMGatewayHandler;

use MusicBrainz::Server::TRMGateway;
use MusicBrainz::Server::LogFile qw( lprint lprintf );
use Apache::Constants qw( :http M_POST OK );
use Time::HiRes qw( gettimeofday tv_interval );

use constant REQ_CONTENT_TYPE => "application/octet-stream";
use constant REQ_BODY_SIZE => 566;
use constant RESP_CONTENT_TYPE => "application/octet-stream";
use constant CMD_GET_GUID => "N";
use constant CMD_DISCONNECT => "E";
use constant KILL_SWITCH => "/tmp/disable-trm-gateway";

sub handler
{
	my $r = shift;

	my $MAX_SIGSERVERS = $r->dir_config('MaxSigServers') || 10;
	my $LOOKUP_TIMEOUT = $r->dir_config('LookupTimeout') || 10;
	my $COLLECT_STATS = $r->dir_config('CollectSigserverStats');

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

	my $memc = MusicBrainz::Server::Cache->_new;

	if (-f KILL_SWITCH)
	{
		lprint "TRMGatewayHandler", "All TRM requests are currently disabled"
			if $r->dir_config('WarnIfSigserverDisabled');
		if ($memc) { $memc->add("trm-disabled", 0); $memc->incr("trm-disabled", 1); }
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	my $key = "sigservers";

	if ($memc)
	{
		$memc->add($key, 0);
		my $newcount = $memc->incr($key, 1) || 0;

		if ($newcount > $MAX_SIGSERVERS)
		{
			defined($memc->decr($key, 1))
				or warn "Failed to decrement $key key";
			$memc->add("trm-busy", 0); $memc->incr("trm-busy", 1);
			lprint "TRMGatewayHandler", "Too many sigservers ($newcount > $MAX_SIGSERVERS)"
				if $r->dir_config('WarnIfSigserverBusy');
			$r->status(HTTP_SERVICE_UNAVAILABLE);
			$r->send_http_header;
			return OK;
		}

		# lprint "TRMGatewayHandler" "$newcount sigservers";
	}

	my $gateway = get_gateway();
	unless ($gateway)
	{
		not($memc)
			or defined($memc->decr($key, 1))
			or warn "Failed to decrement $key key";
		if ($memc) { $memc->add("trm-nogateway", 0); $memc->incr("trm-nogateway", 1); }
		lprint "TRMGatewayHandler", "Couldn't get gateway object";
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	my $t0 = [ gettimeofday ] if $COLLECT_STATS;

	my $bytes;
	my $err;
	{
		alarm 0;
		$SIG{ALRM} = sub { die "ALARM\n" };
		alarm $LOOKUP_TIMEOUT;
		eval { $bytes = $gateway->request($body) };
		$err = $@;
		$SIG{ALRM} = 'IGNORE';
		alarm 0;
	}

	my $took = tv_interval($t0) if $COLLECT_STATS;

	not($memc)
    	or defined($memc->decr($key, 1))
		or warn "Failed to decrement $key key";

	if ($err eq "ALARM\n")
	{
		$gateway = undef;
		remove_gateway();
		if ($memc) { $memc->add("trm-error", 0); $memc->incr("trm-error", 1); }
		lprint "sigserver", "sigserver timed out"
			if $COLLECT_STATS;
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	if ($err)
	{
		warn "Sigserver error: $err";
		$gateway = undef;
		remove_gateway();
		if ($memc) { $memc->add("trm-error", 0); $memc->incr("trm-error", 1); }
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	lprintf "sigserver", "sigserver took %.4fs\n", $took
		if $COLLECT_STATS;

	if ($memc)
	{
		$memc->add("trm-ok", 0);
		$memc->incr("trm-ok", 1);
		$memc->add("trm-taken", 0);
		$memc->incr("trm-taken", $took * 1E6) if $took;
		$memc->add("trm-taken-count", 0);
		$memc->incr("trm-taken-count", 1) if $took;
	}

	$r->status(HTTP_OK);
	$r->send_http_header(RESP_CONTENT_TYPE);
	$r->print($bytes);

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

{
	our $gateway;
	our $port;

	sub get_gateway
	{
		if ($gateway)
		{
			return $gateway unless $gateway->has_disconnected;
			lprint "TRMGatewayHandler", "Gateway on local port $port has become disconnected - reconnecting";
			$gateway = $port = undef;
		} else {
			lprint "TRMGatewayHandler", "Attempting to connect to gateway ...";
		}
		
		alarm 0;
		$SIG{ALRM} = sub { die "ALARM\n" };
		alarm 10;
		eval { $gateway = MusicBrainz::Server::TRMGateway->new("10.1.1.2", 4447) };
		my $err = $@;
		$SIG{ALRM} = 'IGNORE';
		alarm 0;

		if ($err eq "ALARM\n")
		{
			lprint "TRMGatewayHandler", "Timeout connecting to gateway";
			return($gateway = undef);
		}

		if ($err)
		{
			chomp $err;
			lprint "TRMGatewayHandler", "Error connecting to gateway ($err)";
			return($gateway = undef);
		}

		$port = $gateway->{SOCK}->sockport;
		lprint "TRMGatewayHandler", "Connected to gateway (local port $port)";
		return $gateway;
	}

	sub remove_gateway
	{
		if ($gateway)
		{
			lprint "TRMGatewayHandler", "Disconnecting from gateway (local port $port)";
		}
		$gateway = $port = undef;
	}
}

1;
# eof TRMGatewayHandler.pm
