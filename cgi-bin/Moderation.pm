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
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Track;
use Artist;
use Album;
use Insert;

use constant TYPE_NEW                    => 1;
use constant TYPE_VOTED                  => 2;
use constant TYPE_MINE                   => 3;

use constant MOD_EDIT_ARTISTNAME         => 1;
use constant MOD_EDIT_ARTISTSORTNAME     => 2;
use constant MOD_EDIT_ALBUMNAME          => 3;
use constant MOD_EDIT_TRACKNAME          => 4;
use constant MOD_EDIT_TRACKNUM           => 5;
use constant MOD_MERGE_ARTIST            => 6;
use constant MOD_ADD_TRACK               => 7;
use constant MOD_MOVE_ALBUM              => 8;
use constant MOD_SAC_TO_MAC              => 9;
use constant MOD_CHANGE_TRACK_ARTIST     => 10;
use constant MOD_REMOVE_TRACK            => 11;
use constant MOD_REMOVE_ALBUM            => 12;
use constant MOD_MAC_TO_SAC              => 13;
use constant MOD_REMOVE_ARTISTALIAS      => 14;
use constant MOD_ADD_ARTISTALIAS         => 15;

use constant STATUS_OPEN                 => 1;
use constant STATUS_APPLIED              => 2;
use constant STATUS_FAILEDVOTE           => 3;
use constant STATUS_FAILEDDEP            => 4;
use constant STATUS_ERROR                => 5;
use constant STATUS_FAILEDPREREQ         => 6;

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
    "15" => "Add Artist Alias"
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
           STATUS_OPEN . ", $this->{depmod})");

    return $sql->GetLastInsertId();
}

# Some modifications need to get changed before being inserted into
# the database. For instance, if an artist edit ends up clashing with
# and existing artist, then the moderation needs to get changed to a
# merge artist moderation
sub CheckSpecialCases
{
    my ($this) = @_;

    if ($this->{type} == Moderation::MOD_EDIT_ARTISTNAME)
    {
        my $ar;

        # Check to see if we already have the artist that we're supposed
        # to edit to. If so, change this mod to a MERGE_ARTISTNAME.
        $ar = Artist->new($this->{DBH});
        if ($ar->LoadFromName($this->{new}))
        {
           $this->{type} = MOD_MERGE_ARTIST;
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
   if ($type == TYPE_NEW)
   {
       $query = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, 0, count(Votes.id) as num_votes from 
            Artist, ModeratorInfo, Changes left join Votes on Votes.uid = $uid 
            and Votes.rowid=Changes.id where Changes.Artist = Artist.id and 
            ModeratorInfo.id = moderator and moderator != $uid and status = /
            . STATUS_OPEN . 
            qq/ group by Changes.id having num_votes < 1 limit $num/;
   }
   elsif ($type == TYPE_MINE)
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
            $mod = Moderation->new($this->{DBH});
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
        $sql->Finish;
   }

   return ($num_rows, @data);
}

# This function will get called from the html pages to output the
# contents of the previous value field.
sub ShowModPrev
{
   my ($this) = @_;
   
   my $type = $this->GetType();
   my $prev = $this->GetPrev();
   if ($type == Moderation::MOD_EDIT_ARTISTNAME ||
       $type == Moderation::MOD_EDIT_ARTISTSORTNAME ||
       $type == Moderation::MOD_MERGE_ARTIST)
   {
       return "Old: <a href=\"/showartist.html?artistid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_ADD_TRACK)
   {
       return "Album: <a href=\"/showalbum.html?albumid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_ADD_ARTISTALIAS)
   {
       return "Aliases: <a href=\"/showaliases.html?artistid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_EDIT_ALBUMNAME ||
          $type == Moderation::MOD_SAC_TO_MAC ||
          $type == Moderation::MOD_MAC_TO_SAC ||
          $type == Moderation::MOD_REMOVE_ALBUM)
   {
       return "Old: <a href=\"/showalbum.html?albumid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_EDIT_TRACKNAME ||
          $type == Moderation::MOD_CHANGE_TRACK_ARTIST)
   {
       return "Old: <a href=\"/showtrack.html?trackid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_EDIT_TRACKNUM)
   {
       return "Old: <a href=\"/showtrack.html?albumjoinid=$this->{rowid}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_REMOVE_TRACK)
   {
       my ($name, $id) = split /\n/, $prev;

       if ($this->GetStatus() == STATUS_APPLIED)
       {
           return "Old: $name";
       }
       else
       {
           return "Old: <a href=\"/showtrack.html?trackid=$this->{rowid}\">$name</a>";
       }
   }
   elsif ($type == Moderation::MOD_MOVE_ALBUM)
   {
       return "Old: <a href=\"/showartist.html?artistid=$this->{artist}\">$prev</a>";
   }
   elsif ($type == Moderation::MOD_REMOVE_ARTISTALIAS)
   {
       return "Old: <a href=\"/showaliases.html?artistid=$this->{artist}\">$prev</a>";
   }

   return "[Internal Error]";
}

# This function will get called from the html pages to output the
# contents of the new value field.
sub ShowModNew
{
   my ($this) = @_;
   my ($out, $type, $new);

   $type = $this->GetType();
   $new = $this->GetNew();
   if ($type == Moderation::MOD_ADD_TRACK) 
   {
      my (@data) = split(/\n/, $new);

      $out = qq\Name: <span class="bold">$data[0]</span>\;
      $out .= qq\ Track: <span class="bold">$data[1]</span>\;
      if ($this->GetArtist() == Artist::VARTIST_ID) 
      {
          $out .= qq\<br>Artist: <span class="bold">$data[3]</span>\;
          if (defined $data[4]) 
          {
              $out .= qq\ (<span class="bold">$data[4]</span>)\;
          }
      }
   } 
   elsif ($type == Moderation::MOD_MERGE_ARTIST ||
          $type == Moderation::MOD_MOVE_ALBUM ||
          $type == Moderation::MOD_CHANGE_TRACK_ARTIST) 
   {
      if ($new =~ /\n/) 
      {
          my (@data) = split(/\n/, $new);
          $out = qq\Artist: <span class="bold">$data[1]</span>\;
          $out .= qq\ (<span class="bold">$data[0]</span>)\;
      } 
      else 
      {
          $out = qq\Artist: <span class="bold">$new</span>\;
      }
   } 
   else 
   {
      $out = qq\New: <span class="bold">$new</span>\;
   }

   return $out;
}

# This function will get called from the html pages to output the
# contents of the moderation type field
sub ShowModType
{
   my ($this) = @_;
   my ($out, $type);

   $type = $this->GetType();
   $out = GetModificationName($type) . " ";
   if ($type == Moderation::MOD_MOVE_ALBUM) 
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
              status = / . STATUS_OPEN . qq/ and
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
   my ($sql, $query, $rowid, @row, $status, $dep_status); 

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
                if ($dep_status == STATUS_OPEN)
                {
                    # If the prereq. change is still open, skip this change 
                    $sql->Finish;
                    next;
                }
                if ($dep_status != STATUS_OPEN && $dep_status != STATUS_APPLIED)
                {
                    # If the prereq. change failed, close this modification
                    $this->CreditModerator($row[5], 0);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], STATUS_FAILEDPREREQ);
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
                    $status = $this->ApplyModification($rowid, $row[6]);
                    $this->CreditModerator($row[5], 1);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], $status);
                }
                else
                {
                    $this->CreditModerator($row[5], 0);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], STATUS_FAILEDVOTE);
                }
            }
            # Are the number of required unanimous votes present?
            elsif ($row[0] == DBDefs::NUM_UNANIMOUS_VOTES && $row[1] == 0)
            {
                # A unanimous yes. Apply and the remove from db
                $status = $this->ApplyModification($rowid, $row[6]);
                $this->CreditModerator($row[5], 1);
                $this->CloseModification($rowid, $row[3], 
                                         $row[4], $status);
            }
            elsif ($row[1] == DBDefs::NUM_UNANIMOUS_VOTES && $row[0] == 0)
            {
                # A unanimous no. Remove from db
                $this->CreditModerator($row[5], 0);
                $this->CloseModification($rowid, $row[3], 
                                         $row[4], STATUS_FAILEDVOTE);
            }
            $sql->Finish;
       }
   }
}

sub GetModerationStatus
{
   my ($this, $id) = @_;
   my ($sql, @row, $ret); 

   $ret = STATUS_ERROR;
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

sub ApplyModification
{
   my ($this, $rowid, $type) = @_;

   if ($type == MOD_EDIT_ARTISTNAME || $type == MOD_EDIT_ARTISTSORTNAME ||
       $type == MOD_EDIT_ALBUMNAME  || $type == MOD_EDIT_TRACKNAME ||
       $type == MOD_EDIT_TRACKNUM)
   {
       return ApplyEditModification($this, $rowid);
   }
   elsif ($type == MOD_MERGE_ARTIST)
   {
       return ApplyMergeArtistModification($this, $rowid);
   }
   elsif ($type == MOD_ADD_TRACK)
   {
       return ApplyAddTrackModification($this, $rowid);
   }
   elsif ($type == MOD_ADD_ARTISTALIAS)
   {
       return ApplyAddArtistAliasModification($this, $rowid);
   }
   elsif ($type == MOD_MOVE_ALBUM || $type == MOD_MAC_TO_SAC)
   {
       return ApplyMoveAlbumModification($this, $rowid);
   }
   elsif ($type == MOD_CHANGE_TRACK_ARTIST)
   {
       return ApplyChangeTrackArtistModification($this, $rowid);
   }
   elsif ($type == MOD_SAC_TO_MAC)
   {
       return ApplySACToMACModification($this, $rowid);
   }
   elsif ($type == MOD_REMOVE_TRACK)
   {
       return ApplyRemoveTrackModification($this, $rowid);
   }
   elsif ($type == MOD_REMOVE_ALBUM)
   {
       return ApplyRemoveAlbumModification($this, $rowid);
   }
   elsif ($type == MOD_REMOVE_ARTISTALIAS)
   {
       return ApplyRemoveArtistAliasModification($this, $rowid);
   }

   return STATUS_ERROR;
}

sub ApplyAddTrackModification
{
   my ($this, $id) = @_;
   my (@data, $in, $tid, $status, $sql, @row, %info);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   # Pull back all the pertinent info for this mod
   if ($sql->Select(qq/select newvalue, rowid, artist 
                    from Changes where id = $id/))
   {
        $in = Insert->new($this->{DBH});
        @row = $sql->NextRow();
        $sql->Finish();

        # Is this a single artist that we're adding a track to?
        if ($row[2] != Artist::VARTIST_ID)
        {
            my ($trackname, $tracknum, $album) = split(/\n/, $row[0]);

            # Single artist album
            $info{artistid} = $row[2];
            $info{albumid} = $album;
            $info{tracks} =
              [
                 {
                    track => $trackname,
                    tracknum => $tracknum
                 }
              ];

            $status = STATUS_APPLIED 
                if (defined $in->Insert(\%info));
        }
        else
        {
            my ($newartistid);
            @data = split(/\n/, $row[0]);
            my ($trackname, $tracknum, $album, $artistname, $sortname) = 
                  split(/\n/, $row[0]);

            # Multiple artist album
            $info{artistid} = Artist::VARTIST_ID;
            $info{albumid} = $album;
            $info{tracks} =
              [
                 {
                    track => $trackname,
                    tracknum => $tracknum,
                    artist => $data[3],
                    sortname => $data[4]
                 }
              ];

            $status = STATUS_APPLIED 
                if (defined $in->Insert(\%info));
        }
   }

   return $status;
}

sub ApplyMergeArtistModification
{
   my ($this, $id) = @_;
   my (@row, $prevval, $rowid, $status, $newid);
   my ($name, $sortname);

   $status = STATUS_ERROR;
   my $sql = Sql->new($this->{DBH});

   # Pull back all the pertinent info for this mod
   if ($sql->Select(qq/select prevvalue, newvalue, rowid 
                    from Changes where id = $id/))
   {
        @row = $sql->NextRow();
        $prevval = $row[0];
        $rowid = $row[2];
        $name = $row[1];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        $sql->Finish;
        # Check to see that the old value is still what we think it is
        if ($sql->Select(qq/select name from Artist where id = $rowid/))
        {
            @row = $sql->NextRow();
            $sql->Finish;
            if ($row[0] eq $prevval)
            {
               $name = $sql->Quote($name);
               # Check to see that the new artist is still around 
               if ($sql->Select(qq/select id from Artist where name = $name/))
               {
                   @row = $sql->NextRow();
                   $newid = $row[0];
                   $status = STATUS_APPLIED;
                   $sql->Finish;
               }
               else
               {
                   $status = STATUS_FAILEDDEP;
               }
            }
            else
            {
               $status = STATUS_FAILEDDEP;
            }
        }
   }

   if ($status == STATUS_APPLIED)
   {
       $sql->Do(qq/update Album set artist = $newid where artist = $rowid/);
       $sql->Do(qq/update Track set artist = $newid where artist = $rowid/);
       $sql->Do("delete from Artist where id = $rowid");
       $sql->Do("update Changes set artist = $newid where artist = $rowid");

       my $al = Alias->new($this->{DBH});
       $al->SetTable("ArtistAlias");
       $al->Insert($newid, $prevval);
   }

   return $status;
}

sub ApplyEditModification
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $prevval, $newval);
   my ($status, $table, $column, $datarowid);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select tab, col, prevvalue, newvalue, 
                    rowid from Changes where id = $rowid/))
   {
        @row = $sql->NextRow();
        $table = $row[0];
        $column = $row[1];
        $prevval = $row[2];
        $newval = $sql->Quote($row[3]);
        $datarowid = $row[4];

        $sql->Finish;
        if ($sql->Select(qq/select $column from $table where id = $datarowid/))
        {
            @row = $sql->NextRow;
            if ($row[0] eq $prevval)
            {
                $sql->Do(qq/update $table set $column = $newval  
                                    where id = $datarowid/); 
                if ($table eq 'Artist' && $column eq 'Name')
                {
                    my $al = Alias->new($this->{DBH});
                    $al->SetTable("ArtistAlias");
                    $al->Insert($datarowid, $prevval);
                }
                $status = STATUS_APPLIED;
            }
            else
            {
                $status = STATUS_FAILEDDEP;
            }
            $sql->Finish;
        }
   }

   return $status;
}

sub ApplyMoveAlbumModification
{
   my ($this, $id) = @_;
   my ($sql, @row, $rowid, $status, $ar, $newid);
   my ($name, $sortname, $qname);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   # Pull back all the pertinent info for this mod
   if ($sql->Select(qq/select newvalue, rowid from Changes where id = $id/))
   {
        @row = $sql->NextRow;
        $sql->Finish;

        $name = $row[0];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        else
        {
           $sortname = $name;
        }
        $qname = $sql->Quote($name);
        $rowid = $row[1];

        if ($sql->Select(qq/select id from Artist where name = $qname/))
        {
            @row = $sql->NextRow;
            $newid = $row[0];
            $sql->Finish;
        }
        else
        {
            $ar = Artist->new($this->{DBH});
            $ar->SetName($name);
            $ar->SetSortName($sortname);
            $newid = $ar->Insert();
        }
        if ($sql->Select(qq/select track from AlbumJoin where Album = $rowid/))
        {
            while(@row = $sql->NextRow)
            {
                $sql->Do(qq/update Track set artist = $newid 
                            where id = $row[0]/);
            }

            $sql->Do(qq/update Album set artist = $newid where id = $rowid/);
            $status = STATUS_APPLIED;
            $sql->Finish;
        }
   }

   return $status;
}

sub ApplySACToMACModification
{
   my ($this, $id) = @_;
   my ($status, $sql, @row);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   # Pull back all the pertinent info for this mod
   if ($sql->Select(qq/select rowid from Changes where id = $id/))
   {
        @row = $sql->NextRow();

        $sql->Do("update Album set Artist = " . 
                         Artist::VARTIST_ID . "  where id = $row[0]");
        $status = STATUS_APPLIED; 
        $sql->Finish;
   }

   return $status;
}

sub ApplyChangeTrackArtistModification
{
   my ($this, $id) = @_;
   my ($sql, @row, $rowid, $status, $ar, $newid);
   my ($name, $sortname, $qname);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});

   # Pull back all the pertinent info for this mod
   if ($sql->Select(qq/select newvalue, rowid from Changes where id = $id/))
   {
        @row = $sql->NextRow;
        $name = $row[0];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        else
        {
           $sortname = $name;
        }
        $qname = $sql->Quote($name);
        $rowid = $row[1];

        $sql->Finish;
        if ($sql->Select(qq/select id from Artist where name = $qname/))
        {
            @row = $sql->NextRow;
            $newid = $row[0];
            $sql->Finish;
        }
        else
        {
            $ar = Artist->new($this->{DBH});
            $ar->SetName($name);
            $ar->SetSortName($sortname);
            $newid = $ar->Insert();
        }
        $sql->Do("update Track set Artist = $newid where id = $rowid");
        $status = STATUS_APPLIED 
   }

   return $status;
}

sub ApplyRemoveTrackModification
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $trackid);
   my ($status);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select rowid, prevvalue from Changes 
                                   where id = $rowid/))
   {
        my $album;

        @row = $sql->NextRow;
        $trackid = $row[0];
        $album = $row[1];
        $album =~ s/^.*?\n//s;
        $sql->Do(qq/delete from AlbumJoin where Album = $album and
                         track = $row[0]/);

        $sql->Finish;
        if ($sql->Select(qq/select count(*) from AlbumJoin
                                     where track = $trackid/)) 
        {
            @row = $sql->NextRow;

            if ($row[0] == 0)
            {
                $sql->Do(qq/delete from Track where id = $trackid/);
            }
            $sql->Finish;
        }

        $status = STATUS_APPLIED;
   }

   return $status;
}

sub ApplyRemoveAlbumModification
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $trackid);
   my ($status);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select rowid from Changes where id = $rowid/))
   {
        my $album;

        @row = $sql->NextRow;
        $album = $row[0];

        # Check to see if there are any tracks in this album. If so,
        # don't delete the album -- set it to failed dependency
        $sql->Finish;
        if ($sql->Select(qq/select count(*) from AlbumJoin
                                     where album = $album/)) 
        {
            @row = $sql->NextRow;

            if ($row[0] > 0)
            {
                $status = STATUS_FAILEDDEP;
            }
            else
            {
                $sql->Do(qq/delete from Album where id = $album/);
                $status = STATUS_APPLIED;
            }
            $sql->Finish;
        }
   }

   return $status;
}

sub ApplyRemoveArtistAliasModification
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $al);
   my ($status);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select rowid from Changes where id = $rowid/))
   {
        @row = $sql->NextRow;
        $sql->Finish;

        $al = Alias->new($this->{DBH});
        $al->SetTable("ArtistAlias");
        $al->Remove($row[0]);
        
        $status = STATUS_APPLIED;
   }

   return $status;
}

sub ApplyAddArtistAliasModification
{
   my ($this, $rowid) = @_;
   my ($sql, @row, $al);
   my ($status);

   $status = STATUS_ERROR;
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select rowid, newvalue from Changes where id = $rowid/))
   {
        @row = $sql->NextRow;
        $sql->Finish;

        $al = Alias->new($this->{DBH});
        $al->SetTable("ArtistAlias");
        $status = STATUS_APPLIED
            if (defined $al->Insert($row[0], $row[1]));
   }

   return $status;
}
