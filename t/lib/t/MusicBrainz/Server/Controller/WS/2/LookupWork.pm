package t::MusicBrainz::Server::Controller::WS::2::LookupWork;
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

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');
MusicBrainz::Server::Test->prepare_test_database($c, <<'EOSQL');
INSERT INTO iswc (work, iswc)
VALUES ( (SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'), 'T-000.000.002-0');
EOSQL

ws_test 'basic work lookup',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song">
    <title>サマーれげぇ!レインボー</title>
    <language>jpn</language>
    <iswc>T-000.000.002-0</iswc>
    <iswc-list><iswc>T-000.000.002-0</iswc></iswc-list>
  </work>
</metadata>';

ws_test 'work lookup, inc=annotation',
    '/work/482530c1-a2ab-32e8-be43-ea5240aa7913?inc=annotation' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="482530c1-a2ab-32e8-be43-ea5240aa7913">
    <title>Plock</title>
    <annotation><text>this is a work annotation</text></annotation>
  </work>
</metadata>';

ws_test 'work lookup via iswc',
    '/iswc/T-000.000.002-0' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work-list count="1">
    <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song">
      <title>サマーれげぇ!レインボー</title>
      <language>jpn</language>
      <iswc>T-000.000.002-0</iswc>
      <iswc-list><iswc>T-000.000.002-0</iswc></iswc-list>
    </work>
  </work-list>
</metadata>';

ws_test 'work lookup with recording relationships',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=recording-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song">
    <title>サマーれげぇ!レインボー</title>
    <language>jpn</language>
    <iswc>T-000.000.002-0</iswc>
    <iswc-list><iswc>T-000.000.002-0</iswc></iswc-list>
    <relation-list target-type="recording">
      <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
        <target>162630d9-36d2-4a8d-ade1-1c77440b34e7</target>
        <direction>backward</direction>
        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
          <title>サマーれげぇ!レインボー</title>
          <length>296026</length>
        </recording>
      </relation>
      <relation type-id="fdc57134-e05c-30bc-aff6-425684475276" type="performance">
        <target>eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e</target>
        <direction>backward</direction>
        <recording id="eb818aa4-d472-4d2b-b1a9-7fe5f1c7d26e">
          <title>サマーれげぇ!レインボー (instrumental)</title>
          <length>292800</length>
        </recording>
      </relation>
    </relation-list>
  </work>
</metadata>';

};

1;

