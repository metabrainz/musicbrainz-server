package t::MusicBrainz::Server::Controller::WS::1::LookupReleaseGroup;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use HTTP::Request::Common;
use MusicBrainz::Server::Test qw( xml_ok schema_validator );
use MusicBrainz::Server::Test ws_test => {
    version => 1
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'release group lookup',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?type=xml' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album">
    <title>My Demons</title>
  </release-group>
</metadata>';

ws_test 'release group lookup with artists',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?type=xml&inc=artist' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album">
    <title>My Demons</title>
    <artist id="472bc127-8861-45e8-bc9e-31e8dd32de7a">
      <sort-name>Distance</sort-name><name>Distance</name>
    </artist>
  </release-group>
</metadata>';

ws_test 'release group lookup with releases',
    '/release-group/22b54315-6e51-350b-bb34-e6e16f7688bd?type=xml&inc=releases' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">
  <release-group id="22b54315-6e51-350b-bb34-e6e16f7688bd" type="Album">
    <title>My Demons</title>
    <release-list>
      <release id="adcf7b48-086e-48ee-b420-1001f88d672f" type="Album Official">
        <title>My Demons</title><text-representation script="Latn" language="ENG" /><track-list offset="11" />
      </release>
    </release-list>
  </release-group>
</metadata>';

};

1;

