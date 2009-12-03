use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/work/745c079d-374e-4436-9448-da92dedef3ce/tags");
xml_ok($mech->content);
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}),
    'link to the "musical" tag');

done_testing;
