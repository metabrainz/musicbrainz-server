use strict;
use warnings;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::More;
use Test::WWW::Mechanize::Catalyst;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/admin/linkattributetype');
xml_ok($mech->content);

$mech->content_contains('New Link Attribute Type');
$mech->content_contains('String Instruments');

$mech->get_ok('/admin/linkattributetype/create');
xml_ok($mech->content);
$mech->submit_form_ok( { with_fields => {
    'linkattrtype.parent_id' => '',
    'linkattrtype.child_order' => '0',
    'linkattrtype.name' => 'Test Attribute',
} } );
$mech->get('/admin/linkattributetype');
$mech->content_contains('Test Attribute');

$mech->get_ok('/admin/linkattributetype/edit/3');
xml_ok($mech->content);
$mech->submit_form_ok( { with_fields => {
    'linkattrtype.name' => 'Wind Instruments',
} } );
$mech->get('/admin/linkattributetype');
$mech->content_contains('Wind Instruments');
$mech->content_lacks('String Instruments');

$mech->get_ok('/admin/linkattributetype/delete/3');
xml_ok($mech->content);
$mech->submit_form_ok( { form_number => 1 } );
$mech->content_lacks('Wind Instruments');
$mech->content_lacks('String Instruments');

done_testing;
