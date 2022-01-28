package t::MusicBrainz::Server::Controller::Artist::Releases;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

# Test /artist/gid/releases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/releases', 'get Test Artist page');
html_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has Test Artist');
$mech->title_like(qr/releases/i, 'title indicates releases listing');
$mech->content_contains('Test Release', 'release title');
$mech->content_contains('2009-05-08', 'release date');
$mech->content_contains('/release/f34c079d-374e-4436-9448-da92dedef3ce', 'has a link to the release');

};

1;
