package t::MusicBrainz::Server::Controller::WS::2::LookupURL;
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
$mech->default_header ("Accept" => "application/xml");

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'basic url lookup',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
    </url>
</metadata>';

ws_test 'basic url lookup (by URL)',
    '/url?resource=http://www.discogs.com/artist/Paul%2BAllgood' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
    </url>
</metadata>';

ws_test 'basic url lookup (with inc=artist-rels)',
    '/url/e0a79771-e9f0-4127-b58a-f5e6869c8e96?inc=artist-rels' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
    <url id="e0a79771-e9f0-4127-b58a-f5e6869c8e96">
      <resource>http://www.discogs.com/artist/Paul+Allgood</resource>
      <relation-list target-type="artist">
        <relation type-id="04a5b104-a4c2-4bac-99a1-7b837c37d9e4" type="discogs">
          <target>05d83760-08b5-42bb-a8d7-00d80b3bf47c</target>
          <direction>backward</direction>
          <artist id="05d83760-08b5-42bb-a8d7-00d80b3bf47c">
            <name>Paul Allgood</name>
            <sort-name>Allgood, Paul</sort-name>
          </artist>
        </relation>
      </relation-list>
    </url>
</metadata>';

};

1;

