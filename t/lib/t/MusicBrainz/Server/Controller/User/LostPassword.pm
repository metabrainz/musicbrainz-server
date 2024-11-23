package t::MusicBrainz::Server::Controller::User::LostPassword;
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

$mech->get_ok('/lost-password');
html_ok($mech->content);
$mech->submit_form( with_fields => {
    'lostpassword.username' => 'new_editor',
    'lostpassword.email' => 'test@email.com',
} );
$mech->content_contains('We&#x27;ve sent you instructions on how to reset your password.');

my $email_transport = MusicBrainz::Server::Email->get_test_transport;
my $email = $email_transport->shift_deliveries->{email};
is($email->get_header('Subject'), 'Password reset request');

my $email_body = $email->object->body_str;
like($email_body, qr{http://localhost/reset-password.*});

$email_body =~ qr{http://localhost(/reset-password.*)};
my $reset_password_path = $1;
$mech->get_ok($reset_password_path);
html_ok($mech->content);
$mech->content_contains('Set a new password for your MusicBrainz account.');
$mech->submit_form( with_fields => {
    'resetpassword.password' => 'new_password',
    'resetpassword.confirm_password' => 'new_password_2',
} );
$mech->content_contains('The password confirmation does not match the password');
$mech->submit_form( with_fields => {
    'resetpassword.password' => 'new_password',
    'resetpassword.confirm_password' => 'new_password',
} );

$mech->content_contains('Your password has been reset.');

$mech->get_ok('/logout');
$mech->get('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'new_password' } );

};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
