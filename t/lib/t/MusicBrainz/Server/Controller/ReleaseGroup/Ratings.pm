package t::MusicBrainz::Server::Controller::ReleaseGroup::Ratings;
use Test::Routine;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5/ratings', 'get rg ratings');
html_ok($mech->content);

};

1;
