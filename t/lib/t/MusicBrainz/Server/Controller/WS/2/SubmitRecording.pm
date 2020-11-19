package t::MusicBrainz::Server::Controller::WS::2::SubmitRecording;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Request;
use HTTP::Status qw( :constants );

use MusicBrainz::Server::Test qw( xml_ok xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478', 'foo@example.com', now());
INSERT INTO recording_gid_redirect (gid, new_id) VALUES ('78ad6e24-dc0a-4c20-8284-db2d44d28fb9', 4223060);
EOSQL

# Check OPTIONS support
my $req = HTTP::Request->new('OPTIONS', '/ws/2/recording?client=test-1.0');

$mech->request($req);
is($mech->status, HTTP_OK);

my $response1_headers = $mech->response->headers;
is($response1_headers->header('access-control-allow-origin'), '*');
is($response1_headers->header('allow'), 'GET, POST, OPTIONS');

# Check CORS preflight support
$req = HTTP::Request->new('OPTIONS', '/ws/2/recording?client=test-1.0', [
    'Access-Control-Request-Headers' => 'Authorization, Content-Type',
    'Access-Control-Request-Method' => 'POST',
    'Origin' => 'https://example.com',
]);

$mech->request($req);
is($mech->status, HTTP_OK);

my $response2_headers = $mech->response->headers;
is($response2_headers->header('access-control-allow-headers'), 'Authorization, Content-Type, User-Agent');
is($response2_headers->header('access-control-allow-methods'), 'GET, POST, OPTIONS');
is($response2_headers->header('access-control-allow-origin'), '*');
is($response2_headers->header('allow'), 'GET, POST, OPTIONS');

my $content = '<?xml version="1.0" encoding="UTF-8"?>
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
is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

$mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
my $rec = $c->model('Recording')->get_by_gid('162630d9-36d2-4a8d-ade1-1c77440b34e7');
isa_ok($edit, 'MusicBrainz::Server::Edit::Recording::AddISRCs');
is_deeply($edit->data->{isrcs}, [
    { isrc => 'GBAAA0300123',
      recording => {
          id => $rec->id,
          name => $rec->name
      }
  }
]);

};

1;

