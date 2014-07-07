package t::MusicBrainz::Server::Controller::Recording::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', 'fetch recording');
html_ok($mech->content);
$mech->title_like(qr/King of the Mountain/, 'title has recording name');
$mech->content_like(qr/King of the Mountain/, 'content has recording name');
$mech->content_like(qr/4:54/, 'has recording duration');
$mech->content_like(qr{1\.1}, 'track position');
$mech->content_like(qr{United Kingdom}, 'release country');
$mech->content_like(qr{DEE250800230}, 'ISRC');
$mech->content_like(qr{2005-11-07}, 'release date 1');
$mech->content_like(qr{2005-11-08}, 'release date 2');
$mech->content_like(qr{/release/f205627f-b70a-409d-adbe-66289b614e80}, 'link to release 1');
$mech->content_like(qr{/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b}, 'link to release 2');
$mech->content_like(qr{/artist/4b585938-f271-45e2-b19a-91c634b5e396}, 'link to artist');
$mech->content_like(qr{has <a href="[^"]+">Guitar</a> performed by}, 'relationships');

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'fetch dancing queen recording');
html_ok($mech->content);
$mech->title_like(qr/Dancing Queen/);
$mech->content_contains('Test annotation 3', 'has annotation');

};

1;
