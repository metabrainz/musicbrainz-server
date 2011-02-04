package t::MusicBrainz::Server::Controller::Release::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80', 'fetch release');
html_ok($mech->content);
$mech->title_like(qr/Aerial/, 'title has release name');
$mech->content_like(qr/Aerial/, 'content has release name');
$mech->content_like(qr/Kate Bush/, 'release artist credit');
$mech->content_like(qr/Test Artist/, 'artist credit on the last track');
$mech->content_contains('343 960 2', 'has catalog number');
$mech->content_contains('Warp Records', 'contains label name');
$mech->content_contains('/label/46f0f4cd-8aab-4b33-b698-f459faf64190',
                        'has a link to the label');

};

1;
