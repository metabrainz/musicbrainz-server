package t::MusicBrainz::Server::Controller::WS::2::SubmitRecording;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );
use XML::SemanticDiff;
use XML::XPath;

use MusicBrainz::Server::Test qw( xml_ok schema_validator xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $mech = $test->mech;
$mech->default_header ("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
SELECT setval('clientversion_id_seq', (SELECT MAX(id) FROM clientversion));
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478');
INSERT INTO recording_gid_redirect (gid, new_id) VALUES ('78ad6e24-dc0a-4c20-8284-db2d44d28fb9', 4223060);
EOSQL


my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <puid-list>
        <puid id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e"></puid>
      </puid-list>
    </recording>
  </recording-list>
</metadata>';

my $req = xml_post('/ws/2/recording?client=test-1.0', $content);

$mech->request($req);
is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

$mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
my $rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');
is_deeply($edit->data->{puids}, [
    { puid => 'eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e',
      recording => {
          id => $rec->id,
          name => $rec->name
      }
  }
]);
is($edit->data->{client_version}, 'test-1.0');

$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
      <isrc-list>
        <isrc id="GBAAA0300123"></isrc>
      </isrc-list>
    </recording>
  </recording-list>
</metadata>';

$req = xml_post('/ws/2/recording?client=test-1.0', $content);
$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
$rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
is_deeply($edit->data->{isrcs}, [
    { isrc => 'GBAAA0300123',
      recording => {
          id => $rec->id,
          name => $rec->name
      }
  }
]);

$content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <recording-list>
    <recording id="78ad6e24-dc0a-4c20-8284-db2d44d28fb9">
      <puid-list>
        <puid id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e"></puid>
      </puid-list>
    </recording>
  </recording-list>
</metadata>';

$req = xml_post('/ws/2/recording?client=test-2.0', $content);
$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

$edit = MusicBrainz::Server::Test->get_latest_edit($c);
$rec = $c->model('Recording')->get_by_gid('487cac92-eed5-4efa-8563-c9a818079b9a');
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddPUIDs');
is_deeply($edit->data->{puids}, [
    { puid => 'eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e',
      recording => {
          id => $rec->id,
          name => $rec->name
      }
  }
]);
is($edit->data->{client_version}, 'test-2.0');

};

1;

