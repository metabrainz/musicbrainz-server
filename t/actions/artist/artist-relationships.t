use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test relationships
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/relationships', 'get artist relationships');
xml_ok($mech->content);
$mech->content_contains('performed guitar');
$mech->content_contains('/recording/123c079d-374e-4436-9448-da92dedef3ce');

done_testing;
