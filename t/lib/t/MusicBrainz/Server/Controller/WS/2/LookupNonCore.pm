package t::MusicBrainz::Server::Controller::WS::2::LookupNonCore;
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

ws_test 'discid lookup with artist-credits',
    '/discid/T.epJ9O5SoDjPqAJuOJfAI9O8Nk-?inc=artist-credits' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <disc id="T.epJ9O5SoDjPqAJuOJfAI9O8Nk-">
        <sectors>256486</sectors>
        <release-list count="1">
            <release id="757a1723-3769-4298-89cd-48d31177852a">
                <title>LOVE &amp; HONESTY</title><status>Pseudo-Release</status>
                <quality>normal</quality>
                <text-representation>
                    <language>jpn</language><script>Latn</script>
                </text-representation>
                <artist-credit>
                    <name-credit>
                        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                            <name>BoA</name>
                            <sort-name>BoA</sort-name>
                        </artist>
                    </name-credit>
                </artist-credit>
                <date>2004-01-15</date>
                <country>JP</country>
                <release-event-list count="1">
                    <release-event>
                        <date>2004-01-15</date>
                        <area id="2db42837-c832-3c27-b4a3-08198f75693c">
                            <name>Japan</name>
                            <sort-name>Japan</sort-name>
                            <iso-3166-1-code-list>
                                <iso-3166-1-code>JP</iso-3166-1-code>
                            </iso-3166-1-code-list>
                        </area>
                    </release-event>
                </release-event-list>
                <asin>B0000YGBSG</asin>
                <cover-art-archive>
                    <artwork>false</artwork>
                    <count>0</count>
                    <front>false</front>
                    <back>false</back>
                </cover-art-archive>
                <medium-list count="1">
                  <medium>
                    <position>1</position>
                    <disc-list count="2">
                      <disc id="T.epJ9O5SoDjPqAJuOJfAI9O8Nk-"><sectors>256486</sectors></disc>
                      <disc id="afhq1hAs2MoqPcU9JENE5i_mACM-"><sectors>254650</sectors></disc>
                    </disc-list>
                    <track-list count="13" />
                  </medium>
                </medium-list>
            </release>
        </release-list>
    </disc>
</metadata>';

ws_test 'basic puid lookup',
    '/puid/138f0487-85eb-5fe9-355d-9b94a60ff1dc' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <puid id="138f0487-85eb-5fe9-355d-9b94a60ff1dc">
        <recording-list count="2">
            <recording id="44704dda-b877-4551-a2a8-c1f764476e65">
                <title>On My Bus</title><length>267560</length>
            </recording>
            <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
                <title>Plock</title><length>237133</length>
            </recording>
        </recording-list>
    </puid>
</metadata>';

ws_test 'isrc lookup with releases',
    '/isrc/JPA600102460?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
        <isrc id="JPA600102460">
            <recording-list count="1">
                <recording id="487cac92-eed5-4efa-8563-c9a818079b9a">
                    <title>HELLO! また会おうね (7人祭 version)</title><length>213106</length>
                    <release-list count="2">
                        <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                            <title>サマーれげぇ!レインボー</title><status>Official</status>
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
                            <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
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
        </isrc>
</metadata>';

};

1;

