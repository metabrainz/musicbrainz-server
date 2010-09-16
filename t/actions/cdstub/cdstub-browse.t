use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

MusicBrainz::Server::Test->prepare_raw_test_database($c, '+cdstub_raw');

$mech->get_ok("/cdstub/browse", 'fetch top cdstubs page');
xml_ok($mech->content);
$mech->title_like(qr/Top CD Stubs/, 'title is correct');
$mech->content_like(qr/Test Artist/, 'content has artist name');
$mech->content_like(qr/YfSgiOEayqN77Irs.VNV.UNJ0Zs-/, 'content has disc id');
$mech->content_like(qr/Added 11 years ago/, 'content has added timestamp');
$mech->content_like(qr/last modified 10 years ago/, 'content has last modified timestamp');

done_testing;

