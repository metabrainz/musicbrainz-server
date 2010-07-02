use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use XML::SemanticCompare;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok v2_schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v2 = v2_schema_validator;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a', 'basic artist lookup');
&$v2 ($mech->content, "Validate basic artist lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases', 'artist lookup, inc=aliases');
&$v2 ($mech->content, "Validate artist lookup with aliases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <alias-list count="5">
            <alias>보아</alias><alias>ボア</alias><alias>Kwon BoA</alias><alias>BoA Kwon</alias><alias>Beat of Angel</alias>
        </alias-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases', 'artist lookup with releases');
&$v2 ($mech->content, "Validate artist lookup with releases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="group">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="2">
            <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                <title>Summer Reggae! Rainbow</title>
                <status>pseudo-release</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Latn</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>official</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Jpan</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases', 'artist lookup with releases');
&$v2 ($mech->content, "Validate artist lookup with releases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="group">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="2">
            <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                <title>Summer Reggae! Rainbow</title>
                <status>pseudo-release</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Latn</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>official</status>
                <text-representation>
                    <language>jpn</language>
                    <script>Jpan</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=releases+discids', 'artist lookup with releases and discids');
&$v2 ($mech->content, "Validate artist lookup with releases and discids");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <release-list count="2">
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
                <title>My Demons</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2007-01-29</date><country>GB</country>
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>cd</format>
                        <disc-list count="1">
                            <disc id="75S7Yp3IiqPVREQhjAjMXPhwz0Y-">
                                <sectors>281289</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="12" />
                    </medium>
                </medium-list>
            </release>
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
                <title>Repercussions</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2008-11-17</date><country>GB</country>
                <medium-list count="2">
                    <medium>
                        <position>1</position><format>cd</format>
                        <disc-list count="1">
                            <disc id="93K4ogyxWlv522XF0BG8fZOuay4-">
                                <sectors>215137</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="9" />
                    </medium>
                    <medium>
                        <title>Chestplate Singles</title><position>2</position><format>cd</format>
                        <disc-list count="1">
                            <disc id="VnL0A7ksXznBxvZ94H3Z61EZY3k-">
                                <sectors>208393</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="9" />
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=recordings+artist-credits', 'artist lookup with recordings and artist credits');
&$v2 ($mech->content, "Validate artist lookup with recordings and artist credits");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
        <name>m-flo</name><sort-name>m-flo</sort-name>
        <life-span>
            <begin>1998</begin>
        </life-span>
        <recording-list count="2">
            <recording id="0cf3008f-e246-428f-abc1-35f87d584d60">
                <title>the Love Bug</title><length>242226</length>
                <artist-credit>
                    <name-credit joinphrase="♥">
                        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                            <name>m-flo</name>
                        </artist>
                    </name-credit>
                    <name-credit>
                        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                            <name>BoA</name>
                        </artist>
                    </name-credit>
                </artist-credit>
            </recording>
            <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
                <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
                <artist-credit>
                    <name-credit joinphrase="♥">
                        <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                            <name>m-flo</name>
                        </artist>
                    </name-credit>
                    <name-credit>
                        <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55">
                            <name>BoA</name>
                        </artist>
                    </name-credit>
                </artist-credit>
            </recording>
        </recording-list>
    </artist>
</metadata>';


$mech->get_ok('/ws/2/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=release-groups', 'artist lookup with release groups');
&$v2 ($mech->content, "Validate artist lookup with release groups");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
        <name>m-flo</name><sort-name>m-flo</sort-name>
        <life-span>
            <begin>1998</begin>
        </life-span>
        <release-group-list count="1">
            <release-group type="single" id="153f0a09-fead-3370-9b17-379ebd09446b">
                <title>the Love Bug</title>
            </release-group>
        </release-group-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=releases', 'single artist release lookup');
&$v2 ($mech->content, "Validate single artist release lookup");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
        <name>m-flo</name><sort-name>m-flo</sort-name>
        <life-span>
            <begin>1998</begin>
        </life-span>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=releases+various-artists', 'various artists release lookup');
&$v2 ($mech->content, "Validate various artists release lookup");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title><status>official</status>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
