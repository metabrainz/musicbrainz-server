package t::MusicBrainz::Server::Controller::PUID::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
html_ok($mech->content);
$mech->content_contains('Dancing Queen');
$mech->content_contains('ABBA');

$mech->get('/puid/foob9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);

$mech->get('/puid/ffffffff-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);

};

1;
