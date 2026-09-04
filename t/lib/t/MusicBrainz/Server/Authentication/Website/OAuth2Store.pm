package t::MusicBrainz::Server::Authentication::Website::OAuth2Store;

use strict;
use warnings;

use HTTP::Status qw( :constants );
use JSON::XS qw( decode_json );
use LWP::UserAgent::Mockable;
use Test::Deep qw( cmp_deeply );
use Test::Routine;
use Test::More;
use URI;
use URI::QueryParam;

use DBDefs;
use MusicBrainz::Server::Constants qw( $SPAMMER_FLAG );
use MusicBrainz::Server::Test qw( metabrainz_oauth2_response );

with 't::Mechanize', 't::Context';

my $EDITOR_ID = 3000003;
my $EDITOR_NAME = 'auto_create_user_test';

sub _metabrainz_login_request {
    my ($mech, %extra_mock_state) = @_;

    $mech->max_redirect(0);
    $mech->get('/login');

    my $location = URI->new($mech->response->header('Location'));
    my $state = $location->query_param('state');
    my $code_challenge = $location->query_param('code_challenge');

    ok($code_challenge, 'the authorize URL contains a code challenge');
    is(
        $location->query_param('code_challenge_method'),
        'S256',
        'the code challenge method is S256',
    );

    my $mock_state = {
        state => $state,
        code_challenge => $code_challenge,
        editor_id => $EDITOR_ID,
        editor_name => $EDITOR_NAME,
        %extra_mock_state,
    };
    LWP::UserAgent::Mockable->reset;
    LWP::UserAgent::Mockable->set_record_pre_callback(sub {
        metabrainz_oauth2_response(shift, $mock_state);
    });

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $state);
    LWP::UserAgent::Mockable->finished;

    return $mock_state;
}

test 'Auto-create user on OAuth login' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    no warnings 'redefine';
    # Enable MetaBrainz OAuth login.
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    ok(
        !defined $c->model('Editor')->get_by_id($EDITOR_ID),
        "editor $EDITOR_ID does not exist before logging in",
    );

    my $mock_state = _metabrainz_login_request($mech);

    my $editor = $c->model('Editor')->get_by_id($EDITOR_ID);
    ok(
        defined $editor && $editor->name eq $EDITOR_NAME,
        "editor $EDITOR_ID was auto-created on login",
    );

    $mech->get('/metabrainz/oauth2/callback?code=foo&state=' . $mock_state->{state});
    is(
        $mech->status,
        HTTP_BAD_REQUEST,
        'replaying the callback with the same state is rejected',
    );
    $mech->content_contains('This page has expired');
};

test 'Login is refused if the introspected client_id does not match' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    _metabrainz_login_request($mech, client_id => 'other_client');
    is(
        $mech->status,
        HTTP_INTERNAL_SERVER_ERROR,
        'the login attempt failed',
    );
    $mech->content_contains('Failed to authenticate the requested user');

    ok(
        !defined $c->model('Editor')->get_by_id($EDITOR_ID),
        "editor $EDITOR_ID was not auto-created",
    );

    $mech->get('/ws/js/check-login');
    cmp_deeply(
        decode_json($mech->content),
        { id => JSON::null, name => JSON::null },
        'the user is not authenticated',
    );
};

test 'Login is refused for deleted or spammer editors' => sub {
    my $test = shift;
    my $c = $test->c;
    my $mech = $test->mech;

    no warnings 'redefine';
    local *DBDefs::LOCAL_ACCOUNTS_ENABLED = sub { 0 };
    local *DBDefs::METABRAINZ_OAUTH_CLIENT_ID = sub { 'mb_test_client' };
    use warnings 'redefine';

    $c->model('Editor')->insert_from_metabrainz(
        $EDITOR_ID,
        $EDITOR_NAME,
        '2000-01-01T00:00:00+00:00',
    );
    $c->sql->do('UPDATE editor SET deleted = TRUE WHERE id = ?', $EDITOR_ID);

    my $attempt_login = sub {
        my $description = shift;

        _metabrainz_login_request($mech);

        $mech->get('/ws/js/check-login');
        cmp_deeply(
            decode_json($mech->content),
            { id => JSON::null, name => JSON::null },
            $description,
        );
    };

    $attempt_login->('the deleted editor is not authenticated');

    $c->sql->do(
        'UPDATE editor SET deleted = FALSE, privs = ? WHERE id = ?',
        $SPAMMER_FLAG, $EDITOR_ID,
    );
    $attempt_login->('the spammer is not authenticated');
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2026 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
