#!/usr/bin/perl
use strict;
use Test::More tests => 7;

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

TODO: {
    local $TODO = "Not implemented";

    $mech->get_ok('/tag/musical/artist');
    $mech->get_ok('/tag/musical/label');
    $mech->get_ok('/tag/musical/recording');
    $mech->get_ok('/tag/musical/release-group');
    $mech->get_ok('/tag/musical/work');
}
