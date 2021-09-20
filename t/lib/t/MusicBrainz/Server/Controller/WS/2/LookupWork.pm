package t::MusicBrainz::Server::Controller::WS::2::LookupWork;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use utf8;
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
MusicBrainz::Server::Test->prepare_test_database($c, '+webservice_annotation');
MusicBrainz::Server::Test->prepare_test_database($c, '+multi_language_work');
MusicBrainz::Server::Test->prepare_test_database($c, <<~'SQL');
    INSERT INTO iswc (work, iswc)
        VALUES ( (SELECT id FROM work WHERE gid = '3c37b9fa-a6c1-37d2-9e90-657a116d337c'), 'T-000.000.002-0');
    INSERT INTO work_attribute VALUES (1, 1307406, 1, 33, NULL);
    SQL

ws_test 'basic work lookup',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song" type-id="f061270a-2fd6-32f1-a641-f0f8676d14e6">
    <title>サマーれげぇ!レインボー</title>
    <language>jpn</language>
    <language-list>
      <language>jpn</language>
    </language-list>
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
    <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song" type-id="f061270a-2fd6-32f1-a641-f0f8676d14e6">
      <title>サマーれげぇ!レインボー</title>
      <language>jpn</language>
      <language-list>
        <language>jpn</language>
      </language-list>
      <iswc>T-000.000.002-0</iswc>
      <iswc-list><iswc>T-000.000.002-0</iswc></iswc-list>
    </work>
  </work-list>
</metadata>';

ws_test 'work lookup with recording relationships',
    '/work/3c37b9fa-a6c1-37d2-9e90-657a116d337c?inc=recording-rels' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="3c37b9fa-a6c1-37d2-9e90-657a116d337c" type="Song" type-id="f061270a-2fd6-32f1-a641-f0f8676d14e6">
    <title>サマーれげぇ!レインボー</title>
    <language>jpn</language>
    <language-list>
      <language>jpn</language>
    </language-list>
    <iswc>T-000.000.002-0</iswc>
    <iswc-list><iswc>T-000.000.002-0</iswc></iswc-list>
    <relation-list target-type="recording">
      <relation type-id="a3005666-a872-32c3-ad06-98af558e99b0" type="performance">
        <target>162630d9-36d2-4a8d-ade1-1c77440b34e7</target>
        <direction>backward</direction>
        <recording id="162630d9-36d2-4a8d-ade1-1c77440b34e7">
          <title>サマーれげぇ!レインボー</title>
          <length>296026</length>
        </recording>
      </relation>
      <relation type-id="a3005666-a872-32c3-ad06-98af558e99b0" type="performance">
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

ws_test 'work lookup with attributes',
    '/work/7981d409-8e76-33df-be27-ef625d81c501' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <work id="7981d409-8e76-33df-be27-ef625d81c501">
    <title>Shine We Are!</title>
    <attribute-list>
      <attribute type="Key" type-id="7526c19d-3be4-3420-b6cc-9fb6e49fa1a9" value-id="32ea711e-9df6-328c-a495-1e6e32e7253b">B major</attribute>
    </attribute-list>
  </work>
</metadata>';

ws_test 'work lookup with multiple languages',
    '/work/8753a51f-dd84-492d-8c5a-a39283045118' =>
    '<?xml version="1.0"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
<work type="Song" id="8753a51f-dd84-492d-8c5a-a39283045118" type-id="f061270a-2fd6-32f1-a641-f0f8676d14e6">
  <title>Mon petit amoureux</title>
  <language>mul</language>
  <language-list>
    <language>eng</language>
    <language>fra</language>
  </language-list>
</work>
</metadata>';

};

1;

