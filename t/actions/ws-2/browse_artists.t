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



$mech->get_ok('/ws/2/artist?release-group=22b54315-6e51-350b-bb34-e6e16f7688bd', 'browse artists via release group');
&$v2 ($mech->content, "Validate browse artists via release group");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="1">
        <artist type="person" id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
            <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        </artist>
    </artist-list>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist?inc=aliases&recording=0cf3008f-e246-428f-abc1-35f87d584d60', 'browse artists via recording');
&$v2 ($mech->content, "Validate browse artists via recording");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="2">
        <artist type="person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <name>BoA</name><sort-name>BoA</sort-name>
            <life-span>
                <begin>1986-11-05</begin>
            </life-span>
            <alias-list count="5">
                <alias>보아</alias><alias>ボア</alias><alias>Kwon BoA</alias><alias>BoA Kwon</alias><alias>Beat of Angel</alias>
            </alias-list>
        </artist>
        <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
            <alias-list count="6">
                <alias>エムフロウ</alias><alias>m-flow</alias><alias>mflo</alias><alias>meteorite-flow crew</alias><alias>mediarite-flow crew</alias><alias>えむふろう</alias>
            </alias-list>
        </artist>
    </artist-list>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/2/artist?release=aff4a693-5970-4e2e-bd46-e2ee49c22de7', 'browse artists via release');
&$v2 ($mech->content, "Validate browse artists via release");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <artist-list count="3">
        <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
            <name>BAGDAD CAFE THE trench town</name><sort-name>BAGDAD CAFE THE trench town</sort-name>
        </artist>
        <artist type="person" id="a16d1433-ba89-4f72-a47b-a370add0bb55">
            <name>BoA</name><sort-name>BoA</sort-name>
            <life-span>
                <begin>1986-11-05</begin>
            </life-span>
        </artist>
        <artist type="group" id="22dd2db3-88ea-4428-a7a8-5cd3acf23175">
            <name>m-flo</name><sort-name>m-flo</sort-name>
            <life-span>
                <begin>1998</begin>
            </life-span>
        </artist>
    </artist-list>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
