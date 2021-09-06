package t::MusicBrainz::Server::Controller::OAuth2;
use Test::Routine;
use Test::More;
use Test::Deep qw( cmp_set );
use utf8;

use Encode;
use HTTP::Request;
use URI;
use URI::QueryParam;
use JSON;
use MusicBrainz::Server::Test qw( html_ok );
use Digest::SHA qw( sha256 );
use MIME::Base64 qw( encode_base64url );

with 't::Context', 't::Mechanize';

sub oauth_redirect_ok
{
    my ($mech, $host, $path, $state) = @_;

    is($mech->status, 302);
    my $uri = URI->new($mech->response->header('Location'));
    is($uri->scheme, 'http');
    is($uri->host, $host);
    is($uri->path, $path);
    is($uri->query_param('state'), $state);
    my $code = $uri->query_param('code');
    ok($code);
    is($uri->query_param('code_challenge'), undef);
    is($uri->query_param('code_challenge_method'), undef);
    return $code;
}

sub oauth_redirect_error
{
    my ($mech, $host, $path, $state, $error, $error_description) = @_;

    is($mech->status, 302);
    my $uri = URI->new($mech->response->header('Location'));
    is($uri->scheme, 'http');
    is($uri->host, $host);
    is($uri->path, $path);
    is($uri->query_param('state'), $state);
    is($uri->query_param('error'), $error);
    is($uri->query_param('error_description'), $error_description)
        if defined $error_description;
    is($uri->query_param('code'), undef);
    is($uri->query_param('code_challenge'), undef);
    is($uri->query_param('code_challenge_method'), undef);
}

sub oauth_authorization_code_ok
{
    my ($test, $code, $application_id, $editor_id, $offline) = @_;

    my $token = $test->c->model('EditorOAuthToken')->get_by_authorization_code($code);
    ok($token);
    is($token->application_id, $application_id);
    is($token->editor_id, $editor_id);
    is($token->authorization_code, $code);
    if ($offline) {
        isnt($token->refresh_token, undef);
    }
    else {
        is($token->refresh_token, undef);
    }
    is($token->access_token, undef);

    my $application = $test->c->model('Application')->get_by_id($application_id);
    $test->mech->post_ok('/oauth2/token', {
        client_id => $application->oauth_id,
        client_secret => $application->oauth_secret,
        redirect_uri => $application->oauth_redirect_uri || 'urn:ietf:wg:oauth:2.0:oob',
        grant_type => 'authorization_code',
        code => $code,
    });

    return $token;
}

# https://tools.ietf.org/html/draft-ietf-oauth-security-topics-14
# Authorization servers MUST prevent clickjacking attacks.
sub csp_headers_ok {
    my $test = shift;
    my $response = $test->mech->response;
    is($response->header('X-Frame-Options'), 'DENY');
    my $csp_pattern =
        q(default-src 'self'; ) .
        q(frame-ancestors 'none'; ) .
        q(script-src 'self' 'nonce-[0-9A-Za-z\+/]{43}=' staticbrainz\.org; ) .
        q(style-src 'self' staticbrainz\.org; ) .
        q(img-src 'self' data: staticbrainz\.org gravatar\.com; ) .
        q(frame-src 'self');
    like($response->header('Content-Security-Policy'), qr{^$csp_pattern$});
}

sub token_response_ok {
    my $test = shift;
    my $response = from_json($test->mech->content);
    is($response->{error}, undef);
    is($response->{error_description}, undef);
    is($response->{token_type}, 'bearer');
    ok($response->{access_token});
    ok($response->{expires_in});
    return $response;
}

test 'Authorize web workflow online' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $client_id = 'id-web';
    my $redirect_uri = 'http://www.example.com/callback';

    my $headers_ok = sub {
        csp_headers_ok($test);
        is($test->mech->response->header('Referrer-Policy'), 'strict-origin-when-cross-origin');
    };

    # This requires login first
    $test->mech->get_ok('/oauth2/authorize?client_id=id-web&response_type=code&scope=profile&state=xxx&redirect_uri=http://www.example.com/callback');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{You need to be logged in to view this page});

    # Logged in and now it asks for permission
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Web is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $headers_ok->();

    # Deny the request
    $test->mech->max_redirect(0);
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.cancel' );
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'access_denied');

    # Incorrect scope
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=does-not-exist&state=xxx&redirect_uri=$redirect_uri");
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'invalid_scope');
    $headers_ok->();

    # Incorrect response type
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=yyy&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'unsupported_response_type');
    $headers_ok->();

    # https://tools.ietf.org/html/rfc6749#section-3.1
    # Request and response parameters MUST NOT be included more than once.
    my %dupe_test_params = (
        client_id => $client_id,
        response_type => 'code',
        scope => 'profile',
        state => 'xxx',
        redirect_uri => $redirect_uri,
    );
    for my $dupe_param (keys %dupe_test_params) {
        my $uri = URI->new;
        $uri->query_form(%dupe_test_params);
        my $content = ("$uri" =~ s/^\?//r) .
            "&$dupe_param=" . $dupe_test_params{$dupe_param};
        $test->mech->get('/oauth2/authorize?' . $content);
        is($test->mech->status, 400);
        $test->mech->content_like(qr{invalid_request});
        $test->mech->content_like(qr{Parameter is included more than once in the request: $dupe_param});
        $headers_ok->();
    }

    # Authorize the request
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xxx');
    $headers_ok->();
    oauth_authorization_code_ok($test, $code, 2, 11, 0);

    # Try to authorize one more time, this time we should be redirected automatically and only get the access_token
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    my $code2 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code2);
    $headers_ok->();
    oauth_authorization_code_ok($test, $code2, 2, 11, 0);
};

test 'Authorize web workflow offline' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $client_id = 'id-web';
    my $redirect_uri = 'http://www.example.com/callback';

    # Login first and disable redirects
    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );
    $test->mech->max_redirect(0);

    # Authorize first request
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=xxx&access_type=offline&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Web is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_like(qr{Perform the above operations when I&#x27;m not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xxx');
    oauth_authorization_code_ok($test, $code, 2, 11, 1);

    # Try to authorize one more time, this time we should be redirected automatically and only get the access_token
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&access_type=offline&redirect_uri=$redirect_uri");
    my $code2 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 2, 11, 0);

    # And one more time, this time force manual authorization
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&access_type=offline&redirect_uri=$redirect_uri&approval_prompt=force");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Web is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_like(qr{Perform the above operations when I&#x27;m not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code3 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code3);
    isnt($code2, $code3);
    oauth_authorization_code_ok($test, $code3, 2, 11, 1);
};

test 'Authorize desktop workflow oob' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $client_id = 'id-desktop';
    my $redirect_uri = 'urn:ietf:wg:oauth:2.0:oob';

    # Login first and disable redirects
    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => { username => 'editor2', password => 'pass' } );
    $test->mech->max_redirect(0);

    # Authorize first request
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'localhost', '/oauth2/oob', 'xxx');
    $test->mech->content_contains($code);
    oauth_authorization_code_ok($test, $code, 1, 12, 1);

    # Try to authorize one more time, this should ask for manual approval as well
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code2 = oauth_redirect_ok($test->mech, 'localhost', '/oauth2/oob', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 1, 12, 1);
};

test 'Authorize desktop workflow localhost' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $client_id = 'id-desktop';
    my $redirect_uri = 'http://localhost:5678/cb';

    # Login first and disable redirects
    $test->mech->get_ok('/login');
    $test->mech->submit_form( with_fields => { username => 'editor2', password => 'pass' } );
    $test->mech->max_redirect(0);

    # Authorize first request
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'localhost', '/cb', 'xxx');
    $test->mech->content_contains($code);
    oauth_authorization_code_ok($test, $code, 1, 12, 1);

    # Try to authorize one more time, this should ask for manual approval as well
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code2 = oauth_redirect_ok($test->mech, 'localhost', '/cb', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 1, 12, 1);
};

test 'Exchange authorization code' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # CORS preflight
    $test->mech->request(HTTP::Request->new(OPTIONS => '/oauth2/token'));
    $response = $test->mech->response;
    is($response->code, 200);
    is($response->header('allow'), 'POST, OPTIONS');
    is($response->header('access-control-allow-origin'), '*');

    # https://tools.ietf.org/html/rfc6749#section-3.2
    # Request and response parameters MUST NOT be included more than once.
    my %dupe_test_params = (
        client_id => 'abc',
        client_secret => 'abc',
        grant_type => 'authorization_code',
        redirect_uri => 'abc',
        code => 'abc',
    );
    for my $dupe_param (keys %dupe_test_params) {
        my $uri = URI->new;
        $uri->query_form(%dupe_test_params);
        my $content = ("$uri" =~ s/^\?//r) .
            "&$dupe_param=" . $dupe_test_params{$dupe_param};
        $test->mech->post('/oauth2/token', content => $content);
        $response = from_json($test->mech->content);
        is($test->mech->status, 400);
        is($response->{error}, 'invalid_request');
        is(
            $response->{error_description},
            'Parameter is included more than once in the request: ' . $dupe_param,
        );
    }

    # Malformed authorization code
    $code = qq{'"\x00<script>alert(1);</script>};
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');
    is(
        $response->{error_description},
        'Malformed authorization code',
    );

    # Unknown authorization code
    $code = 'xxxxxxxxxxxxxxxxxxxxxx';
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_grant');

    # Expired authorization code
    $code = 'kEbi7Dwg4hGRFvz9W8VIuQ';
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_grant');

    $code = 'liUxgzsg4hGvDxX9W8VIuQ';

    # Missing client_id
    $test->mech->post('/oauth2/token', {
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 401);
    is($response->{error}, 'invalid_client');

    # Incorrect client_id
    $test->mech->post('/oauth2/token', {
        client_id => 'id-xxx',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 401);
    is($response->{error}, 'invalid_client');

    # Missing client_secret
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 401);
    is($response->{error}, 'invalid_client');

    # Incorrect client_secret
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-xxx-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 401);
    is($response->{error}, 'invalid_client');

    # Missing grant_type
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');

    # Incorrect grant_type
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'xxx',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'unsupported_grant_type');

    # Missing redirect_uri
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');

    # Incorect redirect_uri
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'xxx',
        code => $code
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');

    # Missing code
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');

    # Correct code, but incorrect application
    $test->mech->post('/oauth2/token', {
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'http://www.example.com/callback',
        code => $code
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_grant');

    # Correct parameters, but GET request
    $test->mech->get('/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code');
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_request');

    # No problems, receives access token
    $test->mech->post_ok('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = token_response_ok($test);
    ok($response->{refresh_token});
};

test 'Authorize web workflow online with PKCE' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($authorization_code, $response);
    my $common_auth_params = '/oauth2/authorize' .
        '?client_id=id-web' .
        '&response_type=code' .
        '&scope=profile' .
        '&state=xyz' .
        '&redirect_uri=http://www.example.com/callback';

    $test->mech->get_ok('/login');
    $test->mech->submit_form(with_fields => { username => 'editor1', password => 'pass' });

    $test->mech->max_redirect(0);
    $test->mech->get($common_auth_params . '&code_challenge_method=idk');
    oauth_redirect_error(
        $test->mech,
        'www.example.com', '/callback', 'xyz',
        'invalid_request', q(The code_challenge_method must be 'S256' or 'plain'),
    );

    $test->mech->get($common_auth_params . '&code_challenge_method=S256');
    oauth_redirect_error(
        $test->mech,
        'www.example.com', '/callback', 'xyz',
        'invalid_request', q(A code_challenge_method was supplied without an accompanying code_challenge),
    );

    $test->mech->get($common_auth_params . '&code_challenge=&code_challenge_method=S256');
    oauth_redirect_error(
        $test->mech,
        'www.example.com', '/callback', 'xyz',
        'invalid_request', 'Invalid code_challenge; see https://tools.ietf.org/html/rfc7636#section-4.1',
    );

    # code_challenge too short
    $test->mech->get($common_auth_params . '&code_challenge=abc&code_challenge_method=S256');
    oauth_redirect_error(
        $test->mech,
        'www.example.com', '/callback', 'xyz',
        'invalid_request', 'Invalid code_challenge; see https://tools.ietf.org/html/rfc7636#section-4.1',
    );

    # code_challenge too long
    $test->mech->get($common_auth_params .
        '&code_challenge=' . ('a' x 129) . '&code_challenge_method=S256');
    oauth_redirect_error(
        $test->mech,
        'www.example.com', '/callback', 'xyz',
        'invalid_request', 'Invalid code_challenge; see https://tools.ietf.org/html/rfc7636#section-4.1',
    );

    my $code_verifier_raw = '...never gonna guess this code..';
    my $code_verifier = encode_base64url($code_verifier_raw); # exactly 43 chars
    # code_challenge_method should default to 'plain'
    $test->mech->get_ok($common_auth_params . "&code_challenge=$code_verifier");
    $test->mech->submit_form(form_name => 'confirm', button => 'confirm.submit');
    $authorization_code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xyz');

    my %common_token_params = (
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'http://www.example.com/callback',
    );

    # Pass an incorrect code_verifier
    $test->mech->post('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => encode_base64url('wrong'),
    });
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_grant');
    is($response->{error_description}, 'Invalid PKCE verifier');

    # Pass an empty code_verifier
    $test->mech->post('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => '',
    });
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_grant');
    is($response->{error_description}, 'Invalid PKCE verifier');

    # Pass no code_verifier
    $test->mech->post('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
    });
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_request');
    is($response->{error_description}, 'Required parameter is missing: code_verifier');

    # This one is okay
    $test->mech->post_ok('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => $code_verifier,
    });
    token_response_ok($test);

    # Specify code_challenge_method=plain explicitly.
    $test->mech->get($common_auth_params .
        "&code_challenge=$code_verifier&code_challenge_method=plain");
    # No confirmation since we're pre-authorized.
    $authorization_code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xyz');

    $test->mech->post_ok('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => $code_verifier,
    });
    token_response_ok($test);

    # With code_challenge_method=S256, the same request should be rejected.
    $test->mech->get($common_auth_params .
        "&code_challenge=$code_verifier&code_challenge_method=S256");
    # No confirmation since we're pre-authorized.
    $authorization_code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xyz');

    $test->mech->post('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => $code_verifier,
    });
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_grant');
    is($response->{error_description}, 'Invalid PKCE verifier');

    my $code_challenge = encode_base64url(sha256($code_verifier));
    $test->mech->get($common_auth_params .
        "&code_challenge=$code_challenge&code_challenge_method=S256");
    # No confirmation since we're pre-authorized.
    $authorization_code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xyz');

    $test->mech->post_ok('/oauth2/token', {
        %common_token_params,
        code => $authorization_code,
        code_verifier => $code_verifier,
    });
    token_response_ok($test);
};

test 'Authorize web workflow with response_mode=form_post' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $mech = $test->mech;
    $mech->get_ok('/login');
    $mech->submit_form(with_fields => { username => 'editor1', password => 'pass' });

    $mech->get('/oauth2/authorize' .
        '?client_id=id-web' .
        '&response_type=code' .
        '&scope=profile' .
        '&state=zyx' .
        '&redirect_uri=http://www.example.com/callback' .
        '&response_mode=form_post');
    $mech->submit_form(form_name => 'confirm', button => 'confirm.submit');
    $mech->content_like(qr{Redirecting to Test Web});
    my $csp_header =
        q(default-src 'self'; ) .
        q(frame-ancestors 'none'; ) .
        q(script-src 'sha256-ePniVEkSivX/c7XWBGafqh8tSpiRrKiqYeqbG7N1TOE=');
    $mech->header_is('Content-Security-Policy', $csp_header);

    my $form = $mech->form_number(1);
    is($form->action, 'http://www.example.com/callback');

    my %inputs = map {
        $_->name => $_->value
    } $mech->grep_inputs({type => qr/^hidden$/});
    is(scalar keys %inputs, 2);

    my $state = $inputs{state};
    is($state, 'zyx');

    my $authorization_code = $inputs{code};
    $mech->post_ok('/oauth2/token', {
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'http://www.example.com/callback',
        code => $authorization_code,
    });
    token_response_ok($test);
};

test 'Exchange refresh code' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown refresh token
    $code = 'xxxxxxxxxxxxxxxxxxxxxx';
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'refresh_token',
        refresh_token => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_grant');

    # Correct token, but incorrect application
    $code = 'yi3qjrMf4hG9VVUxXMVIuQ';
    $test->mech->post('/oauth2/token', {
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'refresh_token',
        refresh_token => $code,
    });
    $response = from_json($test->mech->content);
    is($test->mech->status, 400);
    is($response->{error}, 'invalid_grant');

    # No problems, receives access token
    $test->mech->post_ok('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'refresh_token',
        refresh_token => $code,
    });
    $response = token_response_ok($test);
    ok($response->{refresh_token});
    $test->mech->header_is('access-control-allow-origin', '*');
};

test 'Token info' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # CORS preflight
    $test->mech->request(HTTP::Request->new(OPTIONS => '/oauth2/tokeninfo'));
    $response = $test->mech->response;
    is($response->code, 200);
    is($response->header('allow'), 'GET, OPTIONS');
    is($response->header('access-control-allow-origin'), '*');

    # Unknown token
    $code = 'xxxxxxxxxxxxxxxxxxxxxx';
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 400);
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_token');

    # Expired token
    $code = '3fxf40Z5r6K78D9b031xaw';
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 400);
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_token');

    # Valid token
    $code = 'Nlaa7v15QHm9g8rUOmT3dQ';
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json($test->mech->content);
    ok($response->{expires_in});
    delete $response->{expires_in};
    is($response->{audience}, 'id-desktop');
    is($response->{issued_to}, 'id-desktop');
    is($response->{access_type}, 'offline');
    is($response->{token_type}, 'Bearer');
    cmp_set(
        [ split /\s+/, $response->{scope} ],
        [ qw( profile collection rating email tag submit_barcode submit_isrc ) ]
    );
    $test->mech->header_is('access-control-allow-origin', '*');
};

test 'User info' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # CORS preflight
    $test->mech->request(HTTP::Request->new(OPTIONS => '/oauth2/userinfo'));
    $response = $test->mech->response;
    is($response->code, 200);
    is($response->header('allow'), 'GET, POST, OPTIONS');
    is($response->header('access-control-allow-headers'), 'authorization');
    is($response->header('access-control-allow-origin'), '*');

    # Unknown token
    $code = 'xxxxxxxxxxxxxxxxxxxxxx';
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 401);

    # Expired token
    $code = '3fxf40Z5r6K78D9b031xaw';
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 401);

    # Valid token with email
    $code = 'Nlaa7v15QHm9g8rUOmT3dQ';
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json(decode('utf8', $test->mech->content(raw => 1)));
    my $editor1_with_email = {
        sub => 'editor1',
        profile => 'http://localhost/user/editor1',
        website => 'http://www.mysite.com/',
        gender => 'male',
        zoneinfo => 'Europe/Bratislava',
        email => 'me@mysite.com',
        email_verified => JSON::true,
        metabrainz_user_id => 11,
    };
    is_deeply($response, $editor1_with_email);
    $test->mech->header_is('access-control-allow-origin', '*');

    # Same test as above, but sending the access_token via POST parameter.
    $test->mech->post('/oauth2/userinfo', {access_token => $code});
    is($test->mech->status, 200);
    $response = from_json(decode('utf8', $test->mech->content(raw => 1)));
    is_deeply($response, $editor1_with_email);
    $test->mech->header_is('access-control-allow-origin', '*');

    # Valid token without email
    $code = '7Fjfp0ZBr1KtDRbnfVdmIw';
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json(decode('utf8', $test->mech->content(raw => 1)));
    is_deeply($response, {
        sub => 'editor1',
        profile => 'http://localhost/user/editor1',
        website => 'http://www.mysite.com/',
        gender => 'male',
        zoneinfo => 'Europe/Bratislava',
        metabrainz_user_id => 11,
    });

    # MBS-9744
    $code = 'h_UngEx7VcA6I-XybPS13Q';
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json(decode('utf8', $test->mech->content(raw => 1)));
    is_deeply($response, {
        metabrainz_user_id => 14,
        profile => 'http://localhost/user/%C3%A6ditor%E2%85%A3',
        sub => 'æditorⅣ',
        zoneinfo => 'UTC',
    });

    # Deleted users (bearer)
    $test->c->sql->do('UPDATE editor SET deleted = true WHERE id = 14');
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is(401, $test->mech->status);
    $test->mech->get('/oauth2/userinfo', {Authorization => "Bearer $code"});
    is(401, $test->mech->status);
};

test 'Revoke token' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $mech = $test->mech;
    # CORS preflight
    $mech->request(HTTP::Request->new(OPTIONS => '/oauth2/revoke'));
    my $response = $mech->response;
    is($response->code, 200);
    is($response->header('allow'), 'POST, OPTIONS');
    is($response->header('access-control-allow-headers'), 'authorization');
    is($response->header('access-control-allow-origin'), '*');

    # Bad Request
    $mech->post('/oauth2/revoke');
    $response = from_json($mech->content);
    is($mech->status, 400);
    is($response->{error}, 'invalid_request');
    is($response->{error_description}, 'Required parameter is missing: token');

    $mech->post('/oauth2/revoke', {token => 'invalid'});
    $response = from_json($mech->content);
    is($mech->status, 400);
    is($response->{error}, 'invalid_request');
    is($response->{error_description}, 'Required parameter is missing: client_id');

    $mech->post('/oauth2/revoke', {
        token => 'invalid',
        client_id => 'id-desktop',
    });
    $response = from_json($mech->content);
    is($mech->status, 400);
    is($response->{error}, 'invalid_request');
    is($response->{error_description}, 'Required parameter is missing: client_secret');

    # Unauthorized
    $mech->post('/oauth2/revoke', {
        token => 'invalid',
        client_id => 'not-id-desktop',
        client_secret => 'id-desktop-secret',
    });
    $response = from_json($mech->content);
    is($mech->status, 401);
    is($response->{error}, 'invalid_client');
    is($response->{error_description}, 'Client not authentified');

    $mech->post('/oauth2/revoke', {
        token => 'invalid',
        client_id => 'id-desktop',
        client_secret => 'not-id-desktop-secret',
    });
    $response = from_json($mech->content);
    is($mech->status, 401);
    is($response->{error}, 'invalid_client');
    is($response->{error_description}, 'Client not authentified');

    # Invalid token -> 200 OK
    $mech->post('/oauth2/revoke', {
        token => 'invalid',
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
    });

    # Refresh token from another client -> 200 OK
    my $refresh_token = 'bF3aEvwpgZ-ELDemv7wTpA';
    $mech->post('/oauth2/revoke', {
        token => $refresh_token,
        client_id => 'id-web',
        client_secret => 'id-web-secret',
    });
    # Token is not actually removed
    my $model = $test->c->model('EditorOAuthToken');
    my $token = $model->get_by_refresh_token($refresh_token);
    is($token->refresh_token, $refresh_token);
    my $authorization_code = $token->authorization_code;
    $token = $model->get_by_authorization_code($authorization_code);
    is($token->refresh_token, $refresh_token);

    # Log in as the real client.
    # Try passing client_id/client_secret in the body this time.
    $mech->clear_credentials;
    $mech->post('/oauth2/revoke', {
        token => $refresh_token,
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
    });
    # Now the token is actually removed
    $token = $model->get_by_refresh_token($refresh_token);
    is($token, undef);
    $token = $model->get_by_authorization_code($authorization_code);
    is($token, undef);

    # Access token from another client -> 200 OK
    my $access_token = 'h_UngEx7VcA6I-XybPS13Q';
    $mech->post_ok('/oauth2/revoke', {
        token => $access_token,
        client_id => 'id-web',
        client_secret => 'id-web-secret',
    });
    # Token is not actually removed
    $token = $model->get_by_access_token($access_token);
    is($token->access_token, $access_token);
    $refresh_token = $token->refresh_token;
    $token = $model->get_by_refresh_token($refresh_token);
    is($token->access_token, $access_token);

    # Try revoking only an access token. The refresh token should still be valid.
    $access_token = '7Fjfp0ZBr1KtDRbnfVdmIw';
    $token = $model->get_by_access_token($access_token);
    $refresh_token = $token->refresh_token;
    $mech->post('/oauth2/revoke', {
        token => $access_token,
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
    });
    $token = $model->get_by_access_token($access_token);
    is($token, undef);
    $token = $model->get_by_refresh_token($refresh_token);
    is($token->access_token, undef);

    # Try revoking only an access token for an online client
    # (having no refresh token). The grant should be deleted.
    $access_token = '8YCRGDkkIooBHeriCgk1d6oUpWJ-XCDd';
    $token = $model->get_by_access_token($access_token);
    is($token->refresh_token, undef);
    $mech->post('/oauth2/revoke', {
        token => $access_token,
        client_id => 'id-web',
        client_secret => 'id-web-secret',
    });
    $token = $model->get_by_id($token->id);
    is($token, undef);
};

1;
