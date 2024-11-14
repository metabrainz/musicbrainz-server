package MusicBrainz::Server::ExternalUtils;
use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
    get_chunked_with_retry
);

sub get_chunked_with_retry {
    my ($ua, $url) = @_;
    my $response;
    my $retries_remaining = int(25.0 / $ua->timeout);
    while (!defined($response) && --$retries_remaining > 0) {
        $response = $ua->get($url);

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
