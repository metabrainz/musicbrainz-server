package t::MusicBrainz::Server::Controller::Label::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190", 'fetch label index');
html_ok($mech->content);
$mech->title_like(qr/Warp Records/, 'title has label name');
$mech->content_like(qr/Warp Records/, 'content has label name');
$mech->content_like(qr/Sheffield based electronica label/, 'disambiguation comments');
$mech->content_like(qr/1989-02-03/, 'has start date');
$mech->content_like(qr/2008-05-19/, 'has end date');
$mech->content_like(qr/United Kingdom/, 'has area');
$mech->content_like(qr/Production/, 'has label type');
$mech->content_like(qr/Test annotation 2/, 'has annotation');

# Check releases
$mech->content_like(qr/Arrival/, 'has release title');
$mech->content_like(qr/ABC-123/, 'has catalog of first release');
$mech->content_like(qr/ABC-123-X/, 'has catalog of second release');
$mech->content_like(qr/2009-05-08/, 'has release date');
$mech->content_like(qr{GB}, 'has country in release list');
$mech->content_like(qr{/release/f34c079d-374e-4436-9448-da92dedef3ce}, 'links to correct release');

};

1;
