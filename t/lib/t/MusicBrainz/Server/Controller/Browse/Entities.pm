package t::MusicBrainz::Server::Controller::Browse::Entities;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_browse');

$mech->get_ok("/browse/artist");
html_ok($mech->content);
$mech->get_ok("/browse/label");
html_ok($mech->content);
$mech->get_ok("/browse/release");
html_ok($mech->content);
$mech->get_ok("/browse/release-group");
html_ok($mech->content);
$mech->get_ok("/browse/work");
html_ok($mech->content);

$mech->get_ok("/browse/artist?index=q");
html_ok($mech->content);
$mech->content_contains("Queen");

$mech->get_ok("/browse/label?index=w");
html_ok($mech->content);
$mech->content_contains("Warp");

$mech->get_ok("/browse/release?index=a");
html_ok($mech->content);
$mech->content_contains("Aerial");

$mech->get_ok("/browse/release-group?index=a");
html_ok($mech->content);
$mech->content_contains("Aerial");

$mech->get_ok("/browse/work?index=d");
html_ok($mech->content);
$mech->content_contains("Dancing Queen");

};

1;
