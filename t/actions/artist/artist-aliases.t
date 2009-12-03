use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test aliases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/aliases', 'get artist aliases');
xml_ok($mech->content);
$mech->content_contains('Test Alias', 'has the artist alias');

$mech->get_ok('/artist/60e5d080-c964-11de-8a39-0800200c9a66', 'get artist aliases');
xml_ok($mech->content);
$mech->content_unlike(qr/Test Alias/, 'other artist pages do not have the alias');

done_testing;
