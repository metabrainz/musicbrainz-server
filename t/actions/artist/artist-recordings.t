use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test /artist/gid/recordings
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/recordings', 'get Test Artist page');
xml_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has Test Artist');
$mech->title_like(qr/recordings/i, 'title indicates recordings listing');
$mech->content_contains('Test Recording');
$mech->content_contains('2:03');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'has a link to the recording');

done_testing;
