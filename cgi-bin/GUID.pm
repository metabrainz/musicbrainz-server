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
                                                                               
package GUID;
use TableBase;

BEGIN { require 5.003 }
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
   my ($sql, $guid);

   $sql = Sql->new($this->{DBH});
   ($guid) = $sql->GetSingleRow("GUIDJoin, GUID", ["GUID.guid"], 
                                ["GUIDJoin.track", $id,
                                 "GUIDJoin.guid", "GUID.id"]);
   return $guid;
}

sub Insert
{
    my ($this, $guid, $trackid) = @_;
    my ($id, $sql);

    $sql = Sql->new($this->{DBH});

    $id = $this->GetIdFromGUID($guid);
    if (!defined $id)
    {
        $guid = $sql->Quote($guid);
        if ($sql->Do(qq/insert into GUID (guid) values ($guid)/))
        {
            $id = $sql->GetLastInsertId;
        }
    }
    if (defined $id && defined $trackid)
    {
        $sql->Do(qq/insert into GUIDJoin (guid, track) values 
                   ($id, $trackid)/);
    }
    return $id;
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
