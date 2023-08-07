package t::MusicBrainz::Server::Controller::Role::WikipediaExtract;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Request;
use HTTP::Status qw( :constants );

test 'CORS support' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+mozart');

    my $response;

    # Check basic OPTIONS support
    $test->mech->request(HTTP::Request->new(OPTIONS => '/artist/b972f589-fb0e-474e-b64a-803b0364fa75/wikipedia-extract'));
    $response = $test->mech->response;
    is($response->code, HTTP_OK, 'OK status is returned to any OPTIONS request');
    is($response->content, '', 'No content is returned to any OPTIONS request');
    is($response->header('access-control-allow-headers'), undef, 'Access-Control-Allow-Headers header isn’t returned to basic OPTIONS request');
    is($response->header('access-control-allow-methods'), undef, 'Access-Control-Allow-Methods header isn’t returned to basic OPTIONS request');
    is($response->header('access-control-allow-origin'), '*', 'Access-Control-Allow-Origin header is returned to any OPTIONS request');
    is($response->header('allow'), 'GET, OPTIONS', 'Allow header is returned to basic OPTIONS request');

    # Check CORS preflight support
    $test->mech->request(HTTP::Request->new('OPTIONS', '/artist/b972f589-fb0e-474e-b64a-803b0364fa75/wikipedia-extract', [
            'Access-Control-Request-Headers' => 'Content-Type, User-Agent',
            'Access-Control-Request-Method' => 'GET',
            'Origin' => 'https://example.com',
        ]));
    $response = $test->mech->response;
    is($response->code, HTTP_OK, 'OK status is returned to any OPTIONS request');
    is($response->content, '', 'No content is returned to any OPTIONS request');
    is($response->header('access-control-allow-headers'), 'User-Agent', 'Access-Control-Allow-Headers header is returned to CORS preflight request');
    is($response->header('access-control-allow-methods'), 'GET, OPTIONS', 'Access-Control-Allow-Methods header is returned to CORS preflight request');
    is($response->header('access-control-allow-origin'), '*', 'Access-Control-Allow-Origin header is returned to any OPTIONS request');
    is($response->header('allow'), undef, 'Allow header isn’t returned to CORS preflight request');
};

1;
