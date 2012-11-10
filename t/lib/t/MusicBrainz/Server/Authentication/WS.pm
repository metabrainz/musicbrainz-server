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

test 'Authenticate WS mac' => sub {
    my $test = shift;

    MusicBrainz::Server::Test->prepare_test_database($test->c, '+oauth');

    #In [25]: hmac.HMAC('secret', '1352543598\nabc123\nGET\n/ws/1/user/?name=editor1\nlocalhost\n80\n\n', hashlib.sha1).digest().encode('base64')
    #Out[25]: 'mlMWUmfya9O/7zIuc+SLAhDe66E=\n'

    # No authentication
    $test->mech->get('/ws/1/user/?name=editor1');
    is(401, $test->mech->status);

    # Missing MAC auth parameters
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q"');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598"');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc123"');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(401, $test->mech->status);

    # Invalid MAC signature
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q" ts="1352543598", nonce="abc123", mac="xxx"');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q" ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q" ts="1352543500", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(401, $test->mech->status);
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q" ts="1352543598", nonce="abc789", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(401, $test->mech->status);

    # Correctly authenticated
    $test->mech->get_ok('/ws/1/user/?name=editor1', { Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="' });

    # Second authentication with the same ts but different nonce
    $test->mech->get_ok('/ws/1/user/?name=editor1', { Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc456", mac="W4DD2JLtzqWgdZlcIGWFYO4rCyw="' });

    # Timestamp too far in the future (compared to the first one)
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543958", nonce="abc456", mac="QwjZd84a/+Jz8naRgVnLzX2quo4="');
    is(401, $test->mech->status);

    # The same nonce used multiple times
    # XXX can't test this because the default test context doesn't have cache
    #$test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    #is(401, $test->mech->status);

    # Drop the profile scope
    $test->c->sql->do("UPDATE editor_oauth_token SET scope = 0 WHERE access_token = 'NeYRRMSFFEjRoowpZ1K59Q'");
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(403, $test->mech->status);

    # Expire the token
    $test->c->sql->do("UPDATE editor_oauth_token SET expire_time = now() - interval '1 hour' WHERE access_token = 'NeYRRMSFFEjRoowpZ1K59Q'");
    $test->mech->get('/ws/1/user/?name=editor1', Authorization => 'MAC id="NeYRRMSFFEjRoowpZ1K59Q", ts="1352543598", nonce="abc123", mac="mlMWUmfya9O/7zIuc+SLAhDe66E="');
    is(401, $test->mech->status);
};

1;
