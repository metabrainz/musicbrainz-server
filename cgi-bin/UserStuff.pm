#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package UserStuff;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use MusicBrainz;
use Apache;
use Net::SMTP;
use URI::Escape;
use CGI::Cookie;
use Digest::SHA1 qw(sha1_base64);
use MIME::QuotedPrint qw( encode_qp );

use constant AUTOMOD_FLAG => 1;
use constant BOT_FLAG => 2;

sub GetPassword			{ $_[0]{password} }
sub SetPassword			{ $_[0]{password} = $_[1] }
sub GetPrivs			{ $_[0]{privs} }
sub SetPrivs			{ $_[0]{privs} = $_[1] }
sub GetModsAccepted		{ $_[0]{modsaccepted} }
sub SetModsAccepted		{ $_[0]{modsaccepted} = $_[1] }
sub GetModsRejected		{ $_[0]{modsrejected} }
sub SetModsRejected		{ $_[0]{modsrejected} = $_[1] }
sub GetEmail			{ $_[0]{email} }
sub SetEmail			{ $_[0]{email} = $_[1] }
sub GetWebURL			{ $_[0]{weburl} }
sub SetWebURL			{ $_[0]{weburl} = $_[1] }
sub GetBio				{ $_[0]{bio} }
sub SetBio				{ $_[0]{bio} = $_[1] }
sub GetMemberSince		{ $_[0]{membersince} }
sub SetMemberSince		{ $_[0]{membersince} = $_[1] }
sub GetEmailConfirmDate	{ $_[0]{emailconfirmdate} }
sub SetEmailConfirmDate	{ $_[0]{emailconfirmdate} = $_[1] }
sub GetLastLoginDate	{ $_[0]{lastlogindate} }
sub SetLastLoginDate	{ $_[0]{lastlogindate} = $_[1] }

sub newFromId
{
	my ($this, $uid) = @_;
	my $sql = Sql->new($this->{DBH});

	$this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE id = ?",
			$uid,
		),
	);
}

sub newFromName
{
	my ($this, $name) = @_;
	my $sql = Sql->new($this->{DBH});

	$this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE name = ? LIMIT 1",
			$name,
		),
	);
}

sub Current
{
	my $this = shift;

	# For now this constructs just a partial user, containing
	# an id, name, and privs.  In the future it would be nice
	# if any attempt to fetch any of the other fields would
	# cause this object to be silently "upgraded" by fetching
	# the full user record from the database.
	# To do so manually use:
	# $user = $user->newFromId($user->GetId) if $user;

	my $s = \%HTML::Mason::Commands::session;
	$s->{uid} or return undef;

	my %u = (
		id		=> $s->{uid},
		name	=> $s->{user},
		privs	=> $s->{privs},
	);

	$this->_new_from_row(\%u);
}

sub Login
{
	my ($this, $user, $pwd) = @_;

	my $sql = Sql->new($this->{DBH});

	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM moderator WHERE name = ? LIMIT 1",
		$user,
	);

	return unless $row;

	return if $row->{id} == &ModDefs::ANON_MODERATOR;
	return if $row->{id} == &ModDefs::FREEDB_MODERATOR;
	return if $row->{id} == &ModDefs::MODBOT_MODERATOR;

	# Maybe this should be unicode, but a byte-by-byte comparison of passwords
	# is probably not a bad thing.
	return unless $row->{password} eq $pwd;

	return (1, $row->{name}, $row->{privs}, $row->{id}, $row->{email},
			$row->{email} && !$row->{emailconfirmdate});
}

sub CreateLogin
{
	my ($this, $user, $pwd, $pwd2) = @_;
	my ($sql, $uid, $dbuser);

	$sql = Sql->new($this->{DBH});

	if ($pwd ne $pwd2)
	{
		return "The given passwords do not match. Please try again.";
	}
	if ($pwd eq "")
	{
		return "You cannot leave the password blank. Please try again.";
	}
	if ($user eq "")
	{
		return "You cannot leave the user name blank. Please try again."
	}

	$dbuser = $sql->Quote($user);
	$pwd = $sql->Quote($pwd);

	my $msg = eval
	{
		$sql->Begin;

		if ($sql->Select("select id from Moderator where name ilike $dbuser"))
		{
			$sql->Finish;
			$sql->Rollback;
			return ("That login already exists. Please choose another login name.");
		}

		$sql->Do(qq/
					insert into Moderator (Name, Password, Privs, ModsAccepted, 
					ModsRejected, MemberSince) values ($dbuser, $pwd, 0, 0, 0, now())
		/);

		$uid = $sql->GetLastInsertId("Moderator");
		$sql->Commit;

		return "";
	};
	if ($@)
	{
		$sql->Rollback;
		return ("A database error occurred. ($@)", undef, undef, undef);
	}
	if ($msg ne '')
	{
		return $msg; 
	}

	return ("", $user, 0, $uid);
} 

sub GetUserPasswordAndId
{
	my ($this, $username) = @_;
	my ($sql, $dbuser);

	$sql = Sql->new($this->{DBH});
	return undef if (!defined $username || $username eq '');

	$dbuser = $sql->Quote($username);
	if ($sql->Select(qq|select password, id from Moderator 
							where name ilike $dbuser|))
	{
		my @row = $sql->NextRow();
		$sql->Finish;
		return ($row[0], $row[1]);
	}

	return (undef, undef);
} 

sub GetUserInfo
{
	my ($this, $uid) = @_;
	my ($sql, $dbuser);

	$sql = Sql->new($this->{DBH});
	return undef if (!defined $uid || $uid == 0);

	if ($sql->Select(qq|select name, email, password, privs, modsaccepted, 
					modsrejected, WebUrl, MemberSince, Bio, 
					emailconfirmdate
					from Moderator 
					where id = $uid|))
	{
		my @row = $sql->NextRow();
		$sql->Finish;
		return {
			name=>$row[0],
			email=>$row[1],
			passwd=>$row[2],
			privs=>$row[3],
			modsaccepted=>$row[4],
			modsrejected=>$row[5],
			weburl =>$row[6],
			membersince =>$row[7],
			bio=>$row[8],
			emailconfirmdate=>$row[9],
			uid=>$uid,
		};
	}
	return undef;
}

# Used by (login|moderator|confirmaddress).html
sub SetUserInfo
{
	my ($this, $uid, $email, $password, $weburl, $bio) = @_;

	my $sql = Sql->new($this->{DBH});
	return undef if (!defined $uid || $uid == 0);

	my $query = "UPDATE moderator SET";

	$query .= " email = " . $sql->Quote($email) . ", emailconfirmdate = NOW(),"
		if (defined $email && $email ne '');

	$query .= " password = " . $sql->Quote($password) . ","
		if (defined $password && $password ne '');

	$query .= " weburl = " . $sql->Quote($weburl) . ","
		if (defined $weburl && $weburl ne '');

	$query .= " bio = " . $sql->Quote($bio) . ","
		if (defined $bio && $bio ne '');

	if ($query =~ m/,$/)
	{
		chop($query);
	}
	else
	{
		# No valid args were specified, so bail
		return;
	}

	$query .= " WHERE id = $uid";

	eval {
		$sql->AutoTransaction(
			sub { $sql->Do($query); 1 },
		);
	};
} 

sub GetUserType
{
	my ($this, $privs) = @_;
	$privs = $this->GetPrivs if not defined $privs;

	my $type = "";

	$type = "Automatic Moderator "
		if ($this->IsAutoMod($privs));

	$type = "Internal/Bot User "
		if ($this->IsBot($privs));

	$type = "Normal User"
		if ($type eq "");

	return $type;
}

sub IsAutoMod
{
	my ($this, $privs) = @_;

	return ($privs & AUTOMOD_FLAG) > 0;
}

sub IsBot
{
	my ($this, $privs) = @_;

	return ($privs & BOT_FLAG) > 0;
}

################################################################################
# E-mail
################################################################################

sub CheckEMailAddress
{
	my ($this, $email) = @_;
	$email = $this->GetEmail
		if not defined $email;

	return 0 if ($email =~ /\@localhost$/);
	return 0 if ($email =~ /\@127.0.0.1$/);

	return ($email =~ /^\S+@\S+$/);
} 

sub GetForwardingAddress
{
	my ($self, $name) = @_;
	$name = $self->GetName unless defined $name;

	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->_quoted_string($name)
		. '@users.musicbrainz.org';
}

sub GetForwardingAddressHeader
{
	my $self = shift;
	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->format_address_line(
		$self->GetName,
		$self->GetForwardingAddress,
	);
}

sub GetRealAddressHeader
{
	my $self = shift;
	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->format_address_line(
		$self->GetName,
		$self->GetEmail,
	);
}

# Sanity check
die "SMTP_SECRET_CHECKSUM not set"
	if &DBDefs::SMTP_SECRET_CHECKSUM eq "";

sub GetVerifyChecksum
{
	my ($this, $email, $uid, $time) = @_;
	sha1_base64("$email $uid $time " . &DBDefs::SMTP_SECRET_CHECKSUM);
}

sub GetEmailActivationLink
{
	my ($self, $email) = @_;

	my $t = time;
	my $chk = $self->GetVerifyChecksum($email, $self->GetId, $t);

	"http://" . &DBDefs::WEB_SERVER . "/user/confirmaddress.html"
		. "?uid=" . $self->GetId
		. "&email=" . uri_escape($email)
		. "&time=$t"
		. "&chk=" . uri_escape($chk)
		;
}

# Send an address verification e-mail for a user to the specified address.
# Used by htdocs/(createlogin|login|moderator).html

sub SendVerificationEmail
{
	my ($self, $email) = @_;

	my $url = $self->GetEmailActivationLink($email);

	require MusicBrainz::Server::Mail;
	my $to_line = MusicBrainz::Server::Mail->format_address_line(
		$self->GetName,
		$email,
	);

	my $mailer = MusicBrainz::Server::Mail->open(
		'noreply@musicbrainz.org',
		$email,
	) or return "Could not send mail. Please try again later.";

	print $mailer
		<<EOF,
Sender: Webserver <webserver\@musicbrainz.org>
From: MusicBrainz <noreply\@musicbrainz.org>
To: $to_line
Subject: email address verification
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

EOF
		encode_qp(<<EOF),
This is the email confirmation for your MusicBrainz account.
Please click on the link below to verify your email address:

$url

If clicking on the link does not work, you may need to cut and paste
the link into your web browser manually.

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOF
		;

	close($mailer) ? undef : "Failed to send mail. Please try again later.";
}

sub SendMessageToUser
{
	my ($self, $subject, $message, $otheruser) = @_;
	
	my $fromname = $self->GetName;
	my $fromline = $self->GetForwardingAddressHeader;

	# Collapse onto a single line
	$subject =~ s/\s+/ /g;

	$otheruser->SendFormattedEmail(
		<<EOF
Sender: Webserver <webserver\@musicbrainz.org>
From: $fromline
Subject: $subject
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

EOF
		. encode_qp(<<EOF)
$message

------------------------------------------------------------------------
Please do not respond to this email.

If you would like to send mail to moderator '$fromname',
please use this link:
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->GetId }
EOF
	);
}

sub SendModNoteToUser
{
	my ($self, $mod, $notetext, $otheruser) = @_;

	my $modid = $mod->GetId;
	my $fromname = $self->GetName;
	my $fromline = $self->GetForwardingAddressHeader;

	$otheruser->SendFormattedEmail(
		<<EOF
Sender: Webserver <webserver\@musicbrainz.org>
From: $fromline
Subject: Note added to moderation #$modid
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

EOF
		. encode_qp(<<EOF)
Moderator '$fromname' has attached a note to your moderation #$modid:

$notetext

Moderation link: http://${\ DBDefs::WEB_SERVER() }/showmod.html?modid=$modid

------------------------------------------------------------------------
Please do not respond to this email.

If you would like to send mail to moderator '$fromname',
please use this link:
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->GetId }
EOF
	);
}

# Send a complete formatted message ($messagetext) to a user ($self).
# The envelope sender may be specified.  The "To" header will be written
# for you, so should not be included in $messagetext.

sub SendFormattedEmail
{
	my ($self, $messagetext, $envelope_from) = @_;
	$envelope_from ||= 'noreply@musicbrainz.org';

	my $email = $self->GetEmail
		or return "No email address available for moderator " . $self->GetName;

	require MusicBrainz::Server::Mail;
	my $mailer = MusicBrainz::Server::Mail->open(
		$envelope_from,
		$email,
	) or return "Could not send mail. Please try again later.";

	print $mailer "To: " . $self->GetRealAddressHeader . "\n";
	print $mailer $messagetext;

	my $ok = close $mailer;
	$ok ? undef : "Failed to send mail. Please try again later.";
}

################################################################################
# Logging in
################################################################################

sub SetSession
{
	my ($this, $session, $user, $privs, $uid, $email_nag) = @_;

	tie %HTML::Mason::Commands::session,
	'Apache::Session::File', undef,
	{
		Directory => &DBDefs::SESSION_DIR,
		LockDirectory => &DBDefs::LOCK_DIR,
	};
	my $cookie = new CGI::Cookie(
		-name=>'AF_SID',
		-value=>$HTML::Mason::Commands::session{_session_id},
		-path => '/',
	);

	my $r = Apache->request;
	$r->headers_out->add('Set-cookie' => $cookie);

	$session->{user} = $user;
	$session->{privs} = $privs;
	$session->{uid} = $uid;
	$session->{expire} = time() + &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;
	$session->{email_nag} = $email_nag;

	require UserPreference;
	UserPreference::LoadForUser($this->Current);

	eval { $this->_SetLastLoginDate($uid) };
}

sub _SetLastLoginDate
{
	my ($this, $uid) = @_;
	my $sql = Sql->new($this->{DBH});
	my $wrap_transaction = $sql->{DBH}{AutoCommit};

	eval {
		$sql->Begin if $wrap_transaction;
		$sql->Do(
			"UPDATE moderator SET lastlogindate = NOW() WHERE id = ?",
			$uid,
		);
		$sql->Commit if $wrap_transaction;
		1;
	} or do {
		my $e = $@;
		$sql->Rollback if $wrap_transaction;
		die $e;
	};
}

1;
# eof UserStuff.pm
