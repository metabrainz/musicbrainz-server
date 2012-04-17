package t::MusicBrainz::Server::Controller::Label::Aliases;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok('/label/46f0f4cd-8aab-4b33-b698-f459faf64190/aliases', 'get label aliases');
html_ok($mech->content);
$mech->content_contains('Test Label Alias', 'has the label alias');
$mech->content_contains('Search hint', 'has the label alias type');

};

1;
