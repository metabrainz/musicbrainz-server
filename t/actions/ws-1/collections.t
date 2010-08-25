use utf8;
use strict;
use Test::More;

use HTTP::Request::Common;
use MusicBrainz::Server::Test
    qw( xml_ok schema_validator ),
    ws_test => { version => 1 };

use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

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

done_testing;

