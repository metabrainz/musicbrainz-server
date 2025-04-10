package MusicBrainz::Server::ExternalUtils;
use strict;
use warnings;

use base 'Exporter';
use Data::Dumper;
use MusicBrainz::Server::Log qw( log_error );
use Readonly;
use Time::HiRes qw( gettimeofday tv_interval );

our @EXPORT_OK = qw(
    get_chunked_with_retry
);

Readonly my $retry_timeout => 25;

sub get_chunked_with_retry {
    my ($ua, $url) = @_;

    my $retries_remaining = 5;
    my @start_time = gettimeofday;
    my $response;
    while (
        !defined($response) &&
        --$retries_remaining > 0 &&
        tv_interval(\@start_time) < $retry_timeout
    ) {
        $response = $ua->get($url);

        log_error {
            "Failed to get $url in get_chunked_with_retry:\n" .
            Dumper($response->content) . "\n" .
            "Response headers:\n" .
            Dumper($response->headers->as_string)
        } if $response->is_error;

        # When using chunked transfer encoding, occasionally, a chunk gets
        # delayed, and the LWP timeout fires causing the response to only be
        # partially completed. In this case, the X-Died header is set.  If this
        # happens, we retry the request.
        my $x_died = $response->headers->header('X-Died');
        $response = undef if ($x_died && $x_died =~ /read timeout/);
    }
    return $response;
}

1;

