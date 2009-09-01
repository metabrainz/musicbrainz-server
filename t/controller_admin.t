#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 3;

use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/admin');
$mech->content_contains('Link Types');
$mech->content_contains('Link Attribute Types');
