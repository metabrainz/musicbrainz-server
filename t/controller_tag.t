#!/usr/bin/perl
use strict;
use Test::More tests => 23;

BEGIN {
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Test->create_test_context();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/tag/musical');
$mech->content_like(qr{Tag .musical.});

$mech->get_ok('/tag/musical/artist');
$mech->content_like(qr{Test Artist});
$mech->get_ok('/tag/not-used/artist');
$mech->content_like(qr{No artists});

$mech->get_ok('/tag/musical/label');
$mech->content_like(qr{Warp Records});
$mech->get_ok('/tag/not-used/label');
$mech->content_like(qr{No labels});

$mech->get_ok('/tag/musical/recording');
$mech->content_like(qr{Dancing Queen.*?ABBA});
$mech->get_ok('/tag/not-used/recording');
$mech->content_like(qr{No recordings});

$mech->get_ok('/tag/musical/release-group');
$mech->content_like(qr{Arrival.*?ABBA});
$mech->get_ok('/tag/not-used/release-group');
$mech->content_like(qr{No release groups});

$mech->get_ok('/tag/musical/work');
$mech->content_like(qr{Dancing Queen.*?ABBA});
$mech->get_ok('/tag/not-used/work');
$mech->content_like(qr{No works});

$mech->get('/tag/not-found');
is($mech->status(), 404);
