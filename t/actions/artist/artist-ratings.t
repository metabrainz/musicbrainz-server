use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request '/';
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test ratings
$mech->get_ok('/artist/745c079d-374e-4436-9448-da92dedef3ce/ratings', 'get artist ratings');
xml_ok($mech->content);
$mech->content_contains('new_editor');
$mech->content_contains('20 - ');
$mech->content_lacks('alice');
$mech->content_lacks('100');
$mech->content_contains('1 private rating not listed');

done_testing;
