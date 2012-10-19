package t::MusicBrainz::Server::Controller::CDStub::Show;
use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

$mech->get_ok("/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs-", 'fetch cdstub page');
html_ok($mech->content);
$mech->title_like(qr/Test Stub/, 'title has artist name');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/, 'content has disc id');
$mech->content_like(qr/Track title 1/, 'content has first track');
$mech->content_like(qr/Track title 2/, 'content has first track');
$mech->content_like(qr/837101029192/, 'content has barcode');
$mech->content_like(qr/this is a comment/, 'content has comment');

$mech->get_ok("/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs", 'fetch cdstub page, sans dash');

};

1;
