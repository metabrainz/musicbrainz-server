use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/account/change-password');
xml_ok($mech->content);

$mech->submit_form( with_fields => {
    'changepassword.old_password' => 'wrong password',
    'changepassword.password' => 'password',
    'changepassword.confirm_password' => 'password'
} );
$mech->content_contains('The old password is incorrect');
$mech->submit_form( with_fields => {
    'changepassword.old_password' => 'password',
    'changepassword.password' => 'new_password',
    'changepassword.confirm_password' => 'new_password'
} );
$mech->content_contains('Your password has been changed');
$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'new_password' } );
is($mech->uri->path, '/user/profile/new_editor');

$mech->get_ok('/account/change-password');
xml_ok($mech->content);

# Reset the password so the other tests in action/user/*.t still run, without resetting
# the whole database.
$mech->submit_form( with_fields => {
    'changepassword.old_password' => 'new_password',
    'changepassword.password' => 'password',
    'changepassword.confirm_password' => 'password'
} );
$mech->content_contains('Your password has been changed', 'Reset password');

done_testing;
