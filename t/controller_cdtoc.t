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

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-');
xml_ok($mech->content);
$mech->content_like(qr{Aerial});
$mech->content_like(qr{Kate Bush});

done_testing;
