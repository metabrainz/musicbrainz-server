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
                                                                               
package Discid;
use TableBase;

BEGIN { require 5.6.1 }
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

# Accessor functions
sub GetAlbum
{
   return $_[0]->{album};
}

sub SetAlbum
{
   $_[0]->{album} = $_[1];
}

sub GetDiscid
{
   return $_[0]->{discid};
}

sub SetDiscid
{
   $_[0]->{discid} = $_[1];
}

sub GetTOC
{
   return $_[0]->{toc};
}

sub SetTOC
{
   $_[0]->{toc} = $_[1];
}

sub GenerateAlbumFromDiscid
{
   my ($this, $rdf, $id, $numtracks, $toc) = @_;
   my ($sql, @row, $album, $di);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $id);

   $sql = Sql->new($this->{DBH});

   # Check to see if the album is in the main database
   $di = Discid->new($this->{DBH});
   if ($sql->Select("select Album from Discid where disc = '$id'"))
   {
        @row = $sql->NextRow();
        $sql->Finish();
        return $rdf->CreateAlbum(0, $row[0]);
   }
   else
   {
        my (@albums, $album, $disc);

        if (!defined $toc || !defined $numtracks)
        {
            return $rdf->CreateStatus(0);
        }

        # Ok, no freedb entries were found. Can we find a fuzzy match?
        @albums = $di->FindFuzzy($numtracks, $toc);
        if (scalar(@albums) > 0)
        {
            return $rdf->CreateAlbum(1, @albums);
        }
        else
        {
            # Ok, its not in the main db. Do we have a freedb entry that
            # matches, but has no Discid?
            $album = $di->FindFreeDBEntry($numtracks, $toc, $id);
            if (defined $album)
            {
                return $rdf->CreateAlbum(0, $album);
            }
            else
            {
                my ($fd, $ref);

                # No fuzzy matches either. Let's pull the records
                # from freedb.org and insert it into the db if we find it.
                $fd = FreeDB->new($this->{DBH});
                $ref = $fd->Lookup($id, $toc);
                if (defined $ref)
                {
                    $fd->InsertForModeration($ref);
                    return $rdf->CreateFreeDBLookup($ref);
                }
                else
                {
                    # No Dice. This CD cannot be found!
                    return $rdf->CreateStatus(0);
                }
            }
        }
   }
}

sub GetAlbumFromDiscid
{
    my ($this, $id) = @_;
    my ($rv, $sql);
 
    $sql = Sql->new($this->{DBH});
    $id = $sql->Quote($id);
    ($rv) = $sql->GetSingleRow("Discid", ["album"], ["disc", $id]);
 
    return $rv;
}

sub GetAlbumAndIdFromDiscid
{
    my ($this, $id) = @_;
    my ($sql);
 
    $sql = Sql->new($this->{DBH});
    $id = $sql->Quote($id);
    return $sql->GetSingleRow("Discid", ["album", "id"], ["disc", $id]);
}

sub GetDiscidFromAlbum
{
    my ($this, $album) = @_;
    my (@row, $sql, @ret);
 
    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select id, disc, toc, modpending 
                          from Discid 
                         where album = $album|))
    {
        while(@row = $sql->NextRow())
        {
            push @ret, { id=>$row[0],
                         discid=>$row[1],
                         toc=>$row[2],
                         modpending=>$row[3] };
        }
        $sql->Finish();
    }
    return @ret;
}

sub Insert
{
    my ($this, $id, $album, $toc) = @_;
    my ($Discidalbum, $sql, $temp, $rowid);

    return if (!defined $id || !defined $album || !defined $toc);

    $Discidalbum = $this->GetAlbumFromDiscid($id);
    if (!defined $Discidalbum)
    {
        $sql = Sql->new($this->{DBH});
        $temp = $sql->Quote($id);
        $sql->Do(qq|insert into Discid (disc,album,toc,
                    modpending) values ($temp, $album, '$toc', 0)|); 

        $rowid = $sql->GetLastInsertId("Discid");
    }

    $this->InsertTOC($id, $album, $toc);

    return $rowid;
}
 
sub InsertTOC
{
    my ($this, $Discid, $album, $toc) = @_;
    my (@offsets, $query, $i, $sql);

    return if (!defined $Discid || !defined $album || !defined $toc);

    @offsets = split / /, $toc;

    $query = "insert into TOC (Discid, Album, Tracks, Leadout, ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
         $query .= "Track" . ($i - 2) . ", ";
    }
    chop($query);
    chop($query);

    $sql = Sql->new($this->{DBH});
    $Discid = $sql->Quote($Discid);
    $query .= ") values ($Discid, $album, ". (scalar(@offsets) - 3) .
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

# Remove an Discid from the database. Set the id via the accessor function.
sub Remove
{
    my ($this, $id) = @_;
    my ($sql);

    return if (!defined $id);
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("delete from Discid where disc = '$id'");
    $sql->Do("delete from TOC where Discid = '$id'");
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

      eval
      {
          $sql->Begin;

          # Once we've found a record that matches exactly, update
          # the missing data (leadout) and the Discid for future use.
          $query = "update TOC set Leadout = $list[2], Discid = '$id' " . 
                   "where id = $row[0]";
          $sql->Do($query);
          $query = "update Discid set Disc = '$id', Toc = '$toc', " .
                   "LastChanged = now() where id = $row[0]";
          $sql->Do($query);

          $sql->Commit;
      };
      if ($@)
      {
          $sql->Rollback;
      }
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

# Load all the aliases for a given artist and return an array of references to alias
# objects. Returns undef if error occurs
sub LoadFull
{
   my ($this, $album) = @_;
   my (@info, $query, $sql, @row, $disc);

   $sql = Sql->new($this->{DBH});
   $query = qq|select id, album, disc, toc 
                 from Discid
                where album = $album
             order by id|;

   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
           $disc = Discid->new($this->{DBH});
           $disc->SetId($row[0]);
           $disc->SetAlbum($row[1]);
           $disc->SetDiscid($row[2]);
           $disc->SetTOC($row[3]);
           push @info, $disc;
       }
       $sql->Finish;

       return \@info;
   }

   return undef;
}
