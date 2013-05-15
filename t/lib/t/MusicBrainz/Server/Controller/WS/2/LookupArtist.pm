package t::MusicBrainz::Server::Controller::WS::2::LookupArtist;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use XML::SemanticDiff;
use Test::XML::SemanticCompare;
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
$mech->default_header ("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

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
            <alias sort-name="Beat of Angel">Beat of Angel</alias>
            <alias sort-name="BoA Kwon">BoA Kwon</alias>
            <alias sort-name="Kwon BoA">Kwon BoA</alias>
            <alias sort-name="ボア">ボア</alias>
            <alias sort-name="보아">보아</alias>
        </alias-list>
    </artist>
</metadata>';

ws_test 'artist lookup, inc=annotation',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=annotation' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name>
        <annotation><text>this is an artist annotation</text></annotation>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

ws_test 'artist lookup with releases',
    '/artist/802673f0-9b88-4e8a-bb5c-dd01d68b086f?inc=releases' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Group" id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
        <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        <release-list count="2">
            <release id="0385f276-5f4f-4c81-a7a4-6bd7b8d85a7e">
                <title>サマーれげぇ!レインボー</title>
                <status>Official</status>
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
            </release>
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
    </artist>
</metadata>';

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
                <title>Repercussions</title>
                <status>Official</status>
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
                <title>My Demons</title>
                <status>Official</status>
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
                <primary-type>Single</primary-type>
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
            </release>
        </release-list>
    </artist>
</metadata>';

ws_test 'various artists release lookup',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=releases+various-artists&status=official' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
        <name>BoA</name>
        <sort-name>BoA</sort-name>
        <life-span><begin>1986-11-05</begin></life-span>
        <release-list count="1">
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7">
                <title>the Love Bug</title><status>Official</status>
                <quality>normal</quality>
                <text-representation>
                    <language>eng</language><script>Latn</script>
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
            </release>
        </release-list>
    </artist>
</metadata>';

$mech->get('/ws/2/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=coffee');
is($mech->status, 400);
is_xml_same($mech->content, q{<?xml version="1.0"?>
<error>
  <text>coffee is not a valid inc parameter for the artist resource.</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>});

ws_test 'artist lookup with works (using l_artist_work)',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=works' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
    <name>Distance</name><sort-name>Distance</sort-name>
    <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    <work-list count="1">
    <work id="f5cdd40d-6dc3-358b-8d7d-22dd9d8f87a8"><title>Asseswaving</title></work>
    </work-list>
  </artist>
</metadata>';

ws_test 'artist lookup with works (using l_recording_work)',
    '/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=works' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
    <name>BoA</name><sort-name>BoA</sort-name>
    <life-span><begin>1986-11-05</begin></life-span>
    <work-list count="15">
      <work id="286ecfdd-2ffe-3bc7-b3e9-04cc8cea229b"><title>Easy To Be Hard</title></work>
      <work id="2d967c29-63dc-309d-bbc1-a2d38639aaa1"><title>心の手紙</title></work>
      <work id="303f9bd2-152f-3145-9e09-afa34edb6a57"><title>DOUBLE</title></work>
      <work id="46724ef1-241e-3d7f-9f3b-e51ba34e2aa1"><title>the Love Bug</title></work>
      <work id="4b6a46c2-a904-3471-9bff-3942d4549f47"><title>SOME DAY ONE DAY )</title></work>
      <work id="50c07b24-7ee2-31ac-ab87-f0d399011c71"><title>Milky Way 〜君の歌〜</title></work>
      <work id="511f5124-c0ae-3386-bb76-4b6521498a68"><title>Milky Way-君の歌-</title></work>
      <work id="53d1fbac-e60a-38cb-85ff-e5a9224c9749"><title>Be the one</title></work>
      <work id="61ab56f0-e803-3aef-a91b-63564b7a8043"><title>Rock With You</title></work>
      <work id="6f08d5a8-1811-3e5e-848b-35ffa77babe5"><title>Midnight Parade</title></work>
      <work id="7981d409-8e76-33df-be27-ef625d81c501"><title>Shine We Are!</title></work>
      <work id="7e78f281-52b4-315b-9d7b-6d215732f3d7"><title>EXPECT</title></work>
      <work id="cd86f9e2-83ce-3192-a817-fe6c98079303"><title>Song With No Name～名前のない歌～</title></work>
      <work id="d2f1ea1f-de2e-3d0c-b534-e96377912478"><title>OVER～across the time～</title></work>
      <work id="f23ae726-0300-3830-b1ca-634f4362f78c"><title>LOVE &amp; HONESTY</title></work>
    </work-list>
  </artist>
</metadata>';

ws_test 'artist lookup with artist relations',
    '/artist/678ba12a-e485-44c7-8eaf-25e61a78a61b?inc=artist-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="678ba12a-e485-44c7-8eaf-25e61a78a61b">
        <name>後藤真希</name><sort-name>Goto, Maki</sort-name><gender>Female</gender><country>JP</country>
        <area id="2db42837-c832-3c27-b4a3-08198f75693c">
    	    <name>Japan</name>
            <sort-name>Japan</sort-name>
	    <iso-3166-1-code-list>
		<iso-3166-1-code>JP</iso-3166-1-code>
	    </iso-3166-1-code-list>
	</area>
        <life-span>
            <begin>1985-09-23</begin>
        </life-span>
        <relation-list target-type="artist">
            <relation type-id="5be4c609-9afa-4ea0-910b-12ffb71e3821" type="member of band">
                <target>802673f0-9b88-4e8a-bb5c-dd01d68b086f</target><begin>2001</begin>
                <artist id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
                    <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
                </artist>
            </relation>
        </relation-list>
    </artist>
</metadata>';

};

1;

