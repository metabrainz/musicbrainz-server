package t::MusicBrainz::Server::Controller::WS::2::LookupRelease;
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

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'EOSQL');
    INSERT INTO release_tag (count, release, tag) VALUES (1, 123054, 114);
    INSERT INTO editor (id, name, password, ha1, email, email_confirm_date)
        VALUES (15412, 'editor', '{CLEARTEXT}mb', 'be88da857f697a78656b1307f89f90ab', 'foo@example.com', now());
    INSERT INTO editor_collection (id, gid, editor, name, public, type)
        VALUES (14933, 'f34c079d-374e-4436-9448-da92dedef3cd', 15412, 'My Collection', TRUE, 1);
    INSERT INTO editor_collection (id, gid, editor, name, public, type)
        VALUES (14934, '5e8dd65f-7d52-4d6e-93f6-f84651e137ca', 15412, 'My Private Collection', FALSE, 1);
    INSERT INTO editor_collection_release (collection, release)
        VALUES (14933, 123054), (14934, 123054);
    EOSQL

ws_test 'basic release lookup',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
</metadata>';

ws_test 'MBS-8845',
    '/release/8268c2f8-bfc3-4079-9c25-fad0d69a38df?inc=collections' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="8268c2f8-bfc3-4079-9c25-fad0d69a38df">
        <title>Surrender</title>
        <status id="518ffc83-5cde-34df-8627-81bff5093d92">Promotion</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
        <date>1999</date>
        <country>US</country>
        <release-event-list count="1">
            <release-event>
                <date>1999</date>
                <area id="489ce91b-6658-3307-9877-795b68554c98">
                    <name>United States</name>
                    <sort-name>United States</sort-name>
                    <iso-3166-1-code-list>
                        <iso-3166-1-code>US</iso-3166-1-code>
                    </iso-3166-1-code-list>
                </area>
            </release-event>
        </release-event-list>
        <asin>B00000J8EK</asin>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'release lookup, inc=annotation',
    '/release/adcf7b48-086e-48ee-b420-1001f88d672f?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
        <title>My Demons</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <annotation><text>this is a release annotation</text></annotation>
        <text-representation>
            <language>eng</language><script>Latn</script>
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
    </release>
</metadata>';

ws_test 'basic release with tags',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
</metadata>';

ws_test 'basic release with collections',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=collections' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
        <collection-list count="1">
            <collection type="Release" entity-type="release" id="f34c079d-374e-4436-9448-da92dedef3cd">
                <name>My Collection</name>
                <editor>editor</editor>
                <release-list count="1"/>
            </collection>
        </collection-list>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'basic release with private collections',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=user-collections' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
        <collection-list count="2">
            <collection type="Release" entity-type="release" id="f34c079d-374e-4436-9448-da92dedef3cd">
                <name>My Collection</name>
                <editor>editor</editor>
                <release-list count="1"/>
            </collection>
            <collection type="Release" entity-type="release" id="5e8dd65f-7d52-4d6e-93f6-f84651e137ca">
                <name>My Private Collection</name>
                <editor>editor</editor>
                <release-list count="1"/>
            </collection>
        </collection-list>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>', { username => 'editor', password => 'mb' };

ws_test 'release lookup with artists + aliases',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artists+aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                    <alias-list count="6">
                        <alias sort-name="m-flow">m-flow</alias>
                        <alias sort-name="mediarite-flow crew">mediarite-flow crew</alias>
                        <alias sort-name="meteorite-flow crew">meteorite-flow crew</alias>
                        <alias sort-name="mflo">mflo</alias>
                        <alias sort-name="えむふろう">えむふろう</alias>
                        <alias sort-name="エムフロウ">エムフロウ</alias>
                    </alias-list>
                </artist>
            </name-credit>
        </artist-credit>
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
</metadata>';

ws_test 'release lookup with labels, recordings and tags',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=labels+recordings+tags' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
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
        <label-info-list count="1">
            <label-info>
                <catalog-number>RZCD-45118</catalog-number>
                <label id="72a46579-e9a0-405a-8ee1-e6e6b63b8212" type="Original Production" type-id="7aaa37fe-2def-3476-b359-80245850062d">
                    <name>rhythm zone</name><sort-name>rhythm zone</sort-name>
                </label>
            </label-info>
        </label-info-list>
        <medium-list count="1">
            <medium>
                <position>1</position>
                <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                <track-list count="3" offset="0">
                    <track id="ec60f5e2-ed8a-391d-90cd-bf119c50f6a0">
                        <position>1</position><number>1</number>
                        <length>243000</length>
                        <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
                            <title>the Love Bug</title><length>243000</length>
                            <first-release-date>2004-03-17</first-release-date>
                            <tag-list>
                                <tag count="1"><name>kpop</name></tag>
                            </tag-list>
                        </recording>
                    </track>
                    <track id="2519283c-93d9-30de-a0ba-75f99ca25604">
                        <position>2</position><number>2</number>
                        <length>222000</length>
                        <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
                            <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
                            <first-release-date>2004-03-17</first-release-date>
                            <tag-list>
                                <tag count="1"><name>jpop</name></tag>
                            </tag-list>
                        </recording>
                    </track>
                    <track id="4ffc18f0-96cc-3e1f-8192-cf0d0c489beb">
                        <position>3</position><number>3</number>
                        <length>333000</length>
                        <recording id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
                            <title>the Love Bug (cover)</title><length>333000</length>
                            <first-release-date>2004-03-17</first-release-date>
                            <tag-list>
                                <tag count="1"><name>c-pop</name></tag>
                            </tag-list>
                        </recording>
                    </track>
                </track-list>
            </medium>
        </medium-list>
        <cover-art-archive>
            <artwork>true</artwork>
            <count>1</count>
            <front>true</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'release lookup with release-groups and ratings',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artist-credits+release-groups+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name>
                    <sort-name>m-flo</sort-name>
                    <rating votes-count="3">3</rating>
                </artist>
            </name-credit>
        </artist-credit>
        <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="153f0a09-fead-3370-9b17-379ebd09446b">
            <title>the Love Bug</title>
            <first-release-date>2004-03-17</first-release-date>
            <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
            <artist-credit>
                <name-credit>
                    <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                        <name>m-flo</name>
                        <sort-name>m-flo</sort-name>
                        <rating votes-count="3">3</rating>
                    </artist>
                </name-credit>
            </artist-credit>
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
</metadata>';

ws_test 'release lookup with release-group-level-rels and series-rels',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=release-groups+release-group-level-rels+series-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
        <release-group type="Single" type-id="d6038452-8ee0-3f68-affc-2de9a1ede0b9" id="153f0a09-fead-3370-9b17-379ebd09446b">
            <title>the Love Bug</title>
            <first-release-date>2004-03-17</first-release-date>
            <primary-type id="d6038452-8ee0-3f68-affc-2de9a1ede0b9">Single</primary-type>
            <relation-list target-type="series">
                <relation type="part of" type-id="01018437-91d8-36b9-bf89-3f885d53b5bd">
                    <target>d977f7fd-96c9-4e3e-83b5-eb484a9e6581</target>
                    <ordering-key>1</ordering-key>
                    <direction>forward</direction>
                    <attribute-list>
                        <attribute type-id="a59c5830-5ec7-38fe-9a21-c7ea54f6650a" value="1">number</attribute>
                    </attribute-list>
                    <series id="d977f7fd-96c9-4e3e-83b5-eb484a9e6581" type="Release group" type-id="4c1c4949-7b6c-3a2d-9d54-a50a27e4fa77">
                        <name>A Release Group Series</name>
                    </series>
                </relation>
            </relation-list>
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
</metadata>';

ws_test 'release lookup with discids and recordings',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=discids+recordings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
        <medium-list count="1">
            <medium>
                <position>1</position><format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
                <disc-list count="1">
                    <disc id="W01Qvrvwkaz2Cm.IQm55_RHoRxs-">
                        <sectors>60295</sectors>
                        <offset-list count="3">
                            <offset position="1">150</offset>
                            <offset position="2">22352</offset>
                            <offset position="3">38335</offset>
                        </offset-list>
                    </disc>
                </disc-list>
                <track-list count="3" offset="0">
                    <track id="3b9d0128-ed86-3c2c-af24-c331a3798875">
                        <position>1</position><number>1</number><title>Summer Reggae! Rainbow</title><length>296026</length>
                        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
                            <title>サマーれげぇ!レインボー</title><length>296026</length>
                            <first-release-date>2001-07-04</first-release-date>
                        </recording>
                    </track>
                    <track id="c7c21691-6f85-3ec7-9b08-e431c3b310a5">
                        <position>2</position><number>2</number><title>Hello! Mata Aou Ne (7nin Matsuri version)</title><length>213106</length>
                        <recording id="487cac92-eed5-4efa-8563-c9a818079b9a">
                            <title>HELLO! また会おうね (7人祭 version)</title><length>213106</length>
                            <first-release-date>2001-07-04</first-release-date>
                        </recording>
                    </track>
                    <track id="e436c057-ca19-36c6-9f1e-dc4ada2604b0">
                        <position>3</position><number>3</number><title>Summer Reggae! Rainbow (Instrumental)</title><length>292800</length>
                        <recording id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
                            <title>サマーれげぇ!レインボー (instrumental)</title><length>292800</length>
                            <first-release-date>2001-07-04</first-release-date>
                        </recording>
                    </track>
                </track-list>
            </medium>
        </medium-list>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'release lookup, no tracks',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e7?inc=recordings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="b3b7e934-445b-4c68-a097-730c6a6d47e7">
        <title>Testy</title>
        <status id="41121bb9-3413-3818-8a9a-9742318349aa">Pseudo-Release</status>
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
        <asin>B00005LA6G</asin>
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
            <track-list count="0" />
          </medium>
        </medium-list>
      </release>
</metadata>';

ws_test 'release lookup, barcode is NULL',
    '/release/fbe4eb72-0f24-3875-942e-f581589713d4' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
</metadata>';

ws_test 'release lookup, barcode is empty string',
    '/release/dd66bfdd-6097-32e3-91b6-67f47ba25d4c' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="dd66bfdd-6097-32e3-91b6-67f47ba25d4c">
        <title>For Beginner Piano</title>
        <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>1999-09-13</date>
        <country>GB</country>
        <release-event-list count="1">
            <release-event>
                <date>1999-09-13</date>
                <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
                    <name>United Kingdom</name>
                    <sort-name>United Kingdom</sort-name>
                    <iso-3166-1-code-list>
                        <iso-3166-1-code>GB</iso-3166-1-code>
                    </iso-3166-1-code-list>
                </area>
            </release-event>
        </release-event-list>
        <barcode />
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'release lookup, relation attributes',
    '/release/28fc2337-985b-3da9-ac40-ad6f28ff0d8e?inc=release-rels+artist-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
        <relation-list target-type="artist">
            <relation type="producer" type-id="8bf377ba-8d71-4ecc-97f2-7bb2d8a2a75f">
                <target>4d5ec626-2251-4bb1-b62a-f24f471e3f2c</target>
                <direction>backward</direction>
                <attribute-list>
                    <attribute type-id="e0039285-6667-4f94-80d6-aa6520c6d359">executive</attribute>
                </attribute-list>
                <artist id="4d5ec626-2251-4bb1-b62a-f24f471e3f2c" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                    <name>이수만</name>
                    <sort-name>Lee, Soo-Man</sort-name>
                </artist>
            </relation>
        </relation-list>
        <relation-list target-type="release">
            <relation type="transl-tracklisting" type-id="fc399d47-23a7-4c28-bfcf-0607a562b644">
                <target>757a1723-3769-4298-89cd-48d31177852a</target>
                <direction>forward</direction>
                <release id="757a1723-3769-4298-89cd-48d31177852a">
                    <title>LOVE &amp; HONESTY</title>
                    <quality>normal</quality>
                    <text-representation>
                        <language>jpn</language>
                        <script>Latn</script>
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
                </release>
            </relation>
        </relation-list>
    </release>
</metadata>';

ws_test 'release lookup, related artists have no tags',
  '/release/4f5a6b97-a09b-4893-80d1-eae1f3bfa221?inc=artists+recordings+tags+artist-rels+recording-level-rels' =>
  '<?xml version="1.0" ?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
    <title>For Beginner Piano</title>
    <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
    <quality>normal</quality>
    <text-representation>
      <language>eng</language><script>Latn</script>
    </text-representation>
    <artist-credit>
      <name-credit>
        <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
          <name>Plone</name><sort-name>Plone</sort-name>
          <tag-list>
            <tag count="1">
              <name>british</name>
            </tag>
            <tag count="1">
              <name>electronic</name>
            </tag>
            <tag count="1">
              <name>electronica</name>
            </tag>
            <tag count="1">
              <name>english</name>
            </tag>
            <tag count="1">
              <name>glitch</name>
            </tag>
            <tag count="1">
              <name>uk</name>
            </tag>
            <tag count="1">
              <name>warp</name>
            </tag>
          </tag-list>
        </artist>
      </name-credit>
    </artist-credit>
    <date>1999-09-13</date><country>GB</country>
    <release-event-list count="1">
      <release-event>
        <date>1999-09-13</date>
        <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
          <name>United Kingdom</name><sort-name>United Kingdom</sort-name>
          <iso-3166-1-code-list>
            <iso-3166-1-code>GB</iso-3166-1-code>
          </iso-3166-1-code-list>
        </area>
      </release-event>
    </release-event-list>
    <barcode>5021603064126</barcode><asin>B00001IVAI</asin>
    <cover-art-archive>
      <artwork>false</artwork><count>0</count><front>false</front><back>false</back>
    </cover-art-archive>
    <medium-list count="1">
      <medium>
        <position>1</position>
        <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
        <track-list count="10" offset="0">
          <track id="9b9a84b5-0a41-38f6-859f-36cb22ac813c">
            <position>1</position><number>1</number><length>267560</length>
            <recording id="44704dda-b877-4551-a2a8-c1f764476e65">
              <title>On My Bus</title><length>267560</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="f38b8e31-a10d-3973-8c1f-10923ee61adc">
            <position>2</position><number>2</number><length>230506</length>
            <recording id="8920288e-7541-48a7-b23b-f80447c8b1ab">
              <title>Top &amp; Low Rent</title><length>230506</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="d17bed32-940a-3fcc-9210-a5d7c516b4bb">
            <position>3</position><number>3</number><length>237133</length>
            <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
              <title>Plock</title><length>237133</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="001bc675-ba25-32bc-9914-d5d9e22c3c44">
            <position>4</position><number>4</number><length>229826</length>
            <recording id="791d9b27-ae1a-4295-8943-ded4284f2122">
              <title>Marbles</title><length>229826</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="c009176f-ff26-3f5f-bd16-46cede30ebe6">
            <position>5</position><number>5</number><length>217440</length>
            <recording id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877">
              <title>Busy Working</title><length>217440</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="70454e43-b39b-3ca7-8c50-ae235b5ef358">
            <position>6</position><number>6</number><length>227293</length>
            <recording id="dc891eca-bf42-4103-8682-86068fe732a5">
              <title>The Greek Alphabet</title><length>227293</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="1b5da50c-e20f-3762-839c-5a0eea89d6a5">
            <position>7</position><number>7</number><length>244506</length>
            <recording id="25e9ae0f-8b7d-4230-9cde-9a07f7680e4a">
              <title>Press a Key</title><length>244506</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="f1b5bd23-ad01-3c0c-a49a-cf8e99088369">
            <position>8</position><number>8</number><length>173960</length>
            <recording id="6f9c8c32-3aae-4dad-b023-56389361cf6b">
              <title>Bibi Plone</title><length>173960</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="928f2274-5694-35f9-92da-a1fc565867cf">
            <position>9</position><number>9</number><length>208706</length>
            <recording id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
              <title>Be Rude to Your School</title><length>208706</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="40727388-237d-34b2-8a3a-288878e5c883">
            <position>10</position><number>10</number><length>320067</length>
            <recording id="a8614bda-42dc-43c7-ac5f-4067acb6f1c5">
              <title>Summer Plays Out</title><length>320067</length>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
                  <direction>backward</direction>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name><sort-name>Plone</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
        </track-list>
      </medium>
    </medium-list>
    <relation-list target-type="artist">
      <relation type-id="307e95dd-88b5-419b-8223-b146d4a0d439" type="design/illustration">
        <target>3088b672-fba9-4b4b-8ae0-dce13babfbb4</target>
        <direction>backward</direction>
        <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
          <name>Plone</name><sort-name>Plone</sort-name>
        </artist>
      </relation>
    </relation-list>
  </release>
</metadata>';

ws_test 'release lookup, track artists have no aliases',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artists+recordings+artist-credits+aliases+artist-rels+recording-level-rels' =>
    '<?xml version="1.0" ?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
    <title>the Love Bug</title>
    <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
    <quality>normal</quality>
    <text-representation>
      <language>eng</language><script>Latn</script>
    </text-representation>
    <artist-credit>
      <name-credit>
        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
          <name>m-flo</name><sort-name>m-flo</sort-name>
          <alias-list count="6">
            <alias sort-name="m-flow">m-flow</alias><alias sort-name="mediarite-flow crew">mediarite-flow crew</alias><alias sort-name="meteorite-flow crew">meteorite-flow crew</alias><alias sort-name="mflo">mflo</alias><alias sort-name="えむふろう">えむふろう</alias><alias sort-name="エムフロウ">エムフロウ</alias>
          </alias-list>
        </artist>
      </name-credit>
    </artist-credit>
    <date>2004-03-17</date><country>JP</country>
    <release-event-list count="1">
      <release-event>
        <date>2004-03-17</date>
        <area id="2db42837-c832-3c27-b4a3-08198f75693c">
          <name>Japan</name><sort-name>Japan</sort-name>
          <iso-3166-1-code-list>
            <iso-3166-1-code>JP</iso-3166-1-code>
          </iso-3166-1-code-list>
        </area>
      </release-event>
    </release-event-list>
    <barcode>4988064451180</barcode><asin>B0001FAD2O</asin>
    <cover-art-archive>
      <artwork>true</artwork><count>1</count><front>true</front><back>false</back>
    </cover-art-archive>
    <medium-list count="1">
      <medium>
        <position>1</position>
        <format id="9712d52a-4509-3d4b-a1a2-67c88c643e31">CD</format>
        <track-list count="3" offset="0">
          <track id="ec60f5e2-ed8a-391d-90cd-bf119c50f6a0">
            <position>1</position><number>1</number><length>243000</length>
            <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
              <title>the Love Bug</title><length>243000</length>
              <artist-credit>
                <name-credit joinphrase="♥">
                  <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                    <alias-list count="6">
                      <alias sort-name="m-flow">m-flow</alias><alias sort-name="mediarite-flow crew">mediarite-flow crew</alias><alias sort-name="meteorite-flow crew">meteorite-flow crew</alias><alias sort-name="mflo">mflo</alias><alias sort-name="えむふろう">えむふろう</alias><alias sort-name="エムフロウ">エムフロウ</alias>
                    </alias-list>
                  </artist>
                </name-credit>
                <name-credit>
                  <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                    <name>BoA</name><sort-name>BoA</sort-name>
                    <alias-list count="5">
                      <alias sort-name="Beat of Angel">Beat of Angel</alias>
                      <alias sort-name="BoA Kwon">BoA Kwon</alias>
                      <alias sort-name="Kwon BoA">Kwon BoA</alias>
                      <alias sort-name="ボア">ボア</alias>
                      <alias sort-name="보아">보아</alias>
                    </alias-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <relation-list target-type="artist">
                <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                  <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                  <direction>backward</direction>
                  <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                  </artist>
                </relation>
                <relation type-id="36c50022-44e0-488d-994b-33f11d20301e" type="programming">
                  <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                  <direction>backward</direction>
                  <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                  </artist>
                </relation>
                <relation type-id="0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa" type="vocal">
                  <target>a16d1433-ba89-4f72-a47b-a370add0bb55</target>
                  <direction>backward</direction>
                  <attribute-list>
                    <attribute type-id="b3045913-62ac-433e-9211-ac683cdf6b5c">guest</attribute>
                  </attribute-list>
                  <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                    <name>BoA</name><sort-name>BoA</sort-name>
                  </artist>
                </relation>
              </relation-list>
              <first-release-date>2004-03-17</first-release-date>
            </recording>
          </track>
          <track id="2519283c-93d9-30de-a0ba-75f99ca25604">
            <position>2</position><number>2</number><length>222000</length>
            <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
              <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
              <artist-credit>
                <name-credit joinphrase="♥">
                  <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                    <alias-list count="6">
                      <alias sort-name="m-flow">m-flow</alias><alias sort-name="mediarite-flow crew">mediarite-flow crew</alias><alias sort-name="meteorite-flow crew">meteorite-flow crew</alias><alias sort-name="mflo">mflo</alias><alias sort-name="えむふろう">えむふろう</alias><alias sort-name="エムフロウ">エムフロウ</alias>
                    </alias-list>
                  </artist>
                </name-credit>
                <name-credit>
                  <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                    <name>BoA</name><sort-name>BoA</sort-name>
                    <alias-list count="5">
                      <alias sort-name="Beat of Angel">Beat of Angel</alias>
                      <alias sort-name="BoA Kwon">BoA Kwon</alias>
                      <alias sort-name="Kwon BoA">Kwon BoA</alias>
                      <alias sort-name="ボア">ボア</alias>
                      <alias sort-name="보아">보아</alias>
                    </alias-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>2004-03-17</first-release-date>
            </recording>
          </track>
          <track id="4ffc18f0-96cc-3e1f-8192-cf0d0c489beb">
            <position>3</position><number>3</number><length>333000</length>
            <recording id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
              <title>the Love Bug (cover)</title><length>333000</length>
              <artist-credit>
                <name-credit>
                  <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
                    <name>BAGDAD CAFE THE trench town</name><sort-name>BAGDAD CAFE THE trench town</sort-name>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>2004-03-17</first-release-date>
            </recording>
          </track>
        </track-list>
      </medium>
    </medium-list>
  </release>
</metadata>';

ws_test 'release lookup, tags are not duplicated for artists that are both release and recording artists (MBS-7900)',
    '/release/4f5a6b97-a09b-4893-80d1-eae1f3bfa221?inc=tags+artist-credits+artists+recordings' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release id="4f5a6b97-a09b-4893-80d1-eae1f3bfa221">
    <title>For Beginner Piano</title>
    <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
    <quality>normal</quality>
    <text-representation>
      <language>eng</language>
      <script>Latn</script>
    </text-representation>
    <artist-credit>
      <name-credit>
        <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
          <name>Plone</name>
          <sort-name>Plone</sort-name>
          <tag-list>
            <tag count="1">
              <name>british</name>
            </tag>
            <tag count="1">
              <name>electronic</name>
            </tag>
            <tag count="1">
              <name>electronica</name>
            </tag>
            <tag count="1">
              <name>english</name>
            </tag>
            <tag count="1">
              <name>glitch</name>
            </tag>
            <tag count="1">
              <name>uk</name>
            </tag>
            <tag count="1">
              <name>warp</name>
            </tag>
          </tag-list>
        </artist>
      </name-credit>
    </artist-credit>
    <date>1999-09-13</date>
    <country>GB</country>
    <release-event-list count="1">
      <release-event>
        <date>1999-09-13</date>
        <area id="8a754a16-0027-3a29-b6d7-2b40ea0481ed">
          <name>United Kingdom</name>
          <sort-name>United Kingdom</sort-name>
          <iso-3166-1-code-list>
            <iso-3166-1-code>GB</iso-3166-1-code>
          </iso-3166-1-code-list>
        </area>
      </release-event>
    </release-event-list>
    <barcode>5021603064126</barcode>
    <asin>B00001IVAI</asin>
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
        <track-list count="10" offset="0">
          <track id="9b9a84b5-0a41-38f6-859f-36cb22ac813c">
            <position>1</position>
            <number>1</number>
            <length>267560</length>
            <recording id="44704dda-b877-4551-a2a8-c1f764476e65">
              <title>On My Bus</title>
              <length>267560</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="f38b8e31-a10d-3973-8c1f-10923ee61adc">
            <position>2</position>
            <number>2</number>
            <length>230506</length>
            <recording id="8920288e-7541-48a7-b23b-f80447c8b1ab">
              <title>Top &amp; Low Rent</title>
              <length>230506</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="d17bed32-940a-3fcc-9210-a5d7c516b4bb">
            <position>3</position>
            <number>3</number>
            <length>237133</length>
            <recording id="6e89c516-b0b6-4735-a758-38e31855dcb6">
              <title>Plock</title>
              <length>237133</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="001bc675-ba25-32bc-9914-d5d9e22c3c44">
            <position>4</position>
            <number>4</number>
            <length>229826</length>
            <recording id="791d9b27-ae1a-4295-8943-ded4284f2122">
              <title>Marbles</title>
              <length>229826</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="c009176f-ff26-3f5f-bd16-46cede30ebe6">
            <position>5</position>
            <number>5</number>
            <length>217440</length>
            <recording id="4f392ffb-d3df-4f8a-ba74-fdecbb1be877">
              <title>Busy Working</title>
              <length>217440</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="70454e43-b39b-3ca7-8c50-ae235b5ef358">
            <position>6</position>
            <number>6</number>
            <length>227293</length>
            <recording id="dc891eca-bf42-4103-8682-86068fe732a5">
              <title>The Greek Alphabet</title>
              <length>227293</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="1b5da50c-e20f-3762-839c-5a0eea89d6a5">
            <position>7</position>
            <number>7</number>
            <length>244506</length>
            <recording id="25e9ae0f-8b7d-4230-9cde-9a07f7680e4a">
              <title>Press a Key</title>
              <length>244506</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="f1b5bd23-ad01-3c0c-a49a-cf8e99088369">
            <position>8</position>
            <number>8</number>
            <length>173960</length>
            <recording id="6f9c8c32-3aae-4dad-b023-56389361cf6b">
              <title>Bibi Plone</title>
              <length>173960</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="928f2274-5694-35f9-92da-a1fc565867cf">
            <position>9</position>
            <number>9</number>
            <length>208706</length>
            <recording id="7e379a1d-f2bc-47b8-964e-00723df34c8a">
              <title>Be Rude to Your School</title>
              <length>208706</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
          <track id="40727388-237d-34b2-8a3a-288878e5c883">
            <position>10</position>
            <number>10</number>
            <length>320067</length>
            <recording id="a8614bda-42dc-43c7-ac5f-4067acb6f1c5">
              <title>Summer Plays Out</title>
              <length>320067</length>
              <artist-credit>
                <name-credit>
                  <artist id="3088b672-fba9-4b4b-8ae0-dce13babfbb4" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Plone</name>
                    <sort-name>Plone</sort-name>
                    <tag-list>
                      <tag count="1">
                        <name>british</name>
                      </tag>
                      <tag count="1">
                        <name>electronic</name>
                      </tag>
                      <tag count="1">
                        <name>electronica</name>
                      </tag>
                      <tag count="1">
                        <name>english</name>
                      </tag>
                      <tag count="1">
                        <name>glitch</name>
                      </tag>
                      <tag count="1">
                        <name>uk</name>
                      </tag>
                      <tag count="1">
                        <name>warp</name>
                      </tag>
                    </tag-list>
                  </artist>
                </name-credit>
              </artist-credit>
              <first-release-date>1999-09-13</first-release-date>
            </recording>
          </track>
        </track-list>
      </medium>
    </medium-list>
  </release>
</metadata>';

ws_test 'release lookup, pregap track',
    '/release/ec0d0122-b559-4aa1-a017-7068814aae57?inc=artists+recordings+artist-credits' =>
    '<?xml version="1.0" ?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release id="ec0d0122-b559-4aa1-a017-7068814aae57">
    <title>Soup</title>
    <status id="4e304316-386d-3409-af2e-78857eec5cfe">Official</status>
    <quality>normal</quality>
    <text-representation>
      <language>eng</language>
      <script>Latn</script>
    </text-representation>
    <artist-credit>
      <name-credit>
        <artist id="38c5cdab-5d6d-43d1-85b0-dac41bde186e" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
          <name>Blind Melon</name>
          <sort-name>Blind Melon</sort-name>
        </artist>
      </name-credit>
    </artist-credit>
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
            <artist-credit>
              <name-credit>
                <artist id="38c5cdab-5d6d-43d1-85b0-dac41bde186e" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                  <name>Blind Melon</name>
                  <sort-name>Blind Melon</sort-name>
                </artist>
              </name-credit>
            </artist-credit>
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
              <artist-credit>
                <name-credit>
                  <artist id="38c5cdab-5d6d-43d1-85b0-dac41bde186e" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Blind Melon</name>
                    <sort-name>Blind Melon</sort-name>
                  </artist>
                </name-credit>
              </artist-credit>
            </recording>
          </track>
          <track id="e9f7ca98-ba9d-3276-97a4-26475c9f4527">
            <position>2</position>
            <number>2</number>
            <length>240400</length>
            <recording id="c830c239-3f91-4485-9577-4b86f92ad725">
              <title>2 X 4</title>
              <length>240400</length>
              <artist-credit>
                <name-credit>
                  <artist id="38c5cdab-5d6d-43d1-85b0-dac41bde186e" type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b">
                    <name>Blind Melon</name>
                    <sort-name>Blind Melon</sort-name>
                  </artist>
                </name-credit>
              </artist-credit>
            </recording>
          </track>
        </track-list>
      </medium>
    </medium-list>
  </release>
</metadata>';

};

test 'MBS-7914' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+mbs-7914');

    ws_test 'track aliases are included (MBS-7914)',
    '/release/a3ea3821-5955-4cee-b44f-4f7da8a332f7?inc=artists+media+recordings+artist-credits+aliases' =>
    '<?xml version="1.0" ?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release id="a3ea3821-5955-4cee-b44f-4f7da8a332f7">
    <title>Symphony no. 2</title>
    <quality>normal</quality>
    <artist-credit>
      <name-credit>
        <artist id="8d610e51-64b4-4654-b8df-064b0fb7a9d9" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
          <name>Gustav Mahler</name>
          <sort-name>Mahler, Gustav</sort-name>
          <alias-list count="1">
            <alias sort-name="グスタフ・マーラー">グスタフ・マーラー</alias>
          </alias-list>
        </artist>
      </name-credit>
    </artist-credit>
    <cover-art-archive>
      <artwork>false</artwork>
      <count>0</count>
      <front>false</front>
      <back>false</back>
    </cover-art-archive>
    <medium-list count="1">
      <medium>
        <position>1</position>
        <track-list count="1" offset="0">
          <track id="8ac89142-1318-490a-bed2-5b0c89b251b2">
            <position>1</position>
            <number>1</number>
            <artist-credit>
              <name-credit>
                <artist id="8d610e51-64b4-4654-b8df-064b0fb7a9d9" type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df">
                  <name>Gustav Mahler</name>
                  <sort-name>Mahler, Gustav</sort-name>
                  <alias-list count="1">
                    <alias sort-name="グスタフ・マーラー">グスタフ・マーラー</alias>
                  </alias-list>
                </artist>
              </name-credit>
            </artist-credit>
            <recording id="36d398e2-85bf-40d5-8686-4f0b78c80ca8">
              <title>Symphony no. 2 in C minor: I. Allegro maestoso</title>
              <artist-credit>
                <name-credit>
                  <artist id="509c772e-1164-4457-8d09-0553cfa77d64" type="Orchestra" type-id="a0b36c92-3eb1-3839-a4f9-4799823f54a5">
                    <name>Chicago Symphony Orchestra</name>
                    <sort-name>Chicago Symphony Orchestra</sort-name>
                    <alias-list count="1">
                      <alias sort-name="CSO">CSO</alias>
                    </alias-list>
                  </artist>
                </name-credit>
              </artist-credit>
            </recording>
          </track>
        </track-list>
      </medium>
    </medium-list>
  </release>
</metadata>';
};

1;
