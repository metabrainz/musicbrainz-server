package t::MusicBrainz::Server::Controller::WS::2::LookupNonCore;
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

ws_test 'discid lookup with artist-credits',
    '/discid/T.epJ9O5SoDjPqAJuOJfAI9O8Nk-?inc=artist-credits' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <disc id="T.epJ9O5SoDjPqAJuOJfAI9O8Nk-">
        <sectors>256486</sectors>
        <offset-list count="13">
          <offset position="1">150</offset>
          <offset position="2">19383</offset>
          <offset position="3">42431</offset>
          <offset position="4">63091</offset>
          <offset position="5">84429</offset>
          <offset position="6">104202</offset>
          <offset position="7">121393</offset>
          <offset position="8">141045</offset>
          <offset position="9">167408</offset>
          <offset position="10">189301</offset>
          <offset position="11">205078</offset>
          <offset position="12">227368</offset>
          <offset position="13">241484</offset>
        </offset-list>
        <release-list count="1">
            <release id="757a1723-3769-4298-89cd-48d31177852a">
                <title>LOVE &amp; HONESTY</title>
                <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
                <quality>normal</quality>
                <text-representation>
                    <language>jpn</language><script>Latn</script>
                </text-representation>
                <artist-credit>
                    <name-credit>
                        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
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
                      <disc id="T.epJ9O5SoDjPqAJuOJfAI9O8Nk-">
                        <sectors>256486</sectors>
                        <offset-list count="13">
                          <offset position="1">150</offset>
                          <offset position="2">19383</offset>
                          <offset position="3">42431</offset>
                          <offset position="4">63091</offset>
                          <offset position="5">84429</offset>
                          <offset position="6">104202</offset>
                          <offset position="7">121393</offset>
                          <offset position="8">141045</offset>
                          <offset position="9">167408</offset>
                          <offset position="10">189301</offset>
                          <offset position="11">205078</offset>
                          <offset position="12">227368</offset>
                          <offset position="13">241484</offset>
                        </offset-list>
                      </disc>
                      <disc id="afhq1hAs2MoqPcU9JENE5i_mACM-">
                        <sectors>254650</sectors>
                        <offset-list count="13">
                          <offset position="1">150</offset>
                          <offset position="2">19230</offset>
                          <offset position="3">42125</offset>
                          <offset position="4">62632</offset>
                          <offset position="5">83817</offset>
                          <offset position="6">103437</offset>
                          <offset position="7">120475</offset>
                          <offset position="8">139975</offset>
                          <offset position="9">166185</offset>
                          <offset position="10">187925</offset>
                          <offset position="11">203550</offset>
                          <offset position="12">225687</offset>
                          <offset position="13">239650</offset>
                        </offset-list>
                      </disc>
                    </disc-list>
                    <track-list count="13" />
                  </medium>
                </medium-list>
            </release>
        </release-list>
    </disc>
</metadata>';

ws_test 'isrc lookup with releases and isrcs',
    '/isrc/JPA600102460?inc=releases+isrcs' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
        <isrc id="JPA600102460">
            <recording-list count="1">
                <recording id="487cac92-eed5-4efa-8563-c9a818079b9a">
                    <title>HELLO! また会おうね (7人祭 version)</title>
                    <length>213106</length>
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
                    <isrc-list count="1">
                        <isrc id="JPA600102460"/>
                    </isrc-list>
                </recording>
            </recording-list>
        </isrc>
</metadata>';

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
