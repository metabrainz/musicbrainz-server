package t::MusicBrainz::Server::Controller::WS::2::BrowseArtists;
use Test::Routine;
use Test::More;
use HTTP::Status qw( :constants );

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test::WS qw(
    ws2_test_xml
    ws2_test_xml_forbidden
    ws2_test_xml_unauthorized
);

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws2_test_xml 'browse artists via release group',
    '/artist?release-group=22b54315-6e51-350b-bb34-e6e16f7688bd' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        </artist>
    </artist-list>
</metadata>';

ws2_test_xml 'browse artists via recording',
    '/artist?inc=aliases&recording=0cf3008f-e246-428f-abc1-35f87d584d60' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="2">
        <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
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
        <artist type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
            <alias-list count="6">
              <alias sort-name="m-flow">m-flow</alias>
              <alias sort-name="mediarite-flow crew">mediarite-flow crew</alias>
              <alias sort-name="meteorite-flow crew">meteorite-flow crew</alias>
              <alias sort-name="mflo">mflo</alias>
              <alias sort-name="えむふろう">えむふろう</alias>
              <alias sort-name="エムフロウ">エムフロウ</alias>
            </alias-list>
        </artist>
    </artist-list>
</metadata>';

ws2_test_xml 'browse artists via release, inc=tags+ratings',
    '/artist?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7&inc=tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="3">
        <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
            <name>BAGDAD CAFE THE trench town</name>
            <sort-name>BAGDAD CAFE THE trench town</sort-name>
        </artist>
        <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <name>BoA</name><sort-name>BoA</sort-name>
            <life-span>
                <begin>1986-11-05</begin>
            </life-span>
            <tag-list>
              <tag count="1"><name>c-pop</name></tag>
              <tag count="1"><name>j-pop</name></tag>
              <tag count="1"><name>japanese</name></tag>
              <tag count="1"><name>jpop</name></tag>
              <tag count="1"><name>k-pop</name></tag>
              <tag count="1"><name>kpop</name></tag>
              <tag count="1"><name>pop</name></tag>
              <tag count="1"><name>supercalifragilisticexpialidocious</name></tag>
            </tag-list>
            <rating votes-count="3">4.35</rating>
        </artist>
        <artist type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
            <rating votes-count="3">3</rating>
        </artist>
    </artist-list>
</metadata>';

ws2_test_xml 'browse artists via work',
    '/artist?work=3c37b9fa-a6c1-37d2-9e90-657a116d337c' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b" id="802673f0-9b88-4e8a-bb5c-dd01d68b086f">
            <name>7人祭</name><sort-name>7nin Matsuri</sort-name>
        </artist>
    </artist-list>
</metadata>';

ws2_test_xml 'browse artists via public collection',
    '/artist?collection=9c782444-f9f4-4a4f-93cb-92d132c79887' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="Person" type-id="b6e035f4-3ce9-331c-97df-83397230b0df" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <name>BoA</name>
            <sort-name>BoA</sort-name>
            <life-span>
              <begin>1986-11-05</begin>
            </life-span>
        </artist>
    </artist-list>
</metadata>';

ws2_test_xml 'browse artists via private collection',
    '/artist?collection=5f0831af-c84c-44a3-849d-abdf0a18cdd9' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="Group" type-id="e431f5f6-b5d2-343d-8b36-72607fffb74b" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name>
            <sort-name>m-flo</sort-name>
            <life-span>
              <begin>1998</begin>
            </life-span>
        </artist>
    </artist-list>
</metadata>',
    { username => 'the-anti-kuno', password => 'notreally' };

ws2_test_xml_forbidden 'browse artists via private collection, no credentials',
    '/artist?collection=5f0831af-c84c-44a3-849d-abdf0a18cdd9';

ws2_test_xml_unauthorized 'browse artists via private collection, bad credentials',
    '/artist?collection=5f0831af-c84c-44a3-849d-abdf0a18cdd9',
    { username => 'the-anti-kuno', password => 'idk' };

my $res = $test->mech->get('/ws/2/artist?work=3c37b9fa-a6c1-37d2-9e90-657a116d337c&limit=-1');
is($res->code, HTTP_BAD_REQUEST);

$res = $test->mech->get('/ws/2/artist?work=3c37b9fa-a6c1-37d2-9e90-657a116d337c&offset=a+bit');
is($res->code, HTTP_BAD_REQUEST);

$res = $test->mech->get('/ws/2/artist?work=3c37b9fa-a6c1-37d2-9e90-657a116d337c&limit=10&offset=-1');
is($res->code, HTTP_BAD_REQUEST);

};

1;

