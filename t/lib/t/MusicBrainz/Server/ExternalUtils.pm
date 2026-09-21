package t::MusicBrainz::Server::ExternalUtils;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use HTTP::Response;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::ExternalUtils qw( get_chunked_with_retry );

# A mock user agent that simulates a truncated chunked response
# (`X-Died` header with `read timeout`) on its two first calls,
# then succeeds. Tracks the attempt count itself, should be 3.
{
    package t::MusicBrainz::Server::ExternalUtils::RetryUA;
    use HTTP::Response;
    use HTTP::Status qw( :constants );

    sub new { return bless { attempts => 0 }, shift }

    sub get {
        my ($self, $url, @headers) = @_;
        $self->{attempts}++;
        my $response = HTTP::Response->new;
        $response->code(HTTP_OK);
        $response->content('partial');
        # Simulate a truncated chunked response on the two first attempts.
        $response->headers->header('X-Died' => 'read timeout')
            if $self->{attempts} < 3;
        return $response;
    }
}

test 'get_chunked_with_retry retries on X-Died read timeout' => sub {
    my $ua = t::MusicBrainz::Server::ExternalUtils::RetryUA->new;
    my $response = get_chunked_with_retry($ua, 'https://search.example.com/path');

    ok($response, 'a response is returned');
    is($ua->{attempts}, 3, 'retried twice after X-Died read timeout');
    ok(!$response->headers->header('X-Died'),
        'final response has no X-Died header');
};

1;
