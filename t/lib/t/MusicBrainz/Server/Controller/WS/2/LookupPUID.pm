package t::MusicBrainz::Server::Controller::WS::2::LookupPUID;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $v2 = schema_validator;
my $diff = XML::SemanticDiff->new;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'puid lookup',
    '/puid/cdec3fe2-0473-073c-3cbb-bfb0c01a87ff' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff">
    <recording-list count="1">
      <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
      </recording>
    </recording-list>
  </puid>
</metadata>';

ws_test 'puid lookup with releases',
    '/puid/cdec3fe2-0473-073c-3cbb-bfb0c01a87ff?inc=releases' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff">
    <recording-list count="1">
      <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
        <release-list count="2">
          <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status>Official</status>
            <quality>normal</quality>
            <text-representation>
              <language>jpn</language><script>Jpan</script>
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
          <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title>
            <status>Pseudo-Release</status>
            <quality>normal</quality>
            <text-representation>
              <language>jpn</language><script>Latn</script>
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
      </recording>
    </recording-list>
  </puid>
</metadata>';

ws_test 'puid lookup with release groups',
    '/puid/cdec3fe2-0473-073c-3cbb-bfb0c01a87ff?inc=releases+release-groups+artist-credits' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff">
    <recording-list count="1">
      <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
        <artist-credit>
          <name-credit>
            <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
              <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
            </artist>
          </name-credit>
        </artist-credit>
        <release-list count="2">
          <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status>Official</status>
            <quality>normal</quality>
            <text-representation>
              <language>jpn</language><script>Jpan</script>
            </text-representation>
            <artist-credit>
              <name-credit>
                <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
                  <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
                </artist>
              </name-credit>
            </artist-credit>
            <release-group id="b84625af-6229-305f-9f1b-59c0185df016" type="Single">
              <title>サマーれげぇ!レインボー</title>
              <first-release-date>2001-07-04</first-release-date>
              <primary-type>Single</primary-type>
              <artist-credit>
                <name-credit>
                  <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
                    <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
                  </artist>
                </name-credit>
              </artist-credit>
            </release-group>
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
          <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title>
            <status>Pseudo-Release</status>
            <quality>normal</quality>
            <text-representation>
              <language>jpn</language><script>Latn</script>
            </text-representation>
            <artist-credit>
              <name-credit>
                <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
                  <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
                </artist>
              </name-credit>
            </artist-credit>
            <release-group id="b84625af-6229-305f-9f1b-59c0185df016" type="Single">
              <title>サマーれげぇ!レインボー</title>
              <first-release-date>2001-07-04</first-release-date>
              <primary-type>Single</primary-type>
              <artist-credit>
                <name-credit>
                  <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
                    <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
                  </artist>
                </name-credit>
              </artist-credit>
            </release-group>
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
      </recording>
    </recording-list>
  </puid>
</metadata>';

};

1;

