#!/usr/bin/perl
use strict;
use Test::More tests => 23;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Test->create_test_context();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/recording/54b9d183-7dab-42ba-94a3-7388a66604b8', 'fetch recording');
$mech->title_like(qr/King of the Mountain/, 'title has recording name');
$mech->content_like(qr/King of the Mountain/, 'content has recording name');
$mech->content_like(qr/4:54/, 'has recording duration');
$mech->content_like(qr{1/7}, 'track position');
$mech->content_like(qr{United Kingdom}, 'release country');
$mech->content_like(qr{DEE250800230}, 'ISRC');
$mech->content_like(qr{2005-11-07}, 'release date 1');
$mech->content_like(qr{2005-11-08}, 'release date 2');
$mech->content_like(qr{/release/f205627f-b70a-409d-adbe-66289b614e80}, 'link to release 1');
$mech->content_like(qr{/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b}, 'link to release 2');
$mech->content_like(qr{/artist/4b585938-f271-45e2-b19a-91c634b5e396}, 'link to artist');
$mech->content_like(qr/This recording does not have an annotation/, 'has no annotation');

$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce', 'fetch dancing queen recording');
$mech->title_like(qr/Dancing Queen/);
$mech->content_contains('Test annotation 3', 'has annotation');

# Test tags
$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/tags');
$mech->content_like(qr{musical});
ok($mech->find_link(url_regex => qr{/tag/musical}), 'link to the "musical" tag');

# Test ratings
$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/ratings', 'get recording ratings');

# Test PUIDs
$mech->get_ok('/recording/123c079d-374e-4436-9448-da92dedef3ce/puids', 'get recording puids');
$mech->content_contains('puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0', 'has puid 1');
$mech->content_contains('puid/134478d1-306e-41a1-8b37-ff525e53c8be', 'has puid 2');
