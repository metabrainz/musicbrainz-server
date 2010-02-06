use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get('/');
$mech->get_ok('/logout');
xml_ok($mech->content);
is($mech->uri->path, '/', 'Redirected to the previous URL');
$mech->get_ok('/artist/create');
xml_ok($mech->content);
$mech->content_contains('Please log in using the form below');
$mech->get('/login');
$mech->get_ok('/logout');
xml_ok($mech->content);
is($mech->uri->path, '/login', 'Redirected to the previous URL');
$mech->content_contains('Please log in using the form below');

done_testing;
