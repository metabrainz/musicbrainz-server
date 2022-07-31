package t::MusicBrainz::Server::Controller::WS::2::MoodList;
use Test::Routine;

use MusicBrainz::Server::Test::WS qw( ws2_test_xml );

with 't::Mechanize', 't::Context';

use utf8;

=head2 Test description

This test ensures the full mood list at mood/all is working as intended.

=cut

test 'Test mood list is returned as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

    ws2_test_xml 'mood list',
        '/mood/all' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <mood-list count="3">
    <mood id="1f6e3b62-33d6-4ac0-a9dc-f5424af3e6a4">
      <name>happy</name>
    </mood>
    <mood id="186a6a89-24de-4a3a-a92f-b7744dc7b051">
      <name>sad</name>
    </mood>
    <mood id="e1a39f19-5f05-4944-ba2b-b037706cf586">
      <name>supercalifragilisticexpialidocious</name>
      <disambiguation>stuff</disambiguation>
    </mood>
  </mood-list>
</metadata>';
};

test 'Mood list inc parameters work as expected' => sub {
    my $test = shift;
    my $c = $test->c;

    MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');
    MusicBrainz::Server::Test->prepare_test_database(
      $c,
      '+webservice_annotation',
    );

    ws2_test_xml 'mood list',
        '/mood/all?inc=aliases+annotation' =>
        '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <mood-list count="3">
    <mood id="1f6e3b62-33d6-4ac0-a9dc-f5424af3e6a4">
      <name>happy</name>
    </mood>
    <mood id="186a6a89-24de-4a3a-a92f-b7744dc7b051">
      <name>sad</name>
    </mood>
    <mood id="e1a39f19-5f05-4944-ba2b-b037706cf586">
      <name>supercalifragilisticexpialidocious</name>
      <disambiguation>stuff</disambiguation>
      <annotation>
        <text>this is a mood annotation</text>
      </annotation>
      <alias-list count="1">
        <alias locale="en" sort-name="supercalifragilistic">supercalifragilistic</alias>
      </alias-list>
    </mood>
  </mood-list>
</metadata>';
};

1;
