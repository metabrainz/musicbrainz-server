package t::MusicBrainz::Server::Controller::WS::2::BrowseArtists;
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

ws_test 'browse artists via release group',
    '/artist?release-group=22b54315-6e51-350b-bb34-e6e16f7688bd' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="Person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        </artist>
    </artist-list>
</metadata>';

ws_test 'browse artists via recording',
    '/artist?inc=aliases&recording=0cf3008f-e246-428f-abc1-35f87d584d60' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="2">
        <artist type="Group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
            <alias-list count="6">
                <alias>m-flow</alias><alias>mediarite-flow crew</alias><alias>meteorite-flow crew</alias><alias>mflo</alias><alias>えむふろう</alias><alias>エムフロウ</alias>
            </alias-list>
        </artist>
        <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <name>BoA</name><sort-name>BoA</sort-name>
            <life-span>
                <begin>1986-11-05</begin>
            </life-span>
            <alias-list count="5">
                <alias>Beat of Angel</alias><alias>BoA Kwon</alias><alias>Kwon BoA</alias><alias>ボア</alias><alias>보아</alias>
            </alias-list>
        </artist>
    </artist-list>
</metadata>';

ws_test 'browse artists via release, inc=tags+ratings',
    '/artist?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7&inc=tags+ratings' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="3">
        <artist type="Group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
            <rating votes-count="3">3</rating>
        </artist>
        <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
            <name>BAGDAD CAFE THE trench town</name>
            <sort-name>BAGDAD CAFE THE trench town</sort-name>
        </artist>
        <artist type="Person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
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
            </tag-list>
            <rating votes-count="3">4.35</rating>
        </artist>
    </artist-list>
</metadata>';

};

1;

