use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

$mech->get_ok("/cdstub/YfSgiOEayqN77Irs.VNV.UNJ0Zs-", 'fetch cdstub page');
xml_ok($mech->content);
$mech->title_like(qr/Test Stub/, 'title has artist name');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/, 'content has disc id');
$mech->content_like(qr/Track title 1/, 'content has first track');
$mech->content_like(qr/Track title 2/, 'content has first track');
$mech->content_like(qr/837101029192/, 'content has barcode');
$mech->content_like(qr/this is a comment/, 'content has comment');

done_testing;

