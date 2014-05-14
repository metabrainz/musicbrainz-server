package t::MusicBrainz::Server::Authentication::WS;
use Test::Routine;
use Test::More;
use utf8;

use URI;
use URI::QueryParam;
use JSON;

with 't::Context', 't::Mechanize';

test 'Authenticate WS bearer' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    # No authentication
    $test->mech->get('/ws/1/user/?name=editor1');
    is(401, $test->mech->status);

    # Invalid token
    $test->mech->get('/ws/1/user/?name=editor1&access_token=xxxx');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'Bearer xxx');
    is(401, $test->mech->status);

    # Correctly authenticated
    $test->mech->get_ok('/ws/1/user/?name=editor1&access_token=Nlaa7v15QHm9g8rUOmT3dQ');
    $test->mech->get_ok('/ws/1/user/?name=editor1', { Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ' });

    # MAC tokens can't be used as bearer
    $test->mech->get('/ws/1/user/?name=editor1&access_token=NeYRRMSFFEjRoowpZ1K59Q');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', { Authorization => 'Bearer NeYRRMSFFEjRoowpZ1K59Q' });
    is(401, $test->mech->status);

    # Drop the profile scope
    $test->c->sql->do("UPDATE editor_oauth_token SET scope = 0 WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'");
    $test->mech->get('/ws/1/user/?name=editor1&access_token=Nlaa7v15QHm9g8rUOmT3dQ');
    is(403, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is(403, $test->mech->status);

    # Expire the token
    $test->c->sql->do("UPDATE editor_oauth_token SET expire_time = now() - interval '1 hour' WHERE access_token = 'Nlaa7v15QHm9g8rUOmT3dQ'");
    $test->mech->get('/ws/1/user/?name=editor1&access_token=Nlaa7v15QHm9g8rUOmT3dQ');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ');
    is(401, $test->mech->status);
};

test 'Deleted users (bearer)' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    # No authentication
    $test->mech->get('/ws/1/user/?name=editor1');
    is(401, $test->mech->status);

    # Correctly authenticated
    $test->mech->get_ok('/ws/1/user/?name=editor1&access_token=Nlaa7v15QHm9g8rUOmT3dQ');
    $test->mech->get_ok('/ws/1/user/?name=editor1', { Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ' });

    $test->c->sql->do("UPDATE editor SET deleted = TRUE WHERE id = 1;");

    $test->mech->get('/ws/1/user/?name=editor1&access_token=Nlaa7v15QHm9g8rUOmT3dQ');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', { Authorization => 'Bearer Nlaa7v15QHm9g8rUOmT3dQ' });
    is(401, $test->mech->status);
};

1;
