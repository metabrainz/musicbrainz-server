#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :

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
	length($response) == 64 or die;

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
