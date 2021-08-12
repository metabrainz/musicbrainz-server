package t::MusicBrainz::Server::Controller::Work::Ratings;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/work/745c079d-374e-4436-9448-da92dedef3ce/ratings');
html_ok($mech->content);

};

1;
