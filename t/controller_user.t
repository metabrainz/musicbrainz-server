#!/usr/bin/perl
use strict;
use warnings;
use Test::More;

use MusicBrainz::Server::Test qw( xml_ok );
use MusicBrainz::Server::Email;
my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_database($c, '+editor');
MusicBrainz::Server::Test->prepare_test_server();

use Test::WWW::Mechanize::Catalyst;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

# Test login
$mech->get_ok('/login');
xml_ok($mech->content);
$mech->submit_form( with_fields => { username => '', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => '' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => '', password => 'password' } );
$mech->content_contains('Incorrect username or password');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
is($mech->uri->path, '/user/profile/new_editor');

# Test logout
$mech->get('/');
$mech->get_ok('/logout');
xml_ok($mech->content);
is($mech->uri->path, '/', 'Redirected to the previous URL');
$mech->get_ok('/user/profile/new_editor');
xml_ok($mech->content);
$mech->content_contains('Please log in using the form below');
$mech->get('/login');
$mech->get_ok('/logout');
xml_ok($mech->content);
is($mech->uri->path, '/login', 'Redirected to the previous URL');
$mech->content_contains('Please log in using the form below');

$mech->get_ok('/lost-username');
xml_ok($mech->content);
$mech->submit_form( with_fields => { 'lostusername.email' => 'test@email.com' } );
$mech->content_contains("We've sent you informations about your MusicBrainz account.");

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Lost username');
like($email->get_body, qr{Your MusicBrainz username is: new_editor});

$mech->get_ok('/lost-password');
xml_ok($mech->content);
$mech->submit_form( with_fields => {
    'lostpassword.username' => 'new_editor',
    'lostpassword.email' => 'test@email.com'
} );
$mech->content_contains("We've sent you instructions on how to reset your password.");

$email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Password reset request');
like($email->get_body, qr{http://localhost/reset-password.*});

$email->get_body =~ qr{http://localhost(/reset-password.*)};
my $reset_password_path = $1;
$mech->get_ok($reset_password_path);
xml_ok($mech->content);
$mech->content_contains("Set a new password for your Musicbrainz account.");
$mech->submit_form( with_fields => {
    'resetpassword.password' => 'new_password',
    'resetpassword.confirm_password' => 'new_password_2'
} );
$mech->content_contains("The password confirmation does not match the password");
$mech->submit_form( with_fields => {
    'resetpassword.password' => 'new_password',
    'resetpassword.confirm_password' => 'new_password'
} );

$mech->content_contains("Your password has been reset.");

$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'new_password' } );

$mech->get_ok('/account/edit');
xml_ok($mech->content);
$mech->submit_form( with_fields => {
    'profile.website' => 'foo',
    'profile.biography' => 'hello world!',
} );
$mech->content_contains('Invalid URL format');
$mech->submit_form( with_fields => {
    'profile.website' => 'http://example.com/~new_editor/',
    'profile.biography' => 'hello world!',
    'profile.email' => 'new_email@example.com',
} );
$mech->content_contains('Your profile has been updated');
$mech->content_contains('We have sent you a verification email');

$email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('To'), 'new_email@example.com');
is($email->get_header('Subject'), 'Please verify your email address');
like($email->get_body, qr{http://localhost/verify-email.*});

$email->get_body =~ qr{http://localhost(/verify-email.*)};
my $verify_email_path = $1;
$mech->get_ok($verify_email_path);
$mech->content_contains("Thank you, your email address has now been verified!");

$mech->get('/user/profile/new_editor');
$mech->content_contains('http://example.com/~new_editor/');
$mech->content_contains('hello world!');
$mech->content_contains('new_email@example.com');

$mech->get_ok('/account/change-password');
xml_ok($mech->content);
$mech->submit_form( with_fields => {
    'changepassword.old_password' => 'wrong password',
    'changepassword.password' => 'password',
    'changepassword.confirm_password' => 'password'
} );
$mech->content_contains('The old password is incorrect');
$mech->submit_form( with_fields => {
    'changepassword.old_password' => 'new_password',
    'changepassword.password' => 'password',
    'changepassword.confirm_password' => 'password'
} );
$mech->content_contains('Your password has been changed');
$mech->get('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );
is($mech->uri->path, '/user/profile/new_editor');

done_testing;
