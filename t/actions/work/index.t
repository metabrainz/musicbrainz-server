use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce");
xml_ok($mech->content);
$mech->content_like(qr/Dancing Queen/, 'work title');
$mech->content_like(qr/ABBA/, 'artist credit');
$mech->content_like(qr/Composition/, 'work type');
$mech->content_like(qr{/work/745c079d-374e-4436-9448-da92dedef3ce}, 'link back to work');
$mech->content_like(qr{/artist/a45c079d-374e-4436-9448-da92dedef3cf}, 'link to ABBA');
$mech->content_like(qr/T-000.000.001-0/, 'iswc');
$mech->content_like(qr{Test annotation 6}, 'annotation');

# Missing
$mech->get('/work/dead079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

# Invalid UUID
$mech->get('/work/xxxx079d-374e-4436-9448-da92dedef3ce');
is($mech->status(), 404);

done_testing;
