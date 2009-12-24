use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/release/f205627f-b70a-409d-adbe-66289b614e80/details",
              'fetch release details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/release/f205627f-b70a-409d-adbe-66289b614e80',
                        '..has permanent link');
$mech->content_contains('<td>f205627f-b70a-409d-adbe-66289b614e80</td>',
                        '..has mbid in plain text');

done_testing;
