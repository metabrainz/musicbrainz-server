package t::MusicBrainz::Server::Authentication::Website::RememberLoginCredential;

use strict;
use warnings;

use HTTP::Response;
use HTTP::Status qw( :constants );
use LWP::UserAgent::Mockable;
use Test::Routine;
use Test::More;
use URI;
use URI::QueryParam;

use MusicBrainz::Server::Test qw( build_json_response );

with 't::Mechanize', 't::Context';

my $EDITOR_ID = 3000004;
my $EDITOR_NAME = 'remember_login_credential_test';

test 'Authentication using the remember_login cookie' => sub {
    my $test = shift;
    my $mech = $test->mech;
    my $refresh_requests = 0;

    no warnings 'redefine';
    # Enable MetaBrainz OAuth login.
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    use warnings 'redefine';

    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        my ($request) = @_;
        my $path = $request->uri->path;

        if ($path eq '/oauth2/token') {
            my $params = URI->new('?' . $request->content);
            my $grant_type = $params->query_param('grant_type');
            if (defined $grant_type && $grant_type eq 'refresh_token') {
                ++$refresh_requests;
                is(
                    $params->query_param('refresh_token'),
                    'mebr_old_refresh_token',
                    'the stored refresh token is exchanged',
                );
                return build_json_response({
                    access_token => 'meba_new_access_token',
                    token_type => 'Bearer',
                    expires_in => 3600,
                    refresh_token => 'mebr_new_refresh_token',
                });
            }
            return build_json_response({
                access_token => 'meba_old_access_token',
                token_type => 'Bearer',
                expires_in => 0,
                refresh_token => 'mebr_old_refresh_token',
                remember_me => JSON::true,
            });
        } elsif ($path eq '/oauth2/introspect') {
            my $issued_at = time;
            return build_json_response({
                active => JSON::true,
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
        }

        return HTTP::Response->new(
            HTTP_INTERNAL_SERVER_ERROR, "unexpected request to $path");
    });

    $mech->max_redirect(0);
    $mech->get('/login');
    my $redirect = URI->new($mech->response->header('Location'));
    my $state = $redirect->query_param('state');
    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);

    my @session_cookies;
    $mech->cookie_jar->scan(sub {
        my ($version, $name, $value, $path, $domain) = @_;
        push @session_cookies, [$domain, $path, $name]
            if $name eq 'musicbrainz_server_session';
    });
    is(scalar @session_cookies, 1, 'a session cookie was returned');
    $mech->cookie_jar->clear(@$_) for @session_cookies;

    is($refresh_requests, 0, 'the access token was not refreshed yet');
    $mech->get('/ws/js/check-login');
    my $login_data = JSON->new->decode($mech->content);
    is($login_data->{id}, $EDITOR_ID, 'the user was authenticated with only a remember_login cookie');
    is($refresh_requests, 1, 'the access token was refreshed once');

    LWP::UserAgent::Mockable->finished;
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
