#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

use strict;

package MusicBrainz::Server::TRMGatewayHandler;

use MusicBrainz::Server::TRMGateway;
use Apache::Constants qw( :http M_POST OK );
use Time::HiRes qw( gettimeofday tv_interval );

use constant REQ_CONTENT_TYPE => "application/octet-stream";
use constant REQ_BODY_SIZE => 566;
use constant RESP_CONTENT_TYPE => "application/octet-stream";
use constant CMD_GET_GUID => "N";
use constant CMD_DISCONNECT => "E";

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
		print STDERR "Sigserver disconnect request discarded\n";
		$r->status(HTTP_OK);
		$r->send_http_header(RESP_CONTENT_TYPE);
		# No body
		OK;
	}

	unless (substr($body, 0, 1) eq CMD_GET_GUID)
	{
		printf STDERR "Ignoring unknown sigserver request, command = 0x%02X\n",
			ord(substr($body, 0, 1));
		fail($r);
	}

	my $memc = MusicBrainz::Server::Cache->_new;

	if (-f "/tmp/disable-trm-gateway")
	{
		print STDERR "All TRM requests are currently disabled\n"
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
			print STDERR "Too many sigservers ($newcount > $MAX_SIGSERVERS)\n"
				if $r->dir_config('WarnIfSigserverBusy');
			$r->status(HTTP_SERVICE_UNAVAILABLE);
			$r->send_http_header;
			return OK;
		}

		# print STDERR "$newcount sigservers\n";
	}

	my $gateway = get_gateway();
	unless ($gateway)
	{
		not($memc)
			or defined($memc->decr($key, 1))
			or warn "Failed to decrement $key key";
		if ($memc) { $memc->add("trm-nogateway", 0); $memc->incr("trm-nogateway", 1); }
		print STDERR "Couldn't get gateway object\n";
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	my $t0 = [ gettimeofday ] if $COLLECT_STATS;
	my $bytes;
	#eval {
	#	local $SIG{__DIE__} = sub { "alarm\n" };
	#	alarm $LOOKUP_TIMEOUT;
		$bytes = $gateway->request($body);
	#	alarm;
	#	sleep 1;
	#};
	my $took = tv_interval($t0) if $COLLECT_STATS;

	not($memc)
    	or defined($memc->decr($key, 1))
		or warn "Failed to decrement $key key";

	eval { 1 }; # dummy
	if ($@)
	{
		warn "Sigserver error: $@";
		$gateway = undef;
		remove_gateway();
		if ($memc) { $memc->add("trm-error", 0); $memc->incr("trm-error", 1); }
		$r->status(HTTP_SERVICE_UNAVAILABLE);
		$r->send_http_header;
		return OK;
	}

	printf STDERR "sigserver took %.4fs\n", $took if $COLLECT_STATS;

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

	sub get_gateway
	{
		if ($gateway)
		{
			return $gateway unless $gateway->has_disconnected;
			$gateway = undef;
		}
		my $g = eval { MusicBrainz::Server::TRMGateway->new("10.1.1.2", 4447) };
		$gateway = $g if $g;
	}

	sub remove_gateway
	{
		$gateway = undef;
	}
}

1;
# eof TRMGatewayHandler.pm
