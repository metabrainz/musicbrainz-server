use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/user/collection/view/new_editor');
$mech->content_contains('No releases found in collection', "new_editor has no releases in his collection");

$mech->get('/user/collection/view/alice');
is ($mech->status(), 403, "alice' collection is private");

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/user/collection/view/alice');
is ($mech->status(), 403, "alice' collection is still private");

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/collection/view/alice');
is ($mech->status(), 200, "alice can view her own collection");
$mech->content_contains('Kate Bush', "alice has a release by Kate Bush in her collection");

done_testing;
