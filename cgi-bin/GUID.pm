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
                                                                               
package GUID;
use TableBase;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = (TableBase);
@EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

sub GetTrackIdsFromGUID
{
   my ($this, $guid) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   return $sql->GetSingleColumn("GUIDJoin, GUID", "track",
                                ["GUID.guid", $sql->Quote($guid), 
                                "GUID.id", "GUIDJoin.guid"]);
}

sub GetIdFromGUID
{
   my ($this, $guid) = @_;
   my ($sql, $id);

   $sql = Sql->new($this->{DBH});
   ($id) = $sql->GetSingleRow("GUID", ["id"], ["guid", $sql->Quote($guid)]);

   return $id;
}

sub GetGUIDFromTrackId
{
   my ($this, $id) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   return $sql->GetSingleColumn("GUIDJoin, GUID", "GUID.guid", 
                                ["GUIDJoin.track", $id,
                                 "GUIDJoin.guid", "GUID.id"]);
}

sub Insert
{
    my ($this, $guid, $trackid) = @_;
    my ($id, $sql);

    $this->{new_insert} = 0;
    $sql = Sql->new($this->{DBH});

    $id = $this->GetIdFromGUID($guid);
    $guid = $sql->Quote($guid);
    if (!defined $id)
    {
        if ($sql->Do(qq/insert into GUID (guid) values ($guid)/))
        {
            $id = $sql->GetLastInsertId;
            $this->{new_insert} = 1;
        }
    }

    if (defined $id && defined $trackid)
    {
        my ($temp) = $sql->GetSingleRow("GUIDJoin, GUID", 
                                         ["GUIDJoin.id"], 
                                         ["GUIDJoin.track", $trackid,
                                          "GUIDJoin.guid", "GUID.id",
                                          "GUID.guid", $guid]);
        if (!defined $temp)
        {
            $sql->Do(qq/insert into GUIDJoin (guid, track) values 
                       ($id, $trackid)/);
        }
    }
    return $id;
}

# Remove a GUID from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql);

    return undef if (!defined $this->GetId());
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("delete from GUID where id = " . $this->GetId());
    $sql->Do("delete from GUIDJoin where guid = " . $this->GetId());

    return 1;
}

# Remove all the GUID/GUIDJoins from the database for a given track id. 
sub RemoveByTrackId
{
    my ($this, $trackid) = @_;
    my ($sql, $sql2, $refcount, @row);

    return undef if (!defined $trackid);
 
    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq|select GUIDJoin.id, GUIDJoin.guid from GUIDJoin
                         where GUIDJoin.track = $trackid|))
    {
         $sql2 = Sql->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             $sql->Do("delete from GUIDJoin where id = $row[0]");
             ($refcount) = $sql2->GetSingleRow("GUIDJoin", ["count(*)"],
                                              [ "GUIDJoin.guid", $row[1]]);
             if ($refcount == 0)
             {
                $sql->Do("delete from GUID where id=$row[1]");
             }
         }
         $sql->Finish;
    }

    return 1;
}

sub AssociateGUID
{
    my ($this, $guid, $name, $artist, $album) = @_;
    my ($id, $sql, @row);

    $sql = Sql->new($this->{DBH});
    $artist = $sql->Quote($artist);
    $album = $sql->Quote($album);
    $name = $sql->Quote($name);
    if ($sql->Select(qq\select Track.id from Artist, Album, Track, AlbumJoin
                        where Artist.name = $artist and Album.name = $album and
                        Track.name = $name and Track.artist = Artist.id and
                        Track.id = AlbumJoin.track and AlbumJoin.album =
                        Album.id\))
    {
       while(@row = $sql->NextRow())
       {
           $this->Insert($guid, $row[0]);
       }
       $sql->Finish();
       
       return 1;
    }
    return 0;
}
