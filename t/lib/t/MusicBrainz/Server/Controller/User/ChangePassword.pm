package t::MusicBrainz::Server::Controller::User::ChangePassword;
use strict;
use warnings;

use Test::Routine;
use Test::More;
use MusicBrainz::Server::Test qw( html_ok );

with 't::Mechanize', 't::Context';

test all => sub {

my $test = shift;
my $mech = $test->mech;
my $c    = $test->c;

MusicBrainz::Server::Test->prepare_test_database($c, '+editor');

$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/account/change-password');
html_ok($mech->content);

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
is($mech->uri->path, '/user/new_editor');

$mech->get_ok('/account/change-password');
html_ok($mech->content);

};

1;
