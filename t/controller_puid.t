#!/usr/bin/perl
use strict;
use Test::More tests => 5;

BEGIN {
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Test->create_test_context();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
$mech->content_contains('Dancing Queen');
$mech->content_contains('ABBA');

$mech->get('/puid/foob9c8f51f-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);

$mech->get('/puid/ffffffff-cc9a-48fa-a415-4c91fcca80f0');
is($mech->status(), 404);
