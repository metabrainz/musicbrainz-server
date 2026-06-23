package MusicBrainz::Server::Authentication::Utils;

use strict;
use warnings;

use base 'Exporter';
use DateTime;
use HTTP::Request::Common qw( POST );
use HTTP::Status qw( is_server_error is_success );
use Readonly;

use DBDefs;
use MusicBrainz::Errors qw(
    build_request_and_user_context
    send_message_to_sentry
);
use MusicBrainz::Server::Entity::EditorOAuthToken;
use MusicBrainz::Server::Constants qw( :access_scope );

our @EXPORT_OK = qw(
    $REMEMBER_LOGIN_COOKIE_VERSION
    $REMEMBER_LOGIN_COOKIE_EXPIRES
    can_user_login
    clear_remember_login_cookie
    exchange_metabrainz_oauth_refresh_token
    find_active_metabrainz_oauth_access_token
    find_active_oauth_access_token
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
    send_message_to_sentry(
        'Invalid MetaBrainz refresh token',
        build_request_and_user_context($c),
        extra => { refresh_token => $refresh_token },
    );
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
                editor_id => $res_content->{metabrainz_user_id},
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

sub set_remember_login_cookie {
    my ($c, $user_id, $refresh_token) = @_;

    my $remember_login_token = $c->generate_nonce;

    $c->model('MB')->context->store->set(
        "refresh_token:$user_id:$remember_login_token",
        $refresh_token,
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

    return $remember_login_token;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
