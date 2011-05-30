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
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'artist lookup with url relationships',
    '/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?inc=url-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <relation-list target-type="url">
            <relation type="blog">
                <target>http://dj-distance.blogspot.com/</target>
            </relation>
            <relation type="wikipedia">
                <target>http://en.wikipedia.org/wiki/Distance_(musician)</target>
            </relation>
            <relation type="discogs">
                <target>http://www.discogs.com/artist/DJ+Distance</target>
            </relation>
            <relation type="myspace">
                <target>http://www.myspace.com/djdistancedub</target>
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
            <relation type="vocal">
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
        <date>2001-07-04</date><country>JP</country><barcode>4942463511227</barcode>
        <asin>B00005LA6G</asin>
        <relation-list target-type="release">
            <relation type="transl-tracklisting">
                <target>b3b7e934-445b-4c68-a097-730c6a6d47e6</target>
                <attribute-list><attribute>transliterated</attribute></attribute-list>
                <release id="b3b7e934-445b-4c68-a097-730c6a6d47e6">
                    <title>Summer Reggae! Rainbow</title><date>2001-07-04</date><barcode>4942463511227</barcode>
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
            <relation type="producer">
                <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                <direction>backward</direction>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </relation>
            <relation type="programming">
                <target>22dd2db3-88ea-4428-a7a8-5cd3acf23175</target>
                <direction>backward</direction>
                <artist id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
                    <name>m-flo</name><sort-name>m-flo</sort-name>
                </artist>
            </relation>
            <relation type="vocal">
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
        <relation-list target-type="url">
            <relation type="wikipedia">
                <target>http://en.wikipedia.org/wiki/Rhythm_Zone</target>
            </relation>
            <relation type="wikipedia">
                <target>http://ja.wikipedia.org/wiki/Rhythm_zone</target>
            </relation>
            <relation type="official site">
                <target>http://rzn.jp/</target>
            </relation>
            <relation type="discogs">
                <target>http://www.discogs.com/label/Rhythm+Zone</target>
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
        <relation-list target-type="url">
            <relation type="wikipedia">
                <target>http://en.wikipedia.org/wiki/The_Love_Bug_(song)</target>
            </relation>
            <relation type="wikipedia">
                <target>http://ja.wikipedia.org/wiki/The_Love_Bug</target>
            </relation>
        </relation-list>
    </release-group>
</metadata>';

};

1;

