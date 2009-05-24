#!/usr/bin/perl
use strict;
use Test::More tests => 23;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Context->new();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce', 'fetch release group');
$mech->title_like(qr/Arrival/, 'title has release group name');
$mech->content_like(qr/Arrival/, 'content has release group name');
$mech->content_like(qr/Album/, 'has release group type');
$mech->content_like(qr/ABBA/, 'has artist credit credit');
$mech->content_like(qr{/release-group/234c079d-374e-4436-9448-da92dedef3ce}, 'link back to release group');
$mech->content_like(qr{/artist/a45c079d-374e-4436-9448-da92dedef3cf}, 'link to artist');

$mech->get_ok('/release-group/7c3218d7-75e0-4e8c-971f-f097b6c308c5', 'fetch Aerial release group');
$mech->content_like(qr/Aerial/);
$mech->content_like(qr/2xCD/, 'correct medium format');
$mech->content_like(qr/7 \+ 9 tracks/, 'correct track count');

$mech->content_like(qr{/release/f205627f-b70a-409d-adbe-66289b614e80}, 'has uk release');
$mech->content_like(qr{United Kingdom}, 'has uk release');
$mech->content_like(qr{2005-11-07}, 'has uk release');
$mech->content_like(qr{Warp Records}, 'has uk label');
$mech->content_like(qr{343 960 2}, 'has uk label');
$mech->content_like(qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'has uk label');

$mech->content_like(qr{/release/9b3d9383-3d2a-417f-bfbb-56f7c15f075b}, 'has us release');
$mech->content_like(qr{United States}, 'has us release');
$mech->content_like(qr{2005-11-08}, 'has us release');
$mech->content_like(qr{Warp Records}, 'has uk label');
$mech->content_like(qr{82796 97772 2}, 'has uk label');
$mech->content_like(qr{/label/46f0f4cd-8aab-4b33-b698-f459faf64190}, 'has uk label');
