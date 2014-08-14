package t::MusicBrainz::Server::Controller::WS::2::LookupEvent;
use Test::Routine;
use Test::More;

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
$mech->default_header("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');

$mech->get('/ws/2/event/eb668bdc-a928-49a1-beb7-8e37db2a5b65?inc=coffee');
is($mech->status, 400);
is_xml_same($mech->content, q{<?xml version="1.0"?>
<error>
  <text>coffee is not a valid inc parameter for the event resource.</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>});

ws_test 'basic event lookup',
    '/event/eb668bdc-a928-49a1-beb7-8e37db2a5b65' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <event type="Festival" id="eb668bdc-a928-49a1-beb7-8e37db2a5b65">
        <name>Cool Festival</name>
    </event>
</metadata>';

ws_test 'event lookup, inc=aliases',
    '/event/eb668bdc-a928-49a1-beb7-8e37db2a5b65?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <event type="Festival" id="eb668bdc-a928-49a1-beb7-8e37db2a5b65">
        <name>Cool Festival</name>
        <alias-list count="2">
            <alias sort-name="Festival Cool, El">El Festival Cool</alias>
            <alias sort-name="Warm Festival">Warm Festival</alias>
        </alias-list>
    </event>
</metadata>';

};

1;
