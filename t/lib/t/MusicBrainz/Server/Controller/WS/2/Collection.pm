package t::MusicBrainz::Server::Controller::WS::2::Collection;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );
use MusicBrainz::Server::Test::WS qw(
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_unauthorized
);

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );

test "collection lookup" => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO editor (id, name, password, ha1) VALUES (1, 'new_editor', '{CLEARTEXT}password', 'e1dd8fee8ee728b0ddc8027d3a3db478');
INSERT INTO editor_collection (id, gid, editor, name, public, type)
    VALUES (1, 'f34c079d-374e-4436-9448-da92dedef3ce', 1, 'my collection', FALSE, 1),
           (2, '32bb90e3-aa68-4e3c-9f7a-338096a20ae3', 1, 'my public collection', TRUE, 1);
INSERT INTO editor_collection_release (collection, release)
    VALUES (1, 123054), (2, 123054);
EOSQL

    ws2_test_xml 'all collections',
        '/collection/' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection-list>
    <collection entity-type="release" type="Release" id="f34c079d-374e-4436-9448-da92dedef3ce">
      <name>my collection</name>
      <editor>new_editor</editor>
      <release-list count="1" />
    </collection>
    <collection entity-type="release" type="Release" id="32bb90e3-aa68-4e3c-9f7a-338096a20ae3">
      <name>my public collection</name>
      <editor>new_editor</editor>
      <release-list count="1" />
    </collection>
  </collection-list>
</metadata>', { username => 'new_editor', password => 'password' };

    ws2_test_xml_forbidden 'all collections, no credentials',
        '/collection/';

    ws2_test_xml_unauthorized 'all collections, bad credentials',
        '/collection/',
        { username => 'new_editor', password => 'wrong_password' };

    ws2_test_xml 'private collection lookup',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="f34c079d-374e-4436-9448-da92dedef3ce">
    <name>my collection</name>
    <editor>new_editor</editor>
    <release-list count="1" />
  </collection>
</metadata>', { username => 'new_editor', password => 'password' };

    ws2_test_xml_forbidden 'private collection lookup, no credentials',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce';

    ws2_test_xml_unauthorized 'private collection lookup, bad credentials',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce',
        { username => 'new_editor', password => 'wrong_password' };

    ws2_test_xml 'private collection releases lookup',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce/releases/' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="f34c079d-374e-4436-9448-da92dedef3ce">
    <name>my collection</name>
    <editor>new_editor</editor>
    <release-list count="1">
      <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
        <title>Summer Reggae! Rainbow</title>
        <status>Pseudo-Release</status>
        <quality>normal</quality>
        <text-representation>
          <language>jpn</language>
          <script>Latn</script>
        </text-representation>
        <date>2001-07-04</date>
        <country>JP</country>
        <release-event-list count="1">
          <release-event>
            <date>2001-07-04</date>
            <area id="2db42837-c832-3c27-b4a3-08198f75693c">
              <name>Japan</name>
              <sort-name>Japan</sort-name>
              <iso-3166-1-code-list>
                <iso-3166-1-code>JP</iso-3166-1-code>
              </iso-3166-1-code-list>
            </area>
          </release-event>
        </release-event-list>
        <barcode>4942463511227</barcode>
      </release>
    </release-list>
  </collection>
</metadata>', { username => 'new_editor', password => 'password' };

    ws2_test_xml_forbidden 'private collection releases lookup, no credentials',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce/releases/';

    ws2_test_xml_unauthorized 'private collection releases lookup, bad credentials',
        '/collection/f34c079d-374e-4436-9448-da92dedef3ce/releases/',
        { username => 'new_editor', password => 'wrong_password' };

    ws2_test_xml 'public collection lookup',
        '/collection/32bb90e3-aa68-4e3c-9f7a-338096a20ae3' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <collection entity-type="release" type="Release" id="32bb90e3-aa68-4e3c-9f7a-338096a20ae3">
    <name>my public collection</name>
    <editor>new_editor</editor>
    <release-list count="1" />
  </collection>
</metadata>';
};

1;
