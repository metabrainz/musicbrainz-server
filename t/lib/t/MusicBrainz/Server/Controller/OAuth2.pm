package t::MusicBrainz::Server::Controller::OAuth2;
use Test::Routine;
use Test::More;
use utf8;

use URI;
use URI::QueryParam;
use JSON;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

sub oauth_redirect_ok
{
    my ($mech, $host, $path, $state) = @_;

    is(302, $mech->status);
    my $uri = URI->new($mech->response->header('Location'));
    is('http', $uri->scheme);
    is($host, $uri->host);
    is($path, $uri->path);
    is($state, $uri->query_param('state'));
    my $code = $uri->query_param('code');
    ok($code);

    return $code;
}

sub oauth_redirect_error
{
    my ($mech, $host, $path, $state, $error) = @_;

    is(302, $mech->status);
    my $uri = URI->new($mech->response->header('Location'));
    is('http', $uri->scheme);
    is($host, $uri->host);
    is($path, $uri->path);
    is($state, $uri->query_param('state'));
    is($error, $uri->query_param('error'));
    is(undef, $uri->query_param('code'));
}

sub oauth_authorization_code_ok
{
    my ($test, $code, $application_id, $editor_id, $offline) = @_;

    my $token = $test->c->model('EditorOAuthToken')->get_by_authorization_code($code);
    ok($token);
    is($application_id, $token->application_id);
    is($editor_id, $token->editor_id);
    is($code, $token->authorization_code);
    if ($offline) {
        isnt(undef, $token->refresh_token);
    }
    else {
        is(undef, $token->refresh_token);
    }
    is(undef, $token->access_token);

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

test 'Authorize web workflow online' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $client_id = 'id-web';
    my $redirect_uri = 'http://www.example.com/callback';

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

    # Deny the request
    $test->mech->max_redirect(0);
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.cancel' );
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'access_denied');

    # Incorrect scope
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=does-not-exist&state=xxx&redirect_uri=$redirect_uri");
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'invalid_scope');

    # Incorrect response type
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=yyy&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    oauth_redirect_error($test->mech, 'www.example.com', '/callback', 'xxx', 'unsupported_response_type');

    # Authorize the request
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=xxx&redirect_uri=$redirect_uri");
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xxx');
    oauth_authorization_code_ok($test, $code, 2, 1, 0);

    # Try to authorize one more time, this time we should be redirected automatically and only get the access_token
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    my $code2 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 2, 1, 0);
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
    $test->mech->content_like(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'xxx');
    oauth_authorization_code_ok($test, $code, 2, 1, 1);

    # Try to authorize one more time, this time we should be redirected automatically and only get the access_token
    $test->mech->get("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&access_type=offline&redirect_uri=$redirect_uri");
    my $code2 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 2, 1, 0);

    # And one more time, this time force manual authorization
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&access_type=offline&redirect_uri=$redirect_uri&approval_prompt=force");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Web is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_like(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code3 = oauth_redirect_ok($test->mech, 'www.example.com', '/callback', 'yyy');
    isnt($code, $code3);
    isnt($code2, $code3);
    oauth_authorization_code_ok($test, $code3, 2, 1, 1);
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
    oauth_authorization_code_ok($test, $code, 1, 2, 1);

    # Try to authorize one more time, this should ask for manual approval as well
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code2 = oauth_redirect_ok($test->mech, 'localhost', '/oauth2/oob', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 1, 2, 1);
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
    oauth_authorization_code_ok($test, $code, 1, 2, 1);

    # Try to authorize one more time, this should ask for manual approval as well
    $test->mech->get_ok("/oauth2/authorize?client_id=$client_id&response_type=code&scope=profile&state=yyy&redirect_uri=$redirect_uri");
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View your public account information});
    $test->mech->content_unlike(qr{Perform the above operations when I'm not using the application});
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    my $code2 = oauth_redirect_ok($test->mech, 'localhost', '/cb', 'yyy');
    isnt($code, $code2);
    oauth_authorization_code_ok($test, $code2, 1, 2, 1);
};

test 'Exchange authorization code' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown authorization code
    $code = "xxxxxxxxxxxxxxxxxxxxxx";
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # Expired authorization code
    $code = "kEbi7Dwg4hGRFvz9W8VIuQ";
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    $code = "liUxgzsg4hGvDxX9W8VIuQ";

    # Missing client_id
    $test->mech->post('/oauth2/token', {
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Incorrect client_id
    $test->mech->post('/oauth2/token', {
        client_id => 'id-xxx',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Missing client_secret
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        grant_type => 'authorization_code', 
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Incorrect client_secret
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-xxx-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Missing grant_type
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Incorrect grant_type
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'xxx',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('unsupported_grant_type', $response->{error});

    # Missing redirect_uri
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Incorect redirect_uri
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'xxx',
        code => $code
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Missing code
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Correct code, but incorrect application
    $test->mech->post('/oauth2/token', {
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'http://www.example.com/callback',
        code => $code
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # Correct parameters, but GET request
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # No problems, receives access token
    $test->mech->post_ok('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'authorization_code',
        redirect_uri => 'urn:ietf:wg:oauth:2.0:oob',
        code => $code,
    });
    $response = from_json($test->mech->content);
    is(undef, $response->{error});
    is(undef, $response->{error_description});
    is('bearer', $response->{token_type});
    ok($response->{access_token});
    ok($response->{refresh_token});
    ok($response->{expires_in});
};

test 'Exchange refresh code' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown refresh token
    $code = "xxxxxxxxxxxxxxxxxxxxxx";
    $test->mech->post('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'refresh_token', 
        refresh_token => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # Correct token, but incorrect application
    $code = "yi3qjrMf4hG9VVUxXMVIuQ";
    $test->mech->post('/oauth2/token', {
        client_id => 'id-web',
        client_secret => 'id-web-secret',
        grant_type => 'refresh_token',
        refresh_token => $code,
    });
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # No problems, receives access token
    $test->mech->post_ok('/oauth2/token', {
        client_id => 'id-desktop',
        client_secret => 'id-desktop-secret',
        grant_type => 'refresh_token',
        refresh_token => $code,
    });
    $response = from_json($test->mech->content);
    is('bearer', $response->{token_type});
    ok($response->{access_token});
    ok($response->{refresh_token});
    ok($response->{expires_in});
};

test 'Token info' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown token
    $code = "xxxxxxxxxxxxxxxxxxxxxx";
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 400);
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_token');

    # Expired token
    $code = "3fxf40Z5r6K78D9b031xaw";
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 400);
    $response = from_json($test->mech->content);
    is($response->{error}, 'invalid_token');

    # Valid token
    $code = "Nlaa7v15QHm9g8rUOmT3dQ";
    $test->mech->get("/oauth2/tokeninfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json($test->mech->content);
    ok($response->{expires_in});
    delete $response->{expires_in};
    is_deeply($response, {
        audience => 'id-desktop',
        issued_to => 'id-desktop',
        access_type => 'offline',
        token_type => 'Bearer',
        scope => 'profile collection rating email submit_puid tag submit_barcode submit_isrc',
    });
};

test 'User info' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown token
    $code = "xxxxxxxxxxxxxxxxxxxxxx";
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 401);

    # Expired token
    $code = "3fxf40Z5r6K78D9b031xaw";
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 401);

    # Valid token with email
    $code = "Nlaa7v15QHm9g8rUOmT3dQ";
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json($test->mech->content);
    is_deeply($response, {
        sub => 'editor1',
        profile => 'http://localhost/user/editor1',
        website => 'http://www.mysite.com/',
        gender => 'female',
        zoneinfo => 'Europe/Bratislava',
        email => 'me@mysite.com',
        email_verified => JSON::true,
    });

    # Valid token without email
    $code = "7Fjfp0ZBr1KtDRbnfVdmIw";
    $test->mech->get("/oauth2/userinfo?access_token=$code");
    is($test->mech->status, 200);
    $response = from_json($test->mech->content);
    is_deeply($response, {
        sub => 'editor1',
        profile => 'http://localhost/user/editor1',
        website => 'http://www.mysite.com/',
        gender => 'female',
        zoneinfo => 'Europe/Bratislava',
    });
};

1;
