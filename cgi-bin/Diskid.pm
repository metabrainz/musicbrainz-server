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
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

sub GenerateAlbumFromDiskId
{
   my ($this, $doc, $rdf, $id, $numtracks, $toc) = @_;
   my ($sql, @row, $album, $di);

   return $rdf->EmitErrorRDF("No DiskId given.") if (!defined $id);

   $sql = Sql->new($this->{DBH});

   # Check to see if the album is in the main database
   $di = Diskid->new($this->{DBH});
   if ($sql->Select("select Album from Diskid where disk='$id'"))
   {
        @row = $sql->NextRow();
        $sql->Finish();
        return $rdf->CreateAlbum(0, $row[0]);
   }
   else
   {
        # Ok, its not in the main db. Do we have a freedb entry that
        # matches, but has no DiskId?
        $album = $di->FindFreeDBEntry($numtracks, $toc, $id);
        if (defined $album)
        {
            return $rdf->CreateAlbum(0, $album);
        }
        else
        {
            my (@albums, $album, $disk);

            # Ok, no freedb entries were found. Can we find a fuzzy match?
            @albums = $di->FindFuzzy($numtracks, $toc);
            if (scalar(@albums) > 0)
            {
                print STDERR "Found fuzzy\n";
                return $rdf->CreateAlbum(1, @albums);
            }
            else
            {
                my $fd;

                # No fuzzy matches either. Let's pull the records
                # from freedb.org and insert it into the db if we find it.
                $fd = FreeDB->new($this->{DBH});
                $album = $fd->Lookup($id, $toc);
                if (defined $album && $album > 0)
                {
                    print STDERR "Found at freedb.org\n";
                    return $rdf->CreateAlbum(0, $album);
                }
                else
                {
                    print STDERR "no go!\n";
                    # No Dice. This CD cannot be found!
                    return $rdf->CreateStatus(0);
                }
            }
        }
   }
}

sub GetAlbumFromDiskId
{
    my ($this, $id) = @_;
    my ($rv, $sql);
 
    $sql = Sql->new($this->{DBH});
    $id = $sql->Quote($id);
    ($rv) = $sql->GetSingleRow("Diskid", ["album"], ["disk", $id]);
 
    return $rv;
}

sub Insert
{
    my ($this, $id, $album, $toc) = @_;
    my ($diskidalbum, $sql);

    $diskidalbum = $this->GetAlbumFromDiskId($this->{DBH}, $id);
    if (!defined $diskidalbum)
    {
        $sql = Sql->new($this->{DBH});
        $id = $sql->Quote($id);
        $sql->Do("insert into Diskid (disk,album,toc,timecreated) " .
                 "values ($id, $album, '$toc', now())"); 
    }

    $this->InsertTOC($id, $album, $toc);
}
 
sub InsertTOC
{
    my ($this, $diskid, $album, $toc) = @_;
    my (@offsets, $query, $i, $sql);

    @offsets = split / /, $toc;

    $query = "insert into TOC (DiskId, Album, Tracks, Leadout, ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
         $query .= "Track" . ($i - 2) . ", ";
    }
    chop($query);
    chop($query);

    $sql = Sql->new($this->{DBH});
    $diskid = $sql->Quote($diskid);
    $query .= ") values ($diskid, $album, ". (scalar(@offsets) - 3) .
              ", $offsets[2], ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
        $query .= "$offsets[$i], ";
    }
    chop($query);
    chop($query);
    $query .= ")";

    $sql->Do($query);
}

sub FindFreeDBEntry
{
   my ($this, $tracks, $toc, $id) = @_;
   my ($i, $query, @list, $album, @row, $sql);

   return $album if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select id, album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "Track" . ($i-2) . " = $list[$i] and ";
   }
   chop($query); chop($query); chop($query); chop($query); chop($query);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
      @row = $sql->NextRow();
      $sql->Finish;
      $album = $row[1];

      # Once we've found a record that matches exactly, update
      # the missing data (leadout) and the diskid for future use.
      $query = "update TOC set Leadout = $list[2], Diskid = '$id' " . 
               "where id = $row[0]";
      $sql->Do($query);
      $query = "update Diskid set Disk = '$id', Toc = '$toc', " .
               "LastChanged = now() where id = $row[0]";
      $sql->Do($query);
   }

   return $album;
}

sub FindFuzzy
{
   my ($this, $tracks, $toc) = @_;
   my ($i, $query, @list, @albums, @row, $sth, $sql);

   return @albums if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "abs(Track" . ($i - 2) . " - $list[$i]) < 1000 and ";
   }
   chop($query); chop($query); chop($query); chop($query);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
      while(@row = $sql->NextRow())
      {
          push @albums, $row[0];
      }
      $sql->Finish;
   }

   return @albums;
}
