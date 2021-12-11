package t::MusicBrainz::Server::Authentication::WS;
use Test::Routine;
use Test::More;
use utf8;

use URI;
use URI::QueryParam;

with 't::Context', 't::Mechanize';

test 'Authenticate WS bearer' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    my $path = '/ws/2/collection/181685d4-a23a-4140-a343-b7d15de26ff7';
    # No authentication
    $test->mech->get($path);
    is(401, $test->mech->status);

    # Invalid token
    $test->mech->get("$path?access_token=xxxx");
    is(401, $test->mech->status);
    $test->mech->get($path, Authorization => 'Bearer xxx');
    is(401, $test->mech->status);

    # Correctly authenticated
    $test->mech->get_ok("$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ");
    $test->mech->get_ok($path, { Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ' });

    # MAC tokens can't be used as bearer
    $test->mech->get("$path?access_token=NeYRRMSFFEjRoowpZ1K59Q");
    is(401, $test->mech->status);
    $test->mech->get($path, { Authorization => 'Bearer NeYRRMSFFEjRoowpZ1K59Q' });
    is(401, $test->mech->status);

    # Drop the profile scope
    $test->c->sql->do(q(UPDATE editor_oauth_token SET scope = 0 WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'));
    $test->mech->get("$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ");
    is(401, $test->mech->status);
    $test->mech->get($path, Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is(401, $test->mech->status);

    # Expire the token
    $test->c->sql->do(q(UPDATE editor_oauth_token SET expire_time = now() - interval '1 hour' WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'));
    $test->mech->get("$path?access_token=Nlaa7v15QHm9g8rUOmT3dQ");
    is(401, $test->mech->status);
    $test->mech->get($path, Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is(401, $test->mech->status);
};

1;
