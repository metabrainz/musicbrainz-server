package t::MusicBrainz::Server::Controller::WS::2::LookupRecording;
use utf8;
use strict;
use warnings;

use Test::Routine;

with 't::Mechanize', 't::Context';

use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');
MusicBrainz::Server::Test->prepare_test_database($c, '+standalone_recording');

ws_test 'basic recording lookup',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
        <first-release-date>2001-07-04</first-release-date>
    </recording>
</metadata>';

ws_test 'recording lookup with releases',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title><length>296026</length>
        <first-release-date>2001-07-04</first-release-date>
        <release-list count="2">
          <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title>
            <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
            <quality>high</quality>
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
          <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
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

ws_test 'recording lookup, inc=annotation',
    '/recording/6e89c516-b0b6-4735-a758-38e31855dcb6?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
        <title>Plock</title>
        <length>237133</length>
        <annotation><text>this is a recording annotation</text></annotation>
        <first-release-date>1999-09-13</first-release-date>
    </recording>
</metadata>';

ws_test 'lookup recording with official singles',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=releases&status=official&type=single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
        <first-release-date>2001-07-04</first-release-date>
        <release-list count="1">
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
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
        <first-release-date>2001-07-04</first-release-date>
        <release-list count="1">
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
                <quality>normal</quality>
                <date>2001-07-04</date>
                <text-representation>
                  <language>jpn</language>
                  <script>Jpan</script>
                </text-representation>
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
                <medium-list count="1">
                    <medium>
                        <position>1</position>
                        <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
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
        <title>the Love Bug</title><length>243000</length>
        <artist-credit id="8df9a1df-24aa-3457-b994-15a715777ff6">
            <name-credit joinphrase="♥">
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
            <name-credit>
                <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                    <name>BoA</name><sort-name>BoA</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
        <first-release-date>2004-03-17</first-release-date>
    </recording>
</metadata>';

ws_test 'recording lookup with puids (no-op) and isrcs',
    '/recording/162630d9-36d2-4a8d-ade1-1c77440b34e7?inc=puids+isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
        <title>サマーれげぇ!レインボー</title>
        <length>296026</length>
        <first-release-date>2001-07-04</first-release-date>
        <isrc-list count="1">
            <isrc id="JPA600102450" />
        </isrc-list>
    </recording>
</metadata>';

ws_test 'recording lookup with release relationships and artist credits',
    '/recording/37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9?inc=release-rels+artist-credits' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9">
        <title>Dear Diary</title>
        <artist-credit id="b6810eae-d108-3940-9b62-1667531589e6">
            <name-credit>
                <artist id="6fe9f838-112e-44f1-af83-97464f08285b" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Wedlock</name>
                    <sort-name>Wedlock</sort-name>
                    <disambiguation>USA electro pop</disambiguation>
                </artist>
            </name-credit>
        </artist-credit>
        <length>86666</length>
        <first-release-date>2008-04-29</first-release-date>
        <relation-list target-type="release">
            <relation type-id="967746f9-9d79-456c-9d1e-50116f0b27fc" type="samples material">
                <target>4ccb3e54-caab-4ad4-94a6-a598e0e52eec</target>
                <direction>forward</direction>
                <begin>2008</begin>
                <release id="4ccb3e54-caab-4ad4-94a6-a598e0e52eec">
                    <title>An Inextricable Tale Audiobook</title>
                    <artist-credit id="84d4a3ec-0e1a-30ec-b650-643f9ffaf25b">
                        <name-credit>
                            <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c">
                                <name>Paul Allgood</name>
                                <sort-name>Allgood, Paul</sort-name>
                            </artist>
                        </name-credit>
                    </artist-credit>
                    <quality>normal</quality>
                    <text-representation>
                        <language>eng</language>
                        <script>Latn</script>
                    </text-representation>
                    <date>2007-11-08</date>
                    <country>US</country>
                    <release-event-list count="1">
                      <release-event>
                        <date>2007-11-08</date>
                        <area id="489ce91b-6658-3307-9877-795b68554c98">
                          <name>United States</name><sort-name>United States</sort-name>
                          <iso-3166-1-code-list><iso-3166-1-code>US</iso-3166-1-code></iso-3166-1-code-list>
                        </area>
                      </release-event>
                    </release-event-list>
                    <barcode>634479663338</barcode>
                </release>
            </relation>
        </relation-list>
    </recording>
</metadata>';


ws_test 'standalone recording lookup',
    '/recording/c289a368-867e-4ae0-a1ac-ba28a99822f3' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="c289a368-867e-4ae0-a1ac-ba28a99822f3">
        <title>[silence]</title>
        <length>10000</length>
    </recording>
</metadata>';

};

1;

