package t::MusicBrainz::Server::Controller::WS::2::SubmitCDStub;
use utf8;
use strict;
use warnings;

use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

use HTTP::Status qw( :constants );

use MusicBrainz::Server::Test qw( xml_ok xml_post );
use MusicBrainz::Server::Test ws_test => {
    version => 2
};

test all => sub {

my $test = shift;
my $c = $test->c;
my $mech = $test->mech;
$mech->default_header('Accept' => 'application/xml');

MusicBrainz::Server::Test->prepare_test_database($c, '+webservice');

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

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
