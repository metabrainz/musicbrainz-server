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

BEGIN { require 5.6.1 }
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
    "20" => "Remove Diskid",
    "21" => "Move Diskid",
    "22" => "Remove TRM id",
    "23" => "Merge Albums",
    "24" => "Remove Albums",
    "25" => "Merge Various Artist Album"
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
    "-3" => "Your vote: Unknown",
    "-2" => "Not voted",
    "-1" => "Your vote: Abstain",
    "1" => "Your vote: Yes",
    "0" => "Your vote: No"
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
    if ($_[0] =~ m/^-?[\d]*\.?[\d]*$/)
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
        $type == ModDefs::MOD_MOVE_DISKID ||
        $type == ModDefs::MOD_REMOVE_TRMID)
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

   $query = qq/select Changes.id, tab, col, Changes.rowid, 
                      Changes.artist, type, prevvalue, newvalue, 
                      UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, 
                      yesvotes, novotes, Artist.name, status, 0, depmod,
                      ModeratorInfo.id, Changes.automod
               from   Changes, ModeratorInfo, Artist 
               where  ModeratorInfo.id = moderator and Changes.artist = 
                      Artist.id and Changes.id = $id/;

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
           $mod->SetExpireTime($row[8] + DBDefs::MOD_PERIOD);
           $mod->SetModeratorName($row[9]);
           $mod->SetYesVotes($row[10]);
           $mod->SetNoVotes($row[11]);
           $mod->SetArtistName($row[12]);
           $mod->SetStatus($row[13]);
           $mod->SetVote(ModDefs::VOTE_UNKNOWN);
           $mod->SetDepMod($row[15]);
           $mod->SetModerator($row[16]);
           $mod->SetAutomod($row[17]);
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
   elsif ($type == ModDefs::MOD_REMOVE_DISKID)
   {
       return RemoveDiskidModeration->new($this->{DBH});
   }
   elsif ($type == ModDefs::MOD_MOVE_DISKID)
   {
       return MoveDiskidModeration->new($this->{DBH});
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
    my ($sql, $ui, $insertid);

    $this->CheckSpecialCases();

    $sql = Sql->new($this->{DBH});
    $ui = UserStuff->new($this->{DBH});

    $table = $sql->Quote($this->{table});
    $column = $sql->Quote($this->{column});
    $prev = $sql->Quote($this->{prev});
    $new = $sql->Quote($this->{new});

    $sql->Do(qq/insert into Changes (tab, col, rowid, prevvalue, 
           newvalue, timesubmitted, moderator, yesvotes, novotes, artist, 
           type, status, depmod, automod) values ($table, $column, 
           $this->{rowid}, $prev, $new, now(), 
           $this->{moderator}, 0, 0, $this->{artist}, $this->{type}, / . 
           ModDefs::STATUS_OPEN . ", $this->{depmod}, 0)");
    $insertid = $sql->GetLastInsertId();

    if ($this->IsAutoModType($this->GetType()) && 
        defined $privs && $ui->IsAutoMod($privs))
    {
        my ($mod, $status);

        $mod = $this->CreateFromId($insertid);
        $status = $mod->ApprovedAction();
        $sql->Do(qq|update Changes set status = $status, automod = 1 
                    where id = $insertid|);
        $this->CreditModerator($this->{moderator}, 1);
    }
    else
    {
        if ($this->{table} ne 'GUIDJoin')
        {
            $sql->Do(qq/update $this->{table} set modpending = modpending + 1 
                        where id = $this->{rowid}/);
        }
    }

    return $sql->GetLastInsertId();
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
   my ($mod, $query);

   $num_rows = $total_rows = 0;
   if ($type == ModDefs::TYPE_NEW)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, / . ModDefs::VOTE_NOTVOTED .
            qq/, ModeratorInfo.id, Changes.automod, count(Votes.id) 
            as num_votes from 
            Artist, ModeratorInfo, Changes left join Votes on Votes.uid = $uid 
            and Votes.rowid=Changes.id where Changes.Artist = Artist.id and 
            ModeratorInfo.id = moderator and moderator != $uid and 
            moderator != / . ModDefs::FREEDB_MODERATOR . qq/ and status = /
            . ModDefs::STATUS_OPEN . 
            qq/ group by Changes.id having num_votes < 1/;
   }
   elsif ($type == ModDefs::TYPE_MINE)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, / . ModDefs::VOTE_NOTVOTED .
            qq/, ModeratorInfo.id, Changes.automod from Changes, 
            ModeratorInfo, Artist 
            where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and moderator = $uid order by TimeSubmitted desc limit 
            $index, -1/;
   }
   elsif ($type == ModDefs::TYPE_VOTED)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, Votes.vote, ModeratorInfo.id, 
            Changes.automod
            from Changes, ModeratorInfo, Artist,
            Votes where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and Votes.rowid = Changes.id and Votes.uid = $uid 
            order by TimeSubmitted desc limit $index, -1/;
   }
   elsif ($type == ModDefs::TYPE_ARTIST)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, Votes.vote, ModeratorInfo.id,
            Changes.automod
            from ModeratorInfo, Artist, Changes left join Votes on
            Votes.uid = $uid and Votes.rowid=Changes.id
            where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and Changes.artist = $rowid
            order by TimeSubmitted desc limit $index, -1/;
   }
   elsif ($type == ModDefs::TYPE_FREEDB)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, / . ModDefs::VOTE_NOTVOTED .
            qq/, ModeratorInfo.id, Changes.automod, 
            count(Votes.id) as num_votes from 
            Artist, ModeratorInfo, Changes left join Votes on Votes.uid = $uid 
            and Votes.rowid=Changes.id where Changes.Artist = Artist.id and 
            ModeratorInfo.id = moderator and moderator = / . 
            ModDefs::FREEDB_MODERATOR . qq/ and status = /
            . ModDefs::STATUS_OPEN . 
            qq/ group by Changes.id having num_votes < 1/;
   }
   else
   {
       return undef;
   }

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
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
                $mod->SetExpireTime($row[8] + DBDefs::MOD_PERIOD);
                $mod->SetModeratorName($row[9]);
                $mod->SetYesVotes($row[10]);
                $mod->SetNoVotes($row[11]);
                $mod->SetArtistName($row[12]);
                $mod->SetStatus($row[13]);
                if (defined $row[14])
                {
                    $mod->SetVote($row[14]);
                }
                else
                {
                    $mod->SetVote(ModDefs::VOTE_NOTVOTED);
                }
                $mod->SetModerator($row[15]);
                $mod->SetAutomod($row[16]);
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
# The caller must supply three lists of ids in the Changes table:
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
      $sql->Do(qq/update Changes set yesvotes = yesvotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$nolist})
   {
      next if ($this->DoesVoteExist($uid, $val));
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 0)/); 
      $sql->Do(qq/update Changes set novotes = novotes + 1
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

# Go through the Changes table and evaluate open Moderations
sub CheckModifications
{
   my ($this) = @_;
   my ($sql, $query, $rowid, @row, $status, $dep_status, $mod); 
   my (%mods, $now, $key);

   $sql = Sql->new($this->{DBH});
   $query = qq|select id from Changes where status = | . 
               ModDefs::STATUS_OPEN . qq| or status = | .
               ModDefs::STATUS_TOBEDELETED . qq| order by Changes.id|;
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
       if ($mod->GetExpireTime() < $now && 
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
           $mod->SetStatus($mod->ApprovedAction($mod->GetRowId()));
           $this->CreditModerator($mod->GetModerator(), 1);
       }
       elsif ($mod->{__eval__} == ModDefs::STATUS_DELETED)
       {
           print STDERR "Mod " . $mod->GetId() . " deleted\n";
           $mod->SetStatus(ModDefs::STATUS_DELETED);
           $mod->DeniedAction();
       }
       else
       {
           print STDERR "Mod " . $mod->GetId() . " denied\n";
           $mod->DeniedAction();
           $this->CreditModerator($mod->GetModerator(), 0);
       }
       $this->CloseModification($mod->GetId(), $mod->GetTable(), 
                                $mod->GetRowId(), $mod->{__eval__});
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
              ($status) = $sql->GetSingleRow("Changes", ["status"], ["id", $1]);
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
   ($ret) = $sql->GetSingleRow("Changes", ["status"], ["id", $id]);

   return $ret;
}

sub CreditModerator
{
   my ($this, $uid, $yes) = @_;

   my $sql = Sql->new($this->{DBH});
   if ($yes)
   {
       $sql->Do(qq/update ModeratorInfo set 
                   modsaccepted = modsaccepted+1 where id = $uid/);
   }
   else
   {
       $sql->Do(qq/update ModeratorInfo set 
                   modsrejected = modsrejected+1 where id = $uid/);
   }
}

sub CloseModification
{
   my ($this, $rowid, $table, $datarowid, $status) = @_;

   my $sql = Sql->new($this->{DBH});

   # Decrement the mod count in the data row
   if ($table ne 'GUIDJoin')
   {
       $sql->Do(qq/update $table set modpending = modpending - 1
                          where id = $datarowid/);
   }

   # Set the status in the Changes row
   $sql->Do(qq/update Changes set status = $status where id = $rowid/);
}

sub RemoveModeration
{
   my ($this) = @_;
  
   if ($this->GetStatus() == ModDefs::STATUS_OPEN)
   {
       # Set the status to be deleted. THe ModBot will clean it up
       # on its next pass.
       my $sql = Sql->new($this->{DBH});
       $sql->Do(qq|update Changes set status = | . 
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
      if ($nw =~ s/^(.*)=(.*)$//m)
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
   $sql->Do(qq/insert into ModeratorNote (modid, uid, text) values
                      ($modid, $uid, $text)/);
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
   if ($sql->Select(qq|select modid, uid, text, ModeratorInfo.name
                         from ModeratorNote, ModeratorInfo
                        where ModeratorNote.uid = ModeratorInfo.id and
                              ModeratorNote.modid >= $minmodid and
                              ModeratorNote.modid <= $maxmodid
                     order by ModeratorNote.modid, ModeratorNote.id|))
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
