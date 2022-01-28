package t::MusicBrainz::Server::Controller::Artist::Details;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/details',
              'fetch artist details page');
html_ok($mech->content);
$mech->content_contains('https://musicbrainz.org/artist/745c079d-374e-4436-9448-da92dedef3ce',
                        '..has permanent link');
$mech->content_contains('>745c079d-374e-4436-9448-da92dedef3ce</',
                        '..has mbid in plain text');

};

1;
