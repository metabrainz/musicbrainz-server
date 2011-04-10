package t::MusicBrainz::Server::Controller::URL::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+url');

$mech->get_ok('/url/9201840b-d810-4e0f-bb75-c791205f5b24');

};

1;
