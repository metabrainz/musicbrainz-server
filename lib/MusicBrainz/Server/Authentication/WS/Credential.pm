package MusicBrainz::Server::Authentication::WS::Credential;
use base qw/Catalyst::Authentication::Credential::HTTP/;

use DBDefs;
use Digest::HMAC_SHA1 qw ( hmac_sha1 );
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

    $auth = $self->_authenticate_mac($c, $realm, $auth_info);
    return $auth if $auth;

    # We can only use digest authentication if the Authorization header is
    # correctly encoded as UTF-8. Catalyst::Plugin::Unicode::Encoding only deals
    # with parameters and URL captures - not arbitrary headers.
    try {
        decode('utf-8', $c->req->header('Authorization'), Encode::FB_CROAK)
    }
    catch {
        $c->response->status(HTTP_BAD_REQUEST);
        $c->detach;
    };

    $auth = $self->SUPER::authenticate($c, $realm, $auth_info);
    if ($auth && $auth->requires_password_reset) {
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

    if ( my $mac = $self->_build_mac_auth_header($c, $auth_info) ) {
        Catalyst::Authentication::Credential::HTTP::_add_authentication_header($c, $mac);
    }
}

sub _build_bearer_auth_header
{
    my ($self, $c, $opts) = @_;

    return Catalyst::Authentication::Credential::HTTP::_join_auth_header_parts(
        Bearer => $self->_build_auth_header_common($c, $opts)
    );
}

sub _build_mac_auth_header
{
    my ($self, $c, $opts) = @_;

    return Catalyst::Authentication::Credential::HTTP::_join_auth_header_parts(
        MAC => $self->_build_auth_header_common($c, $opts)
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
        return $user if $user && !$user->oauth_token->is_expired && !$user->oauth_token->mac_key;
    }

    if (exists $c->req->params->{access_token}) {
        $c->log->debug('Found bearer access token in GET/POST params') if $c->debug;
        my $user = $realm->find_user( { oauth_access_token => $c->req->params->{access_token} }, $c);
        return $user if $user && !$user->oauth_token->is_expired && !$user->oauth_token->mac_key;
    }

    return;
}

sub _authenticate_mac
{
    my ($self, $c, $realm, $auth_info) = @_;

    $c->log->debug('Checking http mac authentication.') if $c->debug;

    my @authorization = $c->req->headers->header('Authorization');
    for my $authorization (@authorization) {
        next unless $authorization =~ s/^\s*MAC\s+(.+)\s*$/\1/;
        $c->log->debug('Found mac access token in Authorization header') if $c->debug;
        my %res = map {
            my @key_val = split /=/, $_, 2;
            $key_val[0] = lc $key_val[0];
            $key_val[1] =~ s{"}{}g;    # remove the quotes
            @key_val;
        } split /,\s?/, $authorization;
        my $user = $realm->find_user( { oauth_access_token => $res{id} }, $c);
        return $user if $user && !$user->oauth_token->is_expired && $self->_check_mac($c, $user, $res{ts}, $res{nonce}, $res{mac}, $res{ext});
    }

    return;
}

sub _check_mac
{
    my ($self, $c, $user, $ts, $nonce, $mac, $ext) = @_;

    my $token = $user->oauth_token;
    return 0 unless $token->mac_key && $ts && $nonce && $mac;

    my $request_string = join("\n", $ts, $nonce,
        uc($c->request->method),
        $c->request->uri->path_query,
        $c->request->uri->host,
        $c->request->uri->port,
        $ext || "", "");

    my $expected_mac = encode_base64(hmac_sha1($request_string, $token->mac_key), "");
    return 0 if $mac ne $expected_mac;

    my $max_delay = 5 * 60; # 5 minutes
    my $key = sprintf('oauth2mac:%s:%s:%s', $user->id, $ts, $nonce);

    return 0 if $c->get($key);
    $c->cache->set($key, 1, $max_delay);

    my $time_diff = $token->mac_time_diff;
    unless (defined $time_diff) {
        $time_diff =  time() - $ts;
        $c->model('MB')->with_transaction(sub {
            $c->model('EditorOAuthToken')->update_mac_time_diff($token, $time_diff);
        });
    }

    my $client_ts = time() - $time_diff;
    return 0 if abs($client_ts - $ts) > $max_delay;

    return 1;
}

1;

=head1 DESCRIPTION

Extension of Catalyst::Authentication::Credential::HTTP to support OAuth 2.0
authentication methods Bearer and MAC.

http://tools.ietf.org/html/rfc6750

http://tools.ietf.org/html/draft-ietf-oauth-v2-http-mac-01

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
