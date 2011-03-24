package t::MusicBrainz::Server::Controller::WS::2::SubmitRelease;
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

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
SELECT setval('clientversion_id_seq', (SELECT MAX(id) FROM clientversion));
INSERT INTO editor (id, name, password)
    VALUES (1, 'new_editor', 'password');
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
                barcode => '5021603064126'
            }
        ]
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
};

1;

