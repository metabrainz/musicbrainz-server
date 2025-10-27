package t::MusicBrainz::Server::Email;
use strict;
use warnings;

use Test::Routine;
use Test::LongString;
use Test::More;

use HTTP::Status qw( :constants );
use MusicBrainz::Server::Test;
use MusicBrainz::Server::Email;
use DBDefs;
use MusicBrainz::Server::Constants qw(
    $EDITOR_MODBOT
    $MINIMUM_RESPONSE_PERIOD
);
use Types::Serialiser;

with 't::Context', 't::Email';

sub compare_body
{
    my ($got, $expected, $msg) = @_;

    $got =~ s/[\r\n]+/\n/g;
    $expected =~ s/[\r\n]+/\n/g;
    is_string($got, $expected, $msg ? $msg : 'Body is correct');
}

test all => sub {
    my $test = shift;

    $test->skip_unless_mailpit_configured;

    my $email = MusicBrainz::Server::Email->new( c => $test->c );

    my $user1 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 1', email => 'foo@example.com', id => 4444 );
    my $user2 = MusicBrainz::Server::Entity::Editor->new( name => 'Editor 2', email => 'bar@example.com', id => 8888 );

    my $addr = MusicBrainz::Server::Email::_user_address($user1);
    is($addr, '"Editor 1" <foo@example.com>', 'User address is foo@example.com');

    my $server = 'https://' . DBDefs->WEB_SERVER_USED_IN_EMAIL;

    subtest 'send_message_to_editor' => sub {
        $test->skip_unless_mb_mail_service_configured;

        $email->send_message_to_editor(
            from => $user1,
            to => $user2,
            subject => 'Hey',
            message => 'Hello!',
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
        is($email->{headers}{'Reply-To'}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'Reply-To is noreply@');
        is($email->{headers}{To}, '"Editor 2" <bar@example.com>', 'To is Editor 2, bar@example.com');
        is($email->{headers}{BCC}, undef, 'BCC is undefined');
        is($email->{headers}{Subject}, 'MusicBrainz message from Editor 1: Hey', 'Subject is "MusicBrainz message from Editor 1: Hey"');
        like($email->{headers}{'Message-ID'}, qr{<correspondence-4444-8888-[0-9a-z-]+@.*>}, 'Message-ID has right format');
        is($email->{headers}{References}, sprintf('<correspondence-%s-%s@%s>', $user1->id, $user2->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References correct correspondence');
        compare_body($email->{body}, <<~"EOS");
            [MusicBrainz]
            Hello Editor 2,

            MusicBrainz user 'Editor 1' has sent you the following message:
            **Editor 1: Hey**

            Hello!
            [To reply, click here to send Editor 1 an email.][1]

            *\x{2014} The MetaBrainz community*
            Do not reply to this message. For assistance please contact the team or the
            community.

            [1]: https://localhost/user/Editor%201/contact
            EOS
    };

    subtest 'send_message_to_editor & send_to_self' => sub {
        $test->skip_unless_mb_mail_service_configured;

        $email->send_message_to_editor(
            from => $user1,
            to => $user2,
            subject => 'Hey',
            message => 'Hello!',
            reveal_address => 1,
            send_to_self => 1,
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 2, 'Two emails sent');

        my $email = pop @emails;
        is($email->{headers}{From}, '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
        is($email->{headers}{'Reply-To'}, '"Editor 1" <foo@example.com>', 'Reply-To is Editor 1, foo@example.com');
        is($email->{headers}{To}, '"Editor 2" <bar@example.com>', 'To is Editor 2, bar@example.com');
        is($email->{headers}{BCC}, undef, 'BCC is undefined');
        is($email->{headers}{Subject}, 'MusicBrainz message from Editor 1: Hey', 'Subject is "MusicBrainz message from Editor 1: Hey"');
        like($email->{headers}{'Message-ID'}, qr{<correspondence-4444-8888-[0-9a-z-]+@.*>}, 'Message-ID has right format');
        is($email->{headers}{References}, sprintf('<correspondence-%s-%s@%s>', $user1->id, $user2->id, DBDefs->WEB_SERVER_USED_IN_EMAIL), 'References correct correspondence');
        compare_body($email->{body}, <<~"EOS");
            [MusicBrainz]
            Hello Editor 2,

            MusicBrainz user 'Editor 1' has sent you the following message:
            **Editor 1: Hey**

            Hello!
            [To reply, click here to send Editor 1 an email.][1]

            Alternatively, please reply to this message.

            *\x{2014} The MetaBrainz community*

            [1]: https://localhost/user/Editor%201/contact
            EOS

        # send_to_self
        $email = pop @emails;
        is($email->{headers}{From}, '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
        is($email->{headers}{'Reply-To'}, '"Editor 1" <foo@example.com>', 'Reply-To is Editor 1, foo@example.com');
        is($email->{headers}{To}, '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
        is($email->{headers}{BCC}, undef, 'BCC is undefined');
        is($email->{headers}{Subject}, 'MusicBrainz message from Editor 1: Hey', 'Subject is "MusicBrainz message from Editor 1: Hey"');
        compare_body($email->{body}, <<~"EOS");
            [MusicBrainz]
            You sent this message to Editor 2
            Hello Editor 2,

            MusicBrainz user 'Editor 1' has sent you the following message:
            **Editor 1: Hey**

            Hello!
            [To reply, click here to send Editor 1 an email.][1]

            Alternatively, please reply to this message.

            *\x{2014} The MetaBrainz community*

            [1]: https://localhost/user/Editor%201/contact
            EOS
    };

    subtest 'send_email_verification' => sub {
        $email->send_email_verification(
            email => 'user@example.com',
            verification_link => "$server/verify-email",
            editor => $user1,
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'From is noreply@...');
        is($email->{headers}{To}, 'user@example.com', 'To is user@example.com');
        is($email->{headers}{Subject}, 'Verify your email', 'Subject is "Verify your email"');
        like($email->{headers}{'Message-ID'}, qr{<verify-email-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>}, 'Message-ID has right format');
        compare_body($email->{body}, <<~"EOS");
            [MusicBrainz]
            Hello Editor 1,

            Click on the link below to verify your email address:
            [https://localhost/verify-email][1]
            If clicking the link above doesn't work, please copy and paste the URL into
            a new browser window instead.
            Welcome!

            *\x{2014} The MetaBrainz community*
            Do not reply to this message. For assistance please contact the team or the
            community.

            [1]: https://localhost/verify-email
            EOS
    };

    subtest 'send_lost_username' => sub {
        $email->send_lost_username(
            user => $user1,
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 1);
        my $email = shift @emails;
        is($email->{headers}{From}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'From is noreply@...');
        is($email->{headers}{To}, '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
        is($email->{headers}{Subject}, 'Lost username', 'Subject is Lost username');
        like($email->{headers}{'Message-Id'}, qr{<lost-username-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>}, 'Message-Id has right format');
        compare_body($email->{body},
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

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'From is noreply@...');
        is($email->{headers}{To}, '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
        is($email->{headers}{Subject}, 'Password reset request', 'Subject is Password reset request');
        like($email->{headers}{'Message-Id'}, qr{<password-reset-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>}, 'Message-Id has right format');
        compare_body($email->{body},
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

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'From is noreply@...');
        is($email->{headers}{To}, '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
        is($email->{headers}{'Reply-To'}, 'MusicBrainz <support@musicbrainz.org>', 'Reply-To is support@...');
        is($email->{headers}{References}, sprintf('<edit-1234@%s>', DBDefs->WEB_SERVER_USED_IN_EMAIL) , 'References edit-1234');
        like($email->{headers}{'Message-Id'}, qr{<edit-1234-8888-no-vote-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>} , ' has right format');
        is($email->{headers}{Subject}, 'Someone has voted against your edit #1234', 'Subject is Someone has voted against...');
        my $close_time = DateTime->now()->add_duration($MINIMUM_RESPONSE_PERIOD)->truncate( to => 'hour' )->add( hours => 1 );
        $close_time = $close_time->strftime('%F %H:%M %Z');

        my $body = <<~"EOS";
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
        compare_body($email->{body}, $body);
    };

    subtest 'send_edit_note' => sub {
        $email->send_edit_note(
            editor => $user1,
            from_editor => $user2,
            edit_id => 1234,
            note_text => 'Please remember to use guess case!',
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"Editor 2" <noreply@musicbrainz.org>', 'Header from is "Editor 2" <noreply@musicbrainz.org>');
        is($email->{headers}{To}, '"Editor 1" <foo@example.com>', 'To is Editor 1, foo@example.com');
        is($email->{headers}{Subject}, 'Note added to edit #1234', 'Subject is Note added to edit #1234');
        is($email->{headers}{References}, sprintf('<edit-1234@%s>', DBDefs->WEB_SERVER_USED_IN_EMAIL) , 'References edit-1234');
        like($email->{headers}{'Message-Id'}, qr{<edit-1234-8888-edit-note-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>} , 'Message ID has right format');
        is($email->{headers}{Sender}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'Sender is noreply@...');
        compare_body($email->{body},
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

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;

        compare_body(
            $email->{body},
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

    subtest 'send_edit_note (own_edit)' => sub {
        $email->send_edit_note(
            editor => $user2,
            from_editor => $user1,
            edit_id => 9000,
            note_text => 'This edit is totally wrong!',
            own_edit => 1,
        );

        my @emails = $test->get_emails;
        is(scalar @emails, 1, 'One email sent');
        my $email = shift @emails;
        is($email->{headers}{From}, '"Editor 1" <noreply@musicbrainz.org>', 'Header from is "Editor 1" <noreply@musicbrainz.org>');
        is($email->{headers}{To}, '"Editor 2" <bar@example.com>', 'To is Editor 2, bar@example.com');
        is($email->{headers}{Subject}, 'Note added to your edit #9000', 'Subject is Note added to your edit #9000');
        like($email->{headers}{'Message-Id'}, qr{<edit-9000-4444-edit-note-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}@.*>} , 'Message ID has right format');
        is($email->{headers}{Sender}, '"MusicBrainz Server" <noreply@musicbrainz.org>', 'Sender is noreply@...');
        compare_body($email->{body},
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
};

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

1;

