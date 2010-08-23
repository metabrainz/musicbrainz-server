use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/user/new_editor');
$mech->content_contains('Collection', "Collection tab appears on profile of user");

$mech->get('/user/alice');
$mech->content_lacks('Collection', "Collection tab does not appear when collection marked private");

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/alice');
$mech->content_contains('Collection', "Collection tab appears on own profile, even if marked private");

done_testing;
