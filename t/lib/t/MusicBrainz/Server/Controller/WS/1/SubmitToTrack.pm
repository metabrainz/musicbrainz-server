package t::MusicBrainz::Server::Controller::WS::1::SubmitToTrack;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
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
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'editor', '{CLEARTEXT}password', '3a115bc4f05ea9856bd4611b75c80bca'), (2, 'other editor', '{CLEARTEXT}password', '63965b645d6c64e41ad695fd80f1f1e9');
EOSQL

subtest 'Submit a set of PUIDs' => sub {
    my $request = POST '/ws/1/track/?type=xml', [
        client => 'test-1.0',
        puid   => '162630d9-36d2-4a8d-ade1-1c77440b34e7 7b8a868f-1e67-852b-5141-ad1edfb1e492'
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    my $rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');
    is_deeply($edit->data->{puids}, [
        { puid => '7b8a868f-1e67-852b-5141-ad1edfb1e492',
          recording => {
              id => $rec->id,
              name => $rec->name
          }
      }
    ]);
};

subtest 'Submit a set of ISRCs' => sub {
    my $request = POST '/ws/1/track/?type=xml', [
        client => 'test-1.0',
        isrc   => '162630d9-36d2-4a8d-ade1-1c77440b34e7 GBAAA9400365'
    ];

    $mech->credentials('localhost:80', 'musicbrainz.org', 'editor', 'password');

    my $response = $mech->request($request);
    ok($mech->success);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    my $rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
    isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
    is_deeply($edit->data->{isrcs}, [
        { isrc => 'GBAAA9400365',
          recording => {
              id => $rec->id,
              name => $rec->name
          }
      }
    ]);
};

};

1;

