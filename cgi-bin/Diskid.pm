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
                                                                               
package Diskid;
use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub GetAlbumFromDiskId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $id = $this->{DBH}->quote($id);
   $sth = $this->{DBH}->prepare("select album from Diskid where disk=$id");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];

   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub Insert
{
    my ($this, $id, $album, $toc) = @_;
    my ($diskidalbum, $sql);

    $diskidalbum = GetAlbumFromDiskId($this, $id);
    if ($diskidalbum < 0)
    {
        $sql = $this->{DBH}->quote($id);
        $this->{DBH}->do("insert into Diskid (disk,album,toc,timecreated) " .
                         "values ($sql, $album, '$toc', now())"); 
    }

    InsertTOC($this, $id, $album, $toc);
}
 
sub InsertTOC
{
    my ($this, $diskid, $album, $toc) = @_;
    my (@offsets, $query, $i);

    @offsets = split / /, $toc;

    $query = "insert into TOC (DiskId, Album, Tracks, Leadout, ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
         $query .= "Track" . ($i - 2) . ", ";
    }
    chop($query);
    chop($query);

    $diskid = $this->{DBH}->quote($diskid);
    $query .= ") values ($diskid, $album, ". (scalar(@offsets) - 3) .
              ", $offsets[2], ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
        $query .= "$offsets[$i], ";
    }
    chop($query);
    chop($query);
    $query .= ")";

    $this->{DBH}->do($query);
}

sub FindFreeDBEntry
{
   my ($this, $tracks, $toc, $id) = @_;
   my $sth;
   my @row;
   my ($i, $query, @list, $album);

   return $album if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select id, album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "Track" . ($i-2) . " = $list[$i] and ";
   }
   chop($query); chop($query); chop($query); chop($query); chop($query);

   $sth = $this->{DBH}->prepare($query);
   $sth->execute;
   if ($sth->rows == 1)
   {
      @row = $sth->fetchrow_array;
      $album = $row[1];

      # Once we've found a record that matches exactly, update
      # the missing data (leadout) and the diskid for future use.
      $query = "update TOC set Leadout = $list[2], Diskid = '$id' " . 
               "where id = $row[0]";
      $this->{DBH}->do($query);
      $query = "update Diskid set Disk = '$id', Toc = '$toc', " .
               "LastChanged = now() where id = $row[0]";
      $this->{DBH}->do($query);
   }
   $sth->finish;

   return $album;
}

sub FindFuzzy
{
   my ($this, $tracks, $toc) = @_;
   my $sth;
   my @row;
   my ($i, $query, @list, @albums);

   return @albums if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "abs(Track" . ($i - 2) . " - $list[$i]) < 1000 and ";
   }
   chop($query); chop($query); chop($query); chop($query);

   $sth = $this->{DBH}->prepare($query);
   $sth->execute;
   if ($sth->rows)
   {
      while(@row = $sth->fetchrow_array)
      {
          push @albums, $row[0];
      }
   }
   $sth->finish;

   return @albums;
}

1;
