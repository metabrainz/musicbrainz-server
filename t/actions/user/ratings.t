use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/user/ratings/view/new_editor');
$mech->content_contains('Kate Bush', "new_editor has rated Kate Bush");

$mech->get('/user/ratings/view/alice');
is ($mech->status(), 403, "alice' ratings are private");

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/user/collection/view/alice');
is ($mech->status(), 403, "alice' ratings are still private");

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'alice', password => 'secret1' } );

$mech->get('/user/ratings/view/alice');
is ($mech->status(), 200, "alice can view her own ratings");
$mech->content_contains('Alice has not rated anything', "alice has not rated anything");

done_testing;
