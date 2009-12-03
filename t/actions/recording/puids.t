use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/puids', 'get recording puids');
xml_ok($mech->content);
$mech->content_contains('puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 'has puid 1');
$mech->content_contains('puid/134478d1-306e-41a1-8b37-ff525e53c8be', 'has puid 2');

done_testing;
