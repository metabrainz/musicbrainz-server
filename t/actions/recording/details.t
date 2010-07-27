use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/recording/54b9d183-7dab-42ba-94a3-7388a66604b8/details",
              'fetch recording details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/recording/54b9d183-7dab-42ba-94a3-7388a66604b8',
                        '..has permanent link');
$mech->content_contains('<td>54b9d183-7dab-42ba-94a3-7388a66604b8</td>',
                        '..has mbid in plain text');

done_testing;
