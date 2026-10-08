package t::MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use Digest::SHA qw( sha256_hex );
use HTTP::Response;
use HTTP::Status qw( :constants );
use JSON::XS qw( decode_json );
use LWP::UserAgent::Mockable;
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

sub _remember_login_key {
    my ($token) = @_;
    return 'remember_login:' . sha256_hex($token);
}

sub _oauth2_mock_response {
    my ($request, $state) = @_;

    my $path = $request->uri->path;
    if ($path eq '/oauth2/token') {
        my $params = URI->new('?' . $request->content);
        my $grant_type = $params->query_param('grant_type') // '';
        if ($grant_type ne 'authorization_code') {
            return HTTP::Response->new(
                HTTP_INTERNAL_SERVER_ERROR,
                "unexpected OAuth grant type: $grant_type",
            );
        }
        return build_json_response({
            access_token => 'meba_access_token',
            remember_me => JSON::true,
        });
    } elsif ($path eq '/oauth2/introspect') {
        my $issued_at = time;
        return build_json_response({
            active => JSON::true,
            client_id => DBDefs->METABRAINZ_OAUTH_CLIENT_ID,
            sub => $EDITOR_ID,
            username => $EDITOR_NAME,
            scope => ['profile'],
            token_type => 'Bearer',
            issued_at => $issued_at,
            expires_at => $issued_at + 3600,
        });
    } elsif ($path eq '/oauth2/userinfo') {
        return build_json_response({
            sub => $EDITOR_ID,
            username => $EDITOR_NAME,
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

    my $mock_state = {};
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        _oauth2_mock_response(shift, $mock_state);
    });

    _login_with_remember_me($mech);

    my @session_cookies = _get_cookies($mech, 'musicbrainz_server_session');
    is(scalar @session_cookies, 1, 'a session cookie was returned');
    _clear_cookies($mech, @session_cookies);

    my ($version, $user_id, $old_token) = _get_remember_login_value($mech);
    is($version, 5, 'a version 5 remember_login cookie was returned');
    is($user_id, $EDITOR_ID, 'the cookie contains the expected user ID');

    my $store = $test->c->store;
    is(
        $store->get(_remember_login_key($old_token)),
        $EDITOR_ID,
        'the hashed remember_login token maps to the user ID',
    );

    $mech->get('/ws/js/check-login');
    my $login_data = decode_json($mech->content);
    is($login_data->{id}, $EDITOR_ID, 'the user was authenticated with only a remember_login cookie');
    ok(!$mock_state->{revoke_requests}, 'no OAuth token was revoked');

    my ($new_version, undef, $new_token) = _get_remember_login_value($mech);
    is($new_version, 5, 'the rotated cookie is version 5');
    isnt($new_token, $old_token, 'the remember_login token was rotated');

    is(
        $store->get(_remember_login_key($new_token)),
        $EDITOR_ID,
        'the rotated token maps to the user ID',
    );

    my $old_remember_login_key = _remember_login_key($old_token);
    my $old_remember_login_key_ttl =
        $store->_connection->ttl($store->_prepare_key($old_remember_login_key));
    ok(
        $old_remember_login_key_ttl > 0 &&
        $old_remember_login_key_ttl <= 300,
        'the old key expires within the rotation TTL',
    );

    $store->expire($old_remember_login_key, 60);
    $mech->cookie_jar->set_cookie(
        0, 'remember_login', "5%09$user_id%09$old_token",
        '/', 'localhost.local');
    _clear_cookies($mech, _get_cookies($mech, 'musicbrainz_server_session'));

    $mech->get('/ws/js/check-login');
    my $reused_remember_login_key_ttl =
        $store->_connection->ttl($store->_prepare_key($old_remember_login_key));
    ok(
        $reused_remember_login_key_ttl > 0 &&
        $reused_remember_login_key_ttl <= 60,
        'reusing the old token does not extend its rotation TTL',
    );

    LWP::UserAgent::Mockable->finished;
};

test 'A remember_login cookie is rejected on a user ID mismatch' => sub {
    # The cookie value itself contains the user ID, and it should match the
    # user ID stored in Valkey. That's mostly an internal consistency
    # check ("these should match or something weird happened"). There's
    # otherwise no reason we have to store the user ID in the cookie,
    # except that it was previously included in the version 4 cookie.
    # -mwiencek

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
    $store->set(_remember_login_key($token), $EDITOR_ID + 1, 31536000);

    $mech->get('/ws/js/check-login');
    LWP::UserAgent::Mockable->finished;

    is(decode_json($mech->content)->{id}, undef, 'the user is not authenticated');
    ok($store->exists(_remember_login_key($token)), 'the data in valkey is not deleted');
    is(
        _get_cookie_value($mech, 'remember_login'),
       '',
       'the remember_login cookie is cleared',
    );
};

test 'A version 4 remember_login cookie is migrated to version 5' => sub {
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

    my (undef, $user_id, $version_5_token) = _get_remember_login_value($mech);
    $store->delete(_remember_login_key($version_5_token));

    my $version_4_token = 'legacy_remember_login_token';
    my $version_4_key = "remember_login:$user_id:$version_4_token";
    $store->set($version_4_key, { refresh_token => 'mebr_refresh_token' }, 31536000);
    $mech->cookie_jar->set_cookie(
        0, 'remember_login', "4%09$user_id%09$version_4_token",
        '/', 'localhost.local');

    _clear_cookies($mech, _get_cookies($mech, 'musicbrainz_server_session'));

    $mech->get('/ws/js/check-login');
    LWP::UserAgent::Mockable->finished;

    is(
        decode_json($mech->content)->{id},
        $EDITOR_ID,
        'the user is authenticated',
    );
    is($mock_state->{revoke_requests}, 1, 'refresh token revocation was attempted');
    is($mock_state->{last_revoked_token}, 'mebr_refresh_token',
       'the legacy refresh token was submitted for revocation');

    my ($version, undef, $new_token) = _get_remember_login_value($mech);
    is($version, 5, 'the cookie was migrated to version 5');
    is(
        $store->get(_remember_login_key($new_token)),
        $EDITOR_ID,
        'the new version 5 token is stored',
    );

    my $version_4_key_ttl =
        $store->_connection->ttl($store->_prepare_key($version_4_key));
    ok(
        $version_4_key_ttl > 0 && $version_4_key_ttl <= 300,
        'the version 4 key expires within the rotation TTL',
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

test 'Logging out deletes the remember_login token' => sub {
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

    my (undef, undef, $token) = _get_remember_login_value($mech);
    is(
        $store->get(_remember_login_key($token)),
        $EDITOR_ID,
        'remember_login data is stored after logging in',
    );

    $mech->get('/logout');
    LWP::UserAgent::Mockable->finished;

    ok(!$mock_state->{revoke_requests}, 'no OAuth token is revoked on logout');
    ok(
        !$store->exists(_remember_login_key($token)),
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
