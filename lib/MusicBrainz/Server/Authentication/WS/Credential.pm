package MusicBrainz::Server::Authentication::WS::Credential;
use parent qw/Catalyst::Authentication::Credential::HTTP/;

use DBDefs;
use Encode qw( decode );
use HTTP::Status qw( HTTP_BAD_REQUEST );
use MIME::Base64 qw( encode_base64 );
use Try::Tiny;

sub authenticate
{
    my ($self, $c, $realm, $auth_info) = @_;
    my $auth;

    $auth = $self->_authenticate_bearer($c, $realm, $auth_info);
    return $auth if $auth;

    # We can only use digest authentication if the Authorization header is
    # correctly encoded as UTF-8. Catalyst::Plugin::Unicode::Encoding only deals
    # with parameters and URL captures - not arbitrary headers.
    try {
        decode('utf-8', $c->req->header('Authorization'), Encode::FB_CROAK)
    }
    catch {
        $c->stash->{bad_auth_encoding} = 1;
        $c->response->status(HTTP_BAD_REQUEST);
        $c->detach;
    };

    $auth = $self->SUPER::authenticate($c, $realm, $auth_info);
    if ($auth && ($auth->requires_password_reset || $auth->deleted)) {
        $self->authentication_failed($c, $realm, $auth_info);
    }
    else {
        return $auth;
    }
}

sub authorization_required_response
{
    my ($self, $c, $realm, $auth_info) = @_;

    # OAuth schemes are not likely to be understood by browsers, so use Digest first
    $self->SUPER::authorization_required_response($c, $realm, $auth_info);

    if ( my $bearer = $self->_build_bearer_auth_header($c, $auth_info) ) {
        Catalyst::Authentication::Credential::HTTP::_add_authentication_header($c, $bearer);
    }
}

sub _build_bearer_auth_header
{
    my ($self, $c, $opts) = @_;

    return Catalyst::Authentication::Credential::HTTP::_join_auth_header_parts(
        Bearer => $self->_build_auth_header_common($c, $opts)
    );
}

sub _authenticate_bearer
{
    my ($self, $c, $realm, $auth_info) = @_;

    return if DBDefs->OAUTH2_ENFORCE_TLS && !$c->request->secure;

    $c->log->debug('Checking http bearer authentication.') if $c->debug;

    my @authorization = $c->req->headers->header('Authorization');
    for my $authorization (@authorization) {
        next unless $authorization =~ s/^\s*Bearer\s+(\S+)\s*$/\1/;
        $c->log->debug('Found bearer access token in Authorization header') if $c->debug;
        my $user = $realm->find_user( { oauth_access_token => $authorization }, $c);
        return $user if $user && !$user->oauth_token->is_expired;
    }

    if (exists $c->req->params->{access_token}) {
        $c->log->debug('Found bearer access token in GET/POST params') if $c->debug;
        my $user = $realm->find_user( { oauth_access_token => $c->req->params->{access_token} }, $c);
        return $user if $user && !$user->oauth_token->is_expired && !$user->deleted;
    }

    return;
}

sub _build_auth_header_common {
    my ($self, $c, $opts) = @_;
    return (
        $self->SUPER::_build_auth_header_common($c, $opts),
        'charset=UTF-8',
    );
}

1;

=head1 DESCRIPTION

Extension of Catalyst::Authentication::Credential::HTTP to support OAuth 2.0
authentication methods Bearer and MAC.

http://tools.ietf.org/html/rfc6750

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
