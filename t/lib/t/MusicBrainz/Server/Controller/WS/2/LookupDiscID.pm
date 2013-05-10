package t::MusicBrainz::Server::Controller::WS::2::LookupDiscID;
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

MusicBrainz::Server::Test->prepare_test_database($c, '+tracklist');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO medium_cdtoc (medium, cdtoc) VALUES (2, 2);
EOSQL

ws_test 'direct disc id lookup',
    '/discid/IeldkVfIh1wep_M8CMuDvA0nQ7Q-' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <disc id="IeldkVfIh1wep_M8CMuDvA0nQ7Q-">
    <sectors>189343</sectors>
    <release-list count="1">
      <release id="f205627f-b70a-409d-adbe-66289b614e80">
        <title>Aerial</title>
        <quality>normal</quality>
        <date>2007</date>
        <release-event-list count="1">
          <release-event>
            <date>2007</date>
          </release-event>
        </release-event-list>
        <cover-art-archive>
            <artwork>false</artwork>
            <count>0</count>
            <front>false</front>
            <back>false</back>
        </cover-art-archive>
        <medium-list count="2">
          <medium>
            <title>A Sea of Honey</title>
            <position>1</position>
            <format>Format</format>
            <disc-list count="0" />
            <track-list count="7" />
          </medium>
          <medium>
            <title>A Sky of Honey</title>
            <position>2</position>
            <format>Format</format>
            <disc-list count="1">
              <disc id="IeldkVfIh1wep_M8CMuDvA0nQ7Q-"><sectors>189343</sectors>
              </disc>
            </disc-list>
            <track-list count="9" />
          </medium>
        </medium-list>
      </release>
    </release-list>
  </disc>
</metadata>';

$c->model('DurationLookup')->update(2);
$c->model('DurationLookup')->update(4);
ws_test 'lookup via toc',
    '/discid/aa11.sPglQ1x0cybDcDi0OsZw9Q-?toc=1 9 189343 150 6614 32287 54041 61236 88129 92729 115276 153877&cdstubs=no' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release-list>
    <release id="9b3d9383-3d2a-417f-bfbb-56f7c15f075b">
      <title>Aerial</title>
      <quality>normal</quality>
      <date>2008</date>
      <release-event-list count="1">
        <release-event>
          <date>2008</date>
        </release-event>
      </release-event-list>
      <cover-art-archive>
          <artwork>false</artwork>
          <count>0</count>
          <front>false</front>
          <back>false</back>
      </cover-art-archive>
      <medium-list count="2">
        <medium>
          <title>A Sea of Honey</title>
          <position>1</position>
          <format>Format</format>
          <disc-list count="0" />
          <track-list count="7" />
        </medium>
        <medium>
          <title>A Sky of Honey</title>
          <position>2</position>
          <format>Format</format>
          <disc-list count="0" />
          <track-list count="9" />
        </medium>
      </medium-list>
    </release>
    <release id="f205627f-b70a-409d-adbe-66289b614e80">
      <title>Aerial</title>
      <quality>normal</quality>
      <date>2007</date>
      <release-event-list count="1">
        <release-event>
          <date>2007</date>
        </release-event>
      </release-event-list>
      <cover-art-archive>
          <artwork>false</artwork>
          <count>0</count>
          <front>false</front>
          <back>false</back>
      </cover-art-archive>
      <medium-list count="2">
        <medium>
          <title>A Sea of Honey</title>
          <position>1</position>
          <format>Format</format>
          <disc-list count="0" />
          <track-list count="7" />
        </medium>
        <medium>
          <title>A Sky of Honey</title>
          <position>2</position>
          <format>Format</format>
          <disc-list count="1"><disc id="IeldkVfIh1wep_M8CMuDvA0nQ7Q-"><sectors>189343</sectors></disc></disc-list>
          <track-list count="9" />
        </medium>
      </medium-list>
    </release>
  </release-list>
</metadata>';

};

1;

