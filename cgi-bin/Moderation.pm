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
use DBI;
use DBDefs;
use Track;
use Artist;
use Album;
use Insert;
use ModDefs;
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

my %ChangeNames = (
    &ModDefs::STATUS_OPEN			=> "Open",
    &ModDefs::STATUS_APPLIED		=> "Change applied",
    &ModDefs::STATUS_FAILEDVOTE		=> "Failed vote",
    &ModDefs::STATUS_FAILEDDEP		=> "Failed dependency",
    &ModDefs::STATUS_ERROR			=> "Internal error",
    &ModDefs::STATUS_FAILEDPREREQ	=> "Failed prerequisite",
    &ModDefs::STATUS_EVALNOCHANGE	=> "[Not changed]",
    &ModDefs::STATUS_TOBEDELETED	=> "To Be Deleted",
    &ModDefs::STATUS_DELETED		=> "Deleted"
);

my %VoteText = (
    &ModDefs::VOTE_UNKNOWN	=> "Unknown",
    &ModDefs::VOTE_NOTVOTED	=> "Not voted",
    &ModDefs::VOTE_ABS		=> "Abstain",
    &ModDefs::VOTE_YES		=> "Yes",
    &ModDefs::VOTE_NO		=> "No"
);

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
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

sub GetVoteText
{
   return $VoteText{$_[1]};
}

sub GetAutomoderationList
{
   my ($this) = @_;
   my ($type, %temp, @list);

   foreach $type (1..&ModDefs::MOD_LAST)
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

   $query = qq/select Moderation.id, tab, col, Moderation.rowid, 
                      Moderation.artist, type, prevvalue, newvalue, 
                      ExpireTime, Moderator.name, 
                      yesvotes, novotes, Artist.name, status, 0, depmod,
                      Moderator.id, Moderation.automod,
                      opentime, closetime,
                      ExpireTime < now()
               from   Moderation, Moderator, Artist 
               where  Moderator.id = moderator and Moderation.artist = 
                      Artist.id and Moderation.id = ?/;

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
		"INSERT INTO moderation (
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

    my $insertid = $sql->GetLastInsertId("moderation");
	#print STDERR "Inserted as moderation #$insertid\n";

    # Check to see if this moderation should get automod approval
    my $automod = $this->IsAutoMod;

	$automod ||= do {
		my $ui = UserStuff->new($this->{DBH});
		$ui->IsAutoMod($privs)
		and $this->IsAutoModType($this->GetType);
    };

    # If it is automod, then approve the mod and credit the moderator
    if ($automod)
    {
        my $mod = $this->CreateFromId($insertid);
        my $status = $mod->ApprovedAction;

		$sql->Do(
			"UPDATE moderation SET status = ?, automod = 1 WHERE id = ?",
			$status,
			$insertid,
		);

        $this->CreditModerator($this->{moderator}, 1, 0);
    }
    else
    {
		$this->AdjustModPending(+1);
    }

	$this->SetId($insertid);
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

# This function is designed to return the list of moderations to
# be shown on one moderation page. This function returns an array
# of references to Moderation objects.
# Rowid will not be defined for TYPE_NEW or TYPE_VOTED. 
# Rowid is used only for TYPE_ARTIST and TYPE_MODERATOR, and it specifies 
# the rowid of the artist/moderator for which to return moderations. 

# This function is used within GetModerationList to optimise the
# "new moderations" queries (types TYPE_NEW and TYPE_FREEDB).

sub GetMinOpenModID
{
	my $self = shift;

	use HTML::Mason::Utils 'access_data_cache';
	my $cachefile = &DBDefs::CACHE_DIR . "/OldestOpenModID";

	my $v = access_data_cache(
		cache_file => $cachefile,
		action => 'retrieve',
		busy_lock => '10sec',
	);

	return $v if defined $v;
				 
	print STDERR localtime() . " : Finding oldest open moderation\n";

	use Time::HiRes qw( gettimeofday tv_interval );
	my $t0 = [ gettimeofday ];

	my $sql = Sql->new($self->{DBH});
	$v = $sql->SelectSingleValue(
		"SELECT MIN(id) FROM moderation WHERE status = 1",
	) || 0;

	access_data_cache(
		cache_file => $cachefile,
		action => 'store',
		value => $v,
		expire_in => '1 hour',
	);

	printf STDERR "%s : Took %.2f sec to find oldest open moderation - #%d\n",
		scalar localtime,
		tv_interval($t0),
		$v;

	$v;
}

sub GetModerationList
{
   my ($this, $index, $num, $uid, $type, $rowid) = @_;
   my ($sql, @data, @row, $num_rows, $total_rows);
   my ($mod, $query, @args) = ();

   $num_rows = $total_rows = 0;
   if ($type == &ModDefs::TYPE_NEW)
   {
       $query = qq|
        SELECT  m.id, m.tab, m.col, m.rowid,
                m.artist, m.type, m.prevvalue, m.newvalue,
                m.expiretime, m.yesvotes, m.novotes, m.status,
                m.automod,
                u.id, u.name,
                a.name, m.expiretime < NOW()
        FROM    moderation m
                LEFT JOIN votes v ON v.rowid = m.id AND v.uid = ?
                INNER JOIN moderator u ON u.id = m.moderator
                INNER JOIN artist a ON a.id = m.artist
        WHERE   m.moderator NOT IN (2,?)
        AND     m.status = 1
        AND     m.id >= ?
        AND     v.vote IS NULL
        ORDER BY 1
       |;
       @args = ($uid, $uid, $this->GetMinOpenModID);
   }
   elsif ($type == &ModDefs::TYPE_MODERATOR)
   {
       $query = qq|
        SELECT  m.id, m.tab, m.col, m.rowid,
                m.artist, m.type, m.prevvalue, m.newvalue,
                m.expiretime, m.yesvotes, m.novotes, m.status,
                m.automod,
                u.id, u.name,
                a.name, m.expiretime < NOW(),
				v.vote
        FROM    moderation m
                INNER JOIN moderator u ON u.id = m.moderator
                INNER JOIN artist a ON a.id = m.artist
                LEFT JOIN votes v ON v.rowid = m.id AND v.uid = ?
        WHERE   m.moderator = ?
        ORDER BY 1 DESC
		OFFSET ?
       |;
       @args = ($uid, $rowid, $index);
   }
   elsif ($type == &ModDefs::TYPE_VOTED)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, 
                          Moderation.rowid, Moderation.artist, type, 
                          prevvalue, newvalue, ExpireTime, yesvotes, novotes, 
                          status, automod, Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, moderation.expiretime < NOW(),
                          Votes.vote
                     from Moderation, Moderator, Artist, Votes 
                    where Moderator.id = moderation.moderator and 
                          Moderation.artist = Artist.id and 
                          Votes.rowid = Moderation.id and 
                          Votes.uid = ?
                 order by 1 desc 
                          offset ?|;
	@args = ($uid, $index);
   }
   elsif ($type == &ModDefs::TYPE_ARTIST)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, 
                          Moderation.rowid, Moderation.artist, type, 
                          prevvalue, newvalue, ExpireTime, yesvotes, novotes, 
                          status, automod, Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, moderation.expiretime < NOW(),
                          Votes.vote
                     from Moderator, Artist, Moderation left join Votes 
                          on Votes.uid = ? and Votes.rowid=moderation.id 
                    where Moderator.id = moderation.moderator and 
                          Moderation.artist = Artist.id and 
                          moderation.artist = ?
                 order by 1 desc 
                          offset ?|;
	@args = ($uid, $rowid, $index);
   }
   elsif ($type == &ModDefs::TYPE_FREEDB)
   {
       $query = qq|
        SELECT  m.id, m.tab, m.col, m.rowid,
                m.artist, m.type, m.prevvalue, m.newvalue,
                m.expiretime, m.yesvotes, m.novotes, m.status,
                m.automod,
                u.id, u.name,
                a.name, m.expiretime < NOW()
        FROM    moderation m
                LEFT JOIN votes v ON v.rowid = m.id AND v.uid = ?
                INNER JOIN moderator u ON u.id = m.moderator
                INNER JOIN artist a ON a.id = m.artist
        WHERE   m.moderator = ?
        AND     m.status = 1
        AND     m.id >= ?
        AND     v.vote IS NULL
        ORDER BY 1
       |;
       @args = ($uid, &ModDefs::FREEDB_MODERATOR, $this->GetMinOpenModID);
   }
   elsif ($type == &ModDefs::TYPE_ALBUM)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, 
                          Moderation.rowid, Moderation.artist, type, 
                          prevvalue, newvalue, ExpireTime, yesvotes, novotes, 
                          status, automod, Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, moderation.expiretime < NOW(),
                          Votes.vote
                     from Moderator, Artist, Moderation left join Votes 
                          on Votes.uid = ? and Votes.rowid=moderation.id 
                    where Moderator.id = moderation.moderator and 
                          Moderation.artist = Artist.id and
						  Moderation.rowid = ? and
						  LOWER(Moderation.tab) = 'album'
                          offset ?|;
	@args = ($uid, $rowid, $index);
   }
   elsif ($type == &ModDefs::TYPE_MODERATOR_FAILED)
   {
       $query = qq|
        SELECT  m.id, m.tab, m.col, m.rowid,
                m.artist, m.type, m.prevvalue, m.newvalue,
                m.expiretime, m.yesvotes, m.novotes, m.status,
                m.automod,
                u.id, u.name,
                a.name, m.expiretime < NOW(),
				v.vote
        FROM    moderation m
                INNER JOIN moderator u ON u.id = m.moderator
                INNER JOIN artist a ON a.id = m.artist
                LEFT JOIN votes v ON v.rowid = m.id AND v.uid = ?
        WHERE   m.moderator = ?
              AND   m.status IN (|
		. join(",",
			&ModDefs::STATUS_FAILEDVOTE,
			&ModDefs::STATUS_FAILEDDEP,
			&ModDefs::STATUS_FAILEDPREREQ,
		) . qq|)
        ORDER BY 1 DESC
		OFFSET ?
        |;
       @args = ($uid, $rowid, $index);
   }
   else
   {
       return undef;
   }

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query, @args))
   {
        $total_rows = $sql->Rows();
        for($num_rows = 0; $num_rows < $num; $num_rows++)
        {
            last if not @row = $sql->NextRow();
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
                $mod->SetYesVotes($row[9]);
                $mod->SetNoVotes($row[10]);
                $mod->SetStatus($row[11]);
                $mod->SetAutomod($row[12]);
                $mod->SetModerator($row[13]);
                $mod->SetModeratorName($row[14]);
                $mod->SetArtistName($row[15]);
			    $mod->SetExpired($row[16]);
                if (defined $row[17])
                {
                    $mod->SetVote($row[17]);
                }
                else
                {
                    $mod->SetVote(&ModDefs::VOTE_NOTVOTED);
                }
				$mod->PostLoad;
                push @data, $mod;
            }
            else
            {
                print STDERR "Could not create Moderation list ($row[5])\n";
            }
        }
        $sql->Finish;
   }

   return ($num_rows, $total_rows, @data);
}

# TODO make a separate "vote" class

# This function enters a number of votes into the Votes table.
# The caller must a hash of votes, where the keys are the moderation IDs,
# and the values are the VOTE_* constants.
sub InsertVotes
{
	my ($this, $uid, $votes) = @_;
	my $sql = Sql->new($this->{DBH});

	while (my ($modid, $vote) = each %$votes)
	{
	   	next if $this->DoesVoteExist($uid, $modid);
		$this->InsertVote($uid, $modid, $vote);
	}
}

sub DoesVoteExist
{
	my ($this, $uid, $id) = @_;
	my $sql = Sql->new($this->{DBH});

	$sql->SelectSingleValue(
		"SELECT id FROM votes WHERE uid = ? AND rowid = ?",
		$uid, $id,
	);
}

sub InsertVote
{
	my ($this, $uid, $id, $vote) = @_;
	my $sql = Sql->new($this->{DBH});

	my $status = $sql->SelectSingleValue(
		"SELECT status FROM moderation WHERE id = ?",
		$id,
	);

	$status == &ModDefs::STATUS_OPEN
		or return;

	$sql->Do(
		"INSERT INTO votes (uid, rowid, vote) VALUES (?, ?, ?)",
		$uid, $id, $vote,
	);

	$sql->Do("UPDATE moderation SET yesvotes = yesvotes + 1 WHERE id = ?", $id)
		if $vote == &ModDefs::VOTE_YES;
	$sql->Do("UPDATE moderation SET novotes = novotes + 1 WHERE id = ?", $id)
		if $vote == &ModDefs::VOTE_NO;
}

# Go through the Moderation table and evaluate open Moderations
# This is "the modbot!"

sub CheckModerations
{
   my ($this) = @_;
   my ($sql, $query, $rowid, @row, $status, $dep_status, $mod); 
   my (%mods, $now, $key);

   if (&DBDefs::DB_READ_ONLY)
   {
	   print "ModBot bailing out because DB_READ_ONLY is set\n";
	   return;
   }

   $sql = Sql->new($this->{DBH});
   $query = qq|select id from Moderation where status = | . 
               &ModDefs::STATUS_OPEN . qq| or status = | .
               &ModDefs::STATUS_TOBEDELETED . qq| order by Moderation.id|;
   return if (!$sql->Select($query));

   $now = time();
   while(@row = $sql->NextRow())
   {
       $mod = $this->CreateFromId($row[0]);
       if (!defined $mod)
       {
           print STDERR "Cannot create moderation $row[0]. This " .
                        "moderation will remain open.\n";
           next;
       }

       # Save the loaded modules for later
       $mod->{__eval__} = $mod->GetStatus();
       $mods{$row[0]} = $mod;

       print STDERR "\nEvaluate Mod: " . $mod->GetId() . "\n";

       # See if this mod has been marked for deletion
       if ($mod->GetStatus() == &ModDefs::STATUS_TOBEDELETED)
       {
           # Change the status to deleted. 
           print STDERR "EvalChange: $mod->{id} to be deleted\n";
           $mod->{__eval__} = &ModDefs::STATUS_DELETED;
           next;
       }

       # See if a KeyValue mod is pending for this.
       if ($this->CheckModificationForFailedDependencies($mod, \%mods) == 0)
       {
           print STDERR "EvalChange: kv dep failed\n";
           # If the prereq. change failed, close this modification
           $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
           next;
       }

       # Check to see if this change has another change that it depends on
       if (defined $mod->GetDepMod() && $mod->GetDepMod() > 0)
       {
           my $depmod;

           # Get the status of the dependent change. Since all open mods
           # have been loaded (or in this case, all preceding mods have
           # already been loaded) check to see if the dep mod around.
           # If not, its been closed. If so, check its status directly.
           $depmod = $mods{$mod->GetDepMod()};
           if (defined $depmod)
           {
              print STDERR "DepMod status: " . $depmod->{__eval__} . "\n";
              # We have the dependant change in memory
              if ($depmod->{__eval__} == &ModDefs::STATUS_OPEN ||
                  $depmod->{__eval__} == &ModDefs::STATUS_EVALNOCHANGE)
              {
                  print STDERR "EvalChange: Memory dep still open\n";

                  # If the prereq. change is still open, skip this change 
                  $mod->{__eval__} = &ModDefs::STATUS_EVALNOCHANGE;
                  next;
              }
              elsif ($depmod->{__eval__} != &ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Memory dep failed\n";
                  $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
                  next;
              }
           }
           else
           {
              # If we can't find it, we need to load the status by hand.
              $dep_status = $this->GetModerationStatus($mod->GetDepMod());
              if ($dep_status != &ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Disk dep failed\n";
                  # The depedent moderation had failed. Fail this one.
                  $mod->{__eval__} = &ModDefs::STATUS_FAILEDPREREQ;
                  next;
              }
           }
       }

       # Has the vote period expired and there have been votes?
       if ($mod->GetExpired() &&
          ($mod->GetYesVotes() > 0 || $mod->GetNoVotes() > 0))
       {
           # Are there more yes votes than no votes?
           if ($mod->GetYesVotes() <= $mod->GetNoVotes())
           {
               #print STDERR "EvalChange: expire and voted down\n";
               $mod->{__eval__} = &ModDefs::STATUS_FAILEDVOTE;
               next;
           }
           print STDERR "EvalChange: expire and approved\n";
           $mod->{__eval__} = &ModDefs::STATUS_APPLIED;
           next;
       }

       # Are the number of required unanimous votes present?
       if ($mod->GetYesVotes() >= &DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetNoVotes() == 0)
       {
           print STDERR "EvalChange: unanimous yes\n";
           # A unanimous yes. 
           $mod->{__eval__} = &ModDefs::STATUS_APPLIED;
           next;
       }

       if ($mod->GetNoVotes() >= &DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetYesVotes() == 0)
       {
           print STDERR "EvalChange: unanimous no\n";
           # A unanimous no. R
           $mod->{__eval__} = &ModDefs::STATUS_FAILEDVOTE;
           next;
       }
       print STDERR "EvalChange: no change\n";

       # No condition for this moderation triggered. Leave it alone
       $mod->{__eval__} = &ModDefs::STATUS_EVALNOCHANGE;
   }
   $sql->Finish;

   foreach $key (reverse sort { $a <=> $b} keys %mods)
   {
       print STDERR "Check mod: $key\n";
       $mod = $mods{$key};
       next if ($mod->{__eval__} == &ModDefs::STATUS_EVALNOCHANGE);

       if ($mod->{__eval__} == &ModDefs::STATUS_APPLIED)
       {
           print STDERR "Mod " . $mod->GetId() . " applied\n";
           eval
           {
               my $status;

               $sql->Begin;

               $status = $mod->ApprovedAction;
               $mod->SetStatus($status);
               $mod->CreditModerator($mod->GetModerator(), 1, 0);
               $mod->CloseModeration($status);

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
       elsif ($mod->{__eval__} == &ModDefs::STATUS_DELETED)
       {
           print STDERR "Mod " . $mod->GetId() . " deleted\n";
           eval
           {
               $sql->Begin;

               $mod->SetStatus(&ModDefs::STATUS_DELETED);
               $mod->DeniedAction;
               $mod->CloseModeration($mod->{__eval__});

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
       else
       {
           print STDERR "Mod " . $mod->GetId() . " denied\n";
           eval
           {
               $sql->Begin;

               $mod->DeniedAction;
               $mod->CreditModerator($mod->GetModerator, 0, 1);
               $mod->CloseModeration($mod->{__eval__});

               $sql->Commit;
           };
           if ($@)
           {
               my $err = $@;
               $sql->Rollback;

               print STDERR "CheckModsError: Moderation commit failed -- mod " . 
                            $mod->GetId . " will remain open.\n($err)\n";
           }
       }
   }
}

# Check a given moderation for any dependecies that may have not been met
sub CheckModificationForFailedDependencies
{
   my ($this, $mod, $modhash) = @_;
   my ($sql, $status, $i, $depmod); 

   $sql = Sql->new($this->{DBH});
   for($i = 0;; $i++)
   {
       # FIXME this regex looks too slack for my liking
       if ($mod->GetNew() =~ m/Dep$i=(.*)/m)
       {
           #print STDERR "Mod: " . $mod->GetId() . " depmod: $1\n";
           $depmod = $modhash->{$1};
           if (defined $depmod)
           {
              $status = $depmod->{__eval__};
           }
           else
           {
              ($status) = $sql->GetSingleRow("Moderation", ["status"], ["id", $1]);
           }
           if (!defined $status || 
               $status == &ModDefs::STATUS_FAILEDVOTE ||
               $status == &ModDefs::STATUS_FAILEDDEP ||
               $status == &ModDefs::STATUS_DELETED)
           {
              return 0;
           }
       }
       else
       {
           last;
       }
   }
    
   return 1;
}

sub GetModerationStatus
{
 	my ($this, $id) = @_;
	my $sql = Sql->new($this->{DBH});

	my $status = $sql->SelectSingleValue(
		"SELECT status FROM moderation WHERE id = ?",
		$id,
	);

	defined($status) ? $status : &ModDefs::STATUS_ERROR;
}

# TODO Move to UserStuff.pm (which generally handles the "moderator" table)
sub CreditModerator
{
  	my ($this, $uid, $accepts, $rejects) = @_;

 	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE moderator
		SET modsaccepted = modsaccepted + ?,
		modsrejected = modsrejected + ?
		WHERE ID = ?",
		$accepts,
		$rejects,
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
		"UPDATE moderation SET status = ? WHERE id = ?",
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
			"UPDATE moderation SET status = ?
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
	$notes->newFromModerationID($self->GetId);
}

sub InsertNote
{
	my $self = shift;
	require MusicBrainz::Server::ModerationNote;
	my $notes = MusicBrainz::Server::ModerationNote->new($self->{DBH});
	$notes->Insert($self, @_);
}

# TODO Move to vote class

sub GetUserVote
{
	my ($this, $uid) = @_;
	my $sql = Sql->new($this->{DBH});
   
	$sql->SelectSingleValue(
		"SELECT vote FROM votes WHERE uid = ? AND rowid = ?",
		$uid,
		$this->GetId,
	);
}

sub GetVoterList
{
    my ($this) = @_;
	my $sql = Sql->new($this->{DBH});

	my $data = $sql->SelectListOfHashes(
		"SELECT	v.vote, u.id AS modid, u.name AS moderator
		FROM	votes v, moderator u
		WHERE	v.rowid = ?
		AND		v.uid = u.id
		ORDER BY v.id",
		$this->GetId,
	);

	@$data;
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
# Arguments: none
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
# Hook points which are becoming obsolete
################################################################################

# PreVoteAction
# DetermineDependencies

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
