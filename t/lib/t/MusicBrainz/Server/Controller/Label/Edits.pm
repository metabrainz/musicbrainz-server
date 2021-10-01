package t::MusicBrainz::Server::Controller::Label::Edits;
use Test::Routine;
use Test::More;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/edits',
              'fetch label edit history');

};

1;
