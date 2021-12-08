package t::MusicBrainz::Server::Controller::Release::Details;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/details',
              'fetch release details page');
html_ok($mech->content);
$mech->content_contains('https://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
                        '..has permanent link');
$mech->content_contains('>f205627f-b70a-409d-adbe-66289b614e80</',
                        '..has mbid in plain text');

$mech->content_contains('CD', 'contains medium type');
$mech->content_contains('Official', 'contains release status');
$mech->content_contains('Album', 'contains release group type');
$mech->content_contains('343 960 2', 'has catalog number');
$mech->content_contains('Warp Records', 'contains label name');
$mech->content_contains('/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
                        'has a link to the label');

};

1;
