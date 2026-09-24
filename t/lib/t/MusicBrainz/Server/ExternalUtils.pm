package t::MusicBrainz::Server::ExternalUtils;
use strict;
use warnings;

use Test::Routine;
use Test::More;

use HTTP::Response;
use HTTP::Status qw( :constants );
use MusicBrainz::Server::ExternalUtils qw( get_chunked_with_retry );

# A minimal mock user agent that records the arguments passed to get().
{
    package t::MusicBrainz::Server::ExternalUtils::MockUA;
    use HTTP::Response;
    use HTTP::Status qw( :constants );

    sub new { return bless { calls => [] }, shift }

    sub get {
        my ($self, $url, @headers) = @_;
        push @{ $self->{calls} }, { url => $url, headers => \@headers };
        my $response = HTTP::Response->new;
        $response->code(HTTP_OK);
        $response->content('ok');
        return $response;
    }
}

test 'get_chunked_with_retry works with no headers' => sub {
    my $ua = t::MusicBrainz::Server::ExternalUtils::MockUA->new;

    my $response = get_chunked_with_retry($ua, 'https://search.example.com/path');

    ok($response->is_success, 'request succeeds');
    is_deeply($ua->{calls}[0]{headers}, [],
        'no extra headers passed when none supplied');
};

test 'get_chunked_with_retry forwards headers to the user agent' => sub {
    my $ua = t::MusicBrainz::Server::ExternalUtils::MockUA->new;

    my $response = get_chunked_with_retry(
        $ua,
        'https://search.example.com/path',
        'X-MB-Foo' => 'Bar',
    );

    ok($response->is_success, 'request succeeds');
    is(scalar @{ $ua->{calls} }, 1, 'user agent called once');

    my $call = $ua->{calls}[0];
    is($call->{url}, 'https://search.example.com/path',
        'URL is forwarded');
    is_deeply($call->{headers}, ['X-MB-Foo', 'Bar'],
        'headers are forwarded to the user agent');
};

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
