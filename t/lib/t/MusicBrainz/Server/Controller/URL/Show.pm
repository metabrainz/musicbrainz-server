package t::MusicBrainz::Server::Controller::URL::Show;
use Test::Routine;
use utf8;

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+url');

$mech->get_ok('/url/25d6b63a-12dc-41c9-858a-2f42ae610a7d');
$mech->content_contains('http://zh-yue.wikipedia.org/wiki/王菲');
$mech->content_contains('zh-yue: 王菲');

};

1;
