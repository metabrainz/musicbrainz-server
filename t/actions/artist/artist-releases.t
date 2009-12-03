use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test /artist/gid/releases
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/releases', 'get Test Artist page');
xml_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has Test Artist');
$mech->title_like(qr/releases/i, 'title indicates releases listing');
$mech->content_contains('Test Release', 'release title');
$mech->content_contains('2009-05-08', 'release date');
$mech->content_contains('/release/f34c079d-374e-4436-9448-da92dedef3ce', 'has a link to the release');

done_testing;
