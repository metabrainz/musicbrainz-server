package MusicBrainz::Server::Data::RateLimiter;
use Moose;
use namespace::autoclean;

use DBDefs;
use IO::Socket::INET;

use aliased 'MusicBrainz::Server::RateLimitResponse';

has '_socket' => (
    is => 'ro',
    lazy_build => 1
);

sub _build__socket {
    my $server = DBDefs::RATELIMIT_SERVER or return;
    return IO::Socket::INET->new(
        Proto => 'udp',
        PeerAddr => $server
    );
}

sub _close_socket {
    my $self = shift;
    close $self->_socket;
    $self->clear__socket;
}

has 'id' => (
    is => 'rw',
);

sub check_rate_limit
{
    my ($self, $key) = @_;
    return unless DBDefs::RATELIMIT_SERVER;

    my $id = $self->id;
    { use integer; ++$id; $id &= 0xFFFF; }
    $self->id($id);

    my $request = "$id over_limit $key";

    my $r = send($self->_socket, $request, 0);
    # Sending error
    return unless defined $r;

    my $rv = '';
    vec($rv, fileno($self->_socket), 1) = 1;
    select($rv, undef, undef, 0.1);

    # Timeout
    return unless vec($rv, fileno($self->_socket), 1);

    my $data;
    $r = recv($self->_socket, $data, 1000, 0);
    return unless defined $r; # Receive error

    unless ($data =~ s/\A($id) //) {
        close $self->_socket;
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

1;
