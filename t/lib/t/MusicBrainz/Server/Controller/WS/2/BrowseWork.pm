package t::MusicBrainz::Server::Controller::WS::2::BrowseWork;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

ws_test 'browse works via artist (first page)',
    '/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work-list count="10">
    <work id="37814c05-f7ff-308d-a339-21570bc56003">
      <title>Be Rude to Your School</title>
    </work>
    <work id="3a62a9f7-1365-32aa-9da8-3e0ef1f2b0ca">
      <title>Bibi Plone</title>
    </work>
    <work id="294f16fe-e123-3634-a0f4-03953e111321">
      <title>Busy Working</title>
    </work>
    <work id="2734cd31-4bab-3bf6-a758-c5d94ad957bb">
      <title>Marbles</title>
    </work>
    <work id="25c7c80f-a624-3b3e-b643-4204b05cb447">
      <title>On My Bus</title>
    </work>
  </work-list>
</metadata>';

ws_test 'browse works via artist (second page)',
    '/work?artist=3088b672-fba9-4b4b-8ae0-dce13babfbb4&limit=5&offset=5' =>
    '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work-list count="10" offset="5">
    <work id="482530c1-a2ab-32e8-be43-ea5240aa7913">
      <title>Plock</title>
    </work>
    <work id="93836f17-7646-374e-a679-455429162c20">
      <title>Press a Key</title>
    </work>
    <work id="e67f54be-a68b-351d-9fbf-57468e61fd95">
      <title>Summer Plays Out</title>
    </work>
    <work id="f4f581d8-50e0-3886-bcd3-610187821bcd">
      <title>The Greek Alphabet</title>
    </work>
    <work id="4290c4aa-f538-31d8-b502-cb01fc7fc5af">
      <title>Top &amp; Low Rent</title>
    </work>
  </work-list>
</metadata>';

};

1;

