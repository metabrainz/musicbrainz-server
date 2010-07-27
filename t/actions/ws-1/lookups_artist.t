use utf8;
use strict;
use Test::More;
use XML::SemanticDiff;
use XML::SemanticCompare;
use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $v1 = schema_validator (1);
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $diff = XML::SemanticDiff->new;

$mech->get_ok('/ws/1/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a', 'basic artist lookup');
&$v1 ($mech->content, "Validate basic artist lookup");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
        <name>Distance</name><sort-name>Distance</sort-name>
        <disambiguation>UK dubstep artist Greg Sanders</disambiguation>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');


$mech->get_ok('/ws/1/artist/a16d1433-ba89-4f72-a47b-a370add0bb55?inc=aliases', 'artist lookup with aliases');
&$v1 ($mech->content, "Validate artist lookup with aliases");

$expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="a16d1433-ba89-4f72-a47b-a370add0bb55" type="Person">
        <name>BoA</name><sort-name>BoA</sort-name><life-span begin="1986-11-05" />
        <alias-list>
            <alias>Beat of Angel</alias><alias>BoA Kwon</alias><alias>Kwon BoA</alias><alias>보아</alias><alias>ボア</alias>
        </alias-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');


$mech->get_ok('/ws/1/artist/472bc127-8861-45e8-bc9e-31e8dd32de7a?type=xml&inc=release-groups+sa-Album', 'artist lookup with release groups');
&$v1 ($mech->content, "Validate artist lookup with release groups");

my $expected = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a" type="Person">
        <name>Distance</name><sort-name>Distance</sort-name><disambiguation>UK dubstep artist Greg Sanders</disambiguation>
        <release-list>
            <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official" >
                <title>My Demons</title><text-representation language="ENG" script="Latn"/>
                <asin>B000KJTG6K</asin><release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd"/>
            </release>
            <release id="3b3d130a-87a8-4a47-b9fb-920f2530d134" type="Album Official" >
                <title>Repercussions</title><text-representation language="ENG" script="Latn"/>
                <asin>B001IKWNCE</asin><release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2"/>
            </release>
        </release-list>
        <release-group-list>
            <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album" >
                <title>My Demons</title>
            </release-group>
            <release-group id="56683a0b-45b8-3664-a231-5b68efe2e7e2" type="Album" >
                <title>Repercussions</title>
            </release-group>
        </release-group-list>
    </artist>
</metadata>';

is ($diff->compare ($expected, $mech->content), 0, 'result ok');

$mech->get_ok('/ws/1/artist/97fa3f6e-557c-4227-bc0e-95a7f9f3285d?type=xml&inc=va-Single+url-rels+release-events+labels+counts', 'artist lookup with va-Single and more');
&$v1 ($mech->content, "Validate artist lookup with va-Single and more");

$expected ='<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
    <artist id="97fa3f6e-557c-4227-bc0e-95a7f9f3285d">
        <name>BAGDAD CAFE THE trench town</name><sort-name>BAGDAD CAFE THE trench town</sort-name>
        <release-list>
            <release id="aff4a693-5970-4e2e-bd46-e2ee49c22de7" type="Single Official" >
                <title>the Love Bug</title><text-representation language="ENG" script="Latn"/>
                <release-event-list>
                    <event date="2004-03-17" country="JP" catalog-number="RZCD-45118" barcode="4988064451180" format="CD">
                        <label id="72a46579-e9a0-405a-8ee1-e6e6b63b8212">
                            <name>rhythm zone</name><sort-name></sort-name>
                            <relation-list target-type="Url">
                                <relation type="Wikipedia" target="http://ja.wikipedia.org/wiki/Rhythmzone" begin="" end=""/><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/Rhythm_Zone" begin="" end=""/>
                                <relation type="Discogs" target="http://www.discogs.com/label/Rhythm+Zone" begin="" end=""/>
                                <relation type="OfficialSite" target="http://rzn.jp" begin="" end=""/>
                            </relation-list>
                        </label>
                    </event>
                </release-event-list>
                <track-list count="3"/>
                <relation-list target-type="Url">
                    <relation type="Wikipedia" target="http://ja.wikipedia.org/wiki/The_Love_Bug" begin="" end=""/><relation type="Wikipedia" target="http://en.wikipedia.org/wiki/The_Love_Bug_%28song%29" begin="" end=""/>
                    <relation type="AmazonAsin" target="http://www.amazon.co.jp/gp/product/B0001FAD2O" begin="" end=""/>
                </relation-list>
            </release>
        </release-list>
        <relation-list target-type="Url">
            <relation type="OfficialHomepage" target="http://www.mop2001.com/bag.html" begin="" end=""/>
        </relation-list>
    </artist>
</metadata>';

# FIXME: test doesn't pass yet...
# is ($diff->compare ($expected, $mech->content), 0, 'result ok');

done_testing;
