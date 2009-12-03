use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/browse/artist");
xml_ok($mech->content);
$mech->get_ok("/browse/label");
xml_ok($mech->content);
$mech->get_ok("/browse/release");
xml_ok($mech->content);
$mech->get_ok("/browse/release-group");
xml_ok($mech->content);
$mech->get_ok("/browse/work");
xml_ok($mech->content);

$mech->get_ok("/browse/artist?index=q");
xml_ok($mech->content);
$mech->content_contains("Queen");

$mech->get_ok("/browse/label?index=w");
xml_ok($mech->content);
$mech->content_contains("Warp");

$mech->get_ok("/browse/release?index=a");
xml_ok($mech->content);
$mech->content_contains("Aerial");

$mech->get_ok("/browse/release-group?index=a");
xml_ok($mech->content);
$mech->content_contains("Aerial");

$mech->get_ok("/browse/work?index=d");
xml_ok($mech->content);
$mech->content_contains("Dancing Queen");

done_testing;
