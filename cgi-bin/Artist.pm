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
                                                                               
package Artist;

use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Carp qw(cluck);
use DBI;
use DBDefs;
use Alias;

# Use the following id for the multiple/various artist albums
use constant VARTIST_ID => 1;
# Use the following id to reference artist that have been deleted.
# This will be used only by the moderation system
use constant DARTIST_ID => 2;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

# Artist specific accessor function. Others are inherted from TableBase 
sub GetSortName
{
   return $_[0]->{sortname};
}

sub SetSortName
{
   $_[0]->{sortname} = $_[1];
}

# Insert an artist into the DB and return the artist id. Returns undef
# on error. The name and sortname of this artist must be set via the accesor
# functions.
sub Insert
{
    my ($this) = @_;
    my ($artist, $mbid, $sql, $alias);

    $this->{new_insert} = 0;

    return undef if (!defined $this->{name});
    $this->{sortname} = $this->{name} if (!defined $this->{sortname});
  
    $sql = Sql->new($this->{DBH});
    $alias = Alias->new($this->{DBH});

    # Check to see if the artist has an alias.
    $alias->{table} = "ArtistAlias";
    $artist = $alias->Resolve($this->{name});
    return $artist if (defined $artist);

    # Check to see if this artist already exists
    ($artist) = $sql->GetSingleRow("Artist", ["id"], 
                                   ["name", $sql->Quote($this->{name})]); 
    if (!defined $artist)
    {
         $mbid = $sql->Quote($this->CreateNewGlobalId());
         if ($sql->Do(qq/insert into Artist (name, sortname, gid, 
                     modpending) values (/ . $sql->Quote($this->{name}) .
                     ", " . $sql->Quote($this->{sortname}) . ", $mbid, 0)"))
         {
             $artist = $sql->GetLastInsertId;
             $this->{new_insert} = 1;
         }
    } 
    $this->{id} = $artist;
    return $artist;
}

# Remove an artist from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $refcount);

    return if (!defined $this->GetId());

    $sql = Sql->new($this->{DBH});

    # See if there are any tracks that needs this artist
    ($refcount) = $sql->GetSingleRow("Track", ["count(*)"],
                                   [ "Track.artist", $this->GetId()]);
    return undef if ($refcount > 0);
  
    # See if there are any albums that needs this artist
    ($refcount) = $sql->GetSingleRow("Album", ["count(*)"],
                                   [ "Album.artist", $this->GetId()]);
    return undef if ($refcount > 0);
  
    $sql->Do("delete from Artist where id = " . $this->GetId());

    return 1;
}

# Load an artist record given a name. The name must match exactly.
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromName
{
   my ($this, $artistname) = @_;
   my ($sql, @row);

   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRow("Artist", [qw(id name GID modpending sortname)],
                             ["name", $sql->Quote($artistname)]);
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{sortname} = $row[4];
        return 1;
   }
   return undef;
}

# Load an artist record given an artist id.
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
   my ($this) = @_;
   my ($sql, @row);

   if (!defined $this->GetId())
   {
        cluck "Artist::LoadFromId is called with undef Id\n"; 
        return undef;
   }

   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRow("Artist", [qw(id name GID modpending sortname)],
                             ["id", $this->GetId()]);
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{sortname} = $row[4];
        return 1;
   }
   return undef;
}

# Search for an artist by name. The name my be a substring match.
# returns an array of references to an array of artist id, name, sortname,
# The array is empty if there are no matches.
sub SearchByName
{
   my ($this, $search) = @_;
   my (@info, $query, $sql, $i, @row);

   $sql = Sql->new($this->{DBH});
   $query = $this->AppendWhereClause($search, qq/select id, name, sortname 
                    from Artist where /, "name") . " order by sortname";
   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow;)
       {  
           push @info, [$row[0], $row[1], $row[2]];
       }
   }
   $sql->Finish;

   return @info;
};

# Pull back a section of artist names for the browse artist display.
# Given an index character ($ind), a page offset ($offset) and a page length
# ($max_items) it will return an array of references to an array
# of artistid, sortname, modpending. The array is empty on error.
sub GetArtistDisplayList
{
   my ($this, $ind, $offset, $max_items) = @_;
   my ($query, $num_artists, @info, @row, $sql); 

   $sql = Sql->new($this->{DBH});
   ($num_artists) =  $sql->GetSingleRow("Artist", ["count(*)"], 
                                        ["left(sortname, 1)", 
                                         $sql->Quote($ind)]);
   return undef if (!defined $num_artists);
   
   if ($ind == '1')
   {
      $query = qq/select id, sortname, modpending 
                  from   Artist 
                  where  left(sortname, 1) < 'A' or
                         left(sortname, 1) > 'Z' 
                  order  by sortname 
                  limit  $offset, $max_items/;
   }
   else
   {
      $query = qq/select id, sortname, modpending from 
               Artist where left(sortname, 1) = '$ind' order by sortname 
               limit $offset, $max_items/;
   }
   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow;)
       {
           push @info, [$row[0], $row[1], $row[2]];
       }
       $sql->Finish;   
   }

   return ($num_artists, @info);
}

# retreive the set of albums by this artist. Returns an array of 
# references to Album objects. Refer to the Album object for details.
# The returned array is empty on error. Multiple artist albums are
# also returned by this query. Use SetId() to set the id of artist
sub GetAlbums
{
   my ($this) = @_;
   my (@albums, $sql, @row, $album);

   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select id, name, modpending, GID from 
                       Album where artist=$this->{id}/))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist($this->{id});
            $album->SetMBId($row[3]);
            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   # then, pull in the multiple artist albums
   if ($sql->Select(qq/select distinct AlbumJoin.album, Album.name, 
       Album.modpending from Track, Album, AlbumJoin where Track.Artist = 
       $this->{id} and AlbumJoin.track = Track.id and AlbumJoin.album = 
       Album.id and Album.artist = / . Artist::VARTIST_ID ." order by 
       Album.name"))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist(Artist::VARTIST_ID);
            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   return @albums;
} 

# Retreive the set of albums by this artist given a name. Returns an array of 
# references to Album objects. Refer to the Album object for details.
sub GetAlbumsByName
{
   my ($this, $name) = @_;
   my (@albums, $sql, @row, $album);

   return undef if (!exists $this->{id});
   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   $name = $sql->Quote($name);
   if ($sql->Select(qq/select id, name, modpending from Album where 
                       name=$name and artist = $this->{id}/))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist($this->{id});
            push @albums, $album;
            undef $album;
        }
        $sql->Finish;
   }

   return @albums;
} 

sub FindArtist
{
   my ($this, $search) = @_;
   my (@names, $query, $sql);

   $sql = Sql->new($this->{DBH});
   $query = $this->AppendWhereClause($search, qq/select id, name, sortname
               from Artist where /, "name") . " order by sortname";

   if ($sql->Select($query))
   {
       my @row;
       my $i;

       for(;@row = $sql->NextRow();)
       {
           push @names, $row[0];
           push @names, $row[1];
           push @names, $row[2];
       }
       $sql->Finish;
   }

   return @names;
};

