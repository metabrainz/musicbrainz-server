package t::MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use HTTP::Response;
use HTTP::Status qw( :constants );
use JSON::XS qw( decode_json );
use LWP::UserAgent::Mockable;
use Test::Deep qw( cmp_deeply ignore );
use Test::Routine;
use Test::More;
use URI;
use URI::QueryParam;

use DBDefs;
use MusicBrainz::Server::Test qw( build_json_response );

with 't::Mechanize', 't::Context';

my $EDITOR_ID = 3000004;
my $EDITOR_NAME = 'remember_login_credential_test';

sub _get_cookies {
    my ($mech, $name) = @_;

    my @cookies;
    $mech->cookie_jar->scan(sub {
        my (undef, $key, $value, $path, $domain) = @_;
        push @cookies, [$domain, $path, $key, $value] if $key eq $name;
    });
    return @cookies;
}

sub _get_cookie_value {
    my ($mech, $name) = @_;

    my @cookies = _get_cookies($mech, $name);
    return @cookies ? $cookies[0]->[3] : undef;
}

sub _clear_cookies {
    my ($mech, @cookies) = @_;

    # [0..2] is used to exclude the cookie value.
    $mech->cookie_jar->clear(@$_[0..2]) for @cookies;
}

sub _get_remember_login_value {
    my ($mech) = @_;

    split /%09/, _get_cookie_value($mech, 'remember_login');
}

sub _oauth2_mock_response {
    my ($request, $state) = @_;

    my $path = $request->uri->path;
    if ($path eq '/oauth2/token') {
        my $params = URI->new('?' . $request->content);
        my $grant_type = $params->query_param('grant_type') // '';
        if ($grant_type eq 'refresh_token') {
            $state->{refresh_requests}++;
            $state->{last_refresh_token} = $params->query_param('refresh_token');
            if ($state->{reject_refresh_token}) {
                my $response = HTTP::Response->new(HTTP_BAD_REQUEST);
                $response->header('Content-Type' => 'application/json');
                $response->content('{"error":"invalid_grant"}');
                return $response;
            }
            return build_json_response({
                access_token => 'meba_new_access_token',
                token_type => 'Bearer',
                expires_in => 3600,
                refresh_token => 'mebr_new_refresh_token',
            });
        }
        return build_json_response({
            access_token => 'meba_access_token',
            token_type => 'Bearer',
            expires_in => $state->{expires_in} // 3600,
            refresh_token => 'mebr_refresh_token',
            remember_me => JSON::true,
        });
    } elsif ($path eq '/oauth2/introspect') {
        my $issued_at = time;
        return build_json_response({
            active => JSON::true,
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            sub => $state->{sub} // $EDITOR_ID,
            username => $state->{username} // $EDITOR_NAME,
            scope => ['profile'],
            token_type => 'Bearer',
            issued_at => $issued_at,
            expires_at => $issued_at + 3600,
        });
    } elsif ($path eq '/oauth2/userinfo') {
        return build_json_response({
            sub => $state->{sub} // $EDITOR_ID,
            username => $state->{username} // $EDITOR_NAME,
            member_since => '2000-01-01T00:00:00+00:00',
        });
    } elsif ($path eq '/oauth2/revoke') {
        $state->{revoke_requests}++;
        $state->{last_revoked_token} =
            URI->new('?' . $request->content)->query_param('token');
        return build_json_response({});
    }

    return HTTP::Response->new(
        HTTP_INTERNAL_SERVER_ERROR,
        "unexpected request to $path",
    );
}

sub _login_with_remember_me {
    my ($mech) = @_;

    $mech->max_redirect(0);
    $mech->get('/login');

    my $location = URI->new($mech->response->header('Location'));
    my $state = $location->query_param('state');
    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
}

test 'Authentication using the remember_login cookie' => sub {
    my $test = shift;
    my $mech = $test->mech;

    no warnings 'redefine';
    # Enable MetaBrainz OAuth login.
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    my $mock_state = { expires_in => 0, refresh_requests => 0 };
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        _oauth2_mock_response(shift, $mock_state);
    });

    $mech->max_redirect(0);
    $mech->get('/login');
    my $redirect = URI->new($mech->response->header('Location'));
    my $state = $redirect->query_param('state');
    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);

    my @session_cookies = _get_cookies($mech, 'musicbrainz_server_session');
    is(scalar @session_cookies, 1, 'a session cookie was returned');
    _clear_cookies($mech, @session_cookies);

    my (undef, undef, $old_token) = _get_remember_login_value($mech);

    is($mock_state->{refresh_requests}, 0, 'the access token was not refreshed yet');
    $mech->get('/ws/js/check-login');
    my $login_data = decode_json($mech->content);
    is($login_data->{id}, $EDITOR_ID, 'the user was authenticated with only a remember_login cookie');
    is($mock_state->{refresh_requests}, 1, 'the access token was refreshed once');
    is(
        $mock_state->{last_refresh_token},
        'mebr_refresh_token',
        'the stored refresh token was exchanged',
    );

    my (undef, undef, $new_token) = _get_remember_login_value($mech);
    isnt($new_token, $old_token, 'the remember_login token was rotated');

    my $store = $test->c->store;
    # The old remember_login token should point to the new data briefly
    # (see the source package for info explaining why).
    my $old_remember_login_key = "remember_login:$EDITOR_ID:$old_token";
    cmp_deeply(
        $store->get($old_remember_login_key),
        {
          'access_token_expiration' => ignore(),
          'access_token' => 'meba_new_access_token',
          'refresh_token' => 'mebr_new_refresh_token',
          'remember_login_token' => $new_token,
        },
        'the old key points at the new access and remember_login tokens',
    );

    is(
        $store->get("remember_login:$EDITOR_ID:$new_token")->{access_token},
        'meba_new_access_token',
        'the new key holds the new access token',
    );

    my $old_remember_login_key_ttl =
        $store->_connection->ttl($store->_prepare_key($old_remember_login_key));
    ok(
        $old_remember_login_key_ttl > 0 &&
        $old_remember_login_key_ttl <= 600,
        'the old key expires within the rotation TTL',
    );

    LWP::UserAgent::Mockable->finished;
};

test 'remember_login data is discarded on a user ID mismatch' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $store = $test->c->store;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    my $mock_state = {};
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        _oauth2_mock_response(shift, $mock_state);
    });

    _login_with_remember_me($mech);

    my (undef, $user_id, $token) = _get_remember_login_value($mech);
    is($user_id, $EDITOR_ID, 'the remember_login cookie is set for the expected user');

    _clear_cookies($mech, _get_cookies($mech, 'musicbrainz_server_session'));
    $mock_state->{sub} = $EDITOR_ID + 1;
    $mock_state->{username} = 'unexpected_username';

    $mech->get('/ws/js/check-login');
    LWP::UserAgent::Mockable->finished;

    cmp_deeply(
        decode_json($mech->content),
        { id => JSON::null, name => JSON::null },
        'the user is not authenticated',
    );
    is($mock_state->{revoke_requests}, 1, 'the newly issued refresh token is revoked');
    is(
        $mock_state->{last_revoked_token},
        'mebr_new_refresh_token',
        'the revoked token is the newly issued one',
    );
    ok(
        !$store->exists("remember_login:$user_id:$token"),
        'the remember_login data is deleted',
    );
    is(
        _get_cookie_value($mech, 'remember_login'),
       '',
       'the remember_login cookie is cleared',
    );
};

test 'remember_login data is discarded when the refresh token is rejected' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $store = $test->c->store;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    my $mock_state = { expires_in => 0, reject_refresh_token => 1 };
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        _oauth2_mock_response(shift, $mock_state);
    });

    _login_with_remember_me($mech);

    my (undef, $user_id, $token) = _get_remember_login_value($mech);

    _clear_cookies($mech, _get_cookies($mech, 'musicbrainz_server_session'));

    $mech->get('/ws/js/check-login');
    LWP::UserAgent::Mockable->finished;

    is(
        decode_json($mech->content)->{id},
        undef,
        'the user is not authenticated',
    );
    is($mock_state->{refresh_requests}, 1, 'a refresh was attempted');
    ok(!$mock_state->{revoke_requests}, 'no token was revoked');
    ok(
        !$store->exists("remember_login:$user_id:$token"),
        'the remember_login data is deleted',
    );
    is(
        _get_cookie_value($mech, 'remember_login'),
        '',
        'the remember_login cookie is cleared',
    );
};

test 'A malformed remember_login cookie is cleared without authentication' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $store = $test->c->store;

    # bogus user id/token
    $mech->cookie_jar->set_cookie(
        0, 'remember_login', '4%09foo%09bar', '/', 'localhost.local');

    $mech->get('/ws/js/check-login');
    is(
        decode_json($mech->content)->{id},
        undef,
        'the user is not authenticated',
    );
    is(
        _get_cookie_value($mech, 'remember_login'),
        '',
        'the malformed cookie is cleared',
    );

    # old cookie version
    $mech->cookie_jar->set_cookie(
        0, 'remember_login', "1%09$EDITOR_ID%09foo", '/', 'localhost.local');

    # This would likely throw an exception if access was attempted.
    $store->set(
        "remember_login:$EDITOR_ID:foo",
        'malformed_remember_login_data',
    );

    $mech->get('/ws/js/check-login');
    is(
        decode_json($mech->content)->{id},
        undef,
        'an old cookie version is not authenticated',
    );

    $store->delete("remember_login:$EDITOR_ID:foo");
};

test 'Logging out revokes the stored refresh token' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $store = $test->c->store;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    my $mock_state = {};
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        _oauth2_mock_response(shift, $mock_state);
    });

    _login_with_remember_me($mech);

    my (undef, $user_id, $token) = _get_remember_login_value($mech);
    cmp_deeply(
        $store->get("remember_login:$user_id:$token"),
        {
          'access_token_expiration' => ignore(),
          'access_token' => 'meba_access_token',
          'refresh_token' => 'mebr_refresh_token',
          'remember_login_token' => $token,
        },
        'remember_login data is stored after logging in',
    );

    $mech->get('/logout');
    LWP::UserAgent::Mockable->finished;

    is(
        $mock_state->{revoke_requests},
        1,
        'the refresh token is revoked on logout',
    );
    is(
        $mock_state->{last_revoked_token},
        'mebr_refresh_token',
        'the revoked token is the stored one',
    );
    ok(
        !$store->exists("remember_login:$user_id:$token"),
        'the remember_login data is deleted',
    );
    is(
        _get_cookie_value($mech, 'remember_login'),
        '',
        'the remember_login cookie is cleared',
    );
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
