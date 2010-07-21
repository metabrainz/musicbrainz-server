use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
xml_ok($mech->content);
$mech->submit_form( with_fields => { username => '', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => '', password => 'password' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
is($mech->uri->path, '/user/new_editor');

done_testing;
