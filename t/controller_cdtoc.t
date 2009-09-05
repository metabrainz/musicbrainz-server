#!/usr/bin/perl
use strict;
use Test::More tests => 3;

BEGIN {
    use MusicBrainz::Server::Context;
    use MusicBrainz::Server::Test;
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c);
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/cdtoc/tLGBAiCflG8ZI6lFcOt87vXjEcI-');
$mech->content_like(qr{Aerial});
$mech->content_like(qr{Kate Bush});
