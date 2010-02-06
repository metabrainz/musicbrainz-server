use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Email;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

MusicBrainz::Server::Test->prepare_test_server;

my $c = MusicBrainz::Server::Test->create_test_context;
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/lost-password');
xml_ok($mech->content);
$mech->submit_form( with_fields => {
    'lostpassword.username' => 'new_editor',
    'lostpassword.email' => 'test@email.com'
} );
$mech->content_contains("We've sent you instructions on how to reset your password.");

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->deliveries->[-1]->{email};
is($email->get_header('Subject'), 'Password reset request');
like($email->get_body, qr{http://localhost/reset-password.*});

$email->get_body =~ qr{http://localhost(/reset-password.*)};
my $reset_password_path = $1;
$mech->get_ok($reset_password_path);
xml_ok($mech->content);
$mech->content_contains("Set a new password for your MusicBrainz account.");
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

$mech->get_ok('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'new_password' } );

done_testing;
