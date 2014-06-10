package t::MusicBrainz::Server::Controller::WS::2::LookupInstrument;
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

$mech->get('/ws/2/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a?inc=coffee');
is($mech->status, 400);
is_xml_same($mech->content, q{<?xml version="1.0"?>
<error>
  <text>coffee is not a valid inc parameter for the instrument resource.</text>
  <text>For usage, please see: http://musicbrainz.org/development/mmd</text>
</error>});

ws_test 'basic instrument lookup',
    '/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <instrument type="Wind instrument" id="3590521b-8c97-4f4b-b1bb-5f68d3663d8a">
        <name>English horn</name>
    </instrument>
</metadata>';

ws_test 'instrument lookup, inc=aliases',
    '/instrument/3590521b-8c97-4f4b-b1bb-5f68d3663d8a?inc=aliases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <instrument type="Wind instrument" id="3590521b-8c97-4f4b-b1bb-5f68d3663d8a">
        <name>English horn</name>
        <alias-list count="2">
            <alias sort-name="English horn">English horn</alias>
            <alias sort-name="cor anglais">cor anglais</alias>
        </alias-list>
    </instrument>
</metadata>';

};

1;

