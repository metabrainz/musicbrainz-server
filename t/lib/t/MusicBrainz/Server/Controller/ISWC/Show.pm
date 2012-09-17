package t::MusicBrainz::Server::Controller::ISWC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_iswc');

$mech->get_ok('/iswc/T-702.152.911-5');
html_ok($mech->content);
$mech->content_contains('vient le vent');

$mech->get_ok('/iswc/T-702.152.911.5');
html_ok($mech->content);
$mech->content_contains('vient le vent');

$mech->get_ok('/iswc/T7021529115');
html_ok($mech->content);
$mech->content_contains('vient le vent');

$mech->get('/iswc/xxx');
is($mech->status(), 404);

};

1;
