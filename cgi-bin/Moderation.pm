#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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

BEGIN { require 5.003 }
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
);

my %ChangeNames = (
    "1" => "Open",
    "2" => "Change applied",
    "3" => "Failed vote",
    "4" => "Failed dependency",
    "5" => "Internal error",
    "6" => "Failed prerequisite"
);

my %VoteText = (
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

sub GetVoteId
{
   return $_[0]->{voteid};
}

sub SetVoteId
{
   $_[0]->{voteid} = $_[1];
}

# These accessor function are used as shortcuts to avoid having 
# to look up the moderator/artist names. They are not used for inserting
# moderations into the DB.
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

sub GetModificationName
{
   return $ModNames{$_[0]};
}

sub GetChangeName
{
   return $ChangeNames{$_[0]->{status}};
}

sub GetVoteText
{
   return $VoteText{$_[0]};
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
                      yesvotes, novotes, Artist.name, status, 0 
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
           $mod->SetVoteId($row[14]);
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

   return undef;
}

# Insert a new moderation into the database. All of the values to be
# inserted are read from the internal hash -- use the above accessor
# functions to set the data to be inserted
sub InsertModeration
{
    my ($this) = shift @_;
    my ($table, $column, $prev, $new);
    my ($sql);

    $this->CheckSpecialCases();

    $sql = Sql->new($this->{DBH});
    $sql->Do(qq/update $this->{table} set modpending = modpending + 1 
                where id = $this->{rowid}/);

    $table = $sql->Quote($this->{table});
    $column = $sql->Quote($this->{column});
    $prev = $sql->Quote($this->{prev});
    $new = $sql->Quote($this->{new});
    $sql->Do(qq/insert into Changes (tab, col, rowid, prevvalue, 
           newvalue, timesubmitted, moderator, yesvotes, novotes, artist, 
           type, status, depmod) values ($table, $column, 
           $this->{rowid}, $prev, $new, now(), 
           $this->{moderator}, 0, 0, $this->{artist}, $this->{type}, / . 
           ModDefs::STATUS_OPEN . ", $this->{depmod})");

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
           $this->{type} = ModDefs::MOD_MERGE_ARTIST;
        }
    }
}

# This function is designed to return the list of moderations to
# be shown on one moderation page. This function returns an array
# of references to Moderation objects.
sub GetModerationList
{
   my ($this, $index, $num, $uid, $type) = @_;
   my ($sql, @data, @row, $num_rows);
   my ($mod, $query);

   $num_rows = 0;
   if ($type == ModDefs::TYPE_NEW)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, 0, count(Votes.id) as num_votes from 
            Artist, ModeratorInfo, Changes left join Votes on Votes.uid = $uid 
            and Votes.rowid=Changes.id where Changes.Artist = Artist.id and 
            ModeratorInfo.id = moderator and moderator != $uid and status = /
            . ModDefs::STATUS_OPEN . 
            qq/ group by Changes.id having num_votes < 1 limit $num/;
   }
   elsif ($type == ModDefs::TYPE_MINE)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, 0 from Changes, ModeratorInfo, Artist 
            where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and moderator = $uid order by TimeSubmitted desc limit 
            $index, $num/;
   }
   else
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, Votes.vote from Changes, 
            ModeratorInfo, Artist,
            Votes where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and Votes.rowid = Changes.id and Votes.uid = $uid 
            order by TimeSubmitted desc limit $index, $num/;
   }


   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
        for($num_rows = 0; @row = $sql->NextRow(); $num_rows++)
        {
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
                $mod->SetVoteId($row[14]);
                push @data, $mod;
            }
            else
            {
                print STDERR "Could not create ModerationObject ($row[5])\n";
            }
        }
        $sql->Finish;
   }

   return ($num_rows, @data);
}

# This function will get called from the html pages to output the
# contents of the moderation type field
sub ShowModType
{
   my ($this) = @_;
   my ($out, $type);

   $type = $this->GetType();
   $out = GetModificationName($type) . " ";
   if ($type == ModDefs::MOD_MOVE_ALBUM) 
   {
      my ($al, $album);
   
      $al = Album->new($this->{DBH});
      $al->SetId($this->{rowid});
      if (defined($al->LoadFromId()))
      {
          $album = $al->GetName();
      }
      else
      {
          $album = "[deleted]";
      }
      $out .= qq\(<a href="/showalbum.html?albumid=$this->{rowid}">$album</a>)\;
   } 
   else 
   {
      $out .= qq\(<a href="/showartist.html?artistid=$this->{artist}">$this->{artistname}</a>)\;
   }
   
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
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 1)/); 
      $sql->Do(qq/update Changes set yesvotes = yesvotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$nolist})
   {
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 0)/); 
      $sql->Do(qq/update Changes set novotes = novotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$abslist})
   {
      $sql->Do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, -1)/); 
   }

   $this->CheckModifications((@{$yeslist}, @{$nolist}))
}

# Go through the Changes table and find Moderations that have expired.
# Then evaluate the expired mods...
sub CheckModificationsForExpiredItems
{
   my ($this) = @_;
   my ($sql, @ids, @row, $query); 

   $sql = Sql->new($this->{DBH});
   $query = qq/select id from Changes where 
              status = / . ModDefs::STATUS_OPEN . qq/ and
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted) > / 
              . DBDefs::MOD_PERIOD . " order by TimeSubmitted, Depmod";
   if ($sql->Select($query))
   {
       while(@row = $sql->NextRow())
       {
          push @ids, $row[0];
       }
       $sql->Finish;
   }

   $this->CheckModifications(@ids);
}

sub CheckModifications
{
   my ($this, @ids) = @_;
   my ($sql, $query, $rowid, @row, $status, $dep_status, $mod); 

   $sql = Sql->new($this->{DBH});
   while(defined($rowid = shift @ids))
   {
       $query = qq/select yesvotes, novotes,
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted),
              tab, rowid, moderator, type, depmod from Changes 
              where id = $rowid/;
       if ($sql->Select($query))
       {
            @row = $sql->NextRow();

            # Check to see if this change has another change that it depends on
            if ($row[7] > 0)
            {
                # Get the status of the dependent change
                $dep_status = $this->GetModerationStatus($row[7]);
                if ($dep_status == ModDefs::STATUS_OPEN)
                {
                    # If the prereq. change is still open, skip this change 
                    $sql->Finish;
                    next;
                }
                if ($dep_status != ModDefs::STATUS_OPEN && 
                    $dep_status != ModDefs::STATUS_APPLIED)
                {
                    # If the prereq. change failed, close this modification
                    $mod = $this->CreateFromId($rowid);
                    $mod->DeniedAction();
                    $this->CreditModerator($row[5], 0);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], 
                                             ModDefs::STATUS_FAILEDPREREQ);
                    $sql->Finish;
                    next;
                }
            }
            # Has the vote period expired?
            if ($row[2] >= DBDefs::MOD_PERIOD && 
               ($row[0] > 0 || $row[1] > 0))
            {
                # Are there more yes votes than no votes?
                if ($row[0] > $row[1])
                {
                    $mod = $this->CreateFromId($rowid);
                    $status = $mod->ApprovedAction($rowid);
                    $this->CreditModerator($row[5], 1);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], $status);
                }
                else
                {
                    $mod = $this->CreateFromId($rowid);
                    $mod->DeniedAction();
                    $this->CreditModerator($row[5], 0);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], 
                                             ModDefs::STATUS_FAILEDVOTE);
                }
            }
            # Are the number of required unanimous votes present?
            elsif ($row[0] == DBDefs::NUM_UNANIMOUS_VOTES && $row[1] == 0)
            {
                # A unanimous yes. Apply and the remove from db

                $mod = $this->CreateFromId($rowid);
                $status = $mod->ApprovedAction($rowid);
                $this->CreditModerator($row[5], 1);
                $this->CloseModification($rowid, $row[3], 
                                         $row[4], $status);
            }
            elsif ($row[1] == DBDefs::NUM_UNANIMOUS_VOTES && $row[0] == 0)
            {
                # A unanimous no. Remove from db
                $mod = $this->CreateFromId($rowid);
                $mod->DeniedAction();
                $this->CreditModerator($row[5], 0);
                $this->CloseModification($rowid, $row[3], 
                                         $row[4], ModDefs::STATUS_FAILEDVOTE);
            }
            $sql->Finish;
       }
   }
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
   $sql->Do(qq/update $table set modpending = modpending - 1
                       where id = $datarowid/);

   # Set the status in the Changes row
   $sql->Do(qq/update Changes set status = $status where id = $rowid/);
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
