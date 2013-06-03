package t::MusicBrainz::Server::Controller::WS::2::LookupRelationship;
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

ws_test 'artist lookup with url relationships',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <relation-list target-type="url">
            <relation type-id="eb535226-f8ca-499d-9b18-6a144df4ae6f" type="blog">
                <target id="5eb2c075-3c3b-4cf7-ab77-2dacaee19366">http://dj-distance.blogspot.com/</target>
            </relation>
            <relation type-id="29651736-fa6d-48e4-aadc-a557c6add1cb" type="wikipedia">
                <target id="651248e8-6a8f-4365-948a-aa43559caf58">http://en.wikipedia.org/wiki/Distance_(musician)</target>
            </relation>
            <relation type-id="04a5b104-a4c2-4bac-99a1-7b837c37d9e4" type="discogs">
                <target id="03e3d0be-d336-447e-b7da-06d0adcd15cd">http://www.discogs.com/artist/DJ+Distance</target>
            </relation>
            <relation type-id="bac47923-ecde-4b59-822e-d08f0cd10156" type="myspace">
                <target id="63854ab2-4804-481f-8b07-e2cbe8192c0f">http://www.myspace.com/djdistancedub</target>
            </relation>
        </relation-list>
    </artist>
</metadata>';

ws_test 'artist lookup with non-url relationships',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=artist-rels+label-rels+recording-rels+release-rels+release-group-rels+work-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <relation-list target-type="recording">
            <relation type-id="0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa" type="vocal">
                <target>0cf3008f-e246-428f-abc1-35f87d584d60</target>
                <attribute-list><attribute>guest</attribute></attribute-list>
                <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
                    <title>the Love Bug</title><length>242226</length>
                </recording>
            </relation>
        </relation-list>
    </artist>
</metadata>';

ws_test 'release lookup with release relationships',
    '/release/0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e?inc=release-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
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
        <asin>B00005LA6G</asin>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
        <relation-list target-type="release">
            <relation type-id="fc399d47-23a7-4c28-bfcf-0607a562b644" type="transl-tracklisting">
                <target>b3b7e934-445b-4c68-a097-730c6a6d47e6</target>
                <attribute-list><attribute>transliterated</attribute></attribute-list>
                <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                    <title>Summer Reggae! Rainbow</title><date>2001-07-04</date><release-event-list count="1"><release-event><date>2001-07-04</date></release-event></release-event-list><barcode>4942463511227</barcode>
                    <quality>normal</quality>
                </release>
            </relation>
        </relation-list>
    </release>
</metadata>';

ws_test 'recording lookup with artist relationships and credits',
    '/recording/0cf3008f-e246-428f-abc1-35f87d584d60?inc=artist-rels+artist-credits' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
        <title>the Love Bug</title><length>242226</length>
        <artist-credit>
            <name-credit joinphrase="♥">
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name>
                    <sort-name>m-flo</sort-name>
                </artist>
            </name-credit>
            <name-credit>
                <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                  <name>BoA</name>
                  <sort-name>BoA</sort-name>
                </artist>
            </name-credit>
        </artist-credit>
        <relation-list target-type="artist">
            <relation type-id="5c0ceac3-feb4-41f0-868d-dc06f6e27fc0" type="producer">
                <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                <direction>backward</direction>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </relation>
            <relation type-id="36c50022-44e0-488d-994b-33f11d20301e" type="programming">
                <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                <direction>backward</direction>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </relation>
            <relation type-id="0fdbe3c6-7700-4a31-ae54-b53f06ae1cfa" type="vocal">
                <target>a16d1433-ba89-4f72-a47b-a370add0bb55</target>
                <direction>backward</direction>
                <attribute-list><attribute>guest</attribute></attribute-list>
                <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                    <name>BoA</name><sort-name>BoA</sort-name>
                </artist>
            </relation>
        </relation-list>
    </recording>
</metadata>';

ws_test 'label lookup with label and url relationships',
    '/label/72a46579-e9a0-405a-8ee1-e6e6b63b8212?inc=label-rels+url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" id="72a46579-e9a0-405a-8ee1-e6e6b63b8212">
        <name>rhythm zone</name><sort-name>rhythm zone</sort-name><country>JP</country>
        <area id="2db42837-c832-3c27-b4a3-08198f75693c">
            <name>Japan</name>
            <sort-name>Japan</sort-name>
            <iso-3166-1-code-list>
                <iso-3166-1-code>JP</iso-3166-1-code>
            </iso-3166-1-code-list>
        </area>
        <relation-list target-type="url">
            <relation type-id="51e9db21-8864-49b3-aa58-470d7b81fa50" type="wikipedia">
                <target id="4e5f8e53-a6fc-46e2-8fe4-2b3192be57e1">http://en.wikipedia.org/wiki/Rhythm_Zone</target>
            </relation>
            <relation type-id="51e9db21-8864-49b3-aa58-470d7b81fa50" type="wikipedia">
                <target id="e697226c-7752-47d5-9192-5722babd9c32">http://ja.wikipedia.org/wiki/Rhythm_zone</target>
            </relation>
            <relation type-id="fe108f43-acb9-4ad1-8be3-57e6ec5b17b6" type="official site">
                <target id="2a545d02-5447-4f16-a9c5-6239d98ea3f0">http://rzn.jp/</target>
            </relation>
            <relation type-id="5b987f87-25bc-4a2d-b3f1-3618795b8207" type="discogs">
                <target id="baaf9d35-392a-407a-b1bb-564015b146c6">http://www.discogs.com/label/Rhythm+Zone</target>
            </relation>
        </relation-list>
    </label>
</metadata>';

ws_test 'release group lookup with url relationships',
    '/release-group/153f0a09-fead-3370-9b17-379ebd09446b?inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release-group type="Single" id="153f0a09-fead-3370-9b17-379ebd09446b">
        <title>the Love Bug</title>
        <first-release-date>2004-03-17</first-release-date>
        <primary-type>Single</primary-type>
        <relation-list target-type="url">
            <relation type-id="6578f0e9-1ace-4095-9de8-6e517ddb1ceb" type="wikipedia">
                <target id="5e766c4e-16dd-47f2-b032-d96ef23c0cf1">http://en.wikipedia.org/wiki/The_Love_Bug_(song)</target>
            </relation>
            <relation type-id="6578f0e9-1ace-4095-9de8-6e517ddb1ceb" type="wikipedia">
                <target id="dff9a8ca-2029-4818-92d4-d45b91484b0a">http://ja.wikipedia.org/wiki/The_Love_Bug</target>
            </relation>
        </relation-list>
    </release-group>
</metadata>';

ws_test 'release lookup with recording-level relationships',
    '/release/980e0f65-930e-4743-95d3-602665c25c15?inc=recordings+artist-rels+work-rels+recording-level-rels+work-level-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <release id="980e0f65-930e-4743-95d3-602665c25c15">
        <title>Exogamy</title>
        <status>Official</status>
        <quality>normal</quality>
        <text-representation>
            <language>eng</language>
            <script>Latn</script>
        </text-representation>
        <date>2008-04-29</date>
        <country>US</country>
        <release-event-list count="1">
          <release-event>
            <date>2008-04-29</date>
            <area id="489ce91b-6658-3307-9877-795b68554c98">
                <name>United States</name>
                <sort-name>United States</sort-name>
                <iso-3166-1-code-list>
                    <iso-3166-1-code>US</iso-3166-1-code>
                </iso-3166-1-code-list>
            </area>
          </release-event>
        </release-event-list>
        <barcode>844395014422</barcode>
        <asin>B0015XAAY2</asin>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
        <medium-list count="1">
            <medium>
                <position>1</position>
                <track-list count="9" offset="0">
                    <track id="719e1eba-920f-31da-9c45-9eb53f791aee">
                        <position>1</position><number>1</number>
                        <length>256666</length>
                        <recording id="88d26635-cfc8-4fd9-b81e-36f7a1b3d270">
                            <title>Reverend Charisma</title>
                            <length>256666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>e8d55116-1ea6-339a-a059-228d71c2f27d</target>
                                    <work id="e8d55116-1ea6-339a-a059-228d71c2f27d">
                                        <title>Reverend Charisma</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="5a0b7a30-4297-3cda-ba0f-2547c4b7ae9b">
                        <position>2</position><number>2</number>
                        <length>86666</length>
                        <recording id="37a8d72a-a9c9-4edc-9ecf-b5b58e6197a9">
                            <title>Dear Diary</title>
                            <length>86666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>2cd04f80-fbd7-343f-8499-bf0028f0f530</target>
                                    <work id="2cd04f80-fbd7-343f-8499-bf0028f0f530">
                                        <title>Dear Diary</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="a5b038bf-6e36-362b-9397-9cecda03e9bc">
                        <position>3</position><number>3</number>
                        <length>213666</length>
                        <recording id="7152d72e-c7d4-4b15-9f8e-97fabb88b1af">
                            <title>Black Sundress</title>
                            <length>213666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>b07e71c7-1cc7-3c6f-8c31-22be30a472dd</target>
                                    <work id="b07e71c7-1cc7-3c6f-8c31-22be30a472dd">
                                        <title>Black Sundress</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="7c66606c-8a1b-3407-a856-21e4622da140">
                        <position>4</position><number>4</number>
                        <length>266666</length>
                        <recording id="da778cae-9e88-4385-af7f-666e102b94af">
                            <title>Allegiance?WTF?</title>
                            <length>266666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>c4a1c334-ccd3-37df-b248-40653cefb181</target>
                                    <work id="c4a1c334-ccd3-37df-b248-40653cefb181">
                                        <title>Allegiance?WTF?</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="2d11d4ec-b9c0-3bfe-86d9-df5034e2522e">
                        <position>5</position><number>5</number>
                        <length>254666</length>
                        <recording id="150b8c8c-ed02-4ade-99cc-e8d673f6f5b9">
                            <title>Maggie&amp;Heidi</title>
                            <length>254666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>b26203e5-73cb-3579-b575-a12d8b3f8209</target>
                                    <work id="b26203e5-73cb-3579-b575-a12d8b3f8209">
                                        <title>Maggie&amp;Heidi</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="3ec79596-482b-3d1b-8f48-325a1b332366">
                        <position>6</position><number>6</number>
                        <length>236666</length>
                        <recording id="9815c3e5-f842-41c2-bb5c-bcd0dd97dbe5">
                            <title>Discopharma</title>
                            <length>236666</length>
                        </recording>
                    </track>
                    <track id="baaa07d9-6c32-31e6-bbea-1796fd79a8f1">
                        <position>7</position><number>7</number>
                        <length>230666</length>
                        <recording id="6356e37c-a44b-4218-80ce-6fb6c11a124f">
                            <title>Still Unsatisfied</title>
                            <length>230666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>9c38c012-9b30-30a2-a2fb-4b44afdc3973</target>
                                    <work id="9c38c012-9b30-30a2-a2fb-4b44afdc3973">
                                        <title>Still Unsatisfied</title>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="61add1a9-5a53-3eb3-afa6-fb503998a909">
                        <position>8</position><number>8</number>
                        <length>274666</length>
                        <recording id="4878bc36-7306-497a-b45a-561d9f7f8573">
                            <title>Asseswaving</title>
                            <length>274666</length>
                            <relation-list target-type="work">
                                <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                                    <target>f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8</target>
                                    <work id="f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8">
                                        <title>Asseswaving</title>
                                        <language>jpn</language>
                                        <relation-list target-type="artist">
                                            <relation type-id="21d842db-81d4-4d30-a0bd-8c6cc07e1dc2" type="composer">
                                                <target>472bc127-8861-45e8-bc9e-31e8dd32de7a</target>
                                                <direction>backward</direction>
                                                <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                                                    <name>Distance</name>
                                                    <sort-name>Distance</sort-name>
                                                    <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                                                </artist>
                                            </relation>
                                        </relation-list>
                                    </work>
                                </relation>
                            </relation-list>
                        </recording>
                    </track>
                    <track id="8cef791e-3363-3c36-8b29-1f5dd2982902">
                        <position>9</position><number>9</number>
                        <length>249653</length>
                        <recording id="15918f5f-20b1-4e1a-888d-8762790017a9">
                            <title>Just Because</title>
                            <length>249653</length>
                        </recording>
                    </track>
                </track-list>
            </medium>
        </medium-list>
    </release>
</metadata>
';


ws_test 'recording lookup with work-level relationships',
    '/recording/4878bc36-7306-497a-b45a-561d9f7f8573?inc=artist-rels+work-rels+work-level-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <recording id="4878bc36-7306-497a-b45a-561d9f7f8573">
        <title>Asseswaving</title>
        <length>274666</length>
        <relation-list target-type="work">
            <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
                <target>f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8</target>
                <work id="f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8">
                    <title>Asseswaving</title>
                    <language>jpn</language>
                    <relation-list target-type="artist">
                        <relation type-id="21d842db-81d4-4d30-a0bd-8c6cc07e1dc2" type="composer">
                            <target>472bc127-8861-45e8-bc9e-31e8dd32de7a</target>
                            <direction>backward</direction>
                            <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
                                <name>Distance</name>
                                <sort-name>Distance</sort-name>
                                <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
                            </artist>
                        </relation>
                    </relation-list>
                </work>
            </relation>
        </relation-list>
    </recording>
</metadata>
';


};

1;

