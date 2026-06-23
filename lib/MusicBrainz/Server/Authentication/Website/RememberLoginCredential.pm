package MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use Readonly;
use Try::Tiny;

use DBDefs;
use MusicBrainz::Server::Authentication::Utils qw(
    $REMEMBER_LOGIN_COOKIE_VERSION
    $REMEMBER_LOGIN_COOKIE_EXPIRES
    can_user_login
    clear_remember_login_cookie
    exchange_metabrainz_oauth_refresh_token
    set_remember_login_cookie
);
use MusicBrainz::Server::Data::Utils qw( non_empty );
use MusicBrainz::Server::Validation qw( is_database_row_id );

# How long (in seconds) the rotation lock below is held for. This only
# needs to be long enough to cover a single token exchange with the
# MetaBrainz OAuth server.
Readonly my $ROTATION_LOCK_TTL => 10;

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    my $cookie = $c->req->cookie('remember_login') or return;
    return unless non_empty($cookie->value);

    my ($user_id, $remember_login_token) = _parse_cookie($cookie->value);
    clear_remember_login_cookie($c);

    return unless (
        is_database_row_id($user_id) &&
        non_empty($remember_login_token)
    );

    my $store = $c->model('MB')->context->store;

    # We don't currently support the case where the user has no session, and
    # opens multiple tabs using the same `remember_login` cookie.
    # A lock is acquired to specifically block this scenario, since we
    # can't exchange the same refresh token twice. This should hopefully
    # be very rare, since it requires (1) a missing/expired session cookie,
    # and (2) the user opening multiple concurrent tabs.
    my $lock_key = "refresh_token:$user_id:$remember_login_token:lock";
    unless ($store->set_nx($lock_key, 1, $ROTATION_LOCK_TTL)) {
        $c->response->status(409);
        $c->detach;
    }

    my $user;
    try {
        $user = $self->_rotate_tokens(
            $c,
            $realm,
            $user_id,
            $remember_login_token,
        );
    } finally {
        $store->delete($lock_key);
    };

    return $user;
}

sub _rotate_tokens {
    my ($self, $c, $realm, $user_id, $remember_login_token) = @_;

    my $store = $c->model('MB')->context->store;
    my $refresh_token_key = "refresh_token:$user_id:$remember_login_token";
    my $refresh_token = $store->get($refresh_token_key);
    $store->delete($refresh_token_key);

    return unless non_empty($refresh_token);

    my $new_token_data = exchange_metabrainz_oauth_refresh_token(
        $c,
        $refresh_token,
    );
    return unless defined $new_token_data;
    my $new_access_token = $new_token_data->{access_token};
    my $new_refresh_token = $new_token_data->{refresh_token};

    my $oauth_realm = $c->get_auth_realm('website_oauth');
    my $user = $oauth_realm->credential->authenticate($c, $oauth_realm, {
        oauth_access_token => $new_access_token,
    });

    return unless (
        can_user_login($user) &&
        $user->id == $user_id
    );

    set_remember_login_cookie($c, $user_id, $new_refresh_token);

    return $user;
}

sub _parse_cookie {
    my ($value) = @_;

    my @fields = split /\t/, $value, -1;
    if (@fields == 3) {
        my ($version, $user_id, $token) = @fields;
        return ($user_id, $token)
            if $version == $REMEMBER_LOGIN_COOKIE_VERSION;
    }
    return ();
}

1;

=head1 DESCRIPTION

A credential verifier for `Catalyst::Plugin::Authentication` that reads the
`remember_login` cookie to lookup a MetaBrainz OAuth refresh token.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
