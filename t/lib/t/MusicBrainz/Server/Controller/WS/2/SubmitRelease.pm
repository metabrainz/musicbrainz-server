package t::MusicBrainz::Server::Controller::WS::2::SubmitRelease;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use HTTP::Status qw( :constants );
use XML::SemanticDiff;
use XML::XPath;

use MusicBrainz::Server::Test qw( xml_ok schema_validator xml_post capture_edits );
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
INSERT INTO editor (id, name, password, ha1, email, email_confirm_date) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478', 'foo@example.com', now());
INSERT INTO release_gid_redirect (gid, new_id) VALUES ('78ad6e24-dc0a-4c20-8284-db2d44d28fb9', 49161);
EOSQL

    my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list>
    <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
      <barcode>5021603064126</barcode>
    </release>
  </release-list>
</metadata>';

    my $req = xml_post('/ws/2/release?client=test-1.0', $content);
    $mech->request($req);
    is($mech->status, HTTP_UNAUTHORIZED, 'cant POST without authentication');

    $mech->credentials('localhost:80', 'musicbrainz.org', 'new_editor', 'password');

    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
    isa_ok($edit, 'MusicBrainz::Server::Edit::Release::EditBarcodes');
    is_deeply($edit->data, {
        submissions => [
            {
                release => {
                    id => 243064,
                    name => 'For Beginner Piano'
                },
                barcode => '5021603064126',
                old_barcode => undef
            }
        ],
        client_version => 'test-1.0'
    });

    $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list />
</metadata>';

    $req = xml_post('/ws/2/release?client=test-1.0', $content);
    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    my $next_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    is($next_edit->id, $edit->id, 'did not submit an edit');

    $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list>
    <release id="78ad6e24-dc0a-4c20-8284-db2d44d28fb9">
      <barcode>796122009228</barcode>
    </release>
  </release-list>
</metadata>';

    $req = xml_post('/ws/2/release', $content);
    $req->header('User-Agent', 'test-ua');
    $mech->request($req);
    is($mech->status, HTTP_OK);
    xml_ok($mech->content);

    $next_edit = MusicBrainz::Server::Test->get_latest_edit($c);
    my $rel = $c->model('Release')->get_by_gid('0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e');
    isa_ok($next_edit, 'MusicBrainz::Server::Edit::Release::EditBarcodes');
    is_deeply($next_edit->data, {
        submissions => [
            {
                release => {
                    id => $rel->id,
                    name => $rel->name
                },
                barcode => '796122009228',
                old_barcode => '4942463511227'
            }
        ],
        client_version => 'test-ua'
    });

    $next_edit->accept;

    my @edits = capture_edits {
        $req = xml_post('/ws/2/release?client=test-1.0', $content);
        $mech->request($req);
        is($mech->status, HTTP_OK);
        xml_ok($mech->content);
    } $c;
    is(@edits => 0);
};

1;

