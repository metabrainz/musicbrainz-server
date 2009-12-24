use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/label/46f0f4cd-8aab-4b33-b698-f459faf64190/details",
              'fetch label details page');
xml_ok($mech->content);
$mech->content_contains('http://musicbrainz.org/label/46f0f4cd-8aab-4b33-b698-f459faf64190.html',
                        '..has permanent link');
$mech->content_contains('<td>46f0f4cd-8aab-4b33-b698-f459faf64190</td>',
                        '..has mbid in plain text');

done_testing;
