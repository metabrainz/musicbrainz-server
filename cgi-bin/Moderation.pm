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

package Moderation;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA       = 'TableBase';

use strict;
use Carp;
use DBI;
use DBDefs;
use Track;
use Artist;
use Album;
use Insert;
use ModDefs ':all';
use UserStuff;
use Text::Unaccent;
use Encode qw( encode decode );
use utf8;

# Load all the moderation handlers
require MusicBrainz::Server::Moderation::MOD_ADD_ALBUM;
require MusicBrainz::Server::Moderation::MOD_ADD_ARTIST;
require MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_ADD_TRACK;
require MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV;
require MusicBrainz::Server::Moderation::MOD_ADD_TRMS;
require MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST;
require MusicBrainz::Server::Moderation::MOD_EDIT_ALBUMATTRS;
require MusicBrainz::Server::Moderation::MOD_EDIT_ALBUMNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_RELEASES;
require MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME;
require MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM;
require MusicBrainz::Server::Moderation::MOD_MAC_TO_SAC;
require MusicBrainz::Server::Moderation::MOD_MERGE_ALBUM;
require MusicBrainz::Server::Moderation::MOD_MERGE_ALBUM_MAC;
require MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST;
require MusicBrainz::Server::Moderation::MOD_MOVE_ALBUM;
require MusicBrainz::Server::Moderation::MOD_MOVE_DISCID;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ALBUM;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ALBUMS;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST;
require MusicBrainz::Server::Moderation::MOD_REMOVE_ARTISTALIAS;
require MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID;
require MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK;
require MusicBrainz::Server::Moderation::MOD_REMOVE_TRMID;
require MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC;

use constant SEARCHRESULT_SUCCESS => 1;
use constant SEARCHRESULT_NOQUERY => 2;
use constant SEARCHRESULT_TIMEOUT => 3;

use constant DEFAULT_SEARCH_TIMEOUT => 30;

my %ChangeNames = (
    &ModDefs::STATUS_OPEN			=> "Open",
    &ModDefs::STATUS_APPLIED		=> "Change applied",
    &ModDefs::STATUS_FAILEDVOTE		=> "Failed vote",
    &ModDefs::STATUS_FAILEDDEP		=> "Failed dependency",
    &ModDefs::STATUS_ERROR			=> "Internal error",
    &ModDefs::STATUS_FAILEDPREREQ	=> "Failed prerequisite",
    &ModDefs::STATUS_TOBEDELETED	=> "To be deleted",
    &ModDefs::STATUS_DELETED		=> "Deleted"
);

sub Refresh
{
	my $self = shift;
	my $newself = $self->CreateFromId($self->GetId);
	%$self = %$newself;
}

sub GetModerator
{
   return $_[0]->{moderator};
}

sub SetModerator
{
   $_[0]->{moderator} = $_[1];
}

sub GetExpired
{
   return $_[0]->{isexpired};
}

sub SetExpired
{
   $_[0]->{isexpired} = $_[1];
}

sub GetOpenTime
{
   return $_[0]->{opentime};
}

sub SetOpenTime
{
   $_[0]->{opentime} = $_[1];
}

sub GetCloseTime
{
   return $_[0]->{closetime};
}

sub SetCloseTime
{
   $_[0]->{closetime} = $_[1];
}

sub GetExpireTime
{
   return $_[0]->{expiretime};
}

sub SetExpireTime
{
   $_[0]->{expiretime} = $_[1];
}

sub GetType
{
   return $_[0]->{type};
}

sub SetType
{
   $_[0]->{type} = $_[1];
}

sub GetStatus
{
   return $_[0]->{status};
}

sub SetStatus
{
   $_[0]->{status} = $_[1];
}

sub IsOpen { $_[0]{status} == STATUS_OPEN or $_[0]{status} == STATUS_TOBEDELETED }

sub GetArtist
{
   return $_[0]->{artist};
}

sub SetArtist
{
   $_[0]->{artist} = $_[1];
}

sub GetYesVotes
{
   return $_[0]->{yesvotes};
}

sub SetYesVotes
{
   $_[0]->{yesvotes} = $_[1];
}

sub GetNoVotes
{
   return $_[0]->{novotes};
}

sub SetNoVotes
{
   $_[0]->{novotes} = $_[1];
}

sub GetTable
{
   return $_[0]->{table};
}

sub SetTable
{
   $_[0]->{table} = $_[1];
}

sub GetColumn
{
   return $_[0]->{column};
}

sub SetColumn
{
   $_[0]->{column} = $_[1];
}

sub GetRowId
{
   return $_[0]->{rowid};
}

sub SetRowId
{
   $_[0]->{rowid} = $_[1];
}

sub GetDepMod
{
   return $_[0]->{depmod};
}

sub SetDepMod
{
   $_[0]->{depmod} = $_[1];
}

sub GetPrev
{
   return $_[0]->{prev};
}

sub SetPrev
{
   $_[0]->{prev} = $_[1];
}

sub GetNew
{
   return $_[0]->{new};
}

sub SetNew
{
   $_[0]->{new} = $_[1];
}

sub GetVote
{
   return $_[0]->{vote};
}

sub SetVote
{
   $_[0]->{vote} = $_[1];
}

sub GetArtistName
{
   return $_[0]->{artistname};
}

sub SetArtistName
{
   $_[0]->{artistname} = $_[1];
}

sub GetModeratorName
{
   return $_[0]->{moderatorname};
}

sub SetModeratorName
{
   $_[0]->{moderatorname} = $_[1];
}

sub GetAutomod
{
   return $_[0]->{automod};
}

sub SetAutomod
{
   $_[0]->{automod} = $_[1];
}

sub GetError
{
   return $_[0]->{error};
}

sub SetError
{
   $_[0]->{error} = $_[1];
}

# TODO move this into mod handlers?
sub IsAutoModType
{
    my ($this, $type) = @_;

    if ($type == &ModDefs::MOD_EDIT_ARTISTNAME ||
        $type == &ModDefs::MOD_EDIT_ARTISTSORTNAME ||
        $type == &ModDefs::MOD_EDIT_ARTISTALIAS ||
        $type == &ModDefs::MOD_EDIT_ALBUMNAME ||
        $type == &ModDefs::MOD_EDIT_TRACKNAME ||
        $type == &ModDefs::MOD_EDIT_TRACKNUM ||
        $type == &ModDefs::MOD_ADD_TRACK ||
        $type == &ModDefs::MOD_MOVE_ALBUM ||
        $type == &ModDefs::MOD_SAC_TO_MAC ||
        $type == &ModDefs::MOD_CHANGE_TRACK_ARTIST ||
        $type == &ModDefs::MOD_MAC_TO_SAC ||
        $type == &ModDefs::MOD_ADD_ARTISTALIAS ||
        $type == &ModDefs::MOD_ADD_ALBUM ||
        $type == &ModDefs::MOD_ADD_ARTIST ||
        $type == &ModDefs::MOD_ADD_TRACK_KV ||
        $type == &ModDefs::MOD_MOVE_DISCID ||
        $type == &ModDefs::MOD_REMOVE_TRMID ||
        $type == &ModDefs::MOD_EDIT_ALBUMATTRS)
    {
        return 1;
    }
    return 0;
}

sub GetChangeName
{
   return $ChangeNames{$_[0]->{status}};
}

sub GetAutomoderationList
{
   my ($this) = @_;
   my ($type, %temp, @list);

   my $types = ModDefs->type_as_hashref;

   foreach $type (values %$types)
   {
       if ($this->IsAutoModType($type))
       {
           my $mod = $this->CreateModerationObject($type);
           $temp{$mod->Name()} = 1;
       }
   }
   @list = sort keys %temp;

   return \@list;
}

sub GetAutomoderatorList
{
   my ($this) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   return $sql->SelectSingleColumnArray("select name from moderator where privs & " .
                                        UserStuff::AUTOMOD_FLAG . " > 0 order by name");
}

# This function will load a change from the database and return
# a new ModerationXXXXXX object. Pass the rowid to load as the first arg
sub CreateFromId
{
   my ($this, $id) = @_;
   my ($mod, $query, $sql, @row);

   $query = qq/select m.id, tab, col, m.rowid, 
                      m.artist, type, prevvalue, newvalue, 
                      ExpireTime, Moderator.name, 
                      yesvotes, novotes, Artist.name, status, 0, depmod,
                      Moderator.id, m.automod,
                      opentime, closetime,
                      ExpireTime < now()
               from   moderation_all m, Moderator, Artist 
               where  Moderator.id = moderator and m.artist = 
                      Artist.id and m.id = ?/;

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query, $id))
   {
        @row = $sql->NextRow();
        $mod = $this->CreateModerationObject($row[5]);
        if (defined $mod)
        {
           $mod->SetId($row[0]);
           $mod->SetTable($row[1]);
           $mod->SetColumn($row[2]);
           $mod->SetRowId($row[3]);
           $mod->SetArtist($row[4]);
           $mod->SetType($row[5]);
           $mod->SetPrev($row[6]);
           $mod->SetNew($row[7]);
           $mod->SetExpireTime($row[8]);
           $mod->SetModeratorName($row[9]);
           $mod->SetYesVotes($row[10]);
           $mod->SetNoVotes($row[11]);
           $mod->SetArtistName($row[12]);
           $mod->SetStatus($row[13]);
           $mod->SetVote(&ModDefs::VOTE_UNKNOWN);
           $mod->SetDepMod($row[15]);
           $mod->SetModerator($row[16]);
           $mod->SetAutomod($row[17]);
           $mod->SetOpenTime($row[18]);
           $mod->SetCloseTime($row[19]);
           $mod->SetExpired($row[20]);
			$mod->PostLoad;
       }
       $sql->Finish();
   }

   return $mod;
}

# Use this function to create a new moderation object of the specified type
sub CreateModerationObject
{
	my ($this, $type) = @_;
	my $class = $this->ClassFromType($type)
		or die "Unknown moderation type $type";
	$class->new($this->{DBH});
}

# Insert a new moderation into the database.
sub InsertModeration
{
    my ($class, %opts) = @_;

	# If we're called as a nested insert, we provide the values for
	# these mandatory fields (so in this case, "type" is the only mandatory
	# field).
	if (ref $class)
	{
		$opts{DBH} = $class->{DBH};
		$opts{uid} = $class->GetModerator;
		$opts{privs} = $class->{_privs_};
	}

	# Process the required %opts keys - DBH, type, uid, privs.
	my $privs;
	my $this = do {
		my $t = $opts{'type'}
			or die "No type passed to Moderation->InsertModeration";
		my $modclass = $class->ClassFromType($t)
			or die "No such moderation type #$t";

		my $this = $modclass->new($opts{'DBH'} || die "No DBH passed");
		$this->SetType($this->Type);

		$this->SetModerator($opts{'uid'} or die "No uid passed");
		defined($privs = $opts{'privs'}) or die;

		delete @opts{qw( type DBH uid privs )};

		$this;
	};

	# Save $privs in $self so that if a nested ->InsertModeration is called,
	# we know what privs to use (see above).
	$this->{_privs_} = $privs;

	# The list of moderations inserted by this call.
	my @inserted_moderations;
	$this->{inserted_moderations} = \@inserted_moderations;

	# The PreInsert method must perform any work it needs to - e.g. inserting
	# records which maybe ->DeniedAction will delete later - and then override
	# these default column values as appropriate:
	$this->SetArtist(&ModDefs::VARTIST_ID);
	$this->SetTable("");
	$this->SetColumn("");
	$this->SetRowId(0);
	$this->SetDepMod(0);
	$this->SetPrev("");
	$this->SetNew("");
	$this->PreInsert(%opts);

	goto SUPPRESS_INSERT if $this->{suppress_insert};
	$this->PostLoad;

	# Now go on to insert the moderation record itself, and to
	# deal with automods and modpending flags.

    use DebugLog;
    if (my $d = DebugLog->open)
    {
        $d->stamp;
        $d->dumper([$this], ['this']);
        $d->dumpstring($this->{prev}, "this-prev");
        $d->dumpstring($this->{new}, "this-new");
        $d->close;
    }

    if (my $d = DebugLog->open)
    {
        $d->stamp;
        $d->dumpstring($this->{prev}, "this-prev");
        $d->dumpstring($this->{new}, "this-new");
        $d->close;
    }

    my $sql = Sql->new($this->{DBH});

    $sql->Do(
		"INSERT INTO moderation_open (
			tab, col, rowid,
			prevvalue, newvalue,
			moderator, artist, type,
			depmod,
			status, expiretime, yesvotes, novotes, automod
		) VALUES (
			?, ?, ?,
			?, ?,
			?, ?, ?,
			?,
			?, now() + interval ?, 0, 0, 0
		)",
		$this->GetTable, $this->GetColumn, $this->GetRowId,
		$this->GetPrev, $this->GetNew,
		$this->GetModerator, $this->GetArtist, $this->GetType,
		$this->GetDepMod,
		&ModDefs::STATUS_OPEN, &DBDefs::MOD_PERIOD,
	);

    my $insertid = $sql->GetLastInsertId("moderation_open");
	#print STDERR "Inserted as moderation #$insertid\n";
	$this->SetId($insertid);

    # Check to see if this moderation should get automod approval
	my $ui = UserStuff->new($this->{DBH});
	my $user_is_automod = $ui->IsAutoMod($privs);

    my $automod = $this->IsAutoMod($user_is_automod);
	$automod = 0 if $ui->IsUntrusted($privs)
		and $this->GetType != &ModDefs::MOD_ADD_TRMS;
	$automod = 1
		if not $automod
		and $user_is_automod
		and $this->IsAutoModType($this->GetType);

    # If it is automod, then approve the mod and credit the moderator
    if ($automod)
    {
        my $mod = $this->CreateFromId($insertid);
        my $status = $mod->ApprovedAction;

		$sql->Do(
			"UPDATE moderation_open SET status = ?, automod = 1 WHERE id = ?",
			$status,
			$insertid,
		);

        $this->CreditModerator($this->{moderator}, $status, $automod);
    }
    else
    {
		$this->AdjustModPending(+1);
    }

	push @inserted_moderations, $this;

SUPPRESS_INSERT:

	# Deal with any calls to ->PushModeration
	for my $opts (@{ $this->{pushed_moderations} })
	{
		# Note that we don't have to do anything with the returned
		# moderations because of the next block, about four lines down.
		$this->InsertModeration(%$opts);
	}

	# Ensure our inserted moderations get passed up to our parent,
	# if this is a nested call to ->InsertModeration.
	push @{ $class->{inserted_moderations} }, @inserted_moderations
		if ref $class;

	# Save problems with self-referencing and garbage collection
	delete $this->{inserted_moderations};

	wantarray ? @inserted_moderations : pop @inserted_moderations;
}

sub GetMaxModID
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});
	$sql->SelectSingleValue("SELECT NEXTVAL('moderation_open_id_seq')");
}

sub OpenModsByType_as_hashref
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $rows = $sql->SelectListOfLists(
		"SELECT type, COUNT(*) FROM moderation_open
		WHERE status = ".&ModDefs::STATUS_OPEN." GROUP BY type",
	);

	+{
		map { $_->[0] => $_->[1] } @$rows
	};
}

# This function returns the list of moderations to
# be shown on one moderation page.  It returns an array
# of references to Moderation objects.

sub GetModerationList
{
	my ($this, $query, $voter, $index, $num) = @_;
	$query or return SEARCHRESULT_NOQUERY;

	my $sql = Sql->new($this->{DBH});

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = " . int(DEFAULT_SEARCH_TIMEOUT*1000));

	my $ok = eval {
		local $sql->{Quiet} = 1;
		$query .= " OFFSET " . ($index||0);
		print STDERR "Executing mod SQL: $query\n";
		$sql->Select($query);
		1;
	};
	my $err = $@;

    $sql->AutoCommit;
	$sql->Do("SET SESSION STATEMENT_TIMEOUT = DEFAULT");

	if (not $ok)
	{
		if ($err =~ /query.*cancel/i)
		{
			warn "Moderation search timed out.  The query was: $query\n";
			return SEARCHRESULT_TIMEOUT;
		}

		die $err;
	}

	my @mods;

	while (@mods < $num)
	{
		my $r = $sql->NextRowHashRef
			or last;
		my $mod = $this->CreateModerationObject($r->{type});

		unless ($mod)
		{
			print STDERR "Could not create moderation object for type=$r->{type}\n";
			next;
		}

		$mod->SetId($r->{id});
		$mod->SetArtist($r->{artist});
		$mod->SetModerator($r->{moderator});
		$mod->SetTable($r->{tab});
		$mod->SetColumn($r->{col});
		$mod->SetType($r->{type});
		$mod->SetStatus($r->{status});
		$mod->SetRowId($r->{rowid});
		$mod->SetPrev($r->{prevvalue});
		$mod->SetNew($r->{newvalue});
		$mod->SetYesVotes($r->{yesvotes});
		$mod->SetNoVotes($r->{novotes});
		$mod->SetDepMod($r->{depmod});
		$mod->SetAutomod($r->{automod});
		$mod->SetOpenTime($r->{opentime});
		$mod->SetCloseTime($r->{closetime});
		$mod->SetExpireTime($r->{expiretime});

		$mod->SetExpired($r->{expired});
		$mod->SetVote($r->{vote});

		push @mods, $mod;
	}

	my $total_rows = $sql->Rows;

	$sql->Finish;

	# Fetch mod name and artist name for each mod
	my %moderator_cache;
	my %artist_cache;
	my $user = UserStuff->new($this->{DBH});
	my $artist = Artist->new($this->{DBH});
	my $vote = MusicBrainz::Server::Vote->new($this->{DBH});
	for my $mod (@mods)
	{
		# Fetch moderator name
		my $uid = $mod->GetModerator;
		$moderator_cache{$uid} = do {
			my $u = $user->newFromId($uid);
			$u ? $u->GetName : "?";
		} unless defined $moderator_cache{$uid};
		$mod->SetModeratorName($moderator_cache{$uid});

		# Fetch artist name
		my $artistid = $mod->GetArtist;
		$artist_cache{$artistid} = do {
			$artist->SetId($artistid);
			$artist->LoadFromId()
				? $artist->GetName : "?";
		} unless defined $artist_cache{$artistid};
		$mod->SetArtistName($artist_cache{$artistid});

		# Find vote
		if ($mod->GetVote == VOTE_UNKNOWN and $voter)
		{
			my $thevote = $vote->GetLatestVoteFromUser($mod->GetId, $voter);
			$mod->SetVote($thevote);
		}
	}

	$_->PostLoad for @mods;

	return (SEARCHRESULT_SUCCESS, \@mods, $index+$total_rows);
}

################################################################################

# TODO Move to UserStuff.pm (which generally handles the "moderator" table)
sub CreditModerator
{
  	my ($this, $uid, $status, $isautomod) = @_;

	my $column = (
		($status == STATUS_FAILEDVOTE)
			? "modsrejected"
			: ($status == STATUS_APPLIED)
				? ($isautomod ? "automodsaccepted" : "modsaccepted")
				: "modsfailed"
	);

 	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE moderator SET $column = $column + 1 WHERE id = ?",
		$uid,
	);
}

sub CloseModeration
{
	my ($this, $status) = @_;

	# Decrement the mod count in the data row
	$this->AdjustModPending(-1);

 	# Set the status in the Moderation row
  	my $sql = Sql->new($this->{DBH});
   	$sql->Do(
		"UPDATE moderation_open SET status = ? WHERE id = ?",
		$status,
		$this->GetId,
	);
}

sub RemoveModeration
{
   my ($this, $uid) = @_;
  
   if ($this->GetStatus() == &ModDefs::STATUS_OPEN)
   {
		# Set the status to be deleted.  The ModBot will clean it up
		# on its next pass.
		my $sql = Sql->new($this->{DBH});
		$sql->Do(
			"UPDATE moderation_open SET status = ?
			WHERE id = ? AND moderator = ? AND status = ?",
	   		&ModDefs::STATUS_TOBEDELETED,
			$this->GetId,
			$uid,
	   		&ModDefs::STATUS_OPEN,
		);
   }
}

# Links to the ModerationNote class

sub Notes
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->newFromModerationId($self->GetId);
}

sub InsertNote
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->Insert($self, @_);
}

# Links to the Vote class

sub Votes
{
	my $self = shift;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	$votes->newFromModerationId($self->GetId);
}

sub VoteFromUser
{
	my ($self, $uid) = @_;
	require MusicBrainz::Server::Vote;
	my $votes = MusicBrainz::Server::Vote->new($self->{DBH});
	# The number of votes per mod is small, so we may as well just retrieve
	# all votes for the mod, then find the one we want.
	my @votes = $votes->newFromModerationId($self->GetId);
	# Pick the most recent vote from this user
	(my $thevote) = reverse grep { $_->GetUserId == $uid } @votes;
	$thevote;
}

################################################################################
# Sub-class registration
################################################################################

{
	our %subs;

	sub RegisterHandler
	{
		my $subclass = shift;
		my $type = $subclass->Type;
		
		if (my $existing = $subs{$type})
		{
			$existing eq $subclass
				or die "$subclass and $existing both claim moderation type $type";
		}

		$subs{$type} = $subclass;
	}

	sub ClassFromType
	{
		my ($class, $type) = @_;
		$subs{$type};
	}

	sub RegisteredMods { \%subs }
}

################################################################################
# Methods which sub-classes should probably not override
################################################################################

sub Token
{
	my $self = shift;
	my $classname = ref($self) || $self;

	(my $token) = (reverse $classname) =~ /^(\w+)/;
	$token = reverse $token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Token => '$token'";
	eval "sub ${classname}::Token() { '$token' }";
	die $@ if $@;

	$token;
}

sub Type
{
	my $self = shift;
	my $classname = ref($self) || $self;

	require ModDefs;
	my $token = $self->Token;
	my $type = ModDefs->$token;

	# Cache it by turning it into a constant
	#eval "package $classname; use constant Type => $type";
	eval "sub ${classname}::Type() { $type }";
	die $@ if $@;

	$type;
}

sub GetComponent
{
	my ($self, $mason) = @_;
	my $token = $self->Token;
	$mason->fetch_comp("/comp/moderation/$token")
		or die "Failed to find Mason component for $token";
}

# This function will get called from the html pages to output the
# contents of the moderation type field
sub ShowModType
{
	my ($this, $mason) = splice(@_, 0, 2);

	use HTML::Mason::Tools qw( html_escape );

	$mason->out("
		Type:
		<span class='bold'>${\ html_escape($this->Name) }</span>
		<br>
		Artist:
		<a href='/showartist.html?artistid=${\ $this->GetArtist }'
			>${\ html_escape($this->GetArtistName) }</a>
	");
}

sub ShowPreviousValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowPreviousValue", $this, @_);
}

sub ShowNewValue
{
	my ($this, $mason) = splice(@_, 0, 2);
	my $c = $this->GetComponent($mason);
	$c->call_method("ShowNewValue", $this, @_);
}

################################################################################
# Methods which must be implemented by sub-classes
################################################################################

# (class)
# sub Name { "Remove Disc ID" }

# (instance)
# A moderation is being inserted - perform additional actions here, such as
# actually inserting.  Throw an exception if the arguments are invalid.
# Arguments: %opts, (almost) as passed to Moderation->InsertModeration
# Called in void context
# sub PreInsert;

################################################################################
# Methods intended to be overridden by moderation sub-classes
################################################################################

# PostLoad is called after an object of this class has been instantiated
# and its fields have been set via ->SetPrev, ->SetNew etc.  The class should
# then prepare any internal fields it requires, e.g. parse 'prev' and 'new'
# into various internal fields.  An exception should be thrown if appropriate,
# e.g. if 'prev' or 'new' don't parse as required.  The return value is
# ignored (this method will usually be called in void context).  The default
# action is to do nothing.
# Arguments: none
# Called in void context
sub PostLoad { }

# Should this moderation be automatically applied?  (Based on moderation type
# and data, not the moderator).
# Arguments: $user_is_automod (boolean)
# Called in boolean context; return true to automod this moderation
sub IsAutoMod { 0 }

# Adjust the appropriate "modpending" flags.  $adjust is guaranteed to be
# either +1 (add one pending mod) or -1 (subtract one).
# Arguments: $adjust (guaranteed to be either +1 or -1)
# Called in void context
sub AdjustModPending
{
	my ($this, $adjust) = @_;
	my $table = lc $this->GetTable;

	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE $table SET modpending = modpending + ? WHERE id = ?",
		$adjust,
		$this->GetRowId,
	);
}

# Check the moderation to see if it can still be applied, e.g. that all the
# prerequisites and other dependencies are still OK.  If all is well, return
# "undef".  Otherwise, return one of the "bad" STATUS_* codes (e.g.
# STATUS_FAILEDPREREQ).  You might want to add a note using
# $self->InsertNote(MODBOT_MODERATOR, $message) too.  Either way the
# transaction will be committed if possible.
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_* or undef.
sub CheckPrerequisites { undef }

# The moderation has been approved - either immediately (automod), or voted
# in.  Either throw an exception (in which case the transaction will be rolled
# back), or do whatever work is necessary and return &ModDefs::STATUS_* (in
# which case the transaction will probably be committed).
# Arguments: none
# Called in scalar context; returns &ModDefs::STATUS_*
sub ApprovedAction { () }

# The moderation is to be undone (voted down, failed a test, or was deleted)
# Arguments: none
# Called in void context
sub DeniedAction { () }

################################################################################
# Utility methods for moderation handlers
################################################################################

# If a mod handler wants to insert another moderation before itself, it just
# calls ->InsertModeration as an instance method, passing %opts as normal.  It
# doesn't need to specify the DBH, uid or privs options though.  The return
# value of ->InsertModeration can be ignored too, if you like.

# If a mod handler wants another moderation to be inserted after itself, it
# calls ->PushModeration, with the same arguments as for a nested call to
# ->InsertModeration (see above).  Nothing special is returned.
sub PushModeration
{
	my ($self, %opts) = @_;
	push @{ $self->{pushed_moderations} }, \%opts;
}

# If a mod handler wants to suppress insertion of itself (for example, maybe
# because it called ->InsertModeration or ->PushModeration to generate a
# replacement moderation), it calls ->SuppressInsert (no arguments, and no
# special return value).
sub SuppressInsert
{
	my $self = shift;
	$self->{suppress_insert} = 1;
}

sub ConvertNewToHash
{
	my ($this, $nw) = @_;
	my %kv;

	for (;;)
	{
	   	$nw =~ s/^(.*?)=(.*)$//m
			or last;
		$kv{$1} = $2;
	}

	\%kv;
}

sub ConvertHashToNew
{
	my ($this, $kv) = @_;

	my @undef_keys = grep { not defined $kv->{$_} } keys %$kv;
	carp "Uninitialized value(s) @undef_keys passed to ConvertHashToNew"
		if @undef_keys;

	join "", map {
		"$_=$kv->{$_}\n"
	} sort keys %$kv;
}

sub _normalise_strings
{
	my $this = shift;

	my @r = map {
		# Normalise to lower case
		my $t = lc decode("utf-8", $_);

		# Remove leading and trailing space
		$t =~ s/\A\s+//;
		$t =~ s/\s+\z//;

		# Compress whitespace
		$t =~ s/\s+/ /g;

		# So-called smart quotes; in reality, a backtick and an acute accent.
		# Also double-quotes and angled double quotes.
		$t =~ tr/\x{0060}\x{00B4}"\x{00AB}\x{00BB}/'/;

		# Unaccent what's left
		$t = decode("utf-8", unac_string("utf-8", encode("utf-8", $t)));

		$t;
	} @_;

	wantarray ? @r : $r[-1];
}

1;
# vi: set ts=4 sw=4 :
