use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

TODO: {
    local $TODO = "Not implemented";

    $mech->get_ok('/url/9201840b-d810-4e0f-bb75-c791205f5b24');
}

done_testing;
