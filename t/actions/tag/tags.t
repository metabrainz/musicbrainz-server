use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/tag/musical');
xml_ok($mech->content);
$mech->content_like(qr{Tag .musical.});

$mech->get_ok('/tag/musical/artist');
xml_ok($mech->content);
$mech->content_like(qr{Test Artist});
$mech->get_ok('/tag/not-used/artist');
xml_ok($mech->content);
$mech->content_like(qr{No artists});

$mech->get_ok('/tag/musical/label');
xml_ok($mech->content);
$mech->content_like(qr{Warp Records});
$mech->get_ok('/tag/not-used/label');
xml_ok($mech->content);
$mech->content_like(qr{No labels});

$mech->get_ok('/tag/musical/recording');
xml_ok($mech->content);
$mech->content_like(qr{Dancing Queen.*?ABBA});
$mech->get_ok('/tag/not-used/recording');
xml_ok($mech->content);
$mech->content_like(qr{No recordings});

$mech->get_ok('/tag/musical/release-group');
xml_ok($mech->content);
$mech->content_like(qr{Arrival.*?ABBA});
$mech->get_ok('/tag/not-used/release-group');
xml_ok($mech->content);
$mech->content_like(qr{No release groups});

$mech->get_ok('/tag/musical/work');
xml_ok($mech->content);
$mech->content_like(qr{Dancing Queen.*?ABBA});
$mech->get_ok('/tag/not-used/work');
xml_ok($mech->content);
$mech->content_like(qr{No works});

$mech->get('/tag/not-found');
xml_ok($mech->content);
is($mech->status(), 404);

done_testing;

