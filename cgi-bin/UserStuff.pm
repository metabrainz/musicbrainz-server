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
use Digest::SHA1 qw(sha1_base64);

use constant AUTOMOD_FLAG => 1;
use constant BOT_FLAG => 2;

sub new
{
	my ($type, $dbh) = @_;

	my $this = TableBase->new($dbh);
	return bless $this, $type;
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

sub SetUserInfo
{
	my ($this, $uid, $email, $password, $weburl, $bio) = @_;
	my ($sql, $query);

	$sql = Sql->new($this->{DBH});
	return undef if (!defined $uid || $uid == 0);

	$query = "update Moderator set";

	$query .= " email = " . $sql->Quote($email) . ", emailconfirmdate = now(),"
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

	$query .= " where id = $uid";

	eval
	{
		$sql->Begin;
		$sql->Do($query);
		$sql->Commit;
	};
	if ($@)
	{
		return 0;
	}

	return 1;
} 

sub GetUserType
{
	my ($this, $privs) = @_;
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

sub CheckEMailAddress
{
	my ($this, $email) = @_;

	return 0 if ($email =~ /\@localhost$/);
	return 0 if ($email =~ /\@127.0.0.1$/);

	return ($email =~ /^\S+@\S+$/);
} 

# Sanity check
die "SMTP_SECRET_CHECKSUM not set"
	if &DBDefs::SMTP_SECRET_CHECKSUM eq "";

sub GetVerifyChecksum
{
	my ($this, $email, $uid, $time) = @_;

	return sha1_base64("$email $uid $time " . &DBDefs::SMTP_SECRET_CHECKSUM);
}

sub SendVerificationEmail
{
	my ($this, $info, $email) = @_;
	my ($url, $t, $ret, $safe_from);

	$t = time();

	my $smtp = Net::SMTP->new(DBDefs::SMTP_SERVER());
	return "Could not send mail. Please try again later." unless $smtp;

    $safe_from = $info->{name};
    $safe_from =~ s/\W/?/;

	$smtp->mail("noreply\@musicbrainz.org");
	$smtp->to($email);

	$smtp->data();

	$smtp->datasend("To: $safe_from <$email>\n");
	$smtp->datasend("From: MusicBrainz <noreply\@users.musicbrainz.org>\n");
	$smtp->datasend("Subject: email address verification\n");
	$smtp->datasend("\n");
	$smtp->datasend("This is the email confirmation for your MusicBrainz account.\n");
	$smtp->datasend("Please click on the link below to verify your email address:\n\n");
	
	$url = "http://" . DBDefs::WEB_SERVER . "/user/confirmaddress.html?" .
			"uid=$info->{uid}&email=" . uri_escape($email) .
			"&time=$t&chk=" . uri_escape($this->GetVerifyChecksum($email,
			$info->{uid}, $t));
	$smtp->datasend("  $url\n\n");
	$smtp->datasend("If clicking on the link does not work, you may need to cut and paste\n");
	$smtp->datasend("the link into your web browser manually.\n\n");
	$smtp->datasend("Thanks for using MusicBrainz!\n\n");
	$smtp->datasend("-- The MusicBrainz Team\n\n");

	$ret = $smtp->dataend() ? undef : "Failed to send mail. Please try again later.";
	$smtp->quit();

	return $ret;
}

sub SendEMail
{
	my ($this, $from, $from_uid, $to_info, $subject, $text) = @_;
	my ($url, $t, $ret, $safe_from);

	return "No email address available for moderator $to_info->{name}."
		unless $to_info->{email};

    $safe_from = $from;
    $safe_from =~ s/\W/?/;

	my $smtp = Net::SMTP->new(DBDefs::SMTP_SERVER());
	return "Could not send mail. Please try again later." unless $smtp;

	$smtp->mail("noreply\@musicbrainz.org");
	$smtp->to($to_info->{email});

	$smtp->data();

	$smtp->datasend("To: $to_info->{name} <$to_info->{email}>\n");
	$smtp->datasend("From: $safe_from <$safe_from\@users.musicbrainz.org>\n");
	$smtp->datasend("Reply-To: $safe_from <noreply\@musicbrainz.org>\n");
	$smtp->datasend("Subject: $subject\n");
	$smtp->datasend("\n");
	$smtp->datasend("$text\n\n");
	$smtp->datasend("------------------------------------------------------------------------\n");
	$smtp->datasend("Please do not respond to this email.\n");
    if ($from_uid)
    {
          $smtp->datasend("If you would like to send mail to moderator $from,");
          $smtp->datasend(" please use the link below:\n");
	
          $url = "http://" . DBDefs::WEB_SERVER . 
                 "/user/mod_email.html?uid=$from_uid";
          $smtp->datasend("$url\n\n");
    }

	$ret = $smtp->dataend() ? undef : "Failed to send mail. Please try again later.";
	$smtp->quit();

	return $ret;
}

sub SetSession
{
	my ($this, $session, $user, $privs, $uid, $email_nag) = @_;

	print STDERR "$user, $privs, $uid, $email_nag\n";

	tie %HTML::Mason::Commands::session,
	'Apache::Session::File', undef,
	{
		Directory => DBDefs::SESSION_DIR,
		LockDirectory => DBDefs::LOCK_DIR,
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

	eval { $this->_SetLastLoginDate($uid) };
}

sub _SetLastLoginDate
{
	my ($this, $uid) = @_;
	my $sql = Sql->new($this->{DBH});

	$sql->Begin;
	$sql->Do(
		"UPDATE moderator SET lastlogindate = NOW() WHERE id = ?",
		$uid,
	);
	$sql->Commit;
}

1;
# eof UserStuff.pm
