package Catalyst::Authentication::Credential::HTTP::MusicBrainz;
use base qw/Catalyst::Authentication::Credential::HTTP/;

sub authenticate
{
    my ($self, $c, $realm, $auth_info) = @_;
    my $auth;

    $auth = $self->_authenticate_bearer($c, $realm, $auth_info);
    return $auth if $auth;

    $auth = $self->_authenticate_mac($c, $realm, $auth_info);
    return $auth if $auth;

    return $self->SUPER::authenticate($c, $realm, $auth_info);
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

    $c->log->debug('Checking http bearer authentication.') if $c->debug;

    my @authorization = $c->req->headers->header('Authorization');
    for my $authorization (@authorization) {
        next unless $authorization =~ s/^\s*Bearer\s+(\S+)\s*$/\1/;
        $c->log->debug('Found bearer access token in Authorization header') if $c->debug;
        my $user_obj = $realm->find_user( { oauth_access_token => $authorization }, $c);
        # XXX check access_token expiration
        return $user_obj if $user_obj;
    }

    if (exists $c->req->params->{access_token}) {
        $c->log->debug('Found bearer access token in GET/POST params') if $c->debug;
        my $user_obj = $realm->find_user( { oauth_access_token => $c->req->params->{access_token} }, $c);
        # XXX check access_token expiration
        return $user_obj if $user_obj;
    }

    return;
}

sub _authenticate_mac
{
    my ($self, $c, $realm, $auth_info) = @_;

    $c->log->debug('Checking http mac authentication.') if $c->debug;

    my @authorization = $c->req->headers->header('Authorization');
    for my $authorization (@authorization) {
        next unless $authorization =~ s/^\s*MAC\s+(\S+)\s*$/\1/;
        my %res = map {
            my @key_val = split /=/, $_, 2;
            $key_val[0] = lc $key_val[0];
            $key_val[1] =~ s{"}{}g;    # remove the quotes
            @key_val;
        } split /,\s?/, $authorization;
        my $user_obj = $realm->find_user( { oauth_access_token => $res{id} }, $c);
        # XXX check access_token expiration
        # XXX check nonce
        # XXX check mac signature
        return $user_obj if $user_obj;
    }

    return;
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
