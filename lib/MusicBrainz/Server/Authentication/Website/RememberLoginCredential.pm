package MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use Digest::SHA qw( sha256_hex );

use MusicBrainz::Server::Authentication::Utils qw(
    can_user_login
    clear_remember_login_cookie
    clear_remember_login_data
    parse_remember_login_cookie
    revoke_metabrainz_oauth_refresh_token
    set_remember_login_cookie
);
use MusicBrainz::Server::Log qw( log_debug );

sub new {
    my ($class, $config, $app, $realm) = @_;

    return bless {}, $class;
}

sub authenticate {
    my ($self, $c, $realm, $auth_info) = @_;

    # This subroutine may die and propagate errors to its caller.
    # Callers should invoke `authenticate` inside `capture_exceptions`
    # (see Root.pm and `Controller::WS::js` for examples).

    my @remember_login_fields = parse_remember_login_cookie($c);
    return unless @remember_login_fields;
    my ($cookie_version, $cookie_user_id, $remember_login_token) = @remember_login_fields;

    if ($cookie_version == -1) {
        clear_remember_login_cookie($c);
        log_debug {
            'RememberLoginCredential: malformed cookie value for user ' .
            $cookie_user_id
        };
        return;
    }

    my $context = $c->model('MB')->context;
    my ($remember_login_key, $authenticated_user_id);

    if ($cookie_version == 4) {
        # MBS-14445: For version 4 cookies, we no longer use the stored
        # refresh token except to revoke it before issuing a version 5
        # cookie. Existence of the `remember_login` data in Valkey is itself
        # sufficient for authentication.
        $remember_login_key = "remember_login:$cookie_user_id:$remember_login_token";

        my $remember_login_data = $context->store->get($remember_login_key);
        if (defined $remember_login_data) {
            revoke_metabrainz_oauth_refresh_token($remember_login_data->{refresh_token});
            $authenticated_user_id = $cookie_user_id;
        }
    } elsif ($cookie_version == 5) {
        $remember_login_key = 'remember_login:' . sha256_hex($remember_login_token);
        $authenticated_user_id = $context->store->get($remember_login_key);
    }

    unless (
        defined $authenticated_user_id &&
        $authenticated_user_id == $cookie_user_id
    ) {
        clear_remember_login_cookie($c);
        return;
    }

    my $oauth_realm = $c->get_auth_realm('website_oauth');
    my $user = $oauth_realm->store->find_user({
        editor_id => $authenticated_user_id,
    }, $c);

    if (can_user_login($user)) {
        # Expire consumed tokens in 5 minutes. This allows the case where
        # the user has no session, and opens multiple tabs using the same
        # `remember_login` token.
        $context->store->expire($remember_login_key, 5 * 60, 'LT');
        set_remember_login_cookie($c, $authenticated_user_id);
        return $user;
    } else {
        clear_remember_login_data($c);
        return;
    }

    return;
}

1;

=head1 DESCRIPTION

A credential verifier for `Catalyst::Plugin::Authentication` that reads the
`remember_login` cookie to authenticate a user.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
