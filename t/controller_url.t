#!/usr/bin/perl
use strict;
use Test::More tests => 1;

BEGIN {
    use MusicBrainz::Server::Test;
    my $c = MusicBrainz::Server::Test->create_test_context();
    MusicBrainz::Server::Test->prepare_test_database($c);
    MusicBrainz::Server::Test->prepare_test_server();
}

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

TODO: {
    local $TODO = "Not implemented";

    $mech->get_ok('/url/9201840b-d810-4e0f-bb75-c791205f5b24');
}
