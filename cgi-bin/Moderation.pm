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
use ModerationSimple;
use ModerationKeyValue;
use Data::Dumper;
use Text::Unaccent;
use Encode qw( decode );
use utf8;

my %ModNames = (
    "1" => "Edit Artist Name",
    "2" => "Edit Artist Sortname",
    "3" => "Edit Album Name",
    "4" => "Edit Track Name",
    "5" => "Edit Track Number",
    "6" => "Merge Artist",
    "7" => "Add Track",  
    "8" => "Move Album",
    "9" => "Convert to Multiple Artists",
    "10" => "Change Track Artist",
    "11" => "Remove Track",
    "12" => "Remove Album",
    "13" => "Convert to Single Artist",
    "14" => "Remove Artist Alias",
    "15" => "Add Artist Alias",
    "16" => "Add Album",
    "17" => "Add Artist",
    "18" => "Add Track",
    "19" => "Remove Artist",
    "20" => "Remove Discid",
    "21" => "Move Discid",
    "22" => "Remove TRM id",
    "23" => "Merge Albums",
    "24" => "Remove Albums",
    "25" => "Merge into Various Artist Album",
    "26" => "Edit Album Attributes",
    "27" => "Add TRM Ids"
);

my %ChangeNames = (
    "1" => "Open",
    "2" => "Change applied",
    "3" => "Failed vote",
    "4" => "Failed dependency",
    "5" => "Internal error",
    "6" => "Failed prerequisite",
    "7" => "[Not changed]",
    "8" => "To Be Deleted",
    "9" => "Deleted"
);

my %VoteText = (
    "-3" => "Unknown",
    "-2" => "Not voted",
    "-1" => "Abstain",
    "1" => "Yes",
    "0" => "No"
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

sub IsNumber
{
    if ($_[0] =~ m/\A-?[0-9]*\.?[0-9]*\z/)
    {
        return 1;
    }
    else 
    {
        return 0;
    }
}

sub IsAutoModType
{
    my ($this, $type) = @_;

    if ($type == ModDefs::MOD_EDIT_ARTISTNAME ||
        $type == ModDefs::MOD_EDIT_ARTISTSORTNAME ||
        $type == ModDefs::MOD_EDIT_ALBUMNAME ||
        $type == ModDefs::MOD_EDIT_TRACKNAME ||
        $type == ModDefs::MOD_EDIT_TRACKNUM ||
        $type == ModDefs::MOD_ADD_TRACK ||
        $type == ModDefs::MOD_MOVE_ALBUM ||
        $type == ModDefs::MOD_SAC_TO_MAC ||
        $type == ModDefs::MOD_CHANGE_TRACK_ARTIST ||
        $type == ModDefs::MOD_MAC_TO_SAC ||
        $type == ModDefs::MOD_ADD_ARTISTALIAS ||
        $type == ModDefs::MOD_ADD_ALBUM ||
        $type == ModDefs::MOD_ADD_ARTIST ||
        $type == ModDefs::MOD_ADD_TRACK_KV ||
        $type == ModDefs::MOD_MOVE_DISCID ||
        $type == ModDefs::MOD_REMOVE_TRMID ||
        $type == ModDefs::MOD_EDIT_ALBUMATTRS ||
        $type == ModDefs::MOD_ADD_TRMS)
    {
        return 1;
    }
    return 0;
}

sub GetModificationName
{
   return $ModNames{$_[1]};
}

sub GetChangeName
{
   return $ChangeNames{$_[0]->{status}};
}

sub GetVoteText
{
   return $VoteText{$_[1]};
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
                      Artist.id and Moderation.id = $id/;

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
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
           $mod->SetVote(ModDefs::VOTE_UNKNOWN);
           $mod->SetDepMod($row[15]);
           $mod->SetModerator($row[16]);
           $mod->SetAutomod($row[17]);
           $mod->SetOpenTime($row[18]);
           $mod->SetCloseTime($row[19]);
           $mod->SetExpired($row[20]);
       }
       $sql->Finish();
   }

   return $mod;
}

# Use this function to create a new moderation object of the specified type
sub CreateModerationObject
{
   my ($this, $type) = @_;

   if ($type == ModDefs::MOD_EDIT_ARTISTNAME || 
       $type == ModDefs::MOD_EDIT_ARTISTSORTNAME ||
       $type == ModDefs::MOD_EDIT_ALBUMNAME  || 
       $type == ModDefs::MOD_EDIT_TRACKNAME ||
       $type == ModDefs::MOD_EDIT_TRACKNUM)
   {
       return EditModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_MERGE_ARTIST)
   {
       return MergeArtistModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_TRACK)
   {
       return AddTrackModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_TRACK_KV)
   {
       return AddTrackModerationKV->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_ARTISTALIAS)
   {
       return AddArtistAliasModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_MOVE_ALBUM || $type == ModDefs::MOD_MAC_TO_SAC)
   {
       return MoveAlbumModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_CHANGE_TRACK_ARTIST)
   {
       return ChangeTrackArtistModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_SAC_TO_MAC)
   {
       return SACToMACModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_TRACK)
   {
       return RemoveTrackModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_ALBUM)
   {
       return RemoveAlbumModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_ARTISTALIAS)
   {
       return RemoveArtistAliasModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_ALBUM)
   {
       return AddAlbumModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_ARTIST)
   {
       return AddArtistModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_ARTIST)
   {
       return RemoveArtistModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_DISCID)
   {
       return RemoveDiscidModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_MOVE_DISCID)
   {
       return MoveDiscidModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_TRMID)
   {
       return RemoveTRMIdModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_MERGE_ALBUM ||
          $type == ModDefs::MOD_MERGE_ALBUM_MAC)
   {
       return MergeAlbumModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_REMOVE_ALBUMS)
   {
       return RemoveAlbumsModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_EDIT_ALBUMATTRS)
   {
       return EditAlbumAttributesModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_ADD_TRMS)
   {
       return AddTRMIdModeration->new($this->{DBH});
   }

   print STDERR "Undefined moderation type $type.\n";

   return undef;
}

# Insert a new moderation into the database. All of the values to be
# inserted are read from the internal hash -- use the above accessor
# functions to set the data to be inserted
sub InsertModeration
{
    my ($this, $privs) = @_;
    my ($table, $column, $prev, $new);
    my ($sql, $ui, $insertid, $automod);

    use DebugLog;
    if (my $d = DebugLog->open)
    {
	$d->stamp;
	$d->dumper([$this], ['this']);
	$d->dumpstring($this->{prev}, "this-prev");
	$d->dumpstring($this->{new}, "this-new");
	$d->close;
    }

    $automod = 0;
    $this->CheckSpecialCases();

    $sql = Sql->new($this->{DBH});
    $ui = UserStuff->new($this->{DBH});

    if (my $d = DebugLog->open)
    {
	$d->stamp;
	$d->dumpstring($this->{prev}, "this-prev");
	$d->dumpstring($this->{new}, "this-new");
	$d->close;
    }

    $table = $sql->Quote($this->{table});
    $column = $sql->Quote($this->{column});
    $prev = $sql->Quote($this->{prev});
    $new = $sql->Quote($this->{new});

    if (my $d = DebugLog->open)
    {
	$d->stamp;
	$d->dumper([$prev, $new], ['prev', 'new']);
	$d->close;
    }

    $sql->Do(qq|insert into Moderation (tab, col, rowid, prevvalue, 
                            newvalue, expiretime, moderator, yesvotes, 
                            novotes, artist, type, status, depmod, automod) 
                     values ($table, $column, $this->{rowid}, $prev, $new, 
                            now() + interval '| . DBDefs::MOD_PERIOD . qq|', 
                            $this->{moderator}, 0, 0, $this->{artist}, 
                            $this->{type}, | .  ModDefs::STATUS_OPEN . qq|,
                            $this->{depmod}, 0)|);
    $insertid = $sql->GetLastInsertId("Moderation");

    # Check to see if this moderaton should get automod approval
    if ($this->IsAutoModType($this->GetType()) && 
        defined $privs && $ui->IsAutoMod($privs))
    {
        $automod = 1;
    }
    else
    {
        if ($this->GetType() == ModDefs::MOD_EDIT_ARTISTNAME ||
            $this->GetType() == ModDefs::MOD_EDIT_ARTISTSORTNAME ||
            $this->GetType() == ModDefs::MOD_EDIT_ALBUMNAME ||
            $this->GetType() == ModDefs::MOD_EDIT_TRACKNAME)
        {
	    my $old = uc decode("utf-8", unac_string("utf-8", $this->GetPrev));
	    my $new = uc decode("utf-8", unac_string("utf-8", $this->GetNew));
            $automod = 1 if $old eq $new;
        }
        elsif ($this->GetType() == ModDefs::MOD_ADD_TRMS)
        {
            $automod = 1;
        }
    }

    # If it is automod, then approve the mod and credit the moderator
    if ($automod)
    {
        my ($mod, $status);

        $mod = $this->CreateFromId($insertid);
        $status = $mod->ApprovedAction($mod->GetRowId());
        $sql->Do(qq|update Moderation set status = $status, automod = 1
                    where id = $insertid|);
        $this->CreditModerator($this->{moderator}, 1);
    }
    else
    {
        # Not automoded, so set the modpending flags
        if ($this->{table} ne 'TRMJoin')
        {
            if ($this->{table} eq 'Album' && $this->{column} eq 'Attributes')
            {
                $sql->Do(qq/update $this->{table} set attributes[1] = 
                            attributes[1] + 1 where id = $this->{rowid}/);
            }
            else
            {
                $sql->Do(qq/update $this->{table} set modpending = 
                            modpending + 1 where id = $this->{rowid}/);
            }
        }
    }

    return $insertid;
}

# Some modifications need to get changed before being inserted into
# the database. For instance, if an artist edit ends up clashing with
# and existing artist, then the moderation needs to get changed to a
# merge artist moderation
sub CheckSpecialCases
{
    my ($this) = @_;

    if ($this->{type} == ModDefs::MOD_EDIT_ARTISTNAME)
    {
        my $ar;

        # Check to see if we already have the artist that we're supposed
        # to edit to. If so, change this mod to a MERGE_ARTISTNAME.
        $ar = Artist->new($this->{DBH});
        if ($ar->LoadFromName($this->{new}))
        {
            if ($this->{artist} != $ar->GetId())
            {
                $this->{type} = ModDefs::MOD_MERGE_ARTIST;
            }
        }
    }
}

# This function is designed to return the list of moderations to
# be shown on one moderation page. This function returns an array
# of references to Moderation objects.
# Rowid will not be defined for TYPE_NEW, TYPE_MINE or TYPE_VOTED. 
# rowid is used only for TYPE_ARTIST and TYPE_ALBUM , and it specifies 
# the rowid of the artist/album for which to return moderations. 
sub GetModerationList
{
   my ($this, $index, $num, $uid, $type, $rowid) = @_;
   my ($sql, @data, @row, $num_rows, $total_rows);
   my ($mod, $query, @args) = ();

   $num_rows = $total_rows = 0;
   if ($type == ModDefs::TYPE_NEW)
   {
       $query = qq|
	SELECT  m.id, m.tab, m.col, m.rowid,
		m.artist, m.type, m.prevvalue, m.newvalue,
		m.expiretime, m.yesvotes, m.novotes, m.status,
		m.automod,
		u.id, u.name,
		a.name
	FROM	moderation m
		LEFT JOIN votes v ON v.rowid = m.id AND v.uid = ?
		INNER JOIN moderator u ON u.id = m.moderator
		INNER JOIN artist a ON a.id = m.artist
	WHERE	m.moderator NOT IN (2,?)
	AND	m.status = 1
	AND	v.vote IS NULL
	ORDER BY 1
	LIMIT $num
       |;
       @args = ($uid, $uid);
   }
   elsif ($type == ModDefs::TYPE_MINE)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, rowid, 
                          Moderation.artist, type, prevvalue, newvalue, 
                          ExpireTime, yesvotes, novotes, status, automod,
                          Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, | .
                          ModDefs::VOTE_NOTVOTED . qq|
                     from Moderation, Moderator, Artist 
                    where Moderator.id = moderator and 
                          Moderation.artist = Artist.id and 
                          moderator = $uid 
                 order by ExpireTime desc 
                          offset $index|;
   }
   elsif ($type == ModDefs::TYPE_VOTED)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, 
                          Moderation.rowid, Moderation.artist, type, 
                          prevvalue, newvalue, ExpireTime, yesvotes, novotes, 
                          status, automod, Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, 
                          Votes.vote
                     from Moderation, Moderator, Artist, Votes 
                    where Moderator.id = moderation.moderator and 
                          Moderation.artist = Artist.id and 
                          Votes.rowid = Moderation.id and 
                          Votes.uid = $uid
                 order by ExpireTime desc 
                          offset $index|;
   }
   elsif ($type == ModDefs::TYPE_ARTIST)
   {
       $query = qq|select Moderation.id as moderation_id, tab, col, 
                          Moderation.rowid, Moderation.artist, type, 
                          prevvalue, newvalue, ExpireTime, yesvotes, novotes, 
                          status, automod, Moderator.id as moderator_id, 
                          Moderator.name as moderator_name, 
                          Artist.name as artist_name, 
                          Votes.vote
                     from Moderator, Artist, Moderation left join Votes 
                          on Votes.uid = $uid and Votes.rowid=moderation.id 
                    where Moderator.id = moderation.moderator and 
                          Moderation.artist = Artist.id and 
                          moderation.artist = $rowid
                 order by ExpireTime desc 
                          offset $index|;
   }
   elsif ($type == ModDefs::TYPE_FREEDB)
   {
       $query = qq|select open_moderations_freedb.* 
                     from open_moderations_freedb left join votes 
                          on Votes.uid = $uid and Votes.rowid=moderation_id 
                    where moderator_id = | . ModDefs::FREEDB_MODERATOR . qq| 
                 group by moderation_id, moderator_id, moderator_name, tab, 
                          col, open_moderations_freedb.rowid, 
                          open_moderations_freedb.artist,
                          type, prevvalue, newvalue, expiretime, yesvotes, 
                          novotes, status, automod, artist_name, votes.id, 
                          votes.uid, votes.rowid, votes.vote 
                   having count(Votes.id) < 1|;
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
                if (defined $row[16])
                {
                    $mod->SetVote($row[16]);
                }
                else
                {
                    $mod->SetVote(ModDefs::VOTE_NOTVOTED);
                }
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

# This function will get called from the html pages to output the
# contents of the moderation type field
sub ShowModType
{
   my ($this) = @_;
   my ($out, $type);

   $type = $this->GetType();
   $out = 'Type: <span class="bold">' . $this->GetModificationName($type) . 
          qq\<span> <br>Artist: <a href="/showartist.html?artistid=$this->{artist}">$this->{artistname}</a>\;
   
   return $out;
}

# This function enters a number of votes into the Votes table.
# The caller must supply three lists of ids in the Moderation table:
# The list of moderations that the user votes yes on, the no list
# and the abstain list
sub InsertVotes
{
   my ($this, $uid, $yeslist, $nolist, $abslist) = @_;
   my ($val, $sql);

   $sql = Sql->new($this->{DBH});
   foreach $val (@{$yeslist})
   {
      next if ($this->DoesVoteExist($uid, $val));
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 1)/); 
      $sql->Do(qq/update Moderation set yesvotes = yesvotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$nolist})
   {
      next if ($this->DoesVoteExist($uid, $val));
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 0)/); 
      $sql->Do(qq/update Moderation set novotes = novotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$abslist})
   {
      next if ($this->DoesVoteExist($uid, $val));
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                       ($uid, $val, -1)/); 
   }
}

sub DoesVoteExist
{
   my ($this, $uid, $id) = @_;
   my ($val, $sql);

   $sql = Sql->new($this->{DBH});

   ($id) = $sql->GetSingleRow("Votes", ["id"], 
                              ["uid", $uid, "rowid", $id]);

   return defined($id) ? 1 : 0;
}   

# Go through the Moderation table and evaluate open Moderations
sub CheckModerations
{
   my ($this) = @_;
   my ($sql, $query, $rowid, @row, $status, $dep_status, $mod); 
   my (%mods, $now, $key);

   $sql = Sql->new($this->{DBH});
   $query = qq|select id from Moderation where status = | . 
               ModDefs::STATUS_OPEN . qq| or status = | .
               ModDefs::STATUS_TOBEDELETED . qq| order by Moderation.id|;
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
       if ($mod->GetStatus() == ModDefs::STATUS_TOBEDELETED)
       {
           # Change the status to deleted. 
           print STDERR "EvalChange: $mod->{id} to be deleted\n";
           $mod->{__eval__} = ModDefs::STATUS_DELETED;
           next;
       }

       # See if a KeyValue mod is pending for this.
       if ($this->CheckModificationForFailedDependencies($mod, \%mods) == 0)
       {
           print STDERR "EvalChange: kv dep failed\n";
           # If the prereq. change failed, close this modification
           $mod->{__eval__} = ModDefs::STATUS_FAILEDPREREQ;
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
              if ($depmod->{__eval__} == ModDefs::STATUS_OPEN ||
                  $depmod->{__eval__} == ModDefs::STATUS_EVALNOCHANGE)
              {
                  print STDERR "EvalChange: Memory dep still open\n";

                  # If the prereq. change is still open, skip this change 
                  $mod->{__eval__} = ModDefs::STATUS_EVALNOCHANGE;
                  next;
              }
              elsif ($depmod->{__eval__} != ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Memory dep failed\n";
                  $mod->{__eval__} = ModDefs::STATUS_FAILEDPREREQ;
                  next;
              }
           }
           else
           {
              # If we can't find it, we need to load the status by hand.
              $dep_status = $this->GetModerationStatus($mod->GetDepMod());
              if ($dep_status != ModDefs::STATUS_APPLIED)
              {
                  print STDERR "EvalChange: Disk dep failed\n";
                  # The depedent moderation had failed. Fail this one.
                  $mod->{__eval__} = ModDefs::STATUS_FAILEDPREREQ;
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
               $mod->{__eval__} = ModDefs::STATUS_FAILEDVOTE;
               next;
           }
           print STDERR "EvalChange: expire and approved\n";
           $mod->{__eval__} = ModDefs::STATUS_APPLIED;
           next;
       }

       # Are the number of required unanimous votes present?
       if ($mod->GetYesVotes() == DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetNoVotes() == 0)
       {
           print STDERR "EvalChange: unanimous yes\n";
           # A unanimous yes. 
           $mod->{__eval__} = ModDefs::STATUS_APPLIED;
           next;
       }

       if ($mod->GetNoVotes() == DBDefs::NUM_UNANIMOUS_VOTES && 
           $mod->GetYesVotes() == 0)
       {
           print STDERR "EvalChange: unanimous no\n";
           # A unanimous no. R
           $mod->{__eval__} = ModDefs::STATUS_FAILEDVOTE;
           next;
       }
       print STDERR "EvalChange: no change\n";

       # No condition for this moderation triggered. Leave it alone
       $mod->{__eval__} = ModDefs::STATUS_EVALNOCHANGE;
   }
   $sql->Finish;

   foreach $key (reverse sort { $a <=> $b} keys %mods)
   {
       print STDERR "Check mod: $key\n";
       $mod = $mods{$key};
       next if ($mod->{__eval__} == ModDefs::STATUS_EVALNOCHANGE);

       if ($mod->{__eval__} == ModDefs::STATUS_APPLIED)
       {
           print STDERR "Mod " . $mod->GetId() . " applied\n";
           eval
           {
               my $status;

               $sql->Begin;

               $status = $mod->ApprovedAction($mod->GetRowId());
               $mod->SetStatus($status);
               $mod->CreditModerator($mod->GetModerator(), 1);
               $mod->CloseModeration($mod->GetId(), $mod->GetTable(), 
                                     $mod->GetRowId(), $status);

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
       elsif ($mod->{__eval__} == ModDefs::STATUS_DELETED)
       {
           print STDERR "Mod " . $mod->GetId() . " deleted\n";
           eval
           {
               $sql->Begin;

               $mod->SetStatus(ModDefs::STATUS_DELETED);
               $mod->DeniedAction();
               $mod->CloseModeration($mod->GetId(), $mod->GetTable(), 
                                     $mod->GetRowId(), $mod->{__eval__});

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

               $mod->DeniedAction();
               $mod->CreditModerator($mod->GetModerator(), 0);
               $mod->CloseModeration($mod->GetId(), $mod->GetTable(), 
                                     $mod->GetRowId(), $mod->{__eval__});

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
               $status == ModDefs::STATUS_FAILEDVOTE ||
               $status == ModDefs::STATUS_FAILEDDEP ||
               $status == ModDefs::STATUS_DELETED)
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
   my ($sql, @row, $ret); 

   $ret = ModDefs::STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   ($ret) = $sql->GetSingleRow("Moderation", ["status"], ["id", $id]);

   return $ret;
}

sub CreditModerator
{
   my ($this, $uid, $yes) = @_;

   my $sql = Sql->new($this->{DBH});
   if ($yes)
   {
       $sql->Do(qq/update Moderator set 
                   modsaccepted = modsaccepted+1 where id = $uid/);
   }
   else
   {
       $sql->Do(qq/update Moderator set 
                   modsrejected = modsrejected+1 where id = $uid/);
   }
}

sub CloseModeration
{
   my ($this, $rowid, $table, $datarowid, $status) = @_;

   my $sql = Sql->new($this->{DBH});

   # Decrement the mod count in the data row
   if ($this->{table} ne 'TRMJoin')
   {
       if ($this->{table} eq 'Album' && $this->{column} eq 'Attributes')
       {
           $sql->Do(qq/update $this->{table} set attributes[1] = 
                       attributes[1] - 1 where id = $datarowid/);
       }
       else
       {
           $sql->Do(qq/update $table set modpending = modpending - 1
                              where id = $datarowid/);
       }
   }

   # Set the status in the Moderation row
   $sql->Do(qq/update Moderation set status = $status where id = $rowid/);
}

sub RemoveModeration
{
   my ($this) = @_;
  
   if ($this->GetStatus() == ModDefs::STATUS_OPEN)
   {
       # Set the status to be deleted. THe ModBot will clean it up
       # on its next pass.
       my $sql = Sql->new($this->{DBH});
       $sql->Do(qq|update Moderation set status = | . 
                   ModDefs::STATUS_TOBEDELETED . 
                qq| where id = | . $this->GetId());
   }
}

sub ConvertNewToHash
{
   my ($this, $nw) = @_;
   my %kv;

   for(;;)
   {
      if ($nw =~ s/^(.*?)=(.*)$//m)
      {
          $kv{$1} = $2;
      }
      else
      {
          last;
      }
   }

   return \%kv;
}

sub ConvertHashToNew
{
   my ($this, $kv) = @_;
   my ($key, $new);

   foreach $key (keys %$kv)
   {
      $new .= $key . "=" . $kv->{$key} . "\n";
   }

   return $new;
}

sub InsertModerationNote
{
   my ($this, $modid, $uid, $text) = @_;

   my $sql = Sql->new($this->{DBH});
   $text = $sql->Quote($text);

   eval
   {
       $sql->Begin();
       $sql->Do(qq/insert into ModerationNote (modid, uid, text) values
                      ($modid, $uid, $text)/);
       $sql->Commit();
   };
   if ($@)
   {
       return undef;
   }
   return 1;
}

sub LoadModerationNotes
{
   my ($this, $minmodid, $maxmodid) = @_;
   my (%ret, @notes, $lastmodid, @row);

   if ($minmodid > $maxmodid)
   {
      my $temp;

      $temp = $minmodid;
      $minmodid = $maxmodid;
      $maxmodid = $temp;
   }

   my $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select modid, uid, text, Moderator.name
                         from ModerationNote, Moderator
                        where ModerationNote.uid = Moderator.id and
                              ModerationNote.modid >= $minmodid and
                              ModerationNote.modid <= $maxmodid
                     order by ModerationNote.modid, ModerationNote.id|))
   {
        $lastmodid = -1;
        while(@row = $sql->NextRow())
        {
            $lastmodid = $row[0] if $lastmodid == -1;

            if ($row[0] != $lastmodid)
            {
                $ret{$lastmodid} = [ @notes ];
                @notes = ();
            }
            push @notes, { uid=>$row[1], modid=>$row[0], 
                           text=>$row[2], user=>$row[3] };
            $lastmodid = $row[0];
        }
        if (scalar(@notes) > 0)
        {
            $ret{$lastmodid} = [ @notes ];
            @notes = ();
        }
        $sql->Finish();
   }

   return \%ret;
}

sub GetUserVote
{
   my ($this, $uid) = @_;
   my ($sql, $vote);
   
   $sql = Sql->new($this->{DBH});

   ($vote) = $sql->GetSingleRow("Votes", ["vote"], 
                                ["uid", $uid, "rowid", $this->GetId()]);

   return $vote;
}

sub GetVoterList
{
    my ($this) = @_;
    my (@info, $sql, @row);

    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select votes.vote, moderator.id, moderator.name
                          from votes, moderator
                         where votes.rowid = | . $this->GetId() . qq| and
                               votes.uid = moderator.id
                      order by votes.id|))
    {
        while(@row = $sql->NextRow())
        {
            push @info, { vote=>$row[0], modid=>$row[1], moderator=>$row[2] };
        }
        $sql->Finish;
    }

    return @info;
}

1;
