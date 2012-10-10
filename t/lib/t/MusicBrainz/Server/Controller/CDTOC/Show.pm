package t::MusicBrainz::Server::Controller::CDTOC::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+controller_cdtoc');

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-');
html_ok($mech->content);
$mech->content_like(qr{Aerial});
$mech->content_like(qr{Kate Bush});

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI');

};

1;
