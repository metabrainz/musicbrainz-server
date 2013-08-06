package t::MusicBrainz::Server::Controller::ISRC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_isrc');

$mech->get_ok('/isrc/DEE250800230');
html_ok($mech->content);
$mech->content_contains('King of the Mountain');
$mech->content_contains('Kate Bush');
$mech->content_contains('DEE250800230');

$mech->get('/isrc/DEE250812345');
is($mech->status(), 404);

$mech->get('/isrc/xxx');
is($mech->status(), 404);

};

1;
