package t::MusicBrainz::Server::Controller::WS::2::BrowseRelease;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO release_tag (count, release, tag)
        VALUES (1, 123054, 114);
    SQL

ws_test 'browse releases via artist (paging)',
    '/release?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&offset=2' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="3" offset="2">
        <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
            <title>For Beginner Piano</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>eng</language>
                <script>Latn</script>
            </text-representation>
            <date>1999-09-23</date>
            <country>US</country>
            <release-event-list count="1">
                <release-event>
                    <date>1999-09-23</date>
                    <area id="489ce91b-6658-3307-9877-795b68554c98">
                        <name>United States</name>
                        <sort-name>United States</sort-name>
                        <iso-3166-1-code-list>
                            <iso-3166-1-code>US</iso-3166-1-code>
                        </iso-3166-1-code-list>
                    </area>
                </release-event>
            </release-event-list>
            <asin>B00001IVAI</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
        </release>
    </release-list>
</metadata>';

ws_test 'browse releases via label',
    '/release?inc=mediums&label=b4edce40-090f-4956-b82a-5d9d285da40b' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
            <title>My Demons</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>eng</language>
                <script>Latn</script>
            </text-representation>
            <date>2007-01-29</date>
            <country>GB</country>
            <release-event-list count="1">
                <release-event>
                    <date>2007-01-29</date>
                    <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                        <name>United Kingdom</name>
                        <sort-name>United Kingdom</sort-name>
                        <iso-3166-1-code-list>
                            <iso-3166-1-code>GB</iso-3166-1-code>
                        </iso-3166-1-code-list>
                    </area>
                </release-event>
            </release-event-list>
            <barcode>600116817020</barcode>
            <asin>B000KJTG6K</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
            <medium-list count="1">
                <medium>
                    <position>1</position>
                    <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                    <track-list count="12" />
                </medium>
            </medium-list>
        </release>
        <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
            <title>Repercussions</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>eng</language>
                <script>Latn</script>
            </text-representation>
            <date>2008-11-17</date>
            <country>GB</country>
            <release-event-list count="1">
                <release-event>
                    <date>2008-11-17</date>
                    <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                        <name>United Kingdom</name>
                        <sort-name>United Kingdom</sort-name>
                        <iso-3166-1-code-list>
                            <iso-3166-1-code>GB</iso-3166-1-code>
                        </iso-3166-1-code-list>
                    </area>
                </release-event>
            </release-event-list>
            <barcode>600116822123</barcode>
            <asin>B001IKWNCE</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
            <medium-list count="2">
                <medium>
                    <position>1</position>
                    <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                    <track-list count="9" />
                </medium>
                <medium>
                    <title>Chestplate Singles</title><position>2</position>
                    <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                    <track-list count="9" />
                </medium>
            </medium-list>
        </release>
    </release-list>
</metadata>';

ws_test 'browse releases via release group',
    '/release?release-group=b84625af-6229-305f-9f1b-59c0185df016' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>jpn</language>
                <script>Jpan</script>
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
            <asin>B00005LA6G</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
        </release>
        <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title>
            <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
            <quality>high</quality>
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
            <asin>B00005LA6G</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
        </release>
    </release-list>
</metadata>';

ws_test 'browse releases via release group with inc=tags',
    '/release?release-group=b84625af-6229-305f-9f1b-59c0185df016&inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
            <title>サマーれげぇ!レインボー</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>jpn</language>
                <script>Jpan</script>
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
            <asin>B00005LA6G</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
        </release>
        <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
            <title>Summer Reggae! Rainbow</title>
            <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
            <quality>high</quality>
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
            <asin>B00005LA6G</asin>
            <tag-list>
              <tag count="1"><name>hello project</name></tag>
            </tag-list>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
        </release>
    </release-list>
</metadata>';

my $response = $mech->get('/ws/2/release?recording=7b1f6e95-b523-43b6-a048-810ea5d463a8');
is ($response->code, 404, 'browse releases via non-existent recording');

ws_test 'browse releases via recording',
    '/release?inc=labels&status=official&recording=0c0245df-34f0-416b-8c3f-f20f66e116d0' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="2">
        <release id="cacc586f-c2f2-49db-8534-6f44b55196f2">
            <title>LOVE &amp; HONESTY</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>jpn</language>
                <script>Jpan</script>
            </text-representation>
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
            <barcode>4988064173907</barcode>
            <asin>B0000YG9NS</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
            <label-info-list count="1">
                <label-info>
                    <catalog-number>AVCD-17390</catalog-number>
                    <label id="168f48c8-057e-4974-9600-aa9956d21e1a" type="Original Production" type-id="7aaa37fe-2def-3476-b359-80245850062d">
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </label-info>
            </label-info-list>
        </release>
        <release id="28fc2337-985b-3da9-ac40-ad6f28ff0d8e">
            <title>LOVE &amp; HONESTY</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>jpn</language>
                <script>Jpan</script>
            </text-representation>
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
            <barcode>4988064173891</barcode>
            <asin>B0000YGBSG</asin>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
            <label-info-list count="1">
                <label-info>
                    <catalog-number>AVCD-17389</catalog-number>
                    <label id="168f48c8-057e-4974-9600-aa9956d21e1a" type="Original Production" type-id="7aaa37fe-2def-3476-b359-80245850062d">
                        <name>avex trax</name><sort-name>avex trax</sort-name>
                    </label>
                </label-info>
            </label-info-list>
        </release>
    </release-list>
</metadata>';

ws_test 'browse releases via recording, with recording and work rels',
    '/release?inc=recordings+artist-rels+work-rels+recording-level-rels+work-level-rels&status=official&recording=c43ee188-0049-4eec-ba2e-0385c5edd2db' =>
    '<?xml version="1.0" ?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-list count="1">
        <release id="ec0d0122-b559-4aa1-a017-7068814aae57">
            <title>Soup</title>
            <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
            <quality>normal</quality>
            <text-representation>
                <language>eng</language>
                <script>Latn</script>
            </text-representation>
            <barcode>0208311348266</barcode>
            <cover-art-archive>
                <artwork>false</artwork>
                <count>0</count>
                <front>false</front>
                <back>false</back>
            </cover-art-archive>
            <medium-list count="1">
                <medium>
                    <position>1</position>
                    <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                    <pregap id="1a0ba71b-fb23-3931-a426-cd204a82a90e">
                        <position>0</position>
                        <number>0</number>
                        <length>128000</length>
                        <recording id="c0beb80b-4185-4328-8761-b9e45a5d0ac6">
                            <title>Hello Goodbye [hidden track]</title>
                            <length>128000</length>
                            <relation-list target-type="work">
                                <relation type="performance" type-id="a3005666-a872-32c3-ad06-98af558e99b0">
                                    <target>c473ece7-4858-3f4f-9d7a-a1e026400888</target>
                                    <direction>forward</direction>
                                    <work id="c473ece7-4858-3f4f-9d7a-a1e026400888">
                                        <title>Hello Goodbye</title>
                                        <language>eng</language>
                                        <language-list>
                                            <language>eng</language>
                                        </language-list>
                                        <relation-list target-type="artist">
                                            <relation type="composer" type-id="d59d99ea-23d4-4a80-b066-edca32ee158f">
                                                <target>38c5cdab-5d6d-43d1-85b0-dac41bde186e</target>
                                                <direction>backward</direction>
                                                <artist id="38c5cdab-5d6d-43d1-85b0-dac41bde186e" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                                                    <name>Blind Melon</name>
                                                    <sort-name>Blind Melon</sort-name>
                                                </artist>
                                            </relation>
                                        </relation-list>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </pregap>
                    <track-list count="2" offset="0">
                    <track id="7b84af2d-96b3-3c50-a667-e7d10e8b000d">
                        <position>1</position>
                        <number>1</number>
                        <title>Galaxie</title>
                        <length>211133</length>
                        <recording id="c43ee188-0049-4eec-ba2e-0385c5edd2db">
                            <title>Hello Goodbye / Galaxie</title>
                            <length>211133</length>
                            <relation-list target-type="artist">
                                <relation type-id="59054b12-01ac-43ee-a618-285fd397e461" type="instrument">
                                <target>05d83760-08b5-42bb-a8d7-00d80b3bf47c</target>
                                <direction>backward</direction>
                                <attribute-list>
                                    <attribute credited-as="crazy guitar" type-id="63021302-86cd-4aee-80df-2270d54f4978">guitar</attribute>
                                </attribute-list>
                                <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                                    <name>Paul Allgood</name>
                                    <sort-name>Allgood, Paul</sort-name>
                                </artist>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="e9f7ca98-ba9d-3276-97a4-26475c9f4527">
                        <position>2</position>
                        <number>2</number>
                        <length>240400</length>
                        <recording id="c830c239-3f91-4485-9577-4b86f92ad725">
                            <title>2 X 4</title>
                            <length>240400</length>
                        </recording>
                    </track>
                    </track-list>
                </medium>
            </medium-list>
        </release>
    </release-list>
</metadata>';

ws_test 'browse releases via track artist, including RGs and ratings',
    '/release?track_artist=a16d1433-ba89-4f72-a47b-a370add0bb55&inc=release-groups+ratings' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list count="1">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
      <title>the Love Bug</title>
      <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
      <quality>normal</quality>
      <text-representation><language>eng</language><script>Latn</script></text-representation>
      <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="153f0a09-fead-3370-9b17-379ebd09446b">
        <title>the Love Bug</title>
        <first-release-date>2004-03-17</first-release-date>
        <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
        <rating votes-count="2">5</rating>
      </release-group>
      <date>2004-03-17</date>
      <country>JP</country>
      <release-event-list count="1">
        <release-event>
          <date>2004-03-17</date>
          <area id="2db42837-c832-3c27-b4a3-08198f75693c">
            <name>Japan</name>
            <sort-name>Japan</sort-name>
            <iso-3166-1-code-list>
              <iso-3166-1-code>JP</iso-3166-1-code>
            </iso-3166-1-code-list>
          </area>
        </release-event>
      </release-event-list>
      <barcode>4988064451180</barcode>
      <asin>B0001FAD2O</asin>
      <cover-art-archive>
          <artwork>true</artwork>
          <count>1</count>
          <front>true</front>
          <back>false</back>
      </cover-art-archive>
    </release>
  </release-list>
</metadata>';

};

1;

