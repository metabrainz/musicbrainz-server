package t::MusicBrainz::Server::Controller::WS::2::LookupRecording;
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
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

ws_test 'basic recording lookup',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
    </recording>
</metadata>';

ws_test 'recording lookup with releases',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
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
</metadata>';

ws_test 'recording lookup, inc=annotation',
    '/recording/6e89c516-b0b6-4735-a758-38e31855dcb6?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
        <title>Plock</title>
        <length>237133</length>
        <annotation><text>this is a recording annotation</text></annotation>
    </recording>
</metadata>';

ws_test 'lookup recording with official singles',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases&status=official&type=single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
        <release-list count="1">
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
        </release-list>
    </recording>
</metadata>';

ws_test 'lookup recording with official singles (+media)',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases+media&status=official&type=single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
        <release-list count="1">
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>Official</status>
                <quality>normal</quality>
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
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>CD</format>
                        <track-list count="3" offset="0">
                            <track id="4a7c2f1e-cf40-383c-a1c1-d1272d8234cd">
                                <position>1</position><number>1</number>
                                <title>サマーれげぇ!レインボー</title>
                                <length>296026</length>
                            </track>
                        </track-list>
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </recording>
</metadata>';

ws_test 'recording lookup with artists',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artists' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
        <title>the Love Bug</title><length>242226</length>
        <artist-credit>
            <name-credit joinphrase="♥">
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
            <name-credit>
                <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                    <name>BoA</name><sort-name>BoA</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
    </recording>
</metadata>';

ws_test 'recording lookup with puids and isrcs',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=puids+isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
        <puid-list count="1">
            <puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" />
        </puid-list>
        <isrc-list count="1">
            <isrc id="JPA600102450" />
        </isrc-list>
    </recording>
</metadata>';

ws_test 'recording lookup with release relationships',
    '/recording/37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9?inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9">
        <title>Dear Diary</title>
        <length>86666</length>
        <relation-list target-type="release">
            <relation type-id="967746f9-9d79-456c-9d1e-50116f0b27fc" type="samples material">
                <target>4ccb3e54-caab-4ad4-94a6-a598e0e52eec</target>
                <begin>2008</begin>
                <release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec">
                    <title>An Inextricable Tale Audiobook</title>
                    <quality>normal</quality>
                    <date>2007-11-08</date>
                    <release-event-list count="1">
                      <release-event>
                        <date>2007-11-08</date>
                      </release-event>
                    </release-event-list>
                    <barcode>634479663338</barcode>
                </release>
            </relation>
        </relation-list>
    </recording>
</metadata>';

};

1;

