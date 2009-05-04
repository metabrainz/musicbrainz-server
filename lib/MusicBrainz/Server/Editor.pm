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

package MusicBrainz::Server::Editor;

use strict;
use warnings;

use base qw/TableBase Catalyst::Authentication::User/;

use DBDefs;
use MusicBrainz::Server::Validation;
use URI::Escape qw( uri_escape );
use Digest::SHA1 qw/sha1_base64/;
use CGI::Cookie;
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

# For Catalyst::Plugin::Authentication
sub supported_features { return { session => 1 }; }

sub entity_type { 'user' }

sub password
{
    my ($self, $new_password) = @_;

    if (defined $new_password) { $self->{password} = $new_password; }
    return $self->{password};
}

sub privs
{
    my ($self, $new_privs) = @_;

    if (defined $new_privs) { $self->{privs} = $new_privs; }
    return $self->{privs};
}

sub mods_accepted
{
    my ($self, $new_mods) = @_;

    if (defined $new_mods) { $self->{modsaccepted} = $new_mods; }
    return $self->{modsaccepted};
}

sub auto_mods_accepted
{
    my ($self, $new_mods) = @_;

    if (defined $new_mods) { $self->{automodsaccepted} = $new_mods; }
    return $self->{automodsaccepted};
}

sub mods_rejected
{
    my ($self, $new_rejected) = @_;

    if (defined $new_rejected) { $self->{modsrejected} = $new_rejected; }
    return $self->{modsrejected};
}

sub mods_failed
{
    my ($self, $new_failed) = @_;

    if (defined $new_failed) { $self->{modsfailed} = $new_failed; }
    return $self->{modsfailed};
}

sub email
{
    my ($self, $new_email) = @_;

    if (defined $new_email) { $self->{email} = $new_email; }
    return $self->{email};
}

sub email_confirmation_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{emailconfirmdate} = $new_date; }
    return $self->{emailconfirmdate};
}

sub web_url
{
    my ($self, $new_url) = @_;

    if (defined $new_url) { $self->{weburl} = $new_url; }
    return $self->{weburl};
}

sub biography
{
    my ($self, $new_bio) = @_;

    if (defined $new_bio) { $self->{bio} = $new_bio; }
    return $self->{bio};
}

sub member_since
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{membersince} = $new_date; }
    return $self->{membersince};
}

sub last_login_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->{lastlogindate} = $new_date; }
    return $self->{lastlogindate};
}

sub email_status
{
	my $self = shift;
	my ($e, $d) = @$self{qw( email emailconfirmdate )};
	return "confirmed" if $e and $d;
	return "pending" if $e and not $d;
	return "missing";
}

sub web_url_complete
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

sub get
{
    my ($self, $prop) = @_;

    if ($self->can($prop))
    {
        return $self->$prop;
    }
}

sub preferences
{
    my $self = shift;
    if (@_) { $self->{preferences} = shift; }
    unless ($self->{preferences})
    {
        my $prefs = UserPreference->newFromUser($self->dbh, $self->id);
        $prefs->load;
        $self->{preferences} = $prefs;
    }
    return $self->{preferences};
}

sub _id_cache_key
{
	my ($class, $id) = @_;
	"moderator-id-" . int($id);
}

sub _name_cache_key
{
	my ($class, $name) = @_;
	"moderator-name-" . $name;
}

sub InvalidateCache
{
	my $self = shift;
	require MusicBrainz::Server::Cache;
	MusicBrainz::Server::Cache->delete($self->_id_cache_key($self->id));
	MusicBrainz::Server::Cache->delete($self->_name_cache_key($self->name));
}

sub Refresh
{
	my $self = shift;
	my $newself = $self->newFromId($self->id)
		or return;
	%$self = %$newself;
}

sub newFromId
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my $uid = shift;

	my $key = $this->_id_cache_key($uid);
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->dbh($this->dbh) if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($this->dbh);

	$obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE id = ?",
			$uid,
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{dbh} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	MusicBrainz::Server::Cache->set($obj->_name_cache_key($obj->name), \$obj)
		if $obj;
	$obj->dbh($this->dbh) if $obj;

	return $obj;
}

sub newFromName
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my $name = shift;

	my $key = $this->_name_cache_key($name);
	require MusicBrainz::Server::Cache;
	my $obj = MusicBrainz::Server::Cache->get($key);

	if ($obj)
	{
		$$obj->dbh($this->dbh) if $$obj;
		return $$obj;
	}

	my $sql = Sql->new($this->dbh);

	$obj = $this->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM moderator WHERE lower(name) = ? LIMIT 1",
			lc($name),
		),
	);

	# We can't store DBH in the cache...
	delete $obj->{dbh} if $obj;
	MusicBrainz::Server::Cache->set($key, \$obj);
	MusicBrainz::Server::Cache->set($obj->_id_cache_key($obj->id), \$obj) if $obj;
	$obj->dbh($this->dbh) if $obj;

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
	my $sql = Sql->new($this->dbh);

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
			my $name = lc(decode "utf-8", $u->name);
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
	# $user = $user->newFromId($user->id) if $user;

	my $s = $this->GetSession;
	$s->{uid} or return undef;

	my %u = (
		id		=> $s->{uid},
		name	=> $s->{user},
		privs	=> $s->{privs},
	);

	$this->_new_from_row(\%u);
}

# Called by MusicBrainz::Server::Editor->TryAutoLogin and bare/login.html.
# The RDF stuff uses a different mechanism.

sub Login
{
	my $this = shift;
	$this = $this->new(shift) if not ref $this;
	my ($user, $pwd) = @_;

	my $sql = Sql->new($this->dbh);

	my $self = $this->newFromName($user)
		or return;

	return if $self->is_special_editor;

	return if $self->password eq LOCKED_OUT_PASSWORD;

	# Maybe this should be unicode, but a byte-by-byte comparison of passwords
	# is probably not a bad thing.
	return unless $self->password eq $pwd;

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

	$sql = Sql->new($this->dbh);
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
			# if user was validated.
			if (@messages == 0)
			{
				$sql->Do(
					"INSERT INTO moderator (name, password, privs) values (?, ?, 0)",
					$user, $pwd,
				);

				my $uid = $sql->GetLastInsertId("Moderator");
				require MusicBrainz::Server::Cache;
				MusicBrainz::Server::Cache->delete($this->_id_cache_key($uid));

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

	my $sql = Sql->new($this->dbh);

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
	my $sql = Sql->new($this->dbh);

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
	my $sql = Sql->new($self->dbh);

	return 0 if (&DBDefs::REPLICATION_TYPE != &MusicBrainz::Server::Replication::RT_MASTER);

	return $sql->SelectSingleValue(
		"SELECT NOW() < membersince + INTERVAL '2 weeks'
		FROM	moderator
		WHERE	id = ?",
		$self->id,
	);
}

# Used by /login.html, /user/edit.html and /user/sendverification.html
sub SetUserInfo
{
	my ($self, %opts) = @_;

	my $uid = $self->id;
	if (not $uid)
	{
		carp "No user ID in SetUserInfo";
		return undef;
	}

	my $sql = Sql->new($self->dbh);

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
	$session->{has_confirmed_email} = ($self->email ? 1 : 0)
		if exists $session->{has_confirmed_email};

	$ok;
}

sub Remove
{
	my ($self) = @_;
	my %opts;

	return "No user loaded." if (!defined $self->GetId());

	$opts{email} = '';
	$opts{name} = "Deleted User #" . $self->GetId();
	$opts{weburl} = "";
	$opts{bio} = "";
	$opts{password} = "";

	my $us = UserSubscription->new($self->{dbh});
	my $sql = Sql->new($self->{dbh});
	eval
	{
		$sql->Begin;
		$self->SetUserInfo(%opts);
		$us->RemoveSubscriptionsForModerator($self->GetId());
		$sql->Commit;
	};
	if ($@)
	{
		my $err = $@;
		$sql->Rollback();
		return $err;
	}
	undef;
}

sub GetSubscribers
{
	my $self = shift;
	require UserSubscription;
	return UserSubscription->GetSubscribersForEditor($self->{dbh}, $self->id);
}

sub MakeAutoModerator
{
	my $self = shift;

	return if $self->is_auto_editor($self->privs);

	my $sql = Sql->new($self->dbh);
	$sql->AutoTransaction(
		sub {
			$self->SetUserInfo(privs => $self->privs | AUTOMOD_FLAG);
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

 	my $sql = Sql->new($this->dbh);
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
	
    my $sql = Sql->new($self->dbh);
	my $ok = $sql->AutoTransaction(
		sub {
			$sql->Do(
				"UPDATE moderator SET password = ?
					WHERE id = ?",
				$newpass1,
				$self->id,
			);
		},
	);

	if ($ok) 
	{
		$self->InvalidateCache;
	}
	else 
	{	
        die "Unable to change password - does the moderator exist?";
	}
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

sub is_special_editor
{
	my $self = shift;
	my $id = $self->id;

	return $id == &ModDefs::ANON_MODERATOR
		or $id == &ModDefs::FREEDB_MODERATOR
		or $id == &ModDefs::MODBOT_MODERATOR;
}

sub is_auto_editor
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	
    return ($privs & AUTOMOD_FLAG) > 0;
}

sub is_bot
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & BOT_FLAG) > 0;
}

sub is_untrusted
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & UNTRUSTED_FLAG) > 0;
}

sub is_link_moderator
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & LINK_MODERATOR_FLAG) > 0;
}

sub dont_nag
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & DONT_NAG_FLAG) > 0;
}

sub is_wiki_transcluder
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & WIKI_TRANSCLUSION_FLAG) > 0;
}

sub is_mbid_submitter
{
	my ($this, $privs) = @_;
	$privs ||= $this->privs;
	return ($privs & MBID_SUBMITTER_FLAG) > 0;
}

sub IsAccountAdmin
{
	my ($this, $privs) = @_;

	return ($privs & ACCOUNT_ADMIN_FLAG) > 0;
}

# User can vote if they have at least 10 accepted edits and a confirmed
# email address.
sub CanVote
{
	my $session = GetSession();

	return 1 if (&DBDefs::REPLICATION_TYPE != &MusicBrainz::Server::Replication::RT_MASTER);

	# If the user is not trusted, do not let them vote
	return 0 if (IsUntrusted(0, $session->{privs}));

	return ($session->{has_confirmed_email} > 0) && ($session->{editsaccepted} > 10);
}

################################################################################
# E-mail
################################################################################

sub CheckEMailAddress
{
	my ($this, $email) = @_;
	$email = $this->email
		if not defined $email;

	return 0 if ($email =~ /\@localhost$/);
	return 0 if ($email =~ /\@127.0.0.1$/);

	return ($email =~ /^\S+@\S+$/);
}

sub GetForwardingAddress
{
	my ($self, $name) = @_;
	$name = $self->name unless defined $name;

	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->_quoted_string($name)
		. '@users.musicbrainz.org';
}

sub GetForwardingAddressHeader
{
	my $self = shift;
	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->format_address_line(
		$self->name,
		$self->GetForwardingAddress,
	);
}

sub GetRealAddressHeader
{
	my $self = shift;
	require MusicBrainz::Server::Mail;
	MusicBrainz::Server::Mail->format_address_line(
		$self->name,
		$self->email,
	);
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

	my $fromname = $self->name;
	my $toname = $other_user->name;

	# Collapse onto a single line
	$subject =~ s/\s+/ /g;

	my $body = <<EOF;
MusicBrainz editor '$fromname' has sent you the following message:
------------------------------------------------------------------------
$message
------------------------------------------------------------------------
EOF

	$revealaddress = 0 unless $self->email;
	$sendcopy = 0 unless $self->email;

	if ($revealaddress)
	{
	
		$body .= <<EOF;
If you would like to respond, please reply to this message or visit
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->id } to send editor
'$fromname' an email.
EOF
	
	} 
	elsif ($self->email) 
	{
	
		$body .= <<EOF;
If you would like to respond, please visit
http://${\ DBDefs::WEB_SERVER() }/user/mod_email.html?uid=${\ $self->id } to send editor
'$fromname' an email.
Please do not respond to this email.
EOF
	
	} 
	elsif ($self->id != &ModDefs::MODBOT_MODERATOR) 
	{
	
		$body .= <<EOF;
Unfortunately editor '$fromname' has not supplied their email address,
therefore you cannot reply to them.
Please do not respond to this email.
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

	# if the user choose to reveal their email address, override
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
Please do not respond to this email.
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

	my $editid = $edit->id;
	my $fromname = $self->name;

	my $body = <<EOF;
Editor '$fromname' has added the following note your edit #$editid:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
If you would like to reply to this note, please add your note at:
http://${\ DBDefs::WEB_SERVER() }/show/edit/?editid=$editid
Please do not respond to this email.
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

	my $editid = $edit->id;
	my $fromname = $self->name;

	my $body = <<EOF;
Editor '$fromname' has added the following note to edit #$editid:
------------------------------------------------------------------------
$note_text
------------------------------------------------------------------------
The original editor was '${\ $edit_user->name }'.

If you would like to reply to this note, please add your note at:
http://${\ DBDefs::WEB_SERVER() }/show/edit/?editid=$editid
Please do not respond to this email.

If you would prefer not to receive these emails, please adjust your
preferences accordingly at http://${\ DBDefs::WEB_SERVER() }/user/preferences.html
EOF

	$opts{'revealaddress'} = 0 unless $self->email;

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
	my $to = $opts{'to'} || $self->email;
	$to or die "No email address available for user " . $self->name;

	require MusicBrainz::Server::Mail;
	my $mailer = MusicBrainz::Server::Mail->open(
		$from,
		$to,
	) or die "Could not send the email. Please try again later.";

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
	die "Failed to send the email. Please try again later."
        unless $ok;
}

################################################################################
# Logging in
################################################################################

sub GetSession { \%MusicBrainz::Server::ComponentPackage::session }

sub EnsureSessionOpen
{
    eval { require Apache; };
    return if $@;

	my $class = shift;

	my $session = GetSession();
	return if tied %$session;

	my $mod = &DBDefs::SESSION_HANDLER;
	eval "require $mod"; 
	eval "import $mod";
	tie %$session, &DBDefs::SESSION_HANDLER, undef, &DBDefs::SESSION_HANDLER_ARGS;
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
    eval { require Apache; };
    return if $@;

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

	$session->{user} = $self->name;
	$session->{privs} = $self->privs;
	$session->{uid} = $self->id;
	$session->{expire} = time() + &DBDefs::WEB_SESSION_SECONDS_TO_LIVE;
	$session->{has_confirmed_email} = ($self->email ? 1 : 0);
	$session->{editsaccepted} = $self->mods_accepted;

	require Moderation;
	my $mod = Moderation->new($self->dbh);
	$session->{moderation_id_start} = $mod->GetMaxModID;

	require UserPreference;
	UserPreference::LoadForUser($self->Current);

	eval { $self->_update_last_login_date($self->id) };
}

# Given that we've just successfully logged in, set a non-session cookie
# containing our login credentials.  TryAutoLogin (below) then reads this
# cookie when the user returns.

sub SetPermanentCookie
{
    my ($self, $c, %opts) = @_;
    my ($username, $password) = ($self->name, $self->password);

    # There are (will be) multiple formats to this cookie.  This is format #2.
    # See TryAutoLogin.
    my $pass_sha1 = sha1_base64($password . "\t" . &DBDefs::SMTP_SECRET_CHECKSUM);
    my $expirytime = time() + 86400 * 365;

    my $ipmask = "";
    $ipmask = $c->req->address
	if $opts{only_this_ip};

    my $value = "2\t$username\t$pass_sha1\t$expirytime\t$ipmask";
    $value .= "\t" . sha1_base64($value . &DBDefs::SMTP_SECRET_CHECKSUM);

    $c->response->cookies->{&PERMANENT_COOKIE_NAME} = {
        value   => $value,
        path    => '/',
        domain  => &DBDefs::SESSION_DOMAIN,
        expires => '+1y',
    };
}

# Deletes the cookie set by SetPermanentCookie

sub ClearPermanentCookie
{
    my ($self, $c) = @_;

    $c->response->cookies->{&PERMANENT_COOKIE_NAME} = {
        value   => "",
        path    => '/',
        domain  => &DBDefs::SESSION_DOMAIN,
        expires => '-1d',
    };
}

# If we're not logged in, but the PERMANENT_COOKIE_NAME cookie is set,
# then try logging in using those credentials.
# Can be called either as: MusicBrainz::Server::Editor->new($dbh)->TryAutoLogin($cookies)
# or as: MusicBrainz::Server::Editor->TryAutoLogin($cookies)

sub TryAutoLogin
{
    my ($self, $c) = @_;

    # Already logged in?
    return 1 if $c->user_exists;

    # Get the permanent cookie
    my $cookie = $c->req->cookies->{&PERMANENT_COOKIE_NAME}
	or return;

    $cookie = $cookie->value;

    my $delete_cookie = 0;

    # If we were called as a class method, instantiate an object
    if (not ref $self)
    {
	$self = $self->new($c->mb->{dbh});
    }

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
	elsif ($cookie =~ /^2\t(.*?)\t(\S+)\t(\d+)\t(\S*)\t(\S+)$/)
        {
	    ($user, my $pass_sha1, my $expiry, $ipmask, my $sha1)
		= ($1, $2, $3, $4, $5);

	    my $correct_sha1 = sha1_base64("2\t$user\t$pass_sha1\t$expiry\t$ipmask" . &DBDefs::SMTP_SECRET_CHECKSUM);

	    $delete_cookie = 1, last
		unless $sha1 eq $correct_sha1;

	    $delete_cookie = 1, last
		if time() > $expiry;

	    if ($ipmask)
	    {
		my $my_ip = $c->req->address;

		$delete_cookie = 1, last
		    if $my_ip ne $ipmask;
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
	    $delete_cookie = 1;
	    last;
	}
	# TODO add other formats: e.g. sha1(password), tied to IP, etc

	defined($user) and defined($password)
	or $delete_cookie = 1, last;

	# Try logging in with these credentials
	$c->authenticate({
	    username => $user,
	    password => $password,
	})
	    or $delete_cookie = 1;

	$c->session->{'__user_ipmask'} = $ipmask;
	last;
    }

    # If the cookie proved invalid, we now delete it
    if ($delete_cookie)
    {
	$self->ClearPermanentCookie($c);
	return;
    }

    return 1;
}

sub _update_last_login_date
{
	my ($self, $uid) = @_;
	my $sql = Sql->new($self->dbh);

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
    my $privs = $self->privs;
    $nag = 0 if ($self->dont_nag($privs) || $self->is_auto_editor($privs) || $self->is_link_moderator($privs));

    my @types;
    push @types, "AutoEditor" if ($self->is_auto_editor($privs));
    push @types, "RelationshipEditor" if $self->is_link_moderator($privs);
    push @types, "Bot" if $self->is_bot($privs);
    push @types, "NotNaggable" if $self->dont_nag($privs);

    my $days = 0.0;
    if ($nag)
    {
        use LWP::UserAgent;
        use URI::Escape;

        my $agent = new LWP::UserAgent;
        $agent->timeout(2);

        my $response = $agent->get('http://metabrainz.org/cgi-bin/nagcheck_days?moderator=' . uri_escape($self->name));

        $days = $response->content;
        if ($days =~ /\s*([-01]+),([-0-9.]+)\s*/) 
        {
            $nag = $1;
            $days = $2;
        }
    }
    return ($nag, $days); 
}

1;
# eof MusicBrainz::Server::Editor.pm
