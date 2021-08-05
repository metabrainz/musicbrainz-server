package t::MusicBrainz::Server::Controller::ReleaseGroup::Details;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/details',
              'fetch release group details page');
html_ok($mech->content);
$mech->content_contains('https://musicbrainz.org/release-group/234c079d-374e-4436-9448-da92dedef3ce',
                        '..has permanent link');
$mech->content_contains('>234c079d-374e-4436-9448-da92dedef3ce</',
                        '..has mbid in plain text');

};

1;
