package t::MusicBrainz::Server::Controller::WS::2::LookupRelease;
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
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO release_tag (count, release, tag) VALUES (1, 123054, 114);
INSERT INTO editor (id, name, password) VALUES (15412, 'editor', 'mb');
INSERT INTO editor_collection (id, gid, editor, name, public) VALUES (14933, 'f34c079d-374e-4436-9448-da92dedef3cd', 15412, 'My Collection', TRUE);
INSERT INTO editor_collection_release (collection, release) VALUES (14933, 123054);
EOSQL

ws_test 'basic release lookup',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
        <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
        <quality>normal</quality>
        <text-representation>
            <language>jpn</language><script>Latn</script>
        </text-representation>
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        <asin>B00005LA6G</asin>
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
        <status>Official</status><quality>normal</quality>
        <annotation><text>this is a release annotation</text></annotation>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>2007-01-29</date>
        <country>GB</country>
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
        <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
        <quality>normal</quality>
        <text-representation>
            <language>jpn</language><script>Latn</script>
        </text-representation>
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
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
        <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
        <quality>normal</quality>
        <text-representation>
            <language>jpn</language><script>Latn</script>
        </text-representation>
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        <asin>B00005LA6G</asin>
        <collection-list>
            <collection id="f34c079d-374e-4436-9448-da92dedef3cd">
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

ws_test 'release lookup with artists + aliases',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artists+aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title><status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
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
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
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
        <title>the Love Bug</title><status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
        <asin>B0001FAD2O</asin>
        <label-info-list count="1">
            <label-info>
                <catalog-number>RZCD-45118</catalog-number>
                <label id="72a46579-e9a0-405a-8ee1-e6e6b63b8212">
                    <name>rhythm zone</name><sort-name>rhythm zone</sort-name>
                </label>
            </label-info>
        </label-info-list>
        <medium-list count="1">
            <medium>
                <position>1</position>
                <track-list count="3" offset="0">
                    <track>
                        <position>1</position><number>1</number>
                        <length>243000</length>
                        <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
                            <title>the Love Bug</title><length>242226</length>
                            <tag-list>
                                <tag count="1"><name>kpop</name></tag>
                            </tag-list>
                        </recording>
                    </track>
                    <track>
                        <position>2</position><number>2</number>
                        <length>222000</length>
                        <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
                            <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
                            <tag-list>
                                <tag count="1"><name>jpop</name></tag>
                            </tag-list>
                        </recording>
                    </track>
                    <track>
                        <position>3</position><number>3</number>
                        <length>333000</length>
                        <recording id="3f33fc37-43d0-44dc-bfd6-60efd38810c5">
                            <title>the Love Bug (cover)</title><length>333000</length>
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

ws_test 'release lookup with release-groups',
    '/release/aff4a693-5970-4e2e-bd46-e2ee49c22de7?inc=artist-credits+release-groups' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
        <title>the Love Bug</title><status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <artist-credit>
            <name-credit>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name>
                    <sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
        <release-group type="Single" id="153f0a09-fead-3370-9b17-379ebd09446b">
            <title>the Love Bug</title>
            <first-release-date>2004-03-17</first-release-date>
            <primary-type>Single</primary-type>
            <artist-credit>
                <name-credit>
                    <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                        <name>m-flo</name>
                        <sort-name>m-flo</sort-name>
                    </artist>
                </name-credit>
            </artist-credit>
        </release-group>
        <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
        <asin>B0001FAD2O</asin>
        <cover-art-archive>
            <artwork>true</artwork>
            <count>1</count>
            <front>true</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

ws_test 'release lookup with discids and puids',
    '/release/b3b7e934-445b-4c68-a097-730c6a6d47e6?inc=discids+puids+recordings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
        <title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status>
        <quality>normal</quality>
        <text-representation>
            <language>jpn</language><script>Latn</script>
        </text-representation>
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        <asin>B00005LA6G</asin>
        <medium-list count="1">
            <medium>
                <position>1</position><format>CD</format>
                <disc-list count="1">
                    <disc id="W01Qvrvwkaz2Cm.IQm55_RHoRxs-">
                        <sectors>60295</sectors>
                    </disc>
                </disc-list>
                <track-list count="3" offset="0">
                    <track>
                        <position>1</position><number>1</number><title>Summer Reggae! Rainbow</title><length>296026</length>
                        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
                            <title>サマーれげぇ!レインボー</title><length>296026</length>
                            <puid-list count="1">
                                <puid id="cdec3fe2-0473-073c-3cbb-bfb0c01a87ff" />
                            </puid-list>
                        </recording>
                    </track>
                    <track>
                        <position>2</position><number>2</number><title>Hello! Mata Aou Ne (7nin Matsuri version)</title><length>213106</length>
                        <recording id="487cac92-eed5-4efa-8563-c9a818079b9a">
                            <title>HELLO! また会おうね (7人祭 version)</title><length>213106</length>
                            <puid-list count="1">
                                <puid id="251bd265-84c7-ed8f-aecf-1d9918582399" />
                            </puid-list>
                        </recording>
                    </track>
                    <track>
                        <position>3</position><number>3</number><title>Summer Reggae! Rainbow (Instrumental)</title><length>292800</length>
                        <recording id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
                            <title>サマーれげぇ!レインボー (instrumental)</title><length>292800</length>
                            <puid-list count="1">
                                <puid id="7b8a868f-1e67-852b-5141-ad1edfb1e492" />
                            </puid-list>
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

ws_test 'release lookup, barcode is NULL',
    '/release/fbe4eb72-0f24-3875-942e-f581589713d4' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="fbe4eb72-0f24-3875-942e-f581589713d4">
        <title>For Beginner Piano</title><status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>1999-09-23</date><country>US</country>
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
        <title>For Beginner Piano</title><status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language><script>Latn</script>
        </text-representation>
        <date>1999-09-13</date><country>GB</country>
        <barcode />
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
    </release>
</metadata>';

};

1;

