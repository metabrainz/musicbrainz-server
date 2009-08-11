#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 15;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok("/browse/artist");
$mech->get_ok("/browse/label");
$mech->get_ok("/browse/release");
$mech->get_ok("/browse/release-group");
$mech->get_ok("/browse/work");

$mech->get_ok("/browse/artist?index=q");
$mech->content_contains("Queen");

$mech->get_ok("/browse/label?index=w");
$mech->content_contains("Warp");

$mech->get_ok("/browse/release?index=a");
$mech->content_contains("Aerial");

$mech->get_ok("/browse/release-group?index=a");
$mech->content_contains("Aerial");

$mech->get_ok("/browse/work?index=d");
$mech->content_contains("Dancing Queen");
