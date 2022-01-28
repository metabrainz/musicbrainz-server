package t::MusicBrainz::Server::Controller::Artist::Edits;
use Test::Routine;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_artist');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/edits',
              'fetch artist edit history');

};

1;
