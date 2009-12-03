use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
xml_ok($mech->content);
$mech->content_contains('Dancing Queen');
$mech->content_contains('ABBA');

$mech->get('/puid/foob9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);

$mech->get('/puid/ffffffff-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);

done_testing;
