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
{ our @ISA = qw( TableBase ) }

use strict;
use DBDefs;
use MusicBrainz::Server::Validation;
use Apache;
use URI::Escape qw( uri_escape );
use CGI::Cookie;
use Digest::SHA1 qw(sha1_base64);
use Carp;
use String::Similarity;
use Encode qw( decode );

use constant LOCKED_OUT_PASSWORD => "";

use constant AUTOMOD_FLAG => 1;
use constant BOT_FLAG => 2;
use constant UNTRUSTED_FLAG => 4;
use constant LINK_MODERATOR_FLAG => 8;
use constant DONT_NAG_FLAG => 16;
use constant WIKI_TRANSCLUSION_FLAG => 32;
use constant MBID_SUBMITTER_FLAG => 64;
use constant ACCOUNT_ADMIN_FLAG => 128;

use constant SEARCHRESULT_SUCCESS => 1;
use constant SEARCHRESULT_NOQUERY => 2;
use constant SEARCHRESULT_TIMEOUT => 3;

use constant DEFAULT_SEARCH_TIMEOUT => 30;
use constant DEFAULT_SEARCH_LIMIT => 0;

use constant PERMANENT_COOKIE_NAME => "remember_login";
use constant LOOKUPS_PER_NAG       => 5;

sub GetPassword			{ $_[0]{password} }
sub SetPassword			{ $_[0]{password} = $_[1] }
sub GetPrivs			{ $_[0]{privs} }
sub SetPrivs			{ $_[0]{privs} = $_[1] }
sub GetModsAccepted		{ $_[0]{modsaccepted} }
sub SetModsAccepted		{ $_[0]{modsaccepted} = $_[1] }
sub GetAutoModsAccepted	{ $_[0]{automodsaccepted} }
sub SetAutoModsAccepted	{ $_[0]{automodsaccepted} = $_[1] }
sub GetModsRejected		{ $_[0]{modsrejected} }
sub SetModsRejected		{ $_[0]{modsrejected} = $_[1] }
sub GetModsFailed		{ $_[0]{modsfailed} }
sub SetModsFailed		{ $_[0]{modsfailed} = $_[1] }
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

sub GetEmailStatus
{
	my $self = shift;
	my ($e, $d) = @$self{qw( email emailconfirmdate )};
	return "confirmed" if $e and $d;
	return "pending" if $e and not $d;
	return "missing";
}

sub GetWebURLComplete
{
	local $_ = $_[0]{weburl}
		or return undef;
	/\./ or return undef;
	return undef if / /;
	return $_ if m[^(\w+)://];
	return "mailto:$_" if /\@/;
	$_ = "http://$_";
	$_;
}

sub _GetIdCacheKey
{
	my ($class, $id) = @_;
	"moderator-id-" . int($id);
}

sub _GetNameCacheKey
{
	my ($class, $name) = @_;
	"moderator-name-" . $name;
}

sub InvalidateCache
{
	my $self = shift;
	require MusicBrainz::Server::Cache;
	MusicBrainz::Server::Cache->delete($self->_GetIdCacheKey($self->GetId));
	MusicBrainz::Server::Cache->delete($self->_GetNameCacheKey($self->GetName));
}

sub Refresh
{
	my $self = shift;
	my $newself = $self->newFromId($self->GetId)
		or return;
	%$self = %$newself;
}

sub newFromId
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my $uid = shift;

	my $key = $this->_GetIdCacheKey($uid);
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->{DBH} = $this->{DBH} if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($this->{DBH});

	$obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE id = ?",
			$uid,
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{DBH} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	MusicBrainz::Server::Cache->set($obj->_GetNameCacheKey($obj->GetName), \$obj)
		if $obj;
	$obj->{DBH} = $this->{DBH} if $obj;

	return $obj;
}

sub newFromName
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my $name = shift;

	my $key = $this->_GetNameCacheKey($name);
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->{DBH} = $this->{DBH} if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($this->{DBH});

	$obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE lower(name) = ? LIMIT 1",
			lc($name),
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{DBH} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	MusicBrainz::Server::Cache->set($obj->_GetIdCacheKey($obj->GetId), \$obj) if $obj;
	$obj->{DBH} = $this->{DBH} if $obj;

	return $obj;
}

sub coalesce
{
    my $t = shift;

    while (not defined $t and @_)
    {
		$t = shift;
    }

    $t;
}

sub search
{
	my ($this, %opts) = @_;
	my $sql = Sql->new($this->{DBH});

    my $query = coalesce($opts{'query'}, "");
    my $limit = coalesce($opts{'limit'}, DEFAULT_SEARCH_LIMIT, 0);

	$query =~ /\S/ or return SEARCHRESULT_NOQUERY;

	my @u = map { $this->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM moderator WHERE name ILIKE ?"
					. " ORDER BY name"
					. ($limit ? " LIMIT $limit" : ""),
				'%'.$query.'%',
			),
		};

	return (SEARCHRESULT_SUCCESS, [])
		unless @u;

	$query = lc(decode "utf-8", $query);

	@u = map { $_->[0] }
		sort { $b->[2] <=> $a->[2] or $a->[1] cmp $b->[1] }
		map {
			my $u = $_;
			my $name = lc(decode "utf-8", $u->GetName);
			my $sim = similarity($name, $query);
			[ $u, $name, $sim ];
		} @u;

	(SEARCHRESULT_SUCCESS, \@u);
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

	my $s = $this->GetSession;
	$s->{uid} or return undef;

	my %u = (
		id		=> $s->{uid},
		name	=> $s->{user},
		privs	=> $s->{privs},
	);

	$this->_new_from_row(\%u);
}

# Called by UserStuff->TryAutoLogin and bare/login.html.
# The RDF stuff uses a different mechanism.

sub Login
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my ($user, $pwd) = @_;

	my $sql = Sql->new($this->{DBH});

	my $self = $this->newFromName($user)
		or return;

	return if $self->IsSpecialEditor;

	return if $self->GetPassword eq LOCKED_OUT_PASSWORD;

	# Maybe this should be unicode, but a byte-by-byte comparison of passwords
	# is probably not a bad thing.
	return unless $self->GetPassword eq $pwd;

	return $self;
}

sub Logout
{
	my $self = shift;
	$self->EnsureSessionClosed;
	$self->ClearPermanentCookie;
}

sub CreateLogin
{
	my ($this, $user, $pwd, $pwd2) = @_;
	my ($sql, $uid, $newuser, @messages);

	$sql = Sql->new($this->{DBH});
	$sql->Begin;

	if ($user eq "")
	{
		push @messages, "Please enter a user name"
	}
	else
	{
		my $id = $sql->SelectSingleValue(
			"SELECT MIN(id) FROM moderator WHERE LOWER(name) = LOWER(?)",
			$user,
		);
		if ($id)
		{
			$sql->Rollback;
			push @messages, "That login already exists. Please choose another login name.";
		}
		else
		{
			if ($pwd eq "")
			{
				push @messages, "Please enter a password";
			}
			elsif ($pwd ne $pwd2)
			{
				push @messages, "The given passwords do not match. ";
			}

			# if user was validated.
			if (@messages == 0)
			{
				$sql->Do(
					"INSERT INTO moderator (name, password, privs) values (?, ?, 0)",
					$user, $pwd,
				);

				my $uid = $sql->GetLastInsertId("Moderator");
				require MusicBrainz::Server::Cache;
				MusicBrainz::Server::Cache->delete($this->_GetIdCacheKey($uid));

				# No need to flush the by-name cache: this newFromId call will fill in
				# the correct value
				$newuser = $this->newFromId($uid) or die "Failed to retrieve new user record";

				$sql->Commit;
				@messages = ();
			}
		}
	}
	if ($@)
	{
		$sql->Rollback;
		push @messages, "A database error occurred. ($@)";
	}
	return ($newuser, \@messages);
}

sub GetUserPasswordAndId
{
	my ($this, $username) = @_;

    MusicBrainz::Server::Validation::TrimInPlace($username) if defined $username;
    if (not defined $username or $username eq "")
    {
		carp "Missing username in GetUserPasswordAndId";
		return undef;
    }

	my $sql = Sql->new($this->{DBH});

	my $row = $sql->SelectSingleRowArray(
		"SELECT password, id FROM moderator WHERE name = ?",
		$username,
	);

	$row or return (undef, undef);

	@$row;
}

sub LookupNameByEmail
{
	my ($this, $email) = @_;
	my $sql = Sql->new($this->{DBH});

	return $sql->SelectSingleColumnArray(
		"SELECT name
		FROM	moderator
		WHERE	email = ?",
		$email,
	);
}

sub IsNewbie
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	return 0 if (&DBDefs::REPLICATION_TYPE != &MusicBrainz::Server::Replication::RT_MASTER);

	return $sql->SelectSingleValue(
		"SELECT NOW() < membersince + INTERVAL '2 weeks'
		FROM	moderator
		WHERE	id = ?",
		$self->GetId,
	);
}

# Used by /login.html, /user/edit.html and /user/sendverification.html
sub SetUserInfo
{
	my ($self, %opts) = @_;

	my $uid = $self->GetId;
	if (not $uid)
	{
		carp "No user ID in SetUserInfo";
		return undef;
	}

	my $sql = Sql->new($self->{DBH});

	my $query = "UPDATE moderator SET";
	my @args;

	$query .= " email = ?, emailconfirmdate = NOW(),",
		push @args, $opts{email}
		if $opts{email};
	$query .= " email = '', emailconfirmdate = NULL,"
		if exists $opts{email}
		and not $opts{email};

	# Not for general usage; but this provides us with a clean way to rename a
	# user, which handles the cache, etc
	$query .= " name = ?,",
		push @args, $opts{name}
		if defined $opts{name};

	$query .= " weburl = ?,",
		push @args, $opts{weburl}
		if defined $opts{weburl};

	$query .= " bio = ?,",
		push @args, $opts{bio}
		if defined $opts{bio};

	$query .= " privs = ?,",
		push @args, $opts{privs}
		if defined $opts{privs};

	$query .= " password = ?,",
		push @args, $opts{password}
		if defined $opts{password};

	$query =~ s/,$//
		or return; # no changed fields

	$query .= " WHERE id = ?";
	push @args, $uid;

	my $ok = $sql->AutoTransaction(
		sub { $sql->Do($query, @args); 1 },
	);

	# This clears the cache for the ID, and the (old) name
	$self->InvalidateCache if $ok;
	# This also refreshes the cache for the ID, and for the (new) name
	$self->Refresh if $ok;

	my $session = $self->GetSession;
	$session->{has_confirmed_email} = ($self->GetEmail ? 1 : 0)
		if exists $session->{has_confirmed_email};

	$ok;
}

sub GetSubscribers
{
	my $self = shift;
	require UserSubscription;
	return UserSubscription->GetSubscribersForEditor($self->{DBH}, $self->GetId);
}

sub MakeAutoModerator
{
	my $self = shift;

	return if $self->IsAutoEditor($self->GetPrivs);

	my $sql = Sql->new($self->{DBH});
	$sql->AutoTransaction(
		sub {
			$self->SetUserInfo(privs => $self->GetPrivs | AUTOMOD_FLAG);
		},
	);
}

sub CreditModerator
{
  	my ($this, $uid, $status, $isautoeditor) = @_;

	my $self = $this->newFromId($uid)
		or die;

	use ModDefs qw( STATUS_FAILEDVOTE STATUS_APPLIED );

	my $column = (
		($status == STATUS_FAILEDVOTE)
			? "modsrejected"
			: ($status == STATUS_APPLIED)
				? ($isautoeditor ? "automodsaccepted" : "modsaccepted")
				: "modsfailed"
	);

 	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE moderator SET $column = $column + 1 WHERE id = ?",
		$uid,
	);

	$self->InvalidateCache;
}

# Change a user's password.  The old password must be given.
# Returns true or false.  If false, $@ will be an appropriate
# text/plain error message.

sub ChangePassword
{
	my ($self, $oldpassword, $newpass1, $newpass2) = @_;
	my (@messages);

	if (!MusicBrainz::Server::Validation::IsNonEmptyString($oldpassword) or
		!MusicBrainz::Server::Validation::IsNonEmptyString($newpass1) or
		!MusicBrainz::Server::Validation::IsNonEmptyString($newpass2))
		
	{
		push @messages, "Please fill-in Old password, New password, and Verify Password.";
	}
	else
	{
		MusicBrainz::Server::Validation::TrimInPlace($oldpassword, $newpass1, $newpass2);
		unless ($newpass1 eq $newpass2)
		{
			push @messages, "New Password and Verify Password do not match.";
		}
	}

	unless ($self->IsGoodPassword($newpass1))
	{
		# IsGoodPassword sets $@
		push @messages, $@;
	}

	if (@messages == 0)
	{
		my $sql = Sql->new($self->{DBH});
		my $ok = $sql->AutoTransaction(
			sub {
				$sql->Do(
					"UPDATE moderator SET password = ?
						WHERE id = ?
						AND password = ?",
					$newpass1,
					$self->GetId,
					$oldpassword,
				);
			},
		);
		if ($ok) 
		{
			$self->InvalidateCache;
		}
		else 
		{	
			push @messages, "old password is wrong.";
		}
	}
	return \@messages;
}

# Determine if the given password is "good enough".  Returns true or false.
# If false, $@ will be a plain text message describing in what way it fails.

sub IsGoodPassword
{
	my ($class, $password) = @_;

	if (length($password) < 6)
	{
		$@ = "New password is too short";
		return;
	}

	my $t = decode "utf-8", $password;

	if ($t =~ /\A\p{IsAlpha}+\z/)
	{
		$@ = "New password is all letters";
		return;
	}
	if ($t =~ /\A\p{IsDigit}+\z/)
	{
		$@ = "New password is all numbers";
		return;
	}

	$@ = "";
	1;
}

sub DescribePasswordConditions
{
	"must be at least six characters long, and must be"
		. " neither all letters nor all numbers.";
}

sub GetUserType
{
	my ($this, $privs) = @_;
	$privs = $this->GetPrivs if not defined $privs;

	my $type = "";

	$type = '<a href="/doc/AutoEditor">AutoEditor</a>'
		if ($this->IsAutoEditor($privs));

	$type = "Internal/Bot User"
		if ($this->IsBot($privs));

	$type .= ', <a href="/doc/RelationshipEditor">RelationshipEditor</a>'
		if ($this->IsLinkModerator($privs));

	$type .= ', <a href="/doc/TransclusionEditor">TransclusionEditor</a>'
		if ($this->IsWikiTranscluder($privs));

	$type .= ', MB ID Submitter'
		if ($this->IsMBIDSubmitter($privs));

	$type .= ', account admin'
		if ($this->IsAccountAdmin($privs));

	$type = "Normal User"
		if ($type eq "");

	return $type;
}

sub IsSpecialEditor
{
	my $self = shift;
	my $id = $self->GetId;

	return $id == &ModDefs::ANON_MODERATOR
		or $id == &ModDefs::FREEDB_MODERATOR
		or $id == &ModDefs::MODBOT_MODERATOR;
}

sub IsAutoEditor
{
	my ($this, $privs) = @_;

	return ($privs & AUTOMOD_FLAG) > 0;
}

sub IsBot
{
	my ($this, $privs) = @_;

	return ($privs & BOT_FLAG) > 0;
}

sub IsUntrusted
{
	my ($this, $privs) = @_;

	return ($privs & UNTRUSTED_FLAG) > 0;
}

sub IsLinkModerator
{
	my ($this, $privs) = @_;

	return ($privs & LINK_MODERATOR_FLAG) > 0;
}

sub DontNag
{
	my ($this, $privs) = @_;

	return ($privs & DONT_NAG_FLAG) > 0;
}

sub IsWikiTranscluder
{
	my ($this, $privs) = @_;

	return ($privs & WIKI_TRANSCLUSION_FLAG) > 0;
}

sub IsMBIDSubmitter
{
	my ($this, $privs) = @_;

	return ($privs & MBID_SUBMITTER_FLAG) > 0;
}

sub IsAccountAdmin
{
	my ($this, $privs) = @_;

	return ($privs & ACCOUNT_ADMIN_FLAG) > 0;
}

# User can vote if they have at least 10 accepted edits and a confirmed
# e-mail address.
sub CanVote
{
	my $session = GetSession();

	return 1 if (&DBDefs::REPLICATION_TYPE != &MusicBrainz::Server::Replication::RT_MASTER);

	return ($session->{has_confirmed_email} > 0) && ($session->{editsaccepted} > 10);
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

	"http://" . &DBDefs::WEB_SERVER . "/user/verifyemail.html"
		. "?userid=" . $self->GetId
		. "&email=" . uri_escape($email)
		. "&time=$t"
		. "&chk=" . uri_escape($chk)
		;
}

# Send a user their password.

sub SendPasswordReminder
{
	my $self = shift;

	my $username = $self->GetName;
	my $pass = $self->GetPassword;

	my $body = <<EOF;
Hello.  Someone, probably you, asked that your MusicBrainz password be sent
to you via e-mail.

Your MusicBrainz user name is "$username"
Your MusicBrainz password is "$pass"

To log in to MusicBrainz, please use this link:
http://${\ DBDefs::WEB_SERVER() }/login.html

If you still have problems logging in, please drop us a line - see
http://${\ DBDefs::WEB_SERVER() }/support/contact.html
for details.

-- The MusicBrainz Team
EOF

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		# Sender: not required
		From		=> 'MusicBrainz <webserver@musicbrainz.org>',
		# To: $self (automatic)
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Your MusicBrainz account",
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	$self->SendFormattedEmail(entity => $mail);
}

# Send an address verification e-mail for a user to the specified address.
# Used by htdocs/(createlogin|login|moderator).html
# and htdocs/user/sendverification.html

sub SendVerificationEmail
{
	my ($self, $email) = @_;

	my $url = $self->GetEmailActivationLink($email);

	my $body = <<EOF;
This is the a verification e-mail for your MusicBrainz account.
Please click on the link below to verify your e-mail address:

$url

If clicking the link directly does not work, you may need to manually cut and paste
the link into the location bar of your preferred web browser.

Thanks for using MusicBrainz!

-- The MusicBrainz Team
EOF

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		Sender		=> 'MusicBrainz Server <webserver@musicbrainz.org>',
		From		=> 'MusicBrainz <noreply@musicbrainz.org>',
		To			=> MusicBrainz::Server::Mail->format_address_line($self->GetName, $email),
		"Reply-To"	=> 'MusicBrainz Support <support@musicbrainz.org>',
		Subject		=> "Please verify your e-mail address",
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	$self->SendFormattedEmail(entity => $mail, to => $email);
}

# User $self wants to send an ad-hoc message to $other_user.

sub SendMessageToUser
{
	my ($self, %opts) = @_;
	my $other_user = $opts{'to'};
	my $revealaddress = $opts{'revealaddress'};
	my $sendcopy = $opts{'sendcopy'};
	my $subject = $opts{'subject'};
	my $message = $opts{'body'};

	my $fromname = $self->GetName;
	my $toname = $other_user->GetName;

	# Collapse onto a single line
	$subject =~ s/\s+/ /g;

	my $body = <<EOF;
MusicBrainz editor '$fromname' has sent you the following message:
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
EOF

	$revealaddress = 0 unless $self->GetEmail;
	$sendcopy = 0 unless $self->GetEmail;

	if ($revealaddress)
	{
	
		$body .= <<EOF;
If you would like to respond, please reply to this message or visit
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->GetId } to send editor
'$fromname' an e-mail.
EOF
	
	} 
	elsif ($self->GetEmail) 
	{
	
		$body .= <<EOF;
If you would like to respond, please visit
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->GetId } to send editor
'$fromname' an e-mail.
Please do not respond to this e-mail.
EOF
	
	} 
	elsif ($self->GetId != &ModDefs::MODBOT_MODERATOR) 
	{
	
		$body .= <<EOF;
Unfortunately editor '$fromname' has not supplied their e-mail address,
therefore you cannot reply to them.
Please do not respond to this e-mail.
EOF
	}

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		Sender		=> 'MusicBrainz Server <webserver@musicbrainz.org>',
		From		=> $self->GetForwardingAddressHeader,
		# To: $other_user (automatic)
		"Reply-To"	=> 'Nobody <noreply@musicbrainz.org>',
		Subject		=> MusicBrainz::Server::Mail->_quoted_header($subject),
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	# if the user choose to reveal their e-mail address, override
	# the Nobody default settings.
	if ($revealaddress)
	{
		$mail->replace("From" => $self->GetRealAddressHeader);
		$mail->delete("Reply-To");
	}

	$other_user->SendFormattedEmail(entity => $mail);

	if ($sendcopy)
	{
		my $body_copy = <<EOF;
This is a copy of the message you sent to MusicBrainz editor '$toname':
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
Please do not respond to this e-mail.
EOF

		my $mail = MusicBrainz::Server::Mail->new(
			Sender		=> 'MusicBrainz Server <webserver@musicbrainz.org>',
			From		=> $self->GetForwardingAddressHeader,
			# To: $other_user (automatic)
			"Reply-To"	=> 'Nobody <noreply@musicbrainz.org>',
			Subject		=> MusicBrainz::Server::Mail->_quoted_header($subject),
			Type		=> "text/plain",
			Encoding	=> "quoted-printable",
			Data		=> $body_copy,
		);
    	$mail->attr("content-type.charset" => "utf-8");
		$self->SendFormattedEmail(entity => $mail);
	}

}

# User $self has added a note to $mod.  $edit_user was the original editor.

sub SendModNoteToUser
{
	my ($self, %opts) = @_;
	my $edit = $opts{'mod'};
	my $edit_user = $opts{'mod_user'};
	my $note_text = $opts{'note_text'};

	my $editid = $edit->GetId;
	my $fromname = $self->GetName;

	my $body = <<EOF;
Editor '$fromname' has added the following note your edit #$editid:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
http://${\ DBDefs::WEB_SERVER() }/show/edit/?editid=$editid
Please do not respond to this e-mail.
EOF

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		Sender		=> 'MusicBrainz Server <webserver@musicbrainz.org>',
		From		=> $self->GetForwardingAddressHeader,
		# To: $edit_user (automatic)
		"Reply-To"	=> 'Nobody <noreply@musicbrainz.org>',
		Subject		=> "Note added to your edit #$editid",
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	if ($opts{'revealaddress'})
	{
		$mail->replace("From" => $self->GetRealAddressHeader);
		$mail->delete("Reply-To");
	}

	$edit_user->SendFormattedEmail(entity => $mail);
}

# User $self has added a note to $mod.  $edit_user was the original editor.
# $other_user is a third user, who has already added a note to $mod.

sub SendModNoteToFellowNoter
{
	my ($self, %opts) = @_;
	my $edit = $opts{'mod'};
	my $edit_user = $opts{'mod_user'};
	my $other_user = $opts{'other_user'};
	my $note_text = $opts{'note_text'};

	my $editid = $edit->GetId;
	my $fromname = $self->GetName;

	my $body = <<EOF;
Editor '$fromname' has added the following note to edit #$editid:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
The original editor was '${\ $edit_user->GetName }'.

If you would like to reply to this note, please add your note at:
http://${\ DBDefs::WEB_SERVER() }/show/edit/?editid=$editid
Please do not respond to this e-mail.

If you would prefer not to receive these e-mails, please adjust your
preferences accordingly at http://${\ DBDefs::WEB_SERVER() }/user/preferences.html
EOF

	$opts{'revealaddress'} = 0 unless $self->GetEmail;

	require MusicBrainz::Server::Mail;
	my $mail = MusicBrainz::Server::Mail->new(
		Sender		=> 'MusicBrainz Server <webserver@musicbrainz.org>',
		From		=> $self->GetForwardingAddressHeader,
		# To: $other_user (automatic)
		"Reply-To"	=> 'Nobody <noreply@musicbrainz.org>',
		Subject		=> "Note added to edit #$editid",
		Type		=> "text/plain",
		Encoding	=> "quoted-printable",
		Data		=> $body,
	);
    $mail->attr("content-type.charset" => "utf-8");

	if ($opts{'revealaddress'})
	{
		$mail->replace("From" => $self->GetRealAddressHeader);
		$mail->delete("Reply-To");
	}

	$other_user->SendFormattedEmail(entity => $mail);
}

# Send a complete formatted message ($messagetext) to a user ($self).
# The envelope sender may be specified.  The "To" header will be written
# for you, so should not be included in $messagetext.

sub SendFormattedEmail
{
	my ($self, %opts) = @_;

	($opts{entity} xor $opts{text})
		or croak "Must specify 'entity' OR 'text'";

	my $from = $opts{'from'} || 'noreply@musicbrainz.org';
	my $to = $opts{'to'} || $self->GetEmail;
	$to or return "No e-mail address available for user " . $self->GetName;

	require MusicBrainz::Server::Mail;
	my $mailer = MusicBrainz::Server::Mail->open(
		$from,
		$to,
	) or return "Could not send the e-mail. Please try again later.";

	if ($opts{'entity'})
	{
		my $entity = $opts{entity};
		print $mailer "To: " . $self->GetRealAddressHeader . "\n"
			unless $entity->get("To");
		$entity->print($mailer);
	} 
	elsif ($opts{'text'}) 
	{
		my $messagetext = $opts{'text'};
		my $i = index($messagetext, "\n\n");
		my $headers = substr($messagetext, 0, $i+1);
		print $mailer "To: " . $self->GetRealAddressHeader . "\n"
			unless $headers =~ /^To:/mi;
		print $mailer $messagetext;
	}

	my $ok = close $mailer;
	$ok ? undef : "Failed to send the e-mail. Please try again later.";
}

################################################################################
# Logging in
################################################################################

sub GetSession { \%MusicBrainz::Server::ComponentPackage::session }

sub EnsureSessionOpen
{
	my $class = shift;

	my $session = GetSession();
	return if tied %$session;

	tie %$session, 'Apache::Session::File', undef,
	{
		Directory		=> &DBDefs::SESSION_DIR,
		LockDirectory	=> &DBDefs::LOCK_DIR,
	};

	my $cookie = new CGI::Cookie(
		-name	=> &DBDefs::SESSION_COOKIE,
		-value	=> $session->{_session_id},
		-path	=> '/',
		-domain	=> &DBDefs::SESSION_DOMAIN,
	);

	my $r = Apache->request;
	$r->headers_out->add('Set-Cookie' => $cookie);
}

sub EnsureSessionClosed
{
	my $session = GetSession()
		or return;
	my $obj = tied %$session
		or return;

	$obj->delete;
	$obj = undef;
	untie %$session;

	$_[0]->ClearSessionCookie;
}

sub ClearSessionCookie
{
	my $cookie = new CGI::Cookie(
		-name	=> &DBDefs::SESSION_COOKIE,
		-value	=> "",
		-path	=> '/',
		-domain	=> &DBDefs::SESSION_DOMAIN,
	);

	my $r = Apache->request;
	$r->headers_out->add('Set-Cookie' => $cookie);
}

sub SetSession
{
	my ($self, %opts) = @_;

	my $session = GetSession();

	$self->EnsureSessionOpen;

	$session->{user} = $self->GetName;
	$session->{privs} = $self->GetPrivs;
	$session->{uid} = $self->GetId;
	$session->{expire} = time() + &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;
	$session->{has_confirmed_email} = ($self->GetEmail ? 1 : 0);
	$session->{editsaccepted} = $self->GetModsAccepted;

	require Moderation;
	my $mod = Moderation->new($self->{DBH});
	$session->{moderation_id_start} = $mod->GetMaxModID;

	require UserPreference;
	UserPreference::LoadForUser($self->Current);

	eval { $self->_SetLastLoginDate($self->GetId) };
}

# Given that we've just successfully logged in, set a non-session cookie
# containing our login credentials.  TryAutoLogin (below) then reads this
# cookie when the user returns.

sub SetPermanentCookie
{
	my ($this, %opts) = @_;
	my $r = Apache->request;

	my ($username, $password) = ($this->GetName, $this->GetPassword);

	# There are (will be) multiple formats to this cookie.  This is format #2.
	# See TryAutoLogin.
	my $pass_sha1 = sha1_base64($password . "\t" . &DBDefs::SMTP_SECRET_CHECKSUM);
	my $expirytime = time() + 86400 * 365;

	my $ipmask = "";
	$ipmask = $r->connection->remote_ip
		if $opts{only_this_ip};

	my $value = "2\t$username\t$pass_sha1\t$expirytime\t$ipmask";
	$value .= "\t" . sha1_base64($value . &DBDefs::SMTP_SECRET_CHECKSUM);

	my $cookie = new CGI::Cookie(
		-name	=> &PERMANENT_COOKIE_NAME,
		-value	=> $value,
		-path	=> '/',
		-domain	=> &DBDefs::SESSION_DOMAIN,
		-expires=> '+1y',
	);

	$r->headers_out->add('Set-Cookie' => $cookie);
}

# Deletes the cookie set by SetPermanentCookie

sub ClearPermanentCookie
{
	my $r = Apache->request;

	my $cookie = new CGI::Cookie(
		-name	=> &PERMANENT_COOKIE_NAME,
		-value	=> "",
		-path	=> '/',
		-domain	=> &DBDefs::SESSION_DOMAIN,
		-expires=> '-1d',
	);

	$r->headers_out->add('Set-Cookie' => $cookie);
}

# If we're not logged in, but the PERMANENT_COOKIE_NAME cookie is set,
# then try logging in using those credentials.
# Can be called either as: UserStuff->new($dbh)->TryAutoLogin($cookies)
# or as: UserStuff->TryAutoLogin($cookies)

sub TryAutoLogin
{
	my ($self, $cookies) = @_;
	my $mb;

	# Already logged in?
	my $session = GetSession();
	return if $session->{uid};

	my $r = Apache->request;

	# Get the permanent cookie
	my $c = $cookies->{&PERMANENT_COOKIE_NAME}
		or return;

	my $delete_cookie = 0;
	for (1)
	{
		my ($user, $password);

		my ($my_ip, $ipmask);

		# Format 1: plaintext user + password
		if ($c =~ /^1\t(.*?)\t(.*)$/)
		{
			$user = $1;
			$password = $2;
		}
		# Format 2: username, sha1(password + secret), expiry time,
		# IP address mask, sha1(previous fields + secret)
		elsif ($c =~ /^2\t(.*?)\t(\S+)\t(\d+)\t(\S*)\t(\S+)$/)
		{
			($user, my $pass_sha1, my $expiry, $ipmask, my $sha1)
				= ($1, $2, $3, $4, $5);

			my $correct_sha1 = sha1_base64("2\t$1\t$2\t$3\t$4" . &DBDefs::SMTP_SECRET_CHECKSUM);
			$delete_cookie = 1, last
				unless $sha1 eq $correct_sha1;

			$delete_cookie = 1, last
				if time() > $expiry;

			if ($ipmask)
			{
				my $my_ip = $r->connection->remote_ip;
				$delete_cookie = 1, last
					unless $my_ip eq $ipmask;
			}

			# If we were called as a class method, instantiate an object
			if (not ref $self)
			{
				$mb = MusicBrainz->new;
				$mb->Login;
				$self = $self->new($mb->{DBH});
			}
			my ($correct_password, $userid) = $self->GetUserPasswordAndId($user);
			$delete_cookie = 1, last
				if $correct_password eq LOCKED_OUT_PASSWORD;

			my $correct_pass_sha1 = sha1_base64($correct_password . "\t" . &DBDefs::SMTP_SECRET_CHECKSUM);
			$delete_cookie = 1, last
				unless $pass_sha1 eq $correct_pass_sha1;

			$password = $correct_password;
		}
		else
		{
			#warn "Didn't recognise permanent cookie format";
		}
		# TODO add other formats: e.g. sha1(password), tied to IP, etc

		defined($user) and defined($password)
			or $delete_cookie = 1, last;

		# If we were called as a class method, instantiate an object
		if (not ref $self)
		{
			$mb = MusicBrainz->new;
			$mb->Login;
			$self = $self->new($mb->{DBH});
		}

		# Try logging in with these credentials
		my $userobj = $self->Login($user, $password)
			or $delete_cookie = 1, last;

		$userobj->SetSession;
		my $session = GetSession();
		$session->{'ipmask'} = $ipmask;
	}

	# If the cookie proved invalid, we now delete it
	if ($delete_cookie)
	{
		$self->ClearPermanentCookie;
		return;
	}

	1;
}

sub _SetLastLoginDate
{
	my ($self, $uid) = @_;
	my $sql = Sql->new($self->{DBH});

	$sql->AutoTransaction(sub {
		$sql->Do(
			"UPDATE moderator SET lastlogindate = NOW() WHERE id = ?",
			$uid,
		);
	});

	$self->InvalidateCache;
}

# Checks to see if a user should be nagged because they haven't donated or don't have the
# NoNagFlag set.
sub NagCheck
{
	my ($self) = @_;

    my $nag = 1;
    my $privs = $self->GetPrivs;
    $nag = 0 if ($self->DontNag($privs) || $self->IsAutoEditor($privs) || $self->IsLinkModerator($privs));

    my @types;
    push @types, "AutoEditor" if ($self->IsAutoEditor($privs));
    push @types, "RelationshipEditor" if $self->IsLinkModerator($privs);
    push @types, "Bot" if $self->IsBot($privs);
    push @types, "NotNaggable" if $self->DontNag($privs);

    my $days = 0.0;
    if ($nag)
    {
        use LWP::Simple;
        use URI::Escape;
        $days = get('http://metabrainz.org/cgi-bin/nagcheck_days?moderator=' . uri_escape($self->GetName));
        if ($days =~ /\s*([-01]+),([-0-9.]+)\s*/) 
        {
            $nag = $1;
            $days = $2;
        }
    }
    return ($nag, $days); 
}

1;
# eof UserStuff.pm
