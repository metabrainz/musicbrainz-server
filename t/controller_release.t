#!/usr/bin/perl
use strict;
use Test::More;

BEGIN {
    use MusicBrainz::Server::Test qw( xml_ok );
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80', 'fetch release');
xml_ok($mech->content);
$mech->title_like(qr/Aerial/, 'title has release name');
$mech->content_like(qr/Aerial/, 'content has release name');
$mech->content_like(qr/Kate Bush/, 'release artist credit');
$mech->content_like(qr/Test Artist/, 'artist credit on the last track');

$mech->get_ok('/release/f205627f-b70a-409d-adbe-66289b614e80/discids');
xml_ok($mech->content);
$mech->content_like(qr{tLGBAiCflG8ZI6lFcOt87vXjEcI-});

$mech->get_ok('/release/lookup/?toc=1+10+323860+182+36697+68365+94047+125922+180342+209172+245422+275887+300862');

done_testing;
