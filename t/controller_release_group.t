#!/usr/bin/perl
use strict;
use Test::More tests => 7;

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