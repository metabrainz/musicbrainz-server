package t::MusicBrainz::Server::Controller::Work::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c);

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce");
html_ok($mech->content);
$mech->content_like(qr/Dancing Queen/, 'work title');
$mech->content_like(qr/Composition/, 'work type');
$mech->content_like(qr{/work/745c079d-374e-4436-9448-da92dedef3ce}, 'link back to work');
$mech->content_like(qr/T-000.000.001-0/, 'iswc');
$mech->content_like(qr{Test annotation 6}, 'annotation');

# Missing
$mech->get('/work/dead079d-374e-4436-9448-da92dedef3ce', 'work not found');
is($mech->status(), 404);

# Invalid UUID
$mech->get('/work/xxxx079d-374e-4436-9448-da92dedef3ce', 'bad request');
is($mech->status(), 400);

};

1;
