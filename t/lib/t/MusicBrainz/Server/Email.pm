package t::MusicBrainz::Server::Email;
use strict;
use warnings;

use Test::Routine;
use Test::LongString;
use Test::More;

use MusicBrainz::Server::Test;
use MusicBrainz::Server::Email;
use DBDefs;
use MusicBrainz::Server::Constants qw(
    $EDITOR_MODBOT
    $MINIMUM_RESPONSE_PERIOD
);

with 't::Context';

sub compare_body
{
    my ($got, $expected, $msg) = @_;

    $got =~ s/[\r\n]+/\n/g;
    $expected =~ s/[\r\n]+/\n/g;
    is_string($got, $expected, $msg ? $msg : 'Body is correct');
}

test all => sub {

    my $test = shift;

    my $email = MusicBrainz::Server::Email->new( c => $test->c );

    my $user1 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 1', email => 'foo@example.com', id => 4444 );
    my $user2 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 2', email => 'bar@example.com', id => 8888 );

    my $addr = MusicBrainz::Server::Email::_user_address($user1);
    is($addr, '"Editor 1" <foo@example.com>', 'User address is foo@example.com');

    my $server = 'https://' . DBDefs->WEB_SERVER_USED_IN_EMAIL;

    subtest 'send_message_to_editor & send_to_self' => sub {

    $email->send_message_to_editor(
        from => $user1,
        to => $user2,
        subject => 'Hey',
        message => 'Hello!',
        reveal_address => 1,
        send_to_self => 1,
        );

    is($email->transport->delivery_count, 2);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', "Envelope from is noreply@...");
    my $e = $delivery->{email};
    is($e->get_header('From'), '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
    is($e->get_header('Reply-To'), '"Editor 1" <foo@example.com>', 'Reply-To is Editor 1, foo@example.com');
    is($e->get_header('To'), '"Editor 2" <bar@example.com>', 'To is Editor 2, bar@example.com');
    is($e->get_header('BCC'), undef, 'BCC is undefined');
    is($e->get_header('Subject'), 'Hey', 'Subject is Hey');
    like($e->get_header('Message-Id'), qr{<correspondence-4444-8888-\d+@.*>}, 'Message-Id has right format');
    is($e->get_header('References'), sprintf('<correspondence-%s-%s@%s>', $user1->id, $user2->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References correct correspondence');
    compare_body($e->object->body_str,
                 "MusicBrainz user 'Editor 1' has sent you the following message:\n".
                 "------------------------------------------------------------------------\n".
                 "Hello!\n".
                 "------------------------------------------------------------------------\n".
                 "If you would like to respond, please reply to this message or visit\n".
                 "$server/user/Editor\%201/contact to send 'Editor 1' an email.\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

    $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org');
    $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
    is($e->get_header('Reply-To'), '"Editor 1" <foo@example.com>', 'Reply-To is Editor 1, foo@example.com');
    is($e->get_header('To'), '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
    is($e->get_header('BCC'), undef, 'BCC is undefined');
    is($e->get_header('Subject'), 'Hey', 'Subject is Hey');
    compare_body($e->object->body_str,
                 "This is a copy of the message you sent to MusicBrainz editor 'Editor 2':\n".
                 "------------------------------------------------------------------------\n".
                 "Hello!\n".
                 "------------------------------------------------------------------------\n".
                 "Please do not respond to this e-mail.\n");

    };

    subtest 'send_email_verification' => sub {

    $email->send_email_verification(
        email => 'user@example.com',
        verification_link => "$server/verify-email",
        ip => '127.0.0.1',
        editor => $user1,
    );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', "Envelope from is noreply@...");
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'From is noreply@...');
    is($e->get_header('To'), 'user@example.com', 'To is user@example.com');
    is($e->get_header('Subject'), 'Please verify your email address', 'Subject is Please verify your email address');
    like($e->get_header('Message-Id'), qr{<verify-email-\d+@.*>}, 'Message-Id has right format');
    compare_body($e->object->body_str,
                 "Hello Editor 1,\n".
                 "\n".
                 "This is a verification email for your MusicBrainz account. Please click\n".
                 "on the link below to verify your email address:\n".
                 "\n".
                 "$server/verify-email\n".
                 "\n".
                 "If clicking the link above doesn't work, please copy and paste the URL in a\n".
                 "new browser window instead.\n".
                 "This email was triggered by a request from the IP address [127.0.0.1].\n".
                 "\n".
                 "Thanks for using MusicBrainz!\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

    };

    subtest 'send_lost_username' => sub {

    $email->send_lost_username(
        user => $user1,
        );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', 'Envelope from is noreply@...');
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'From is noreply@...');
    is($e->get_header('To'), '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
    is($e->get_header('Subject'), 'Lost username', 'Subject is Lost username');
    like($e->get_header('Message-Id'), qr{<lost-username-\d+@.*>}, 'Message-Id has right format');
    compare_body($e->object->body_str,
                 "Someone, probably you, asked to look up the username of the\n".
                 "MusicBrainz account associated with this email address.\n".
                 "\n".
                 "Your MusicBrainz username is: Editor 1\n".
                 "\n".
                 "If you have also forgotten your password, use this username and your email address\n".
                 "to reset your password here - $server/lost-password\n".
                 "\n".
                 "If you didn't initiate this request and feel that you've received this email in\n".
                 "error, don't worry, you don't need to take any further action and can safely\n".
                 "disregard this email.\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

    };

    subtest 'send_password_reset_request' => sub {

    $email->send_password_reset_request(
        user => $user1,
        reset_password_link => "$server/reset-password",
        );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', 'Envelope from is noreply@...');
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'From is noreply@...');
    is($e->get_header('To'), '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
    is($e->get_header('Subject'), 'Password reset request', 'Subject is Password reset request');
    like($e->get_header('Message-Id'), qr{<password-reset-\d+@.*>}, 'Message-Id has right format');
    compare_body($e->object->body_str,
                 "Someone, probably you, asked that your MusicBrainz password be reset.\n".
                 "\n".
                 "To reset your password, click the link below:\n".
                 "\n".
                 "$server/reset-password\n".
                 "\n".
                 "If clicking the link above doesn't work, please copy and paste the URL in a\n".
                 "new browser window instead.\n".
                 "\n".
                 "If you didn't initiate this request and feel that you've received this email in\n".
                 "error, don't worry, you don't need to take any further action and can safely\n".
                 "disregard this email.\n".
                 "\n".
                 "If you still have problems logging in, please drop us a line - see\n".
                 "https://metabrainz.org/contact for details.\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

    };

    subtest 'send_first_no_vote' => sub {

    $email->send_first_no_vote(
        editor => $user1,
        voter => $user2,
        edit_id => 1234,
        );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', 'Envelope from is noreply@...');
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'From is noreply@...');
    is($e->get_header('To'), '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
    is($e->get_header('Reply-To'), 'MusicBrainz <support@musicbrainz.org>', 'Reply-To is support@...');
    is($e->get_header('References'), sprintf('<edit-1234@%s>', DBDefs->WEB_SERVER_USED_IN_EMAIL) , 'References edit-1234');
    like($e->get_header('Message-Id'), qr{<edit-1234-8888-no-vote-\d+@.*>} , 'Message ID has right format');
    is($e->get_header('Subject'), 'Someone has voted against your edit #1234', 'Subject is Someone has voted against...');
    my $close_time = DateTime->now()->add_duration($MINIMUM_RESPONSE_PERIOD)->truncate( to => 'hour' )->add( hours => 1 );
    $close_time = $close_time->strftime('%F %H:%M %Z');

    my $body = <<"EOS";
'Editor 2' has voted against your edit #1234.
-------------------------------------------------------------------------
To respond, please add your note at:

    $server/edit/1234

Please do not respond to this email.

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

Please note that this email will not be sent for every vote against an edit.

You can disable this notification by changing your preferences at
$server/account/preferences.

To ensure time for you and other editors to respond, the soonest this edit will
be rejected, if applicable, is $close_time, 72 hours from the time of
this email.

-- The MusicBrainz Team
EOS
    compare_body($e->object->body_str, $body);
    };

    subtest 'send_edit_note' => sub {

    $email->send_edit_note(
        editor => $user1,
        from_editor => $user2,
        edit_id => 1234,
        note_text => 'Please remember to use guess case!',
        );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', 'Envelope from is noreply@...');
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), '"Editor 2" <noreply@musicbrainz.org>', 'Header from is "Editor 2" <noreply@musicbrainz.org>');
    is($e->get_header('To'), '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
    is($e->get_header('Subject'), 'Note added to edit #1234', 'Subject is Note added to edit #1234');
    is($e->get_header('References'), sprintf('<edit-1234@%s>', DBDefs->WEB_SERVER_USED_IN_EMAIL) , 'References edit-1234');
    like($e->get_header('Message-Id'), qr{<edit-1234-8888-edit-note-\d+@.*>} , 'Message ID has right format');
    is($e->get_header('Sender'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'Sender is noreply@...');
    compare_body($e->object->body_str,
                 "'Editor 2' has added the following note to edit #1234:\n".
                 "------------------------------------------------------------------------\n".
                 "Please remember to use guess case!\n".
                 "------------------------------------------------------------------------\n".
                 "If you would like to reply to this note, please add your note at:\n".
                 "$server/edit/1234\n".
                 "Please do not respond to this email.\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

    };

    subtest 'localized send_edit_note' => sub {
        $email->send_edit_note(
            edit_id => 1234,
            editor => $user1,
            from_editor => MusicBrainz::Server::Entity::Editor->new(
                email => 'support@musicbrainz.org',
                id => $EDITOR_MODBOT,
                name => 'ModBot',
            ),
            note_text => 'localize:{"message":"Hello {name}","args":{"name":"World"}}',
        );

        my $delivery = $email->transport->shift_deliveries;
        my $e = $delivery->{email};
        $email->transport->clear_deliveries;

        compare_body(
            $e->object->body_str,
            "'ModBot' has added the following note to edit #1234:\n" .
            "------------------------------------------------------------------------\n" .
            "Hello World\n" .
            "------------------------------------------------------------------------\n" .
            "If you would like to reply to this note, please add your note at:\n" .
            "$server/edit/1234\n" .
            "Please do not respond to this email.\n\n" .
            "-- The MusicBrainz Team\n",
        );
    };

    $email->send_edit_note(
        editor => $user2,
        from_editor => $user1,
        edit_id => 9000,
        note_text => 'This edit is totally wrong!',
        own_edit => 1,
        );

    is($email->transport->delivery_count, 1);
    my $delivery = $email->transport->shift_deliveries;
    is($delivery->{envelope}->{from}, 'noreply@musicbrainz.org', 'Envelope from is noreply@...');
    my $e = $delivery->{email};
    $email->transport->clear_deliveries;
    is($e->get_header('From'), '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
    is($e->get_header('To'), '"Editor 2" <bar@example.com>', 'To is Editor 2, bar@example.com');
    is($e->get_header('Subject'), 'Note added to your edit #9000', 'Subject is Note added to your edit #9000');
    like($e->get_header('Message-Id'), qr{<edit-9000-4444-edit-note-\d+@.*>} , 'Message ID has right format');
    is($e->get_header('Sender'), 'MusicBrainz Server <noreply@musicbrainz.org>', 'Sender is noreply@...');
    compare_body($e->object->body_str,
                 "'Editor 1' has added the following note to your edit #9000:\n".
                 "------------------------------------------------------------------------\n".
                 "This edit is totally wrong!\n".
                 "------------------------------------------------------------------------\n".
                 "If you would like to reply to this note, please add your note at:\n".
                 "$server/edit/9000\n".
                 "Please do not respond to this email.\n".
                 "\n".
                 "-- The MusicBrainz Team\n");

};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;
