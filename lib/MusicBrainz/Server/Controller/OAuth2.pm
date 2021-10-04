package MusicBrainz::Server::Controller::OAuth2;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use DateTime;
use Digest::SHA qw( sha256 );
use URI;
use URI::QueryParam;
use JSON;
use MIME::Base64 qw( encode_base64url );
use MusicBrainz::Server::Constants qw( :access_scope );
use MusicBrainz::Server::Data::Utils qw( boolean_to_json is_valid_token );
use Readonly;

Readonly our %ACCESS_SCOPE_BY_NAME => (
    'profile'        => $ACCESS_SCOPE_PROFILE,
    'email'          => $ACCESS_SCOPE_EMAIL,
    'tag'            => $ACCESS_SCOPE_TAG,
    'rating'         => $ACCESS_SCOPE_RATING,
    'collection'     => $ACCESS_SCOPE_COLLECTION,
    'submit_isrc'    => $ACCESS_SCOPE_SUBMIT_ISRC,
    'submit_barcode' => $ACCESS_SCOPE_SUBMIT_BARCODE,
);

Readonly our @AUTHORIZE_PARAMETERS => qw(
    client_id
    scope
    response_type
    redirect_uri
    access_type
    approval_prompt
    state
    code_challenge
    code_challenge_method
    response_mode
);

Readonly our %AUTHORIZE_PARAMETER_DEFAULTS => (
    access_type => 'online',
    approval_prompt => 'auto',
);

Readonly our %OPTIONAL_AUTHORIZE_PARAMETERS => (
    state => 1,
    approval_prompt => 1,
    code_challenge => 1,
    code_challenge_method => 1,
    response_mode => 1,
);

Readonly our @TOKEN_PARAMETERS => qw(
    client_id
    client_secret
    grant_type
    code
    refresh_token
    redirect_uri
    token_type
    code_verifier
);

sub index : Private
{
    my ($self, $c) = @_;

    $c->response->redirect(sprintf('http://%s/doc/OAuth2', DBDefs->WEB_SERVER));
    $c->detach;
}

sub authorize : Local Args(0) RequireAuth SecureForm
{
    my ($self, $c) = @_;

    # https://tools.ietf.org/html/draft-ietf-oauth-security-topics-14#section-4.2.4
    $c->res->header('Referrer-Policy' => 'strict-origin-when-cross-origin');

    $self->_enforce_tls_html($c);

    my %params;
    for my $name (@AUTHORIZE_PARAMETERS) {
        my $value = $c->request->params->{$name};
        if (ref($value) eq 'ARRAY') {
            $self->_send_html_error(
                $c,
                'invalid_request',
                'Parameter is included more than once in the request: ' . $name,
            );
        }
        $value = $AUTHORIZE_PARAMETER_DEFAULTS{$name} unless defined $value;
        if (defined $value) {
            $params{$name} = $value;
        } elsif (!$OPTIONAL_AUTHORIZE_PARAMETERS{$name}) {
            $self->_send_html_error($c, 'invalid_request', 'Required parameter is missing: ' . $name);
        }
    }

    my $application = $c->model('Application')->get_by_oauth_id($params{client_id});
    $self->_send_html_error($c, 'invalid_client', 'Unknown client')
        unless defined $application;
    # Used by root/oauth2/OAuth2FormPost.js
    $c->stash->{application_name} = $application->name;

    my $redirect_uri = $params{redirect_uri};
    $self->_send_html_error($c, 'invalid_request', 'Mismatched redirect URI')
        unless $self->_check_redirect_uri($application, $redirect_uri);

    $self->_send_redirect_error($c, $redirect_uri, 'unsupported_response_type', 'Unsupported response type')
        unless $params{response_type} eq 'code';

    my $response_mode = $params{response_mode};
    $self->_send_redirect_error($c, $redirect_uri, 'invalid_request', 'Unsupported response mode')
        if defined $response_mode && $response_mode ne 'form_post';

    my $scope = 0;
    for my $name (split /\s+/, $params{scope}) {
        $self->_send_redirect_error($c, $redirect_uri, 'invalid_scope', 'Unsupported scope: ' . $name)
            unless exists $ACCESS_SCOPE_BY_NAME{$name};
        $scope |= $ACCESS_SCOPE_BY_NAME{$name};
    }

    my $code_challenge = $params{code_challenge};
    my $code_challenge_method = $params{code_challenge_method};
    $self->_check_pkce_challenge(
        $c,
        $redirect_uri,
        $code_challenge,
        $code_challenge_method,
    );

    my $offline = 1;
    my $pre_authorized = 0;

    if ($application->is_server) {
        $offline = 0 if $params{access_type} ne 'offline';
        my $has_granted_tokens = $c->model('EditorOAuthToken')->check_granted_token($c->user->id, $application->id, $scope, $offline);
        $pre_authorized = 1 if $params{approval_prompt} ne 'force' && $has_granted_tokens;
    }

    my $form = $c->form( form => 'SecureConfirm' );
    if ($pre_authorized || ($c->form_posted_and_valid($form))) {
        if (DBDefs->DB_READ_ONLY) {
            $self->_send_redirect_error($c, $redirect_uri, 'temporarily_unavailable', 'Server is in read-only mode');
        }

        if ($form->field('cancel')->input) {
            $self->_send_redirect_error($c, $redirect_uri, 'access_denied', 'User denied the authorization request');
        }
        else {
            my $token;
            $offline = 0 if $pre_authorized && $offline;
            $c->model('MB')->with_transaction(sub {
                $token = $c->model('EditorOAuthToken')->create_authorization_code(
                    $c->user->id,
                    $application->id,
                    $scope,
                    $offline,
                    $code_challenge || undef,
                    $code_challenge_method || ($code_challenge ? 'plain' : undef),
                );
            });
            $self->_send_redirect_response($c, $redirect_uri, {
                code => $token->authorization_code,
            }, $response_mode);
        }
    }

    my $perms = MusicBrainz::Server::Entity::EditorOAuthToken->permissions($scope);
    $c->stash(
        current_view => 'Node',
        component_path => 'oauth2/OAuth2Authorize',
        component_props => {
            application => $application->TO_JSON,
            form => $form->TO_JSON,
            offline => boolean_to_json($offline),
            permissions => $perms,
        },
    );
}

sub oob : Local Args(0)
{
    my ($self, $c) = @_;

    $self->_enforce_tls_html($c);

    my $code = $c->request->params->{code};
    my $token = $c->model('EditorOAuthToken')->get_by_authorization_code($code);

    $self->_send_html_error($c, 'invalid_request', 'Invalid authorization code')
        unless defined $token;

    $self->_send_html_error($c, 'invalid_request', 'Expired authorization code')
        if $token->is_expired;

    $c->model('Application')->load($token);

    $c->stash(
        current_view => 'Node',
        component_path => 'oauth2/OAuth2Oob',
        component_props => {
            code => $code,
            application => $token->application->TO_JSON,
        },
    );
}

sub _validate_client {
    my ($self, $c, $client_id, $client_secret) = @_;

    my ($auth_client_id, $auth_client_secret) = $c->request->headers->authorization_basic;
    if (defined $auth_client_id && defined $auth_client_secret) {
        $client_id = $auth_client_id;
        $client_secret = $auth_client_secret;
    }

    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless defined $client_id && defined $client_secret;

    my $application = $c->model('Application')->get_by_oauth_id($client_id);
    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless defined $application;

    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless $client_secret eq $application->oauth_secret;

    return $application;
}

sub token : Local Args(0)
{
    my ($self, $c) = @_;

    $c->res->header('Access-Control-Allow-Origin' => '*');

    $self->_enforce_tls($c);

    $self->_send_options_response($c, 'POST')
        if $c->request->method eq 'OPTIONS';

    $self->_send_error($c, 'invalid_request', 'Only POST requests are allowed')
        if $c->request->method ne 'POST';

    my %params;
    for my $name (@TOKEN_PARAMETERS) {
        my $value = $c->request->params->{$name};
        if (ref($value) eq 'ARRAY') {
            $self->_send_error(
                $c,
                'invalid_request',
                'Parameter is included more than once in the request: ' . $name,
            );
        }
        $params{$name} = $value;
        my $optional = 1;
        $optional = 0 if $name eq 'code' && $params{grant_type} eq 'authorization_code';
        $optional = 0 if $name eq 'redirect_uri' && $params{grant_type} eq 'authorization_code';
        $optional = 0 if $name eq 'refresh_token'&& $params{grant_type} eq 'refresh_token';
        $optional = 0 if $name eq 'grant_type';
        $self->_send_error($c, 'invalid_request', 'Required parameter is missing: ' . $name)
            unless $params{$name} or $optional;
    }

    my $application = $self->_validate_client(
        $c,
        $params{client_id},
        $params{client_secret},
    );

    my $token;
    if ($params{grant_type} eq 'authorization_code') {
        $self->_send_error($c, 'invalid_request', 'Mismatched redirect URI')
            unless $self->_check_redirect_uri($application, $params{redirect_uri});
        my $authorization_code = $params{code};
        $self->_send_error($c, 'invalid_request', 'Malformed authorization code')
            unless is_valid_token($authorization_code);
        $token = $c->model('EditorOAuthToken')->get_by_authorization_code($authorization_code);
        $self->_send_error($c, 'invalid_grant', 'Invalid authorization code')
            unless defined $token && $token->application_id == $application->id;
        if ($token->code_challenge) {
            $self->_check_pkce_verifier($c, $token, $params{code_verifier});
        }
        $self->_send_error($c, 'invalid_grant', 'Expired authorization code')
            if $token->is_expired;
    }
    elsif ($params{grant_type} eq 'refresh_token') {
        $token = $c->model('EditorOAuthToken')->get_by_refresh_token($params{refresh_token});
        $self->_send_error($c, 'invalid_grant', 'Invalid refresh token')
            unless defined $token && $token->application_id == $application->id;
    }
    else {
        $self->_send_error($c, 'unsupported_grant_type', 'Unsupported grant_type, only authorization_code and refresh_token are supported');
    }

    my $token_type = lc($c->request->params->{token_type} || 'bearer');
    $self->_send_error($c, 'invalid_request', 'Invalid requested token type, only bearer is allowed')
        unless $token_type eq 'bearer';

    if (DBDefs->DB_READ_ONLY) {
        $self->_send_error($c, 'temporarily_unavailable', 'Server is in read-only mode');
    }

    my $data;
    $c->model('MB')->with_transaction(sub {
        $c->model('EditorOAuthToken')->grant_access_token($token);
        $data = {
            access_token => $token->access_token,
            token_type => $token_type,
            expires_in => $token->expire_time->subtract_datetime_absolute(DateTime->now)->seconds,
        };
        if ($token->refresh_token) {
            $data->{refresh_token} = $token->refresh_token;
        }
    });
    $self->_send_response($c, $data);
}

sub _set_error_status {
    my ($self, $c, $error) = @_;

    if ($error eq 'invalid_client') {
        $c->response->headers->www_authenticate('Basic realm="OAuth2-Client"');
        $c->response->status(401);
    }
    elsif ($error eq 'temporarily_unavailable') {
        $c->response->status(503);
    }
    else {
        $c->response->status(400);
    }
}

sub _send_html_error
{
    my ($self, $c, $error, $error_description) = @_;

    $self->_set_error_status($c, $error);

    $c->stash(
        current_view => 'Node',
        component_path => 'oauth2/OAuth2Error',
        component_props => {
            errorDescription => $error_description,
            errorMessage => $error,
        },
    );
    $c->detach;
}

sub _send_error
{
    my ($self, $c, $error, $error_description) = @_;

    $self->_set_error_status($c, $error);

    $self->_send_response($c, {
        error => $error,
        error_description => $error_description,
    });
}

sub _send_options_response {
    my ($self, $c, $allow) = @_;

    $c->res->headers->header('Allow' => "$allow, OPTIONS");
    $self->_send_response($c, {message => 'OK'});
}

sub _send_response
{
    my ($self, $c, $response) = @_;

    $c->response->headers->header(
        'Cache-Control' => 'no-store',
        'Pragma' => 'no-cache',
    );

    my $body = $c->json_utf8->encode($response);
    $c->response->body($body);
    $c->response->content_type('application/json; charset=utf-8');
    $c->detach;
}

sub _send_redirect_error
{
    my ($self, $c, $uri, $error, $error_description) = @_;

    if ($uri eq 'urn:ietf:wg:oauth:2.0:oob') {
        $self->_send_html_error($c, $error, $error_description);
    }
    else {
        $self->_send_redirect_response($c, $uri, {
            error => $error,
            error_description => $error_description,
        });
    }
}

sub _send_redirect_response
{
    my ($self, $c, $uri, $response, $response_mode) = @_;

    if ($uri eq 'urn:ietf:wg:oauth:2.0:oob') {
        $uri = $c->uri_for_action('/oauth2/oob');
    }

    if (exists $c->request->params->{state}) {
        $response->{state} = $c->request->params->{state};
    }

    if (defined $response_mode && $response_mode eq 'form_post') {
        # This overrides the CSP header set by
        # MusicBrainz::Server::set_csp_headers. This one is more restrictive.
        $c->res->header('Content-Security-Policy' => (
            q(default-src 'self'; ) .
            q(frame-ancestors 'none'; ) .
            q(script-src 'sha256-ePniVEkSivX/c7XWBGafqh8tSpiRrKiqYeqbG7N1TOE=')
        ));
        $c->stash(
            current_view => 'Node',
            component_path => 'oauth2/OAuth2FormPost',
            component_props => {
                applicationName => $c->stash->{application_name},
                fields => $response,
                redirectUri => '' . $uri,
            },
        );
    } else {
        my $parsed_uri = URI->new($uri);
        for my $name (keys %$response) {
            $parsed_uri->query_param($name => $response->{$name});
        }
        $c->response->redirect($parsed_uri->as_string);
    }

    $c->detach;
}

sub _enforce_tls
{
    my ($self, $c) = @_;

    $self->_send_error($c, 'invalid_request', 'Invalid protocol, only HTTPS is allowed')
        if DBDefs->OAUTH2_ENFORCE_TLS && !$c->request->secure;
}

sub _enforce_tls_html
{
    my ($self, $c) = @_;

    $self->_send_html_error($c, 'invalid_request', 'Invalid protocol, only HTTPS is allowed')
        if DBDefs->OAUTH2_ENFORCE_TLS && !$c->request->secure;
}

sub _check_redirect_uri
{
    my ($self, $application, $redirect_uri) = @_;

    if (defined $application->oauth_redirect_uri) {
        return 1 if $redirect_uri eq $application->oauth_redirect_uri;
    }

    if (!$application->is_server) {
        return 1 if $redirect_uri eq 'urn:ietf:wg:oauth:2.0:oob';
        return 1 if $redirect_uri =~ /^http:\/\/localhost(:\d+)?(\/.*?)?$/;
    }
    return 0;
}

sub _check_pkce_challenge {
    my ($self, $c, $redirect_uri, $code_challenge, $code_challenge_method) = @_;

    # https://tools.ietf.org/html/rfc7636
    if (defined $code_challenge_method) {
        if ($code_challenge_method !~ m'^(plain|S256)$') {
            $self->_send_redirect_error(
                $c,
                $redirect_uri,
                'invalid_request',
                q(The code_challenge_method must be 'S256' or 'plain'),
            );
        }
        if (!defined $code_challenge) {
            $self->_send_redirect_error(
                $c,
                $redirect_uri,
                'invalid_request',
                'A code_challenge_method was supplied without an accompanying code_challenge',
            );
        }
    } else {
        $code_challenge_method = 'plain';
    }

    my $invalid_code_challenge =
        defined $code_challenge &&
        ($code_challenge_method eq 'plain' &&
            # code_challenge = code_verifier
            $code_challenge !~ m'^[A-Za-z0-9.~_-]{43,128}$') ||
        ($code_challenge_method eq 'S256' &&
            # code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
            $code_challenge !~ m'^[A-Za-z0-9_-]{43}$');

    if ($invalid_code_challenge) {
        $self->_send_redirect_error(
            $c,
            $redirect_uri,
            'invalid_request',
            'Invalid code_challenge; see https://tools.ietf.org/html/rfc7636#section-4.1',
        );
    }
}

sub _check_pkce_verifier {
    my ($self, $c, $token, $code_verifier) = @_;

    $self->_send_error($c, 'invalid_request', 'Required parameter is missing: code_verifier')
        unless defined $code_verifier;

    my $code_challenge = $token->code_challenge // '';
    my $code_challenge_method = $token->code_challenge_method // 'plain';

    $self->_send_error($c, 'invalid_grant', 'Invalid PKCE verifier') unless (
        ($code_challenge_method eq 'plain' &&
            $code_challenge eq $code_verifier) ||
        ($code_challenge_method eq 'S256' &&
            $code_challenge eq
            encode_base64url(sha256($code_verifier)))
    );
}

sub tokeninfo : Local
{
    my ($self, $c) = @_;

    $c->res->header('Access-Control-Allow-Origin' => '*');

    $self->_enforce_tls($c);

    $self->_send_options_response($c, 'GET')
        if $c->request->method eq 'OPTIONS';

    my $access_token = $c->request->params->{access_token};
    my $token = $c->model('EditorOAuthToken')->get_by_access_token($access_token);

    $self->_send_error($c, 'invalid_token', 'Invalid value')
        if !defined($token) || $token->is_expired;

    my $application = $c->model('Application')->get_by_id($token->application_id);

    my @scope;
    for my $name (keys %ACCESS_SCOPE_BY_NAME) {
        my $i = $ACCESS_SCOPE_BY_NAME{$name};
        if (($token->scope & $i) == $i) {
            push @scope, $name;
        }
    }

    $self->_send_response($c, {
        audience => $application->oauth_id,
        issued_to => $application->oauth_id,
        expires_in => $token->expire_time->subtract_datetime_absolute(DateTime->now)->seconds,
        access_type => $token->refresh_token ? 'offline' : 'online',
        token_type => 'Bearer',
        scope => join(' ', @scope),
    });
}

sub userinfo : Local
{
    my ($self, $c) = @_;

    $c->res->header('Access-Control-Allow-Origin' => '*');

    $self->_enforce_tls($c);

    if ($c->request->method eq 'OPTIONS') {
        $c->res->headers->header('Access-Control-Allow-Headers' => 'authorization');
        $self->_send_options_response($c, 'GET, POST');
    }

    $c->authenticate({}, 'musicbrainz.org');
    $self->_send_error($c, 'invalid_token', 'Invalid value')
        unless $c->user->is_authorized($ACCESS_SCOPE_PROFILE);

    $c->model('Gender')->load($c->user);
    $c->model('Editor')->load_preferences($c->user);

    # http://openid.net/specs/openid-connect-basic-1_0.html#userinfo

    my $data = {
        sub => $c->user->name,
        profile => $c->uri_for_action('/user/profile', [ $c->user->name ])->as_string,
        metabrainz_user_id => $c->user->id,
    };

    if ($c->user->website) {
        $data->{website} = $c->user->website;
    }

    if ($c->user->gender_id) {
        $data->{gender} = lc($c->user->gender->name);
    }

    if ($c->user->preferences->timezone) {
        $data->{zoneinfo} = $c->user->preferences->timezone;
    }

    if ($c->user->is_authorized($ACCESS_SCOPE_EMAIL) && $c->user->has_email_address) {
        $data->{email} = $c->user->email;
        $data->{email_verified} = $c->user->has_confirmed_email_address ? JSON::true : JSON::false;
    }

    $self->_send_response($c, $data);
}

sub revoke : Local {
    my ($self, $c) = @_;

    $c->res->header('Access-Control-Allow-Origin' => '*');

    $self->_enforce_tls($c);

    if ($c->request->method eq 'OPTIONS') {
        $c->res->headers->header('Access-Control-Allow-Headers' => 'authorization');
        $self->_send_options_response($c, 'POST');
    }

    $self->_send_error($c, 'invalid_request', 'Only POST requests are allowed')
        if $c->request->method ne 'POST';

    my %params;
    for my $name (qw( token client_id client_secret )) {
        my $value = $c->request->body_params->{$name};
        if (ref($value) eq 'ARRAY') {
            $self->_send_error(
                $c,
                'invalid_request',
                'Parameter is included more than once in the request: ' . $name,
            );
        }
        $self->_send_error($c, 'invalid_request', 'Required parameter is missing: ' . $name)
            unless defined $value;
        $params{$name} = $value;
    }

    my $application = $self->_validate_client(
        $c,
        $params{client_id},
        $params{client_secret},
    );

    $c->model('MB')->with_transaction(sub {
        $c->model('EditorOAuthToken')->revoke_token($application->id, $params{token});
    });

    # This endpoint returns an empty 200 OK even for invalid tokens.
    # See RFC 7009.
    $c->response->header('Content-Length' => '0');
    $c->response->headers->remove_header('Content-Type');
    $c->response->body('');
    $c->response->status(200);
}

no Moose;
1;

=head1 DESCRIPTION

Implementation of the OAuth 2.0 (rev. 23) authorization protocol:

  http://tools.ietf.org/html/draft-ietf-oauth-v2-23

All handlers from this controller must be accessed via TLS, as they
send/receive secrets in plaintext.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
