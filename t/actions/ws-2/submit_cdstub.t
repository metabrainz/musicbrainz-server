use strict;
use warnings;
use Test::More;

use HTTP::Status qw( :constants );
use MusicBrainz::Server::Test qw( schema_validator xml_ok xml_post );
use MusicBrainz::WWW::Mechanize;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = MusicBrainz::WWW::Mechanize->new(catalyst_app => 'MusicBrainz::Server');

my $content = '<?xml version="1.0" encoding="UTF-8"?>
<metadata xmlns="http://musicbrainz.org/ns/mmd-2.0#">
  <release>
    <title>Anatomy</title>
    <artist>Teebee &amp; Calyx</artist>
    <toc>1 1 50 0</toc>
    <discid>aLEEYhZd9gLkLqePI07J5QbtmF0-</discid>
    <track-list>
      <track>
        <title>Warrior</title>
      </track>
    </track-list>
  </release>
</metadata>';

my $req = xml_post('/ws/2/cdstub?client=test-1.0', $content);
$mech->request($req);
is($mech->status, HTTP_OK);
xml_ok($mech->content);

my ($cdstub) = $c->model('CDStub')->get_by_discid('aLEEYhZd9gLkLqePI07J5QbtmF0-');
ok($cdstub);
is($cdstub->artist, 'Teebee & Calyx');
is($cdstub->title, 'Anatomy');

$c->model('CDStubTrack')->load_for_cdstub($cdstub);
is($cdstub->all_tracks => 1);
is($cdstub->tracks->[0]->title, 'Warrior');

done_testing;
