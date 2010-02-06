use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/search?query=Love&type=artist', 'perform artist search');
#This currently fails, but its seems to for other tests too
xml_ok($mech->content);
$mech->content_contains('784 results', 'has result count');
$mech->content_contains('L.O.V.E.', 'has correct search result');
$mech->content_contains('Love, Laura', 'has artist sortname');
$mech->content_contains('/artist/406bca37-056f-405e-a974-624864c9f641', 'has link to artist');

done_testing;
