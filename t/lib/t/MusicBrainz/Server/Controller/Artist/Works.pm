package t::MusicBrainz::Server::Controller::Artist::Works;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

use aliased 'MusicBrainz::Server::Entity::PartialDate';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/works', 'get Test Artist works page');
html_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has artist');
$mech->title_like(qr/works/i, 'title indicates works listing');
$mech->content_contains('Test Work');
$mech->content_contains('/work/745c079d-374e-4436-9448-da92dedef3ce', 'has a link to the work');

};

1;
