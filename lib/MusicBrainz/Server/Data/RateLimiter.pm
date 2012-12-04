package MusicBrainz::Server::Data::RateLimiter;
use Moose;
use namespace::autoclean;
use namespace::autoclean;

use DBDefs ();
use IO::Socket::INET ();

use aliased 'MusicBrainz::Server::RateLimitResponse';

has '_socket' => (
    is => 'rw',
);

has 'id' => (
    is => 'rw',
);

sub get_socket
{
    my ($self) = @_;

    my $server = DBDefs->RATELIMIT_SERVER or return;

    my $s = $self->_socket;
    return $s if $s;

    $s = IO::Socket::INET->new(
        Proto => 'udp',
        PeerAddr => $server
    ) or return;

    $self->_socket($s);
    return $s;
}

sub reset_socket
{
    my ($self) = @_;
    $self->_socket(undef);
}

sub check_rate_limit
{
    my ($self, $key) = @_;
    my $socket = $self->get_socket
        or return;

    my $id = $self->id;
    { use integer; ++$id; $id &= 0xFFFF; }
    $self->id($id);

    my $request = "$id over_limit $key";

    my $r = send($socket, $request, 0);
    # Sending error
    return unless defined $r;

    my $rv = '';
    vec($rv, fileno($socket), 1) = 1;
    select($rv, undef, undef, 0.1);

    # Timeout
    return unless vec($rv, fileno($socket), 1);

    my $data;
    $r = recv($socket, $data, 1000, 0);
    return unless defined $r; # Receive error

    unless ($data =~ s/\A($id) //) {
        $self->reset_socket;
        return;
    }

    if ($data =~ /^ok ([YN]) ([\d.]+) ([\d.]+) (\d+)$/) {
        my ($over_limit, $rate, $limit, $period) = ($1 eq "Y", $2, $3, $4);
        return RateLimitResponse->new(
            is_over_limit => $over_limit ? 1 : 0,
            rate => $rate,
            limit => $limit,
            period => $period
        );
    }

    return;
}

no Moose;
1;
