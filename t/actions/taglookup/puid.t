use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/taglookup?puid=b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 'lookup puid ... ');
xml_ok($mech->content);
$mech->content_contains('ABBA', 'has correct artist result');
$mech->content_contains('Arrival', 'has correct release result');
$mech->content_contains('Make a donation now', 'has nag screen');

done_testing;
