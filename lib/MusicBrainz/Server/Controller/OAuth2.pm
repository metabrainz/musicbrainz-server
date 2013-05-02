package MusicBrainz::Server::Controller::OAuth2;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use DateTime;
use URI;
use URI::QueryParam;
use JSON;
use MusicBrainz::Server::Constants qw( :access_scope );

our %ACCESS_SCOPE_BY_NAME = (
    'profile'        => $ACCESS_SCOPE_PROFILE,
    'email'          => $ACCESS_SCOPE_EMAIL,
    'tag'            => $ACCESS_SCOPE_TAG,
    'rating'         => $ACCESS_SCOPE_RATING,
    'collection'     => $ACCESS_SCOPE_COLLECTION,
    'submit_puid'    => $ACCESS_SCOPE_SUBMIT_PUID,
    'submit_isrc'    => $ACCESS_SCOPE_SUBMIT_ISRC,
    'submit_barcode' => $ACCESS_SCOPE_SUBMIT_BARCODE,
);

sub index : Private
{
    my ($self, $c) = @_;

    $c->response->redirect(sprintf('http://%s/doc/OAuth2', DBDefs->WEB_SERVER));
    $c->detach;
}

sub authorize : Local Args(0) RequireAuth
{
    my ($self, $c) = @_;

    $self->_enforce_tls_html($c);

    my %params;
    my %defaults = ( access_type => 'online', approval_prompt => 'auto' );
    for my $name (qw/ client_id scope response_type redirect_uri access_type approval_prompt /) {
        my $value = $c->request->params->{$name};
        $value = $defaults{$name} unless defined $value;
        $params{$name} = ref($value) eq 'ARRAY' ? $value->[0] : $value;
        $self->_send_html_error($c, 'invalid_request', 'Required parameter is missing: ' . $name)
            unless $params{$name};
    }

    my $application = $c->model('Application')->get_by_oauth_id($params{client_id});
    $self->_send_html_error($c, 'invalid_client', 'Unknown client')
        unless defined $application;

    $self->_send_html_error($c, 'invalid_request', 'Mismatched redirect URI')
        unless $self->_check_redirect_uri($application, $params{redirect_uri});

    $self->_send_redirect_error($c, $params{redirect_uri}, 'unsupported_response_type', 'Unsupported response type')
        unless $params{response_type} eq 'code';

    my $scope = 0;
    for my $name (split /\s+/, $params{scope}) {
        $self->_send_redirect_error($c, $params{redirect_uri}, 'invalid_scope', 'Unsupported scope: ' . $name)
            unless exists $ACCESS_SCOPE_BY_NAME{$name};
        $scope |= $ACCESS_SCOPE_BY_NAME{$name};
    }

    my $offline = 1;
    my $pre_authorized = 0;

    if ($application->is_server) {
        $offline = 0 if $params{access_type} ne 'offline';
        my $has_granted_tokens = $c->model('EditorOAuthToken')->check_granted_token($c->user->id, $application->id, $scope, $offline);
        $pre_authorized = 1 if $params{approval_prompt} ne 'force' && $has_granted_tokens;
    }

    my $form = $c->form( form => 'SubmitCancel' );
    if ($pre_authorized || ($c->form_posted && $form->submitted_and_valid($c->req->params))) {
        if ($form->field('cancel')->input) {
            $self->_send_redirect_error($c, $params{redirect_uri}, 'access_denied', 'User denied the authorization request');
        }
        else {
            my $token;
            $offline = 0 if $pre_authorized && $offline;
            $c->model('MB')->with_transaction(sub {
                $token = $c->model('EditorOAuthToken')->create_authorization_code($c->user->id, $application->id, $scope, $offline);
            });
            $self->_send_redirect_response($c, $params{redirect_uri}, {
                code => $token->authorization_code,
            });
        }
    }

    my $perms = MusicBrainz::Server::Entity::EditorOAuthToken->permissions($scope);
    $c->stash( application => $application, perms => $perms, offline => $offline );
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

    $c->stash( code => $code, application => $token->application );
}

sub token : Local Args(0)
{
    my ($self, $c) = @_;

    $self->_enforce_tls($c);

    $self->_send_error($c, 'invalid_request', 'Only POST requests are allowed')
        if $c->request->method ne 'POST';

    my %params;
    for my $name (qw/client_id client_secret grant_type code refresh_token redirect_uri token_type/) {
        my $value = $c->request->params->{$name};
        $params{$name} = ref($value) eq 'ARRAY' ? $value->[0] : $value;
        my $optional = 1;
        $optional = 0 if $name eq 'code' && $params{grant_type} eq 'authorization_code';
        $optional = 0 if $name eq 'redirect_uri' && $params{grant_type} eq 'authorization_code';
        $optional = 0 if $name eq 'refresh_token'&& $params{grant_type} eq 'refresh_token';
        $optional = 0 if $name eq 'grant_type';
        $self->_send_error($c, 'invalid_request', 'Required parameter is missing: ' . $name)
            unless $params{$name} or $optional;
    }

    my ($auth_client_id, $auth_client_secret) = $c->request->headers->authorization_basic;
    if (defined $auth_client_id && defined $auth_client_secret) {
        $params{client_id} = $auth_client_id;
        $params{client_secret} = $auth_client_secret;
    }

    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless defined $params{client_id} && defined $params{client_secret};

    my $application = $c->model('Application')->get_by_oauth_id($params{client_id});
    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless defined $application;

    $self->_send_error($c, 'invalid_client', 'Client not authentified')
        unless $params{client_secret} eq $application->oauth_secret;

    my $token;
    if ($params{grant_type} eq 'authorization_code') {
        $self->_send_error($c, 'invalid_request', 'Mismatched redirect URI')
            unless $self->_check_redirect_uri($application, $params{redirect_uri});
        $token = $c->model('EditorOAuthToken')->get_by_authorization_code($params{code});
        $self->_send_error($c, 'invalid_grant', 'Invalid authorization code')
            unless defined $token && $token->application_id == $application->id;
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
    $self->_send_error($c, 'invalid_request', 'Invalid requested token type, only bearer and mac are allowed')
        unless $token_type eq 'bearer' || $token_type eq 'mac';
    my $is_mac = $token_type eq 'mac';

    my $data;
    $c->model('MB')->with_transaction(sub {
        $c->model('EditorOAuthToken')->grant_access_token($token, $is_mac);
        $data = {
            access_token => $token->access_token,
            token_type => $token_type,
            expires_in => $token->expire_time->subtract_datetime_absolute(DateTime->now)->seconds,
        };
        if ($token->refresh_token) {
            $data->{refresh_token} = $token->refresh_token;
        }
        if ($is_mac && $token->mac_key) {
            $data->{mac_key} = $token->mac_key;
            $data->{mac_algorithm} = 'hmac-sha-1';
        }
    });
    $self->_send_response($c, $data);
}

sub _send_html_error
{
    my ($self, $c, $error, $error_description) = @_;

    $c->stash(
        template => 'oauth2/error.tt',
        error_message => $error, # there is a TT macro called "error"
        error_description => $error_description,
    );
    $c->detach;
}

sub _send_error
{
    my ($self, $c, $error, $error_description) = @_;

    if ($error eq 'invalid_client') {
        $c->response->headers->www_authenticate('Basic realm="OAuth2-Client"');
        $c->response->status(401);
    }
    else {
        $c->response->status(400);
    }

    $self->_send_response($c, {
        error => $error,
        error_description => $error_description,
    });
}

sub _send_response
{
    my ($self, $c, $response) = @_;

    $c->response->headers->header(
        'Cache-Control' => 'no-store',
        'Pragma' => 'no-cache',
    );

    $c->stash( json => $response );
    $c->detach('View::JSON');
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
    my ($self, $c, $uri, $response) = @_;

    if ($uri eq 'urn:ietf:wg:oauth:2.0:oob') {
        $uri = $c->uri_for_action('/oauth2/oob');
    }

    my $parsed_uri = URI->new($uri);
    for my $name (keys %$response) {
        $parsed_uri->query_param( $name => $response->{$name} )
    }
    if (exists $c->request->params->{state}) {
        $parsed_uri->query_param( state => $c->request->params->{state} )
    }

    $c->response->redirect($parsed_uri->as_string);
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

    if ($application->is_server) {
        return 1 if $redirect_uri eq $application->oauth_redirect_uri;
    }
    else {
        return 1 if $redirect_uri eq 'urn:ietf:wg:oauth:2.0:oob';
        return 1 if $redirect_uri =~ /^http:\/\/localhost(:\d+)?(\/.*?)?$/;
    }
    return 0;
}

sub tokeninfo : Local
{
    my ($self, $c) = @_;

    $self->_enforce_tls($c);

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
        access_type => $token->refresh_token ? "offline" : "online",
        token_type => $token->mac_key ? "MAC" : "Bearer",
        scope => join(" ", @scope),
    });
}

sub userinfo : Local
{
    my ($self, $c) = @_;

    $self->_enforce_tls($c);

    $c->authenticate({}, 'musicbrainz.org');
    $self->_send_error($c, 'invalid_token', 'Invalid value')
        unless $c->user->is_authorized($ACCESS_SCOPE_PROFILE);

    $c->model('Gender')->load($c->user);
    $c->model('Editor')->load_preferences($c->user);

    # http://openid.net/specs/openid-connect-basic-1_0.html#userinfo

    my $data = {
        sub => $c->user->name,
        profile => $c->uri_for_action('/user/profile', [ $c->user->name ])->as_string,
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

no Moose;
1;

=head1 DESCRIPTION

Implementation of the OAuth 2.0 (rev. 23) authorization protocol:

  http://tools.ietf.org/html/draft-ietf-oauth-v2-23

All handlers from this controller must be accessed via TLS, as they
send/receive secrets in plaintext.

=head1 COPYRIGHT

Copyright (C) 2012 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
