#!/usr/bin/perl
use strict;
use warnings;

use JSON;
use Test::More;
use Test::JSON;
use Test::WWW::Mechanize::Catalyst;
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_server($c);
MusicBrainz::Server::Test->prepare_test_database($c);

my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
my $expected = encode_json ( [ {
    "comment" => undef,
    "id" => 5,
    "gid" => "5441c29d-3602-4898-b1a1-b77fa23b8e50",
    "name" => "David Bowie"
} ] );

$mech->get_ok('/ws/js/artist?q=D', 'artist autocomplete response ok');
is_valid_json($mech->content, '... and it is valid json');
is_json ($mech->content, $expected, '... and it contains the correct name and gid');

$expected = encode_json ( [ {
    "comment" => "Sheffield based electronica label",
    "id" => 2,
    "gid" => "46f0f4cd-8aab-4b33-b698-f459faf64190", 
    "name" => "Warp Records"
} ] );

$mech->get_ok('/ws/js/label?q=W', 'label autocomplete response ok');
is_valid_json($mech->content, '... and it is valid json');
is_json ($mech->content, $expected, '... and it contains the correct name and gid');

done_testing;

1;
