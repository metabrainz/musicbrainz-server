package MusicBrainz::Server::Email;

use utf8;
use Moose;
use Readonly;
use Encode qw( encode );
use Email::Address;
use Email::Sender::Simple qw( sendmail );
use Email::MIME;
use Email::MIME::Creator;
use Email::Sender::Transport::SMTP;
use URI::Escape qw( uri_escape_utf8 );
use DBDefs;
use Try::Tiny;
use List::AllUtils qw( any sort_by );

use MusicBrainz::Server::Constants qw(
    :edit_status
    :email_addresses
    $CONTACT_URL
    $EDITOR_MODBOT
    $MINIMUM_RESPONSE_PERIOD
);
use MusicBrainz::Server::Email::AutoEditorElection::Nomination;
use MusicBrainz::Server::Email::AutoEditorElection::VotingOpen;
use MusicBrainz::Server::Email::AutoEditorElection::Timeout;
use MusicBrainz::Server::Email::AutoEditorElection::Canceled;
use MusicBrainz::Server::Email::AutoEditorElection::Accepted;
use MusicBrainz::Server::Email::AutoEditorElection::Rejected;
use MusicBrainz::Server::Email::Subscriptions;
use MusicBrainz::Server::Translation;

use aliased 'MusicBrainz::Server::Entity::EditNote';

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

Readonly our $url_prefix => 'https://' . DBDefs->WEB_SERVER_USED_IN_EMAIL;

sub _encode_header {
    my $header = shift;

    if ($header =~ /[^\x20-\x7E]/) {
        return encode('MIME-Q', $header);
    } else {
        return $header;
    }
}

sub _user_address
{
    my ($user, $hidden) = @_;

    my $quoted_name = _encode_header($user->name);
    my $email = $hidden ? $EMAIL_NOREPLY_ADDR_SPEC : $user->email;

    return Email::Address->new($quoted_name, $email)->format;
}

sub _message_id
{
    my $format_string = shift;
    return sprintf('<' . $format_string . '@%s>', @_, DBDefs->WEB_SERVER_USED_IN_EMAIL);
}

sub _create_email
{
    my ($self, $headers, $body) = @_;

    # Add a Message-Id header if there isn't one.
    if ( !(any { "$_" eq 'Message-Id' } @$headers) ) {
        push @$headers, 'Message-Id', _message_id('uncategorized-email-%d', time());
    }
    return Email::MIME->create(
        header => $headers,
        body => encode('utf-8', $body),
        attributes => {
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => 'quoted-printable',
        });
}

sub _create_message_to_editor_email
{
    my ($self, %opts) = @_;

    my $from = $opts{from} or die q(Missing 'from' argument);
    my $to = $opts{to} or die q(Missing 'to' argument);
    my $subject = $opts{subject} or die q(Missing 'subject' argument);
    my $message = $opts{message} or die q(Missing 'message' argument);

    my $time = $opts{time} || time();

    my @correspondents = sort_by { $_->name } ($from, $to);
    my @headers = (
        'To'          => _user_address($to),
        'Sender'      => $EMAIL_NOREPLY_ADDRESS,
        'Subject'     => _encode_header($subject),
        'Message-Id'  => _message_id('correspondence-%s-%s-%d', $correspondents[0]->id, $correspondents[1]->id, $time),
        'References'  => _message_id('correspondence-%s-%s', $correspondents[0]->id, $correspondents[1]->id),
        'In-Reply-To' => _message_id('correspondence-%s-%s', $correspondents[0]->id, $correspondents[1]->id),
    );

    push @headers, 'From', _user_address($from, 1);
    if ($opts{reveal_address}) {
        push @headers, 'Reply-To', _user_address($from);
    }
    else {
        push @headers, 'Reply-To', $EMAIL_NOREPLY_ADDRESS;
    }

    my $from_name = $from->name;
    my $contact_url = $url_prefix .
        sprintf '/user/%s/contact', uri_escape_utf8($from->name);

    my $body = <<EOS;
MusicBrainz user '$from_name' has sent you the following message:
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
EOS

    if ($opts{reveal_address}) {
        $body .= <<EOS;
If you would like to respond, please reply to this message or visit
$contact_url to send '$from_name' an email.

-- The MusicBrainz Team
EOS
    }
    else {
        $body .= <<EOS;
If you would like to respond, please visit
$contact_url to send '$from_name' an email.

-- The MusicBrainz Team
EOS
    }

    return $self->_create_email(\@headers, $body);
}

sub _create_email_verification_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'         => $opts{email},
        'From'       => $EMAIL_NOREPLY_ADDRESS,
        'Reply-To'   => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => _message_id('verify-email-%d', time()),
        'Subject'    => 'Please verify your email address',
    );

    my $verification_link = $opts{verification_link};
    my $ip = $opts{ip};
    my $user_name = $opts{editor}->name;

    my $body = <<EOS;
Hello $user_name,

This is a verification email for your MusicBrainz account. Please click
on the link below to verify your email address:

$verification_link

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

This email was triggered by a request from the IP address [$ip].

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_email_in_use_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'         => $opts{email},
        'From'       => $EMAIL_NOREPLY_ADDRESS,
        'Reply-To'   => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => _message_id('email-in-use-%d', time()),
        'Subject'    => 'Email address already in use',
    );

    my $lost_username_link = $url_prefix . '/lost-username';
    my $lost_password_link = $url_prefix . '/lost-password';
    my $bot_code_of_conduct_link = $url_prefix . '/doc/Code_of_Conduct/Bots';
    my $ip = $opts{ip};
    my $user_name = $opts{editor}->name;

    my $body = <<EOS;
Hello $user_name,

You have requested to verify this email address for the MusicBrainz account $user_name,
but we already have at least one account using this address in our database.
If you have forgotten your old username, you can recover it from the following link:

$lost_username_link

You can then request a password reset, if needed, from the link below:

$lost_password_link

If clicking the links above doesn't work, please copy and paste the URL in a
new browser window instead.

If you have a specific reason why you need a second account (for example,
you want to run a bot and have notes also reach you at this address)
please drop us a line (see $CONTACT_URL for details). We will look into
your specific case. For bots, also let us know about what you are intending
to do with it (see $bot_code_of_conduct_link).

If you didn't initiate this request and feel that you've received this email in
error, don't worry, you don't need to take any further action and can safely
disregard this email.

This email was triggered by a request from the IP address [$ip].

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_lost_username_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'         => _user_address($opts{user}),
        'From'       => $EMAIL_NOREPLY_ADDRESS,
        'Reply-To'   => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => _message_id('lost-username-%d', time()),
        'Subject'    => 'Lost username',
    );

    my $user_name = $opts{user}->name;
    my $lost_password_url = $url_prefix . '/lost-password';

    my $body = <<EOS;
Someone, probably you, asked to look up the username of the
MusicBrainz account associated with this email address.

Your MusicBrainz username is: $user_name

If you have also forgotten your password, use this username and your email address
to reset your password here - $lost_password_url

If you didn't initiate this request and feel that you've received this email in
error, don't worry, you don't need to take any further action and can safely
disregard this email.

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_no_vote_email
{
    my ($self, %opts) = @_;

    my $edit_id = $opts{edit_id} or die q(Missing 'edit_id' argument);
    my $voter = $opts{voter} or die q(Missing 'voter' argument);
    my $editor = $opts{editor} or die q(Missing 'editor' argument);

    my @headers = (
        'To'          => _user_address($opts{editor}),
        'From'        => $EMAIL_NOREPLY_ADDRESS,
        'Reply-To'    => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id'  => _message_id('edit-%d-%d-no-vote-%d', $edit_id, $voter->id, time()),
        'References'  => _message_id('edit-%d', $edit_id),
        'In-Reply-To' => _message_id('edit-%d', $edit_id),
        'Subject'     => "Someone has voted against your edit #$edit_id",
    );

    my $url = $url_prefix . sprintf '/edit/%d', $edit_id;
    my $prefs_url = $url_prefix . '/account/preferences';

    my $close_time = DateTime->now()->add_duration($MINIMUM_RESPONSE_PERIOD)->truncate( to => 'hour' )->add( hours => 1 );
    if ($editor->preferences) {
        $close_time->set_time_zone($editor->preferences->timezone);
    }
    $close_time = $close_time->strftime('%F %H:%M %Z');

    my $body = <<EOS;
'${\ $voter->name }' has voted against your edit #$edit_id.
-------------------------------------------------------------------------
To respond, please add your note at:

    $url

Please do not respond to this email.

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

Please note that this email will not be sent for every vote against an edit.

You can disable this notification by changing your preferences at
$prefs_url.

To ensure time for you and other editors to respond, the soonest this edit will
be rejected, if applicable, is $close_time, 72 hours from the time of
this email.

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_password_reset_request_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'         => _user_address($opts{user}),
        'From'       => $EMAIL_NOREPLY_ADDRESS,
        'Reply-To'   => $EMAIL_SUPPORT_ADDRESS,
        'Message-Id' => _message_id('password-reset-%d', time()),
        'Subject'    => 'Password reset request',
    );

    my $reset_password_link = $opts{reset_password_link};

    my $body = <<EOS;
Someone, probably you, asked that your MusicBrainz password be reset.

To reset your password, click the link below:

$reset_password_link

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

If you didn't initiate this request and feel that you've received this email in
error, don't worry, you don't need to take any further action and can safely
disregard this email.

If you still have problems logging in, please drop us a line - see
$CONTACT_URL for details.

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_edit_note_email
{
    my ($self, %opts) = @_;

    my $from_editor = $opts{from_editor} or die q(Missing 'from_editor' argument);
    my $edit_id = $opts{edit_id} or die q(Missing 'edit_id' argument);
    my $editor = $opts{editor} or die q(Missing 'editor' argument);
    my $note_text = $opts{note_text} or die q(Missing 'note_text' argument);
    my $own_edit = $opts{own_edit};

    if ($from_editor->id == $EDITOR_MODBOT) {
        # Messages from ModBot, while they may be translated on the website,
        # are currently always mailed in English via
        # `run_without_translations` below. This is because, for one, the
        # current language set here is unrelated to the language of the
        # recipient: the current process is either authenticated as the
        # user who approved the edit, or no user at all (being applied by
        # ModBot). Second, the UI language of the recipient is stored as a
        # cookie in their browser, which we obviously don't have access
        # to here.
        MusicBrainz::Server::Translation->run_without_translations(sub {
            $note_text = EditNote->new(
                editor_id => $from_editor->id,
                text => "$note_text",
            )->localize;
        });
    }

    my @headers = (
        'To'          => _user_address($editor),
        'From'        => _user_address($from_editor, 1),
        'Sender'      => $EMAIL_NOREPLY_ADDRESS,
        'Message-Id'  => _message_id('edit-%d-%s-edit-note-%d', $edit_id, $from_editor->id, time()),
        'References'  => _message_id('edit-%d', $edit_id),
        'In-Reply-To' => _message_id('edit-%d', $edit_id),
    );

    my $from = $from_editor->name;
    my $respond = $url_prefix . sprintf '/edit/%d', $edit_id;
    my $body;

    if ($own_edit) {
        push @headers, ('Subject'  => "Note added to your edit #$edit_id");

        $body = <<EOS;
'$from' has added the following note to your edit #$edit_id:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
$respond
Please do not respond to this email.

-- The MusicBrainz Team
EOS
    }
    else {
        push @headers, ('Subject'  => "Note added to edit #$edit_id");

        $body = <<EOS;
'$from' has added the following note to edit #$edit_id:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
$respond
Please do not respond to this email.

-- The MusicBrainz Team
EOS
    }

    return $self->_create_email(\@headers, $body);
}

sub send_first_no_vote
{
    my $self = shift;
    my $email = $self->_create_no_vote_email(@_);
    return try { $self->_send_email($email) } catch { warn $_ };
}

sub send_message_to_editor
{
    my ($self, %opts) = @_;

    $opts{time} = time();
    {
        my $email = $self->_create_message_to_editor_email(%opts);
        $self->_send_email($email);
    }

    if ($opts{send_to_self}) {
        my $copy = $self->_create_message_to_editor_email(%opts);
        my $toname = $opts{to}->name;
        my $message = $opts{message};

        $copy->header_str_set( To => _user_address($opts{from}) );
        $copy->body_str_set(<<EOF);
This is a copy of the message you sent to MusicBrainz editor '$toname':
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
Please do not respond to this e-mail.
EOF

        $self->_send_email($copy);
    }
}

sub send_email_verification
{
    my ($self, %opts) = @_;

    my $email = $self->_create_email_verification_email(%opts);
    return $self->_send_email($email);
}

sub send_email_in_use
{
    my ($self, %opts) = @_;

    my $email = $self->_create_email_in_use_email(%opts);
    return $self->_send_email($email);
}

sub send_lost_username
{
    my ($self, %opts) = @_;

    my $email = $self->_create_lost_username_email(%opts);
    return $self->_send_email($email);
}

sub send_password_reset_request
{
    my ($self, %opts) = @_;

    my $email = $self->_create_password_reset_request_email(%opts);
    return $self->_send_email($email);
}

sub send_subscriptions_digest
{
    my ($self, %opts) = @_;

    my $email = MusicBrainz::Server::Email::Subscriptions->new(
        from => $EMAIL_NOREPLY_ADDRESS,
        %opts
    );
    return try { $self->_send_email($email->create_email) } catch { warn $_ };
}

sub _send_election_mail
{
    my ($self, $name, $election) = @_;

    my $email_class = "MusicBrainz::Server::Email::AutoEditorElection::$name";
    my $email = $email_class->new(
        from => 'The Returning Officer <returning-officer@musicbrainz.org>',
        election => $election,
    );
    return try { $self->_send_email($email->create_email) } catch { warn $_ };
}

sub send_election_nomination
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('Nomination', $election);
}

sub send_election_voting_open
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('VotingOpen', $election);
}

sub send_election_timeout
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('Timeout', $election);
}

sub send_election_canceled
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('Canceled', $election);
}

sub send_election_accepted
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('Accepted', $election);
}

sub send_election_rejected
{
    my ($self, $election) = @_;

    return $self->_send_election_mail('Rejected', $election);
}

sub send_edit_note
{
    my ($self, %opts) = @_;

    my $email = $self->_create_edit_note_email(%opts);
    return try { $self->_send_email($email) } catch { warn $_ };
}

sub send_editor_report {
    my ($self, %opts) = @_;

    my $reporter = $opts{reporter};
    my $reported_user = $opts{reported_user};
    my $reported_user_name = $reported_user->name;
    my $subject = 'Editor ' . $reported_user_name . ' has been reported by ' . $reporter->name;
    my $reason = $MusicBrainz::Server::Form::User::Report::REASONS{$opts{reason}};
    my $reporter_tolink = uri_escape_utf8($reporter->name);
    my $reported_user_tolink = uri_escape_utf8($reported_user->name);
    my $report_content = <<~"EOF";
        $subject for the following reason:

        “$reason”

        Reporter’s account: https://musicbrainz.org/user/$reporter_tolink
        Reported user’s account: https://musicbrainz.org/user/$reported_user_tolink

        EOF

    my $message = $opts{message};
    if ($message) {
        $report_content .= <<~"EOF";
            ------------------------------------------------------------------------
            $message
            EOF
    }

    # We keep the report content without reply info for a possible "send copy" email
    my $body = <<~"EOF";
        $report_content
        ------------------------------------------------------------------------
        EOF

    if ($opts{reveal_address}) {
        $body .= "You can reply to this message directly.\n";
    } else {
        $body .= 'The reporter chose not to reveal their email address. ';
        $body .= "You’ll have to contact them through their user page if necessary.\n";
    }

    my @headers = (
        'To'          => $EMAIL_ACCOUNT_ADMINS_ADDRESS,
        'Sender'      => $EMAIL_NOREPLY_ADDRESS,
        'Subject'     => _encode_header($subject),
        'Message-Id'  => _message_id('editor-report-%s-%d', $reported_user->id, time),
    );

    push @headers, 'From', _user_address($reporter, 1);
    if ($opts{reveal_address}) {
        push @headers, 'Reply-To', _user_address($reporter) . ', ' . $EMAIL_ACCOUNT_ADMINS_ADDRESS;
    } else {
        push @headers, 'Reply-To', $EMAIL_ACCOUNT_ADMINS_ADDRESS;
    }

    my $email = $self->_create_email(\@headers, $body);
    $self->_send_email($email);

    if ($opts{send_to_self}) {
        my $copy_subject = 'Copy of your report of ' . $reported_user_name;

        my @copy_headers = (
            'To'          => _user_address($reporter),
            'Sender'      => $EMAIL_NOREPLY_ADDRESS,
            'Subject'     => _encode_header($copy_subject),
            'Message-Id'  => _message_id('editor-report-copy-%s-%d', $reported_user->id, time),
        );

        push @copy_headers, 'From', _user_address($reporter, 1);

        my $copy_body = <<~"EOF";
            This is a copy of your report of MusicBrainz editor '$reported_user_name':
            ------------------------------------------------------------------------
            $report_content
            ------------------------------------------------------------------------
            Please do not respond to this e-mail.
            EOF

        my $copy = $self->_create_email(\@copy_headers, $copy_body);
        $self->_send_email($copy);
    }
}

has 'transport' => (
    is => 'rw',
    lazy => 1,
    builder => '_build_transport'
);

sub get_test_transport
{
    require MusicBrainz::Server::Test;
    MusicBrainz::Server::Email->import;
    return MusicBrainz::Server::Test->get_test_transport;
}

sub _build_transport
{
    my ($self) = @_;

    if ($ENV{MUSICBRAINZ_RUNNING_TESTS}) { # XXX shouldn't be here
        return $self->get_test_transport;
    }

    my ($host, $port) = split /:/, DBDefs->SMTP_SERVER;
    return Email::Sender::Transport::SMTP->new({
        host => $host,
        port => $port // 25,
    });
}

sub _send_email
{
    my ($self, $email) = @_;
    my @all_to = Email::Address->parse($email->header('To'));
    my $to = $all_to[0];
    return unless $to && $to->address;

    my $args = {
        transport => $self->transport,
        to => [
            map  { $_->address               }
            grep { defined                   }
            map  { Email::Address->parse($_) }
            map  { $email->header($_)        }
                qw(to cc bcc)
        ]
    };

    $email->header_set('BCC', undef);

    if ($email->header('Sender')) {
        my @sender = Email::Address->parse($email->header('Sender'));
        $args->{from} = $sender[0]->address;
    }

    return sendmail($email, $args);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
