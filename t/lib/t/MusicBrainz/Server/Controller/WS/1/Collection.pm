package t::MusicBrainz::Server::Controller::WS::1::Collection;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca');
INSERT INTO editor_collection (id, gid, editor, name)
    VALUES (1, 'b33f3e54-caab-4ad4-94a6-a598e0e52eec', 1, 'My Collection');
EOSQL

subtest 'Add a release to a collection' => sub {
    my $request = POST '/ws/1/collection/?type=xml', [
        add => '4ccb3e54-caab-4ad4-94a6-a598e0e52eec,980e0f65-930e-4743-95d3-602665c25c15',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'collection has 2 releases' =>
        '/collection',
        '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" >
          <release-list count="2">
           <release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec" />
           <release id="980e0f65-930e-4743-95d3-602665c25c15" />
        </release-list></metadata>',
        { username => 'editor', password => 'password' };

    done_testing;
};

subtest 'Remove releases from collections' => sub {
    my $request = POST '/ws/1/collection/?type=xml', [
        remove => '980e0f65-930e-4743-95d3-602665c25c15',
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    ws_test 'collection has 2 releases' =>
        '/collection',
        '<?xml version="1.0" encoding="UTF-8"?><metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" >
         <release-list count="1">
          <release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec" />
        </release-list></metadata>',
        { username => 'editor', password => 'password' };

    done_testing;
};

};

1;

