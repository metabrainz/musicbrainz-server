package t::MusicBrainz::Server::Controller::WS::2::LookupArtist;
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
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'basic artist lookup',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

ws_test 'artist lookup, inc=aliases',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name><sort-name>BoA</sort-name>
        <life-span>
            <begin>1986-11-05</begin>
        </life-span>
        <alias-list count="5">
            <alias>Beat of Angel</alias><alias>BoA Kwon</alias><alias>Kwon BoA</alias><alias>ボア</alias><alias>보아</alias>
        </alias-list>
    </artist>
</metadata>';

ws_test 'artist lookup with releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases' =>
    '<?xml version="1.0"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#"><artist type="Group" id="802673f0-9b88-4e8a-bb5c-dd01d68b086f"><name>7人祭</name><sort-name>7nin Matsuri</sort-name><release-list count="2"><release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e"><title>サマーれげぇ!レインボー</title><status>Official</status><quality>normal</quality><text-representation><language>jpn</language><script>Jpan</script></text-representation><date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode></release><release id="b3b7e934-445b-4c68-a097-730c6a6d47e6"><title>Summer Reggae! Rainbow</title><status>Pseudo-Release</status><quality>normal</quality><text-representation><language>jpn</language><script>Latn</script></text-representation><date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode></release></release-list></artist></metadata>';

ws_test 'artist lookup with pseudo-releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases&type=single&status=pseudo-release' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f" type="Group">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="1">
            <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                <title>Summer Reggae! Rainbow</title>
                <status>Pseudo-Release</status>
                <quality>normal</quality>
                <text-representation>
                    <language>jpn</language>
                    <script>Latn</script>
                </text-representation>
                <date>2001-07-04</date>
                <country>JP</country>
                <barcode>4942463511227</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

ws_test 'artist lookup with releases and discids',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=releases+discids' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <release-list count="2">
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134">
                <title>Repercussions</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2008-11-17</date><country>GB</country><barcode>600116822123</barcode>
                <medium-list count="2">
                    <medium>
                        <position>1</position><format>CD</format>
                        <disc-list count="1">
                            <disc id="93K4ogyxWlv522XF0BG8fZOuay4-">
                                <sectors>215137</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="9" />
                    </medium>
                    <medium>
                        <title>Chestplate Singles</title><position>2</position><format>CD</format>
                        <disc-list count="1">
                            <disc id="VnL0A7ksXznBxvZ94H3Z61EZY3k-">
                                <sectors>208393</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="9" />
                    </medium>
                </medium-list>
            </release>
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f">
                <title>My Demons</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2007-01-29</date><country>GB</country><barcode>600116817020</barcode>
                <medium-list count="1">
                    <medium>
                        <position>1</position><format>CD</format>
                        <disc-list count="1">
                            <disc id="75S7Yp3IiqPVREQhjAjMXPhwz0Y-">
                                <sectors>281289</sectors>
                            </disc>
                        </disc-list>
                        <track-list count="12" />
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </artist>
</metadata>';

ws_test 'artist lookup with recordings and artist credits',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=recordings+artist-credits' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
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
            </recording>
            <recording id="84c98ebf-5d40-4a29-b7b2-0e9c26d9061d">
                <title>the Love Bug (Big Bug NYC remix)</title><length>222000</length>
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
            </recording>
        </recording-list>
    </artist>
</metadata>';

ws_test 'artist lookup with release groups',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=release-groups&type=single' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
        <name>m-flo</name><sort-name>m-flo</sort-name>
        <life-span>
            <begin>1998</begin>
        </life-span>
        <release-group-list count="1">
            <release-group type="Single" id="153f0a09-fead-3370-9b17-379ebd09446b">
                <title>the Love Bug</title>
                <first-release-date>2004-03-17</first-release-date>
            </release-group>
        </release-group-list>
    </artist>
</metadata>';

ws_test 'single artist release lookup',
    '/artist/22dd2db3-88ea-4428-a7a8-5cd3acf23175?inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
        <name>m-flo</name><sort-name>m-flo</sort-name>
        <life-span>
            <begin>1998</begin>
        </life-span>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
                </text-representation>
                <date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode>
            </release>
        </release-list>
    </artist>
</metadata>';

ws_test 'various artists release lookup',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=releases+various-artists&status=official' =>
    '<?xml version="1.0"?><metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#"><artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55"><name>BoA</name><sort-name>BoA</sort-name><life-span><begin>1986-11-05</begin></life-span><release-list count="1"><release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7"><title>the Love Bug</title><status>Official</status><quality>normal</quality><text-representation><language>eng</language><script>Latn</script></text-representation><date>2004-03-17</date><country>JP</country><barcode>4988064451180</barcode></release></release-list></artist></metadata>';

};

1;

