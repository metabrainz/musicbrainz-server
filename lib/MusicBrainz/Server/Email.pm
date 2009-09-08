package MusicBrainz::Server::Email;

use Moose;
use Readonly;
use Email::Address;
use Email::Sender::Simple qw( sendmail );
use Email::MIME;
use Email::MIME::Creator;
use URI::Escape qw( uri_escape );
use DBDefs;

has 'c' => (
    is => 'rw',
    isa => 'Object'
);

Readonly my $NOREPLY_ADDRESS => 'MusicBrainz Server <noreply@musicbrainz.org>';

sub _user_address
{
    my ($user, $hidden) = @_;

    if ($hidden) {
        # Hide the deal address
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
        body => $body,
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
MusicBrainz editor '$from_name' has sent you the following message:
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
EOS

    if ($opts{reveal_address}) {
        $body .= <<EOS;
If you would like to respond, please reply to this message or visit
$contact_url to send editor
'$from_name' an e-mail.
EOS
    }
    else {
        $body .= <<EOS;
If you would like to respond, please visit
$contact_url to send editor
'$from_name' an e-mail.
EOS
    }

    return $self->_create_email(\@headers, $body);
}

sub send_message_to_editor
{
    my ($self, %opts) = @_;

    my $email = $self->_create_message_to_editor_email(%opts);
    return $self->_send_email($email);
}

has 'transport' => (
    is => 'rw',
    lazy => 1,
    builder => '_build_transport'
);

sub _build_transport
{
    my ($self) = @_;

    if (&DBDefs::_RUNNING_TESTS) { # XXX shouldn't be here
        use Email::Sender::Transport::Test;
        return Email::Sender::Transport::Test->new();
    }

    use Email::Sender::Transport::SMTP;
    return Email::Sender::Transport::SMTP->new({
        host => &DBDefs::SMTP_SERVER,
    });
}

sub _send_email
{
    my ($self, $email) = @_;

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
