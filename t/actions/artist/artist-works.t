use strict;
use warnings;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/works', 'get Test Artist works page');
xml_ok($mech->content);
$mech->title_like(qr/Test Artist/, 'title has artist');
$mech->title_like(qr/works/i, 'title indicates works listing');
$mech->content_contains('Test Work');
$mech->content_contains('/work/745c079d-374e-4436-9448-da92dedef3ce', 'has a link to the work');

done_testing;
