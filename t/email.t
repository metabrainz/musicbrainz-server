#!/usr/bin/perl
use strict;
use warnings;
use Test::Differences;
use Test::More;
use_ok 'MusicBrainz::Server::Email';

BEGIN {
    no warnings 'redefine';
    use DBDefs;
    *DBDefs::_RUNNING_TESTS = sub { 1 };
    *DBDefs::WEB_SERVER = sub { "localhost" };
}

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Entity::Editor;

my $c = MusicBrainz::Server::Test->create_test_context();
my $email = MusicBrainz::Server::Email->new( c => $c );

my $user1 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 1', email => 'foo@example.com' );
my $user2 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 2', email => 'bar@example.com' );

my $addr = MusicBrainz::Server::Email::_user_address($user1);
is($addr, '"Editor 1" <foo@example.com>');

$email->send_message_to_editor(
    from => $user1,
    to => $user2,
    subject => 'Hey',
    message => 'Hello!'
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
my $e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 1" <Editor 1@users.musicbrainz.org>');
is($e->get_header('Reply-To'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), '"Editor 2" <bar@example.com>');
is($e->get_header('BCC'), undef);
is($e->get_header('Subject'), 'Hey');
compare_body($e->get_body, <<EOS);
MusicBrainz editor 'Editor 1' has sent you the following message:
------------------------------------------------------------------------
Hello!
------------------------------------------------------------------------
If you would like to respond, please visit
http://localhost/user/Editor\%201/contact to send editor
'Editor 1' an e-mail.
EOS

$email->send_message_to_editor(
    from => $user1,
    to => $user2,
    subject => 'Hey',
    message => 'Hello!',
    reveal_address => 1,
    send_to_self => 1,
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 1" <foo@example.com>');
is($e->get_header('To'), '"Editor 2" <bar@example.com>');
is($e->get_header('BCC'), '"Editor 1" <foo@example.com>');
is($e->get_header('Subject'), 'Hey');
compare_body($e->get_body, <<EOS);
MusicBrainz editor 'Editor 1' has sent you the following message:
------------------------------------------------------------------------
Hello!
------------------------------------------------------------------------
If you would like to respond, please reply to this message or visit
http://localhost/user/Editor\%201/contact to send editor
'Editor 1' an e-mail.
EOS

$email->send_email_verification(
    email => 'user@example.com',
    verification_link => 'http://musicbrainz.org/verify-email',
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), 'user@example.com');
is($e->get_header('Subject'), 'Please verify your email address');
compare_body($e->get_body, <<EOS);
This is the a verification email for your MusicBrainz account. Please click
on the link below to verify your email address:

http://musicbrainz.org/verify-email

If clicking the link directly does not work, you may need to manually cut
and paste the link into the location bar of your preferred web browser.

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOS

$email->send_lost_username(
    user => $user1,
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), '"Editor 1" <foo@example.com>');
is($e->get_header('Subject'), 'Lost username');
compare_body($e->get_body, <<EOS);
Hello. Someone asked to look up the MusicBrainz account associated with the
email address.

Your MusicBrainz username is: Editor 1

If you have also forgotten your password, use the username and email address
to reset your password here - http://localhost/lost-password

-- The MusicBrainz Team
EOS

$email->send_password_reset_request(
    user => $user1,
    reset_password_link => 'http://musicbrainz.org/reset-password'
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), '"Editor 1" <foo@example.com>');
is($e->get_header('Subject'), 'Password reset request');
compare_body($e->get_body, <<EOS);
Hello. Someone asked that your MusicBrainz password be reset.

If you did ask to reset the password on your MusicBrainz account, please use
this link:

http://musicbrainz.org/reset-password

If you still have problems logging in, please drop us a line - see
http://localhost/doc/Contact_Us for details.

-- The MusicBrainz Team
EOS

$email->send_first_no_vote(
    editor => $user1,
    voter => $user2,
    edit_id => 1234,
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>');
is($e->get_header('To'), '"Editor 1" <foo@example.com>');
is($e->get_header('References'), '<edit-1234@musicbrainz.org>');
is($e->get_header('Subject'), 'Someone has voted against your edit');
is($e->get_header('Reply-To'), 'MusicBrainz <support@musicbrainz.org>');
compare_body($e->get_body, <<EOS);
MusicBrainz editor 'Editor 2' has voted against your edit #1234.
------------------------------------------------------------------------
If you would like to respond to this vote, please add your note at:

    http://localhost/edit/1234

Please do not respond to this e-mail.

This e-mail is only sent for the first vote against your edit, not for each
one. If you would prefer not to receive these e-mails, please adjust your
preferences accordingly at http://localhost/account/preferences
EOS

$email->send_edit_note(
    editor => $user1,
    from_editor => $user2,
    edit_id => 1234,
    note_text => 'Please remember to use guess case!',
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 2" <Editor 2@users.musicbrainz.org>');
is($e->get_header('To'), '"Editor 1" <foo@example.com>');
is($e->get_header('Subject'), 'Note added to edit #1234');
is($e->get_header('Sender'), 'MusicBrainz Server <noreply@musicbrainz.org>');
compare_body($e->get_body, <<EOS);
Editor 'Editor 2' has added the following note to edit #1234:
------------------------------------------------------------------------
Please remember to use guess case!
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
http://localhost/edit/1234
Please do not respond to this email.

-- The MusicBrainz Team
EOS

$email->send_edit_note(
    editor => $user2,
    from_editor => $user1,
    edit_id => 9000,
    note_text => 'This edit is totally wrong!',
    own_edit => 1
);

is(scalar(@{$email->transport->deliveries}), 1);
is($email->transport->deliveries->[0]->{envelope}->{from}, 'noreply@musicbrainz.org');
$e = $email->transport->deliveries->[0]->{email};
$email->transport->clear_deliveries;
is($e->get_header('From'), '"Editor 1" <Editor 1@users.musicbrainz.org>');
is($e->get_header('To'), '"Editor 2" <bar@example.com>');
is($e->get_header('Subject'), 'Note added to your edit #9000');
is($e->get_header('Sender'), 'MusicBrainz Server <noreply@musicbrainz.org>');
compare_body($e->get_body, <<EOS);
Editor 'Editor 1' has added the following note to your edit #9000:
------------------------------------------------------------------------
This edit is totally wrong!
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
http://localhost/edit/9000
Please do not respond to this email.

-- The MusicBrainz Team
EOS

done_testing;

sub compare_body
{
    my ($got, $expected) = @_;

    $got =~ s/[\r\n]+/\n/g;
    $expected =~ s/[\r\n]+/\n/g;
    eq_or_diff($got, $expected);
}
