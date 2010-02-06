use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/details",
              'fetch work details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/work/745c079d-374e-4436-9448-da92dedef3ce',
                        '..has permanent link');
$mech->content_contains('<td>745c079d-374e-4436-9448-da92dedef3ce</td>',
                        '..has mbid in plain text');

done_testing;
