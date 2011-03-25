package t::MusicBrainz::Server::Controller::Release::DiscIDs;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/discids');
html_ok($mech->content);
$mech->content_like(qr{tLGBAiCflG8ZI6lFcOt87vXjEcI-});

$mech->get_ok('/release/lookup/?toc=1+10+323860+182+36697+68365+94047+125922+180342+209172+245422+275887+300862');

};

1;
