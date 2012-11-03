package MusicBrainz::Server::Controller::OAuth2;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use DateTime;
use URI;
use URI::QueryParam;
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

    $c->response->redirect(sprintf('http://%s/doc/OAuth2', DBDefs::WEB_SERVER));
    $c->detach;
}

sub authorize : Local Args(0) RequireAuth
{
    my ($self, $c) = @_;

    my %params;
    for my $name (qw/client_id scope response_type redirect_uri/) {
        my $value = $c->request->params->{$name};
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
    if ($application->is_server) {
        my $access_type = $c->request->params->{access_type};
        $offline = 0 if !$access_type || $access_type ne 'offline';
    }

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        if ($form->field('cancel')->input) {
            $self->_send_redirect_error($c, $params{redirect_uri}, 'access_denied', 'User denied the authorization request');
        }
        else {
            my $token;
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
    my $needs_secret = $token_type eq 'mac';

    my $data;
    $c->model('MB')->with_transaction(sub {
        $c->model('EditorOAuthToken')->grant_access_token($token, $needs_secret);
        $data = {
            access_token => $token->access_token,
            token_type => $token_type,
            expires_in => $token->expire_time->subtract_datetime_absolute(DateTime->now)->seconds,
        };
        if ($token->refresh_token) {
            $data->{refresh_token} = $token->refresh_token;
        }
        if ($needs_secret && $token->secret) {
            $data->{mac_key} = $token->secret;
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
