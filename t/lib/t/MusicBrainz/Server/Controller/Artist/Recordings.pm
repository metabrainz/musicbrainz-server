package t::MusicBrainz::Server::Controller::Artist::Recordings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test /artist/gid/recordings
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'get Test Artist page');
html_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has Test Artist');
$mech->title_like(qr/recordings/i, 'title indicates recordings listing');
$mech->content_contains('Test Recording');
$mech->content_contains('2:03');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'has a link to the recording');

};

1;
