package MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use Carp qw( croak );
use DateTime;
use DateTime::Format::ISO8601;
use Readonly;
use Try::Tiny;

use DBDefs;
use MusicBrainz::Server::Authentication::Utils qw(
    can_user_login
    clear_remember_login_cookie
    exchange_metabrainz_oauth_refresh_token
    oauth_expires_in_to_iso8601
    parse_remember_login_cookie
    revoke_metabrainz_oauth_refresh_token
    set_remember_login_cookie
);
use MusicBrainz::Server::Data::Utils qw( generate_token non_empty );
use MusicBrainz::Server::Log qw( log_debug );
use MusicBrainz::Server::Validation qw( is_database_row_id );

Readonly my $TOKEN_ROTATION_TTL => 600; # 10 minutes

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    # This subroutine may die and propagate errors to its caller (for
    # example, if the MetaBrainz OAuth API is unavailable). Callers should
    # invoke `authenticate` inside `capture_exceptions` (see Root.pm and
    # `Controller::WS::js` for examples).

    my @remember_login_fields = parse_remember_login_cookie($c);
    return unless @remember_login_fields;
    my ($user_id, $remember_login_token) = @remember_login_fields;

    unless (
        is_database_row_id($user_id) &&
        non_empty($remember_login_token)
    ) {
        clear_remember_login_cookie($c);
        log_debug {
            'RememberLoginCredential: malformed cookie value for user ' .
            $user_id
        };
        return;
    }

    my $context = $c->model('MB')->context;
    my $remember_login_data = $context->store->get(
        "remember_login:$user_id:$remember_login_token",
    );
    if (defined $remember_login_data) {
        my $user = $self->_authenticate_with_access_token(
            $c,
            $user_id,
            $remember_login_data,
        );
        return $user if defined $user;
    }

    return $context->sql->auto_transaction(sub {
        $self->_rotate_refresh_token($c, $user_id, $remember_login_token);
    });
}

sub _authenticate_with_access_token {
    my (
        $self,
        $c,
        $user_id,
        $remember_login_data,
    ) = @_;

    my $access_token_expiration = DateTime::Format::ISO8601->parse_datetime(
        $remember_login_data->{access_token_expiration},
    );
    return unless $access_token_expiration > DateTime->now;

    my $oauth_realm = $c->get_auth_realm('website_oauth');
    my $user = $oauth_realm->credential->authenticate($c, $oauth_realm, {
        oauth_access_token => $remember_login_data->{access_token},
    });

    if (can_user_login($user) && $user->id == $user_id) {
        set_remember_login_cookie($c, $user_id, $remember_login_data);
        return $user;
    }
    return;
}

sub _rotate_refresh_token {
    my ($self, $c, $user_id, $remember_login_token) = @_;

    my $context = $c->model('MB')->context;
    my $remember_login_subkey = "$user_id:$remember_login_token";
    my $remember_login_key = "remember_login:$remember_login_subkey";

    unless (
        # The builtin `hashtext` function is not documented by PostgreSQL
        # but seems to be stable across releases. It's just a hash function
        # that returns an integer.
        $context->sql->select_single_value(
            q{SELECT pg_try_advisory_xact_lock(hashtext('remember_login'), hashtext(?))},
            $remember_login_subkey,
        )
    ) {
        # Another request holds the lock and is likely rotating the token;
        # return the page unauthenticated rather than waiting for it.
        log_debug {
            'RememberLoginCredential: could not acquire a lock ' .
            "for user $user_id"
        };
        return;
    }

    # Re-read the data under the lock, in case a concurrent request has
    # already rotated the token between us reading it in `authenticate`
    # and acquiring the lock here.
    my $remember_login_data = $context->store->get($remember_login_key);

    unless (defined $remember_login_data) {
        clear_remember_login_cookie($c);
        return;
    }

    my $user = $self->_authenticate_with_access_token(
        $c,
        $user_id,
        $remember_login_data,
    );
    return $user if defined $user;

    # If this croaks, the existing `remember_login` cookie will be preserved
    # so it can be retried on a later request.
    my $new_token_data = exchange_metabrainz_oauth_refresh_token(
        $c,
        $remember_login_data->{refresh_token},
    );

    if (defined $new_token_data) {
        my $new_remember_login_data = {
            remember_login_token    => generate_token(),
            access_token            => $new_token_data->{access_token},
            access_token_expiration => oauth_expires_in_to_iso8601($new_token_data->{expires_in}),
            refresh_token           => $new_token_data->{refresh_token},
        };
        my $access_token_error;
        $user = try {
            $self->_authenticate_with_access_token(
                $c,
                $user_id,
                $new_remember_login_data,
            );
        } catch {
            $access_token_error = $_;
            return;
        };
        if (defined $user || defined $access_token_error) {
            # Briefly store `$new_remember_login_data` at the old
            # `$remember_login_key` so that concurrent requests acquiring
            # the lock with the previous cookie can read the new OAuth
            # access token. This is done even in cases of 5xx errors
            # attempting to use the new access token, since it may work on
            # retry, but the previous `$remember_login_data` will certainly
            # not.
            $context->store->set(
                $remember_login_key,
                $new_remember_login_data,
                $TOKEN_ROTATION_TTL,
            );
            croak $access_token_error if defined $access_token_error;
        } else {
            clear_remember_login_cookie($c);
            $context->store->delete($remember_login_key);

            revoke_metabrainz_oauth_refresh_token(
                $c,
                $new_remember_login_data->{refresh_token},
            );
        }
    } else {
        log_debug {
            'RememberLoginCredential: refresh token rejected for ' .
            "user $user_id, discarding remember_login data"
        };
        clear_remember_login_cookie($c);
        $context->store->delete($remember_login_key);
    }

    return $user;
}

1;

=head1 DESCRIPTION

A credential verifier for `Catalyst::Plugin::Authentication` that reads the
`remember_login` cookie to verify an associated MetaBrainz OAuth token.
The cookie stores an access token, its expiration, and a refresh token.

If the access token isn't already expired, we can try to use it for
authentication as-is. Access tokens expire after 1 hour, which is less than
the `musicbrainz_server_session` cookie lasts for, so this is unlikely.

Otherwise, we attempt to use the stored refresh token to gain new access and
refresh tokens. This requires an advisory lock, because presenting an
already-revoked refresh token would cause MetaBrainz to revoke *every* access
and refresh token for this user/client pair. (That's also unlikely to happen,
but consider the case where the user returns with an expired session, and
opens multiple tabs in quick succession, all using the same `remember_login`
cookie.)

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
