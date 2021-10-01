package t::MusicBrainz::Server::Controller::Recording::Edits;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);
$mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/edits',
              'fetch recording edit history');

};

1;
