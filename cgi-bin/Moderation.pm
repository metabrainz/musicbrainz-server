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

use constant MOD_EDIT_ARTISTNAME         => 1;
use constant MOD_EDIT_ARTISTSORTNAME     => 2;
use constant MOD_EDIT_ALBUMNAME          => 3;
use constant MOD_EDIT_TRACKNAME          => 4;
use constant MOD_EDIT_TRACKNUM           => 5;

my %ModNames = (
    "1" => "Edit Artist Name",
    "2" => "Edit Artist Sortname",
    "3" => "Edit Album Name",
    "4" => "Edit Track Name",
    "5" => "Edit Track Number" 
);

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub GetModificationName
{
   return $ModNames{$_[0]};
}

sub InsertModification
{
    my ($this, $table, $column, $artist, $type, $id, $prev, $new, $uid) = @_;

    $this->{DBH}->do(qq/update $table set modpending = modpending + 1  
                        where id = $id/);

    $table = $this->{DBH}->quote($table);
    $column = $this->{DBH}->quote($column);
    $prev = $this->{DBH}->quote($prev);
    $new = $this->{DBH}->quote($new);
    $this->{DBH}->do(qq/insert into Changes (tab, col, rowid, prevvalue, 
           newvalue, timesubmitted, moderator, yesvotes, novotes, artist, 
           type) values ($table, $column, $id, $prev, $new, now(), $uid, 0, 0,
           $artist, $type)/);
}

sub GetModerationList
{
   my ($this, $index, $num, $uid) = @_;
   my ($sth, @data, $num_mods, @row, @votes, $vote, $voted);

   $sth = $this->{DBH}->prepare(qq/select count(*) from Changes/);
   $sth->execute();
   $num_mods = ($sth->fetchrow_array)[0];
   $sth->finish;   

   $sth = $this->{DBH}->prepare(qq/select rowid from Votes where uid = $uid
                                order by rowid/);
   $sth->execute;
   if ($sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @votes, $row[0];
        }
   }
   $sth->finish;   

   $sth = $this->{DBH}->prepare(qq/select Changes.id, tab, col, rowid, 
         Changes.artist, type, prevvalue, newvalue, 
         UNIX_TIMESTAMP(TimeSubmitted), 
         ModeratorInfo.name, yesvotes, novotes, Artist.name 
         from Changes, ModeratorInfo, 
         Artist where ModeratorInfo.id = moderator and Changes.artist = 
         Artist.id order by artist, type limit $index, $num/);
   $sth->execute;
   if ($sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            $voted = 0;
            foreach $vote (@votes)
            {
               if ($vote == $row[0])
               {
                   $voted = 1;
                   last;
               }
            }
            $row[8] += DBDefs::MOD_PERIOD;
            push @data, [@row, $voted];
        }
   }
   $sth->finish;

   return ($num_mods, @data);
}

sub InsertVotes
{
   my ($this, $uid, $yeslist, $nolist) = @_;
   my (@votes, $num_votes, $vote, $ok, $i, $yesno, $yes_votes);
   my ($sth, @row, $val);

   $sth = $this->{DBH}->prepare(qq/select rowid from Votes where uid = $uid
                                order by rowid/);
   $sth->execute;
   if ($sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @votes, $row[0];
        }
   }
   $sth->finish;

   $num_votes = scalar(@votes);
   $yes_votes = scalar(@{$yeslist});
   $i = 0;
   foreach $val (@{$yeslist}, @{$nolist})
   {
      $ok = 1;
      foreach $vote (@votes)
      {
          if ($vote == $val)
          {
              $ok = 0;
              last;
          }
      }
      if ($ok)
      {
          $yesno = ($i >= $yes_votes) ? 0 : 1;
          $this->{DBH}->do(qq/insert into Votes (uid, rowid, vote) values
                           ($uid, $val, $yesno)/); 
          if ($yesno)
          {
              $this->{DBH}->do(qq/update Changes set yesvotes = yesvotes + 1
                               where id = $val/); 
          }
          else
          {
              $this->{DBH}->do(qq/update Changes set novotes = novotes + 1
                               where id = $val/); 
          }
      }
      $i++;
   }

   $this->CheckModifications((@{$yeslist}, @{$nolist}))
}

sub CheckModificationsForExpiredItems
{
   my ($this) = @_;
   my ($sth, @ids, @row); 

   $sth = $this->{DBH}->prepare(qq/select id from Changes where 
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted) > / 
              . DBDefs::MOD_PERIOD);
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
   my ($sth, $rowid, @row); 

   while(defined($rowid = shift @ids))
   {
       $sth = $this->{DBH}->prepare(qq/select yesvotes, novotes,
              UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(TimeSubmitted),
              tab, rowid, moderator from Changes where id = $rowid/);
       $sth->execute;
       if ($sth->rows)
       {
            @row = $sth->fetchrow_array;

            # Has the vote period expired?
            if ($row[2] >= DBDefs::MOD_PERIOD)
            {
                # Are there more yes votes than no votes?
                if ($row[0] > $row[1])
                {
                    $this->ApplyModification($rowid);
                    $this->CreditModerator($row[5], 1);
                }
                else
                {
                    $this->CreditModerator($row[5], 0);
                }
                $this->RemoveModification($rowid, $row[3], $row[4]);
            }
            # Are the number of required unanimous votes present?
            elsif ($row[0] == DBDefs::NUM_UNANIMOUS_VOTES && $row[1] == 0)
            {
                # A unanimous yes. Apply and the remove from db
                $this->ApplyModification($rowid);
                $this->CreditModerator($row[5], 1);
                $this->RemoveModification($rowid, $row[3], $row[4]);
            }
            elsif ($row[1] == DBDefs::NUM_UNANIMOUS_VOTES && $row[0] == 0)
            {
                # A unanimous no. Remove from db
                $this->CreditModerator($row[5], 0);
                $this->RemoveModification($rowid, $row[3], $row[4]);
            }
       }
       $sth->finish;
   }
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

sub RemoveModification
{
   my ($this, $rowid, $table, $datarowid) = @_;

   # Decrement the mod count in the data row
   $this->{DBH}->do(qq/update $table set modpending = modpending - 1
                       where id = $datarowid/);

   # Remove the row from Changes
   $this->{DBH}->do(qq/delete from Changes where id = $rowid/);

   # Remove the votes that correspond to the Changes
   $this->{DBH}->do(qq/delete from Votes where rowid = $rowid/);
}

sub ApplyModification
{
   my ($this, $rowid) = @_;
   my ($sth, @row, $prevval, $newval, $table, $column, $datarowid);

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
            }
        }
   }
   $sth->finish;
}

1;
