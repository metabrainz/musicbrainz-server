package MusicBrainz::Server::Email;

use Moose;
use Readonly;
use Encode qw( decode encode );
use Email::Address;
use Email::Sender::Simple qw( sendmail );
use Email::MIME;
use Email::MIME::Creator;
use Email::Sender::Transport::SMTP;
use URI::Escape qw( uri_escape );
use DBDefs;

use MusicBrainz::Server::Types qw( :edit_status );
use MusicBrainz::Server::Email::Subscriptions;

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

Readonly our $NOREPLY_ADDRESS => 'MusicBrainz Server <noreply@musicbrainz.org>';
Readonly our $SUPPORT_ADDRESS => 'MusicBrainz <support@musicbrainz.org>';

sub _user_address
{
    my ($user, $hidden) = @_;

    if ($hidden) {
        # Hide the real address
        my $email = sprintf '%s@users.musicbrainz.org', $user->name;
        return Email::Address->new($user->name, $email)->format;
    }

    return Email::Address->new($user->name, $user->email)->format;
}

sub _create_email
{
    my ($self, $headers, $body) = @_;

    return Email::MIME->create(
        header => $headers,
        body => encode('utf-8', $body),
        attributes => {
            content_type => "text/plain",
            charset      => "UTF-8",
            encoding     => "quoted-printable",
        });
}

sub _create_message_to_editor_email
{
    my ($self, %opts) = @_;

    my $from = $opts{from} or die "Missing 'from' argument";
    my $to = $opts{to} or die "Missing 'to' argument";
    my $subject = $opts{subject} or die "Missing 'subject' argument";
    my $message = $opts{message} or die "Missing 'message' argument";

    my @headers = (
        'To'      => _user_address($to),
        'Sender'  => $NOREPLY_ADDRESS,
        'Subject' => $subject,
    );

    if ($opts{reveal_address}) {
        push @headers, 'From', _user_address($from);
    }
    else {
        push @headers, 'From', _user_address($from, 1);
        push @headers, 'Reply-To', $NOREPLY_ADDRESS;
    }

    if ($opts{send_to_self}) {
        push @headers, 'BCC', _user_address($from);
    }

    my $from_name = $from->name;
    my $contact_url = sprintf "http://%s/user/%s/contact",
                        &DBDefs::WEB_SERVER,
                        uri_escape($from->name);

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
        'To'       => $opts{email},
        'From'     => $NOREPLY_ADDRESS,
        'Reply-To' => $SUPPORT_ADDRESS,
        'Subject'  => 'Please verify your email address',
    );

    my $verification_link = $opts{verification_link};

    my $body = <<EOS;
This is a verification email for your MusicBrainz account. Please click
on the link below to verify your email address:

$verification_link

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_lost_username_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'       => _user_address($opts{user}),
        'From'     => $NOREPLY_ADDRESS,
        'Reply-To' => $SUPPORT_ADDRESS,
        'Subject'  => 'Lost username',
    );

    my $user_name = $opts{user}->name;
    my $lost_password_url = sprintf "http://%s/lost-password", &DBDefs::WEB_SERVER;

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

    my $edit_id = $opts{edit_id} or die "Missing 'edit_id' argument";
    my $voter = $opts{voter} or die "Missing 'voter' argument";
    my $editor = $opts{editor} or die "Missing 'editor' argument";

    my @headers = (
        'To' => _user_address($opts{editor}),
        'From' => $NOREPLY_ADDRESS,
        'Reply-To' => $SUPPORT_ADDRESS,
        'References' => sprintf('<edit-%d@musicbrainz.org>', $edit_id),
        'Subject' => "Someone has voted against your edit #$edit_id",
    );

    my $url = sprintf 'http://%s/edit/%d', &DBDefs::WEB_SERVER, $edit_id;
    my $prefs_url = sprintf 'http://%s/account/preferences', &DBDefs::WEB_SERVER;

    my $body = <<EOS;
'${\ $voter->name }' has voted against your edit #$edit_id.
-------------------------------------------------------------------------
To respond, please add your note at:

    $url

Please do not respond to this email.

If clicking the link above doesn't work, please copy and paste the URL in a
new browser window instead.

Please note, this email will only be sent for the first vote against your edit,
not for each one, and that you can disable this notification by modifying your
preferences at $prefs_url.

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_password_reset_request_email
{
    my ($self, %opts) = @_;

    my @headers = (
        'To'       => _user_address($opts{user}),
        'From'     => $NOREPLY_ADDRESS,
        'Reply-To' => $SUPPORT_ADDRESS,
        'Subject'  => 'Password reset request',
    );

    my $reset_password_link = $opts{reset_password_link};
    my $contact_url = sprintf "http://%s/doc/Contact_Us", &DBDefs::WEB_SERVER;

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
$contact_url for details.

-- The MusicBrainz Team
EOS

    return $self->_create_email(\@headers, $body);
}

sub _create_edit_note_email
{
    my ($self, %opts) = @_;

    my $from_editor = $opts{from_editor} or die "Missing 'from_editor' argument";
    my $edit_id = $opts{edit_id} or die "Missing 'edit_id' argument";
    my $editor = $opts{editor} or die "Missing 'editor' argument";
    my $note_text = $opts{note_text} or die "Missing 'note_text' argument";
    my $own_edit = $opts{own_edit};

    my @headers = (
        'To'       => _user_address($editor),
        'From'     => _user_address($from_editor, 1),
        'Sender'   => $NOREPLY_ADDRESS,
    );

    my $from = $from_editor->name;
    my $respond = sprintf "http://%s/edit/%d", &DBDefs::WEB_SERVER, $edit_id;
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
    return $self->_send_email($email);
}

sub send_message_to_editor
{
    my ($self, %opts) = @_;

    my $email = $self->_create_message_to_editor_email(%opts);
    return $self->_send_email($email);
}

sub send_email_verification
{
    my ($self, %opts) = @_;

    my $email = $self->_create_email_verification_email(%opts);
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
        from => $NOREPLY_ADDRESS,
        %opts
    );
    return $self->_send_email($email->create_email);
}

sub send_edit_note
{
    my ($self, %opts) = @_;

    my $email = $self->_create_edit_note_email(%opts);
    return $self->_send_email($email);
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

    if (&DBDefs::_RUNNING_TESTS) { # XXX shouldn't be here
        return $self->get_test_transport;
    }

    return Email::Sender::Transport::SMTP->new({
        host => &DBDefs::SMTP_SERVER,
    });
}

sub _send_email
{
    my ($self, $email) = @_;
    my @all_to = Email::Address->parse($email->header('To'));
    my $to = $all_to[0];
    return unless $to && $to->address;

    my $args = { transport => $self->transport };
    if ($email->header('Sender')) {
        my @sender = Email::Address->parse($email->header('Sender'));
        $args->{from} = $sender[0]->address;
    }
    return sendmail($email, $args);
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
