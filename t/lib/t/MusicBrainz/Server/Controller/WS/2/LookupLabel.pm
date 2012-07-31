package t::MusicBrainz::Server::Controller::WS::2::LookupLabel;
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

ws_test 'basic label lookup',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" id="b4edce40-090f-4956-b82a-5d9d285da40b">
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <country>GB</country>
        <life-span><begin>1995</begin></life-span>
    </label>
</metadata>';

ws_test 'label lookup, inc=aliases',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" id="b4edce40-090f-4956-b82a-5d9d285da40b">
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <country>GB</country>
        <life-span><begin>1995</begin></life-span>
        <alias-list count="1"><alias sort-name="Planet µ">Planet µ</alias></alias-list>
    </label>
</metadata>';

ws_test 'label lookup with releases, inc=media',
    '/label/b4edce40-090f-4956-b82a-5d9d285da40b?inc=releases+media' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <label type="Original Production" id="b4edce40-090f-4956-b82a-5d9d285da40b">
        <name>Planet Mu</name><sort-name>Planet Mu</sort-name>
        <country>GB</country>
        <life-span><begin>1995</begin></life-span>
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
                        <position>1</position><format>CD</format><track-list count="9" />
                    </medium>
                    <medium>
                        <title>Chestplate Singles</title>
                        <position>2</position><format>CD</format><track-list count="9" />
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
                        <position>1</position><format>CD</format><track-list count="12" />
                    </medium>
                </medium-list>
            </release>
        </release-list>
    </label>
</metadata>';

};

1;

