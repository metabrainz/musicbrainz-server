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
                                                                               
package Album;
use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = (TableBase);
@EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Artist;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

# Accessor functions to set/get the artist id of this album
sub GetArtist
{
   return $_[0]->{artist};
}

sub SetArtist
{
   $_[0]->{artist} = $_[1];
}

# Insert an album that belongs to this artist. The Artist object should've
# been loaded with a LoadFromXXXX call, or the id of this artist must be
# set before this function is called.
sub Insert
{
    my ($this) = @_;
    my ($album, $id, $sql, $name);

    return undef if (!defined $this->{artist});
    return undef if (!defined $this->{name});

    $sql = Sql->new($this->{DBH});
    $name = $sql->Quote($this->{name});
    $id = $sql->Quote($this->CreateNewGlobalId());
    if ($sql->Do(qq/insert into Album (name,artist,gid,modpending)
                values ($name,$this->{artist}, $id, 0)/))
    {
        $album = $sql->GetLastInsertId;
    }

    $this->{id} = $album;
    return $album;
}

# Given an album, query the number of tracks present in this album
# Returns the number of tracks or undef on error
sub GetTrackCount
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{trackcount} || !defined $this->{trackcount})
   {
        $sql = Sql->new($this->{DBH});
        ($this->{trackcount}) = $sql->GetSingleRow("AlbumJoin", 
                                  ["count(*)"], ["album", $this->{id}]);
   }

   return $this->{trackcount};
}

# This function takes a track id and returns an array of album ids
# on which this track appears. The array is empty on error.
sub GetAlbumIdsFromTrackId
{
   my ($this, $trackid) = @_;
   my (@albums, $sql, @row);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq\select distinct album from AlbumJoin where 
                       track=$trackid\))
   {
        while(@row = $sql->NextRow)
        {
            push @albums, $row[0];
        }
        $sql->Finish;
   }

   return @albums;
}

# This function takes a track id and returns an array of album ids
# on which this track appears. The array is empty on error.
sub GetAlbumIdsFromAlbumJoinId
{
   my ($this, $joinid) = @_;
   my (@albums, $sql, @row);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq\select distinct album from AlbumJoin where 
                       id=$joinid\))
   {
        while(@row = $sql->NextRow)
        {
            push @albums, $row[0];
        }
        $sql->Finish;
   }

   return @albums;
}

# Load an album record. Set the album id via the SetId accessor
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
   my ($this) = @_;
   my ($sth, $sql, @row);

   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRow("Album", [qw(id name GID modpending artist)],
                             ["id", $this->{id}]);
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{artist} = $row[4]; 
        return 1;
   }
   return undef;
}

# Load an album record. Set the album name via the SetName accessor
# returns 1 on success, undef otherwise. Access the Album info via the
# accessor functions.
sub LoadFromName
{
   my ($this) = @_;
   my ($sth, $sql, @row);

   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRow("Album", [qw(id name GID modpending artist)],
                             ["name", $sql->Quote($this->{name})]);
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{artist} = $row[4]; 
        return 1;
   }
   return undef;
}

# Load tracks for current album. Returns an array of Track references
# The array is empty if there are no tracks or on error
sub LoadTracks
{
   my ($this) = @_;
   my (@info, $query, $sql, @row, $track);

   $sql = Sql->new($this->{DBH});
   $query = qq/select Track.id, Track.name, Track.artist,
               AlbumJoin.sequence, Track.length,
               Track.modpending, AlbumJoin.modpending from
               Track, AlbumJoin where AlbumJoin.track = Track.id
               and AlbumJoin.album = $this->{id} order by
               AlbumJoin.sequence/;
   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow();)
       {
           $track = Track->new($this->{DBH});
           $track->SetId($row[0]);
           $track->SetName($row[1]);
           $track->SetArtist($row[2]);
           $track->SetSequence($row[3]);
           $track->SetLength($row[4]);
           $track->SetModPending($row[5]);
           $track->SetAlbumJoinModPending($row[6]);
           push @info, $track;
       }
       $sql->Finish;
   }

   return @info;
}

sub LoadTracksFromMultipleArtistAlbum
{
   my ($this) = @_;
   my (@info, $query, $sql, @row, $track);

   $sql = Sql->new($this->{DBH});
   $query = qq/select Track.id, Track.name, Track.artist,
               AlbumJoin.sequence, Track.length,
               Track.modpending, AlbumJoin.modpending, Artist.name from
               Track, AlbumJoin, Artist where AlbumJoin.track = Track.id
               and AlbumJoin.album = $this->{id} and Track.Artist = Artist.id
               order by AlbumJoin.sequence/;
   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow();)
       {
           $track = Track->new($this->{DBH});
           $track->SetId($row[0]);
           $track->SetName($row[1]);
           $track->SetArtist($row[2]);
           $track->SetSequence($row[3]);
           $track->SetLength($row[4]);
           $track->SetModPending($row[5]);
           $track->SetAlbumJoinModPending($row[6]);
           $track->SetArtistName($row[7]);
           push @info, $track;
       }
       $sql->Finish;
   }

   return @info;
}

# Given an album search argument, this function searches for albums
# that match in name, and then ruturns an array of references to arrays
# of album id, album name, artist name, artist id. The array is empty on
# error
sub SearchByName
{
   my ($this, $search) = @_;
   my (@info, $query, $sql, @row);

   # Search for single artist albums
   $query = $this->AppendWhereClause($search, qq/select Album.id, Album.name,
               Artist.name, Artist.id from Album,Artist where Album.artist = 
               Artist.id and /, "Album.Name") . " order by Album.name";
   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow();)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3]];
       }
       $sql->Finish;
   }

   # Now search for multiple artist albums
   $query = $this->AppendWhereClause($search, "select id, name " .
           "from Album where artist = ". Artist::VARTIST_ID ." and ", "Name");
   $query .= " order by name";

   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow();)
       {  
           push @info, [$row[0], $row[1], 
                       'Various Artists', Artist::VARTIST_ID];
       }
       $sql->Finish;
   }

   return @info;
};
