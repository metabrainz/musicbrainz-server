package t::MusicBrainz::Server::Controller::OAuth2;
use Test::Routine;
use Test::More;
use utf8;

use URI;
use URI::QueryParam;
use JSON;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Context', 't::Mechanize';

test 'Authorize web workflow' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    # This requires login first
    $test->mech->get_ok('/oauth2/authorize?client_id=id-web&response_type=code&scope=profile&state=xxx&redirect_uri=http://www.example.com/callback');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{You need to be logged in to view this page});

    # Logged in and now it asks for permission
    $test->mech->submit_form( with_fields => { username => 'editor1', password => 'pass' } );
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Web is requesting permission});
    $test->mech->content_like(qr{View basic information about your account});

    my $uri;

    # Deny the request
    $test->mech->max_redirect(0);
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.cancel' );
    is(302, $test->mech->status);
    $uri = URI->new($test->mech->response->header('Location'));
    is('http', $uri->scheme);
    is('www.example.com', $uri->host);
    is('/callback', $uri->path);
    is('access_denied', $uri->query_param('error'));

    # Incorrect scope
    $test->mech->get('/oauth2/authorize?client_id=id-web&response_type=code&scope=does-not-exist&state=xxx&redirect_uri=http://www.example.com/callback');
    is(302, $test->mech->status);
    $uri = URI->new($test->mech->response->header('Location'));
    is('http', $uri->scheme);
    is('www.example.com', $uri->host);
    is('/callback', $uri->path);
    is('invalid_scope', $uri->query_param('error'));

    # Incorrect response type
    $test->mech->get('/oauth2/authorize?client_id=id-web&response_type=yyy&scope=profile&state=xxx&redirect_uri=http://www.example.com/callback');
    is(302, $test->mech->status);
    $uri = URI->new($test->mech->response->header('Location'));
    is('http', $uri->scheme);
    is('www.example.com', $uri->host);
    is('/callback', $uri->path);
    is('unsupported_response_type', $uri->query_param('error'));

    # Authorize the request
    $test->mech->get_ok('/oauth2/authorize?client_id=id-web&response_type=code&scope=profile&state=xxx&redirect_uri=http://www.example.com/callback');
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    is(302, $test->mech->status);
    $uri = URI->new($test->mech->response->header('Location'));
    is('http', $uri->scheme);
    is('www.example.com', $uri->host);
    is('/callback', $uri->path);
    is('xxx', $uri->query_param('state'));
    my $code = $uri->query_param('code');
    ok($code);

    my $token = $test->c->model('EditorOAuthToken')->get_by_authorization_code($code);
    ok($token);
    is(2, $token->application_id);
    is(1, $token->editor_id);
    is($code, $token->authorization_code);
    is(undef, $token->refresh_token);
    is(undef, $token->access_token);
};

test 'Authorize desktop workflow' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    # This requires login first
    $test->mech->get_ok('/oauth2/authorize?client_id=id-desktop&response_type=code&scope=profile&state=xxx&redirect_uri=urn:ietf:wg:oauth:2.0:oob');
    html_ok($test->mech->content);
    $test->mech->content_like(qr{You need to be logged in to view this page});

    # Logged in and now it asks for permission
    $test->mech->submit_form( with_fields => { username => 'editor2', password => 'pass' } );
    html_ok($test->mech->content);
    $test->mech->content_like(qr{Test Desktop is requesting permission});
    $test->mech->content_like(qr{View basic information about your account});

    # Authorize the request
    $test->mech->submit_form( form_name => 'confirm', button => 'confirm.submit' );
    is('/oauth2/oob', $test->mech->uri->path);
    is('xxx', $test->mech->uri->query_param('state'));
    my $code = $test->mech->uri->query_param('code');
    ok($code);
    $test->mech->content_contains($code);

    my $token = $test->c->model('EditorOAuthToken')->get_by_authorization_code($code);
    ok($token);
    is(1, $token->application_id);
    is(2, $token->editor_id);
    is($code, $token->authorization_code);
    is(undef, $token->refresh_token);
    is(undef, $token->access_token);
};

test 'Exchange authorization code' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my ($code, $response);

    # Unknown authorization code
    $code = "xxxxxxxxxxxxxxxxxxxxxx";
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # Expired authorization code
    $code = "kEbi7Dwg4hGRFvz9W8VIuQ";
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    $code = "liUxgzsg4hGvDxX9W8VIuQ";

    # Missing client_id
    $test->mech->get("/oauth2/token?client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Incorrect client_id
    $test->mech->get("/oauth2/token?client_id=id-xxx&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Missing client_secret
    $test->mech->get("/oauth2/token?client_id=id-desktop&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Incorrect client_secret
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-xxx-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(401, $test->mech->status);
    is('invalid_client', $response->{error});

    # Missing grant_type
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Incorrect grant_type
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=xxx&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('unsupported_grant_type', $response->{error});

    # Missing redirect_uri
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Incorect redirect_uri
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=xxx&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Missing code
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_request', $response->{error});

    # Correct code, but incorrect application
    $test->mech->get("/oauth2/token?client_id=id-web&client_secret=id-web-secret&grant_type=authorization_code&redirect_uri=http://www.example.com/callback&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # No problems, receives access token
    $test->mech->get_ok("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=authorization_code&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
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
    $test->mech->get("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=refresh_token&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # Correct token, but incorrect application
    $code = "yi3qjrMf4hG9VVUxXMVIuQ";
    $test->mech->get("/oauth2/token?client_id=id-web&client_secret=id-web-secret&grant_type=refresh_token&redirect_uri=http://www.example.com/callback&code=$code");
    $response = from_json($test->mech->content);
    is(400, $test->mech->status);
    is('invalid_grant', $response->{error});

    # No problems, receives access token
    $test->mech->get_ok("/oauth2/token?client_id=id-desktop&client_secret=id-desktop-secret&grant_type=refresh_token&redirect_uri=urn:ietf:wg:oauth:2.0:oob&code=$code");
    $response = from_json($test->mech->content);
    is('bearer', $response->{token_type});
    ok($response->{access_token});
    ok($response->{refresh_token});
    ok($response->{expires_in});
};

1;
