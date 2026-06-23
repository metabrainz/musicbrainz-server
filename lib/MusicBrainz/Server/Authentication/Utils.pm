package MusicBrainz::Server::Authentication::Utils;

use strict;
use warnings;

use base 'Exporter';
use DateTime;
use DateTime::Duration;
use HTTP::Request::Common qw( POST );
use HTTP::Status qw( is_server_error is_success );
use Readonly;

use DBDefs;
use MusicBrainz::Server::Data::Utils qw(
    datetime_to_iso8601
    non_empty
);
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Constants qw( :access_scope );

our @EXPORT_OK = qw(
    can_user_login
    clear_remember_login_cookie
    clear_remember_login_data
    exchange_metabrainz_oauth_refresh_token
    find_active_metabrainz_oauth_access_token
    find_active_oauth_access_token
    oauth_expires_in_to_iso8601
    parse_remember_login_cookie
    revoke_metabrainz_oauth_refresh_token
    set_remember_login_cookie
);

Readonly our $REMEMBER_LOGIN_COOKIE_VERSION => 4;
Readonly our $REMEMBER_LOGIN_COOKIE_EXPIRES => '+1y';

sub can_user_login {
    my ($user) = @_;

    return (
        defined $user &&
        !$user->deleted &&
        !$user->is_spammer
    );
}

sub clear_remember_login_cookie {
    my ($c) = @_;

    $c->res->cookies->{remember_login} = {
        value => '',
        expires => $REMEMBER_LOGIN_COOKIE_EXPIRES,
    };
}

sub clear_remember_login_data {
    my ($c) = @_;

    my @remember_login_fields = parse_remember_login_cookie($c);
    if (@remember_login_fields) {
        my ($user_id, $remember_login_token) = @remember_login_fields;
        clear_remember_login_cookie($c);

        my $store = $c->model('MB')->context->store;
        my $remember_login_key = "remember_login:$user_id:$remember_login_token";

        my $remember_login_data = $store->get($remember_login_key);
        if (defined $remember_login_data) {
            revoke_metabrainz_oauth_refresh_token(
                $c,
                $remember_login_data->{refresh_token},
            );
            $store->delete($remember_login_key);
        }
    }
    return;
}

sub exchange_metabrainz_oauth_refresh_token {
    my ($c, $refresh_token) = @_;

    my $ctx = $c->model('MB')->context;
    my $token_uri = DBDefs->METABRAINZ_INTERNAL_URL . '/oauth2/token';
    my $res = $ctx->lwp->request(
        POST $token_uri,
        [
            grant_type => 'refresh_token',
            refresh_token => $refresh_token,
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
        ],
    );

    if (is_success($res->code)) {
        my $token_data = $c->json_utf8->decode($res->content);
        return $token_data;
    } elsif (is_server_error($res->code)) {
        die 'An internal error occurred while attempting to refresh ' .
            'the MetaBrainz OAuth token.';
    }
    return;
}

sub find_active_metabrainz_oauth_access_token {
    my ($c, $access_token) = @_;

    my $ctx = $c->model('MB')->context;
    my $introspect_url = DBDefs->METABRAINZ_INTERNAL_URL . '/oauth2/introspect';
    my $res = $ctx->lwp->request(
        POST $introspect_url,
        {
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
            token => $access_token,
        },
    );
    if (is_success($res->code)) {
        my $res_content = $c->json_utf8->decode($res->content);
        if ($res_content->{active}) {
            my $scope = 0;
            for my $scope_name (@{ $res_content->{scope} }) {
                $scope |= $ACCESS_SCOPE_BY_NAME{$scope_name};
            }
            my $token_instance = MusicBrainz::Server::Entity::EditorOAuthToken->new(
                access_token => $access_token,
                editor_id => $res_content->{sub},
                expire_time => DateTime->from_epoch($res_content->{expires_at}),
                granted => DateTime->from_epoch($res_content->{issued_at}),
                scope => $scope,
            );
            if ($token_instance->is_expired) {
                return;
            }
            return $token_instance;
        }
    } elsif (is_server_error($res->code)) {
        die 'An internal error occurred while attempting to introspect ' .
            'the access token.';
    }
    return;
}

sub find_active_musicbrainz_oauth_access_token {
    my ($c, $access_token) = @_;

    my $token_instance = $c->model('EditorOAuthToken')->get_by_access_token($access_token);
    if (defined $token_instance && !$token_instance->is_expired) {
        return $token_instance;
    }
    return;
}

sub find_active_oauth_access_token {
    my ($c, $access_token) = @_;

    return unless defined $access_token;

    if ($access_token =~ /^meba_/) {
        return find_active_metabrainz_oauth_access_token($c, $access_token);
    }
    return find_active_musicbrainz_oauth_access_token($c, $access_token);
}

=sub oauth_expires_in_to_iso8601()

Converts C<expires_in> (in seconds), as you would receive from an
OAuth token endpoint, to an ISO8601 datetime string.

 * This subroutine should be called right after the token endpoint returns,
   since the returned datetime is relative to "now".

 * 10 seconds is subtracted from C<expires_in> as a buffer.

=cut

sub oauth_expires_in_to_iso8601 {
    my ($expires_in) = @_;

    my $offset = DateTime::Duration->new(seconds => ($expires_in - 10));
    return datetime_to_iso8601(DateTime->now->add($offset));
}

sub parse_remember_login_cookie {
    my ($c) = @_;

    my $cookie = $c->req->cookie('remember_login');
    return () unless defined $cookie && non_empty($cookie->value);

    my @fields = split /\t/, $cookie->value, -1;
    if (@fields == 3) {
        my ($version, $user_id, $token) = @fields;
        return ($user_id, $token)
            if $version == $REMEMBER_LOGIN_COOKIE_VERSION;
    }
    return ();
}

sub revoke_metabrainz_oauth_refresh_token {
    my ($c, $refresh_token) = @_;

    my $revoke_url = DBDefs->METABRAINZ_INTERNAL_URL . '/oauth2/revoke';
    my $res = $c->model('MB')->context->lwp->request(
        POST $revoke_url,
        {
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            client_secret => DBDefs->METABRAINZ_OAUTH_CLIENT_SECRET,
            token => $refresh_token,
            token_type_hint => 'refresh_token',
        },
    );
    if (is_server_error($res->code)) {
        die 'An internal error occurred while attempting to revoke ' .
            'the refresh token.';
    }
    return;
}

sub set_remember_login_cookie {
    my ($c, $user_id, $remember_login_data) = @_;

    # The caller is responsible for generating a `remember_login_token` (via
    # `generate_token`) when a new one is wanted. It's stored alongside
    # the OAuth tokens because it may differ from the Valkey key it's stored
    # under during token rotation.
    my $remember_login_token = $remember_login_data->{remember_login_token};

    $c->model('MB')->context->store->set(
        "remember_login:$user_id:$remember_login_token",
        {
            access_token => $remember_login_data->{access_token},
            access_token_expiration => $remember_login_data->{access_token_expiration},
            refresh_token => $remember_login_data->{refresh_token},
            remember_login_token => $remember_login_token,
        },
        31536000,  # 1 year (60 * 60 * 24 * 365)
    );

    $c->res->cookies->{remember_login} = {
        expires => $REMEMBER_LOGIN_COOKIE_EXPIRES,
        value => join("\t", $REMEMBER_LOGIN_COOKIE_VERSION,
                            $user_id,
                            $remember_login_token),
        samesite => 'Lax',
        $c->req->secure ? (secure => 1) : (),
        httponly => 1,
    };

    return;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
