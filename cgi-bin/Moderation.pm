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
use CGI;
use DBI;
use DBDefs;
use Track;
use Artist;
use Album;

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
    "10" => "Change Track Artist"
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
   return $ChangeNames{$_[0]};
}

sub GetVoteText
{
   return $VoteText{$_[0]};
}

sub InsertModification
{
    my ($this) = shift @_;
    my ($table, $column, $artist, $type, $id, $prev, $new, $uid, $depmod) =
        $this->CheckSpecialCases(@_);

    $this->{DBH}->do(qq/update $table set modpending = modpending + 1  
                        where id = $id/);

    $table = $this->{DBH}->quote($table);
    $column = $this->{DBH}->quote($column);
    $prev = $this->{DBH}->quote($prev);
    $new = $this->{DBH}->quote($new);
    $this->{DBH}->do(qq/insert into Changes (tab, col, rowid, prevvalue, 
           newvalue, timesubmitted, moderator, yesvotes, novotes, artist, 
           type, status, depmod) values ($table, $column, $id, $prev, $new, 
           now(), $uid, 0, 0, $artist, $type, / . STATUS_OPEN . ", $depmod)");

    return $this->GetLastInsertId();
}

sub CheckSpecialCases
{
    my ($this, $table, $column, $artist, $type, 
        $id, $prev, $new, $uid, $depmod) = @_;

    if ($type == Moderation::MOD_EDIT_ARTISTNAME)
    {
        my $ar;

        # Check to see if we already have the artist that we're supposed
        # to edit to. If so, change this mod to a MERGE_ARTISTNAME.
        $ar = Artist->new($this->{MB});
        if ($ar->GetIdFromName($new) > 0)
        {
           $type = MOD_MERGE_ARTIST;
        }

        return ($table, $column, $artist, $type, $id, 
                $prev, $new, $uid, $depmod);
    }

    return ($table, $column, $artist, $type, $id, 
            $prev, $new, $uid, $depmod);
}

sub GetModerationList
{
   my ($this, $index, $num, $uid, $type) = @_;
   my ($sth, @data, @row, $sql, $num_rows);

   if ($type == TYPE_NEW)
   {
       $sql = qq/select Changes.id, tab, col, Changes.rowid, 
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
       $sql = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, 0 from Changes, ModeratorInfo, Artist 
            where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and moderator = $uid order by TimeSubmitted desc limit 
            $index, $num/;
   }
   else
   {
       $sql = qq/select Changes.id, tab, col, Changes.rowid, 
            Changes.artist, type, prevvalue, newvalue, 
            UNIX_TIMESTAMP(TimeSubmitted), ModeratorInfo.name, yesvotes, 
            novotes, Artist.name, status, Votes.vote from Changes, 
            ModeratorInfo, Artist,
            Votes where ModeratorInfo.id = moderator and Changes.artist = 
            Artist.id and Votes.rowid = Changes.id and Votes.uid = $uid 
            order by TimeSubmitted desc limit $index, $num/;
   }

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute;
   $num_rows = $sth->rows;
   if ($num_rows > 0)
   {
        while(@row = $sth->fetchrow_array)
        {
            $row[8] += DBDefs::MOD_PERIOD;
            push @data, [@row];
        }
   }
   $sth->finish;

   return ($num_rows, @data);
}

sub InsertVotes
{
   my ($this, $uid, $yeslist, $nolist, $abslist) = @_;
   my ($val);

   foreach $val (@{$yeslist})
   {
      $this->{DBH}->do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 1)/); 
      $this->{DBH}->do(qq/update Changes set yesvotes = yesvotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$nolist})
   {
      $this->{DBH}->do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, 0)/); 
      $this->{DBH}->do(qq/update Changes set novotes = novotes + 1
                       where id = $val/); 
   }
   foreach $val (@{$abslist})
   {
      $this->{DBH}->do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, -1)/); 
   }

   $this->CheckModifications((@{$yeslist}, @{$nolist}))
}

sub CheckModificationsForExpiredItems
{
   my ($this) = @_;
   my ($sth, @ids, @row); 

   $sth = $this->{DBH}->prepare(qq/select id from Changes where 
              status = / . STATUS_OPEN . qq/ and
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted) > / 
              . DBDefs::MOD_PERIOD . " order by TimeSubmitted, Depmod");
   $sth->execute;
   if ($sth->rows)
   {
       while(@row = $sth->fetchrow_array)
       {
          push @ids, $row[0];
       }
   }
   $sth->finish;

   $this->CheckModifications(@ids);
}

sub CheckModifications
{
   my ($this, @ids) = @_;
   my ($sth, $rowid, @row, $status, $dep_status); 

   while(defined($rowid = shift @ids))
   {
       $sth = $this->{DBH}->prepare(qq/select yesvotes, novotes,
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted),
              tab, rowid, moderator, type, depmod from Changes 
              where id = $rowid/);
       $sth->execute;
       if ($sth->rows)
       {
            @row = $sth->fetchrow_array;

            # Check to see if this change has another change that it depends on
            if ($row[7] > 0)
            {
                # Get the status of the dependent change
                $dep_status = $this->GetModerationStatus($row[7]);
                if ($dep_status == STATUS_OPEN)
                {
                    # If the prereq. change is still open, skip this change 
                    $sth->finish;
                    next;
                }
                if ($dep_status != STATUS_OPEN && $dep_status != STATUS_APPLIED)
                {
                    # If the prereq. change failed, close this modification
                    $this->CreditModerator($row[5], 0);
                    $this->CloseModification($rowid, $row[3], 
                                             $row[4], STATUS_FAILEDPREREQ);
                    $sth->finish;
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
       }
       $sth->finish;
   }
}

sub GetModerationStatus
{
   my ($this, $id) = @_;
   my ($sth, @row, $ret); 

   $ret = STATUS_ERROR;
   $sth = $this->{DBH}->prepare(qq/select status from Changes 
                                   where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
      @row = $sth->fetchrow_array;

      $ret = $row[0];
   }
   $sth->finish;

   return $ret;
}


sub CreditModerator
{
   my ($this, $uid, $yes) = @_;

   if ($yes)
   {
       $this->{DBH}->do(qq/update ModeratorInfo set 
                       modsaccepted = modsaccepted+1 where id = $uid/);
   }
   else
   {
       $this->{DBH}->do(qq/update ModeratorInfo set 
                       modsrejected = modsrejected+1 where id = $uid/);
   }
}

sub CloseModification
{
   my ($this, $rowid, $table, $datarowid, $status) = @_;

   # Decrement the mod count in the data row
   $this->{DBH}->do(qq/update $table set modpending = modpending - 1
                       where id = $datarowid/);

   # Set the status in the Changes row
   $this->{DBH}->do(qq/update Changes set status = $status where id = $rowid/);
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
   elsif ($type == MOD_MOVE_ALBUM)
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

   return STATUS_ERROR;
}

sub ApplyAddTrackModification
{
   my ($this, $id) = @_;
   my (@data, $tr, $tid, $status, $sth, @row);

   $status = STATUS_ERROR;

   # Pull back all the pertinent info for this mod
   $sth = $this->{DBH}->prepare(qq/select newvalue, rowid, artist 
                                from Changes where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
        @data = split(/\n/, $row[0]);

        $tr = Track->new($this->{MB});
        $status = STATUS_APPLIED 
           if(defined $tr->Insert($data[0], $row[2], $data[2], $data[1]));
   }
   $sth->finish;

   return $status;
}

sub ApplyMergeArtistModification
{
   my ($this, $id) = @_;
   my ($sth, @row, $prevval, $rowid, $status, $newid);
   my ($name, $sortname);

   $status = STATUS_ERROR;

   # Pull back all the pertinent info for this mod
   $sth = $this->{DBH}->prepare(qq/select prevvalue, newvalue, rowid 
                                from Changes where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
        $prevval = $row[0];
        $rowid = $row[2];
        $name = $row[1];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        $sth->finish;
        # Check to see that the old value is still what we think it is
        $sth = $this->{DBH}->prepare(qq/select name from Artist where 
                                     id = $rowid/);
        $sth->execute;
        if ($sth->rows)
        {
            @row = $sth->fetchrow_array;
            if ($row[0] eq $prevval)
            {
               $sth->finish;
               $name = $this->{DBH}->quote($name);
               # Check to see that the new artist is still around 
               $sth = $this->{DBH}->prepare(qq/select id from Artist where 
                                            name = $name/);
               $sth->execute;
               if ($sth->rows)
               {
                   @row = $sth->fetchrow_array;
                   $newid = $row[0];
                   $status = STATUS_APPLIED;
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
   $sth->finish;

   if ($status == STATUS_APPLIED)
   {
       $this->{DBH}->do(qq/update Album set artist = $newid where 
                           artist = $rowid/);
       $this->{DBH}->do(qq/update Track set artist = $newid where 
                           artist = $rowid/);
       $this->{DBH}->do("delete from Artist where id = $rowid");
       $this->{DBH}->do("update Changes set artist = $newid where artist = $rowid");
   }

   return $status;
}

sub ApplyEditModification
{
   my ($this, $rowid) = @_;
   my ($sth, @row, $prevval, $newval);
   my ($status, $table, $column, $datarowid);

   $status = STATUS_ERROR;
   $sth = $this->{DBH}->prepare(qq/select tab, col, prevvalue, newvalue, 
                                rowid from Changes where id = $rowid/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
        $table = $row[0];
        $column = $row[1];
        $prevval = $row[2];
        $newval = $this->{DBH}->quote($row[3]);
        $datarowid = $row[4];

        $sth->finish;
        $sth = $this->{DBH}->prepare(qq/select $column from $table where id =
                                     $datarowid/);
        $sth->execute;
        if ($sth->rows)
        {
            @row = $sth->fetchrow_array;

            if ($row[0] eq $prevval)
            {
                $this->{DBH}->do(qq/update $table set $column = $newval  
                                    where id = $datarowid/); 
                $status = STATUS_APPLIED;
            }
            else
            {
                $status = STATUS_FAILEDDEP;
            }
        }
   }
   $sth->finish;

   return $status;
}

sub ApplyMoveAlbumModification
{
   my ($this, $id) = @_;
   my ($sth, @row, $rowid, $status, $ar, $newid);
   my ($name, $sortname, $qname);

   $status = STATUS_ERROR;

   # Pull back all the pertinent info for this mod
   $sth = $this->{DBH}->prepare(qq/select newvalue, rowid 
                                from Changes where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
        $name = $row[0];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        else
        {
           $sortname = $name;
        }
        $qname = $this->{DBH}->quote($name);
        $rowid = $row[1];

        $sth->finish;
        $sth = $this->{DBH}->prepare(qq/select id from Artist where 
                                     name = $qname/);
        $sth->execute;
        if ($sth->rows)
        {
            @row = $sth->fetchrow_array;
            $newid = $row[0];
        }
        else
        {
            $ar = Artist->new($this->{MB});
            $newid = $ar->Insert($name, $sortname);
        }
        $sth->finish;
        $sth = $this->{DBH}->prepare(qq/select track from AlbumJoin where 
                                     Album = $rowid/);
        $sth->execute;
        if ($sth->rows)
        {
            while(@row = $sth->fetchrow_array)
            {
                $this->{DBH}->do(qq/update Track set artist = $newid where 
                                id = $row[0]/);
            }

            $this->{DBH}->do(qq/update Album set artist = $newid where 
                                id = $rowid/);
            $status = STATUS_APPLIED;
        }
   }
   $sth->finish;

   return $status;
}

sub ApplySACToMACModification
{
   my ($this, $id) = @_;
   my ($status, $sth, @row);

   $status = STATUS_ERROR;

   # Pull back all the pertinent info for this mod
   $sth = $this->{DBH}->prepare(qq/select rowid from Changes where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array();

        $this->{DBH}->do("update Album set Artist = 0 where id = $row[0]");
        $status = STATUS_APPLIED 
   }
   $sth->finish;

   return $status;
}

sub ApplyChangeTrackArtistModification
{
   my ($this, $id) = @_;
   my ($sth, @row, $rowid, $status, $ar, $newid, $al, $album);
   my ($name, $sortname, $qname);

   $status = STATUS_ERROR;

   # Pull back all the pertinent info for this mod
   $sth = $this->{DBH}->prepare(qq/select newvalue, rowid 
                                from Changes where id = $id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
        $name = $row[0];
        if ($name =~ /\n/)
        {
           ($sortname, $name) = split /\n/, $name;
        }
        else
        {
           $sortname = $name;
        }
        $qname = $this->{DBH}->quote($name);
        $rowid = $row[1];

        $sth->finish;
        $sth = $this->{DBH}->prepare(qq/select id from Artist where 
                                     name = $qname/);
        $sth->execute;
        if ($sth->rows)
        {
            @row = $sth->fetchrow_array;
            $newid = $row[0];
        }
        else
        {
            $ar = Artist->new($this->{MB});
            $newid = $ar->Insert($name, $sortname);
        }
        $al = Album->new($this->{MB});
        $album = $al->GetIdFromTrackId($row[0]);
        $this->{DBH}->do("update Track set Artist = $newid where id = $rowid");
        $status = STATUS_APPLIED 
   }
   $sth->finish;

   return $status;
}

1;
