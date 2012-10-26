package MusicBrainz::Server::Controller::OAuth2;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller'; }

use DBDefs;
use DateTime;
use URI;
use URI::QueryParam;

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
        unless $params{redirect_uri} eq $application->oauth_redirect_uri;

    $self->_send_redirect_error($c, $params{redirect_uri}, 'unsupported_response_type', 'Unsupported response type')
        unless $params{response_type} eq 'code';

    my %scopes;
    my %allowed_scopes = ( profile => 1, tags => 1, ratings => 1 );
    for my $scope (split /\s+/, $params{scope}) {
        $self->_send_redirect_error($c, $params{redirect_uri}, 'invalid_scope', 'Unsupported scope: ' . $scope)
            unless exists $allowed_scopes{$scope};
        $scopes{$scope} = 1;
    }

    my $form = $c->form( form => 'SubmitCancel' );
    if ($c->form_posted && $form->submitted_and_valid($c->req->params)) {
        if ($form->field('cancel')->input) {
            $self->_send_redirect_error($c, $params{redirect_uri}, 'access_denied', 'User denied the authorization request');
        }
        else {
            my $token;
            $c->model('MB')->with_transaction(sub {
                $token = $c->model('EditorOAuthToken')->create_authorization_code($c->user->id, $application->id);
            });
            $self->_send_redirect_response($c, $params{redirect_uri}, {
                code => $token->authorization_code,
            });
        }
    }

    $c->stash( application => $application, scopes => \%scopes );
}

sub oob : Local Args(0)
{
    my ($self, $c) = @_;

    my $code = $c->request->params->{code};
    my $token = $c->model('EditorOAuthToken')->get_by_authorization_code($code);

    $self->_send_html_error($c, 'invalid_request', 'Invalid authorization code')
        unless defined $token;

    $self->_send_html_error($c, 'invalid_request', 'Expired authorization code')
        unless $token->expire_time < DateTime->now;

    $c->model('Application')->load($token);

    $c->stash( code => $code, application => $token->application );
}

sub token : Local Args(0)
{
    my ($self, $c) = @_;

    my ($client_id, $client_secret) = $c->request->headers->authorization_basic;
    unless (defined $client_id) {
        $client_id = $c->request->params->{client_id};
        $client_secret = $c->request->params->{client_secret};
    }
    unless (defined $client_id) {
        $self->_send_error($c, 'invalid_request', 'Missing client_id');
    }

    my $application = $c->model('Application')->get_by_oauth_id($client_id);
    unless (defined $application) {
        $self->_send_error($c, 'invalid_client', 'Unknown client_id');
    }

    if (defined $client_secret) {
        unless ($application->oauth_secret eq $client_secret) {
            $self->_send_error($c, 'invalid_client', 'Client not authentified, incorrect secret');
        }
    }
    elsif ($application->oauth_confidential) {
        $self->_send_error($c, 'invalid_client', 'Client not authentified, missing secret');
    }

    my $grant_type = $c->request->params->{grant_type};
    unless (defined $grant_type) {
        $self->_send_error($c, 'invalid_request', 'Missing grant_type');
    }

    my $code = $c->request->params->{code};
    unless (defined $grant_type) {
        $self->_send_error($c, 'invalid_request', 'Missing parameter code');
    }

    my $token;
    if ($grant_type eq 'authorization_code') {
        $token = $c->model('EditorOAuthToken')->get_by_authorization_code($code);
        unless (defined $token) {
            $self->_send_error($c, 'invalid_grant', 'Invalid authorization code');
        }
    }
    elsif ($grant_type eq 'refresh_token') {
        $token = $c->model('EditorOAuthToken')->get_by_refresh_token($code);
        unless (defined $token) {
            $self->_send_error($c, 'invalid_grant', 'Invalid refresh token');
        }
    }
    else {
        $self->_send_error($c, 'unsupported_grant_type', 'Unsupported grant_type, only authorization_code and refresh_token are supported');
    }

    my $token_type = $c->request->params->{token_type};
    $token_type ||= 'bearer';
    unless ($token_type eq 'bearer' || $token_type eq 'mac') {
        $self->_send_error($c, 'invalid_request', 'Invalid requested token type, only bearer and mac are allowed');
    }
    my $needs_secret = $token_type eq 'mac';

    $c->model('MB')->with_transaction(sub {
        $c->model('EditorOAuthToken')->grant_access_token($token, $needs_secret);
        my $data = {
            access_token => $token->access_token,
            token_type => "bearer",
            expires_in => $token->expire_time->subtract_datetime_absolute(DateTime->now)->seconds,
            refresh_token => $token->refresh_token
        };
        if ($needs_secret && $token->secret) {
            $data->{secret} = $token->secret;
        }
        $self->_send_response($c, $data);
    });
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
        $self->_send_redirect_response($c, {
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
