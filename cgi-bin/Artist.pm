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
                                                                               
package Artist;

use TableBase;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Carp qw(cluck);
use DBI;
use DBDefs;
use Alias;
use Album;
use Track;
use String::Similarity;

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
    ($artist) = $sql->GetSingleRowLike("Artist", ["id"], 
                                       ["name", $sql->Quote($this->{name})]); 
    if (!defined $artist)
    {
         $mbid = $sql->Quote($this->CreateNewGlobalId());
         if ($sql->Do(qq/insert into Artist (name, sortname, gid, 
                     modpending) values (/ . $sql->Quote($this->{name}) .
                     ", " . $sql->Quote($this->{sortname}) . ", $mbid, 0)"))
         {
             $artist = $sql->GetLastInsertId('Artist');
             $this->{new_insert} = 1;
         }
    } 
    $this->{id} = $artist;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
    $engine->AddWordRefs($artist,$this->{name});

    return $artist;
}

# Remove an artist from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $refcount);

    return if (!defined $this->GetId());

    $sql = Sql->new($this->{DBH});


    $sql->Do("delete from ArtistAlias where ref = " . $this->GetId());
    $sql->Do("update Moderation set Artist = " . ModDefs::DARTIST_ID . 
             " where artist = " . $this->GetId());

    # Remove references from artist words table
    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Artist' } );
    $engine->RemoveObjectRefs($this->GetId());

    print STDERR "DELETE: Removed artist " . $this->GetId() . "\n";
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

   # First try to find the artist by name
   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRowLike("Artist", 
                                 [qw(id name GID modpending sortname)],
                                 ["name", $sql->Quote($artistname)]);
   if (!defined $row[0])
   {
        # If that failed, then try to find the artist by sortname
        @row = $sql->GetSingleRowLike("Artist", 
                                      [qw(id name GID modpending sortname)],
                                      ["sortname", $sql->Quote($artistname)]);
   }
   if (!defined $row[0])
   {
        my ($artist, $alias);

        # If that failed too, then try the artist aliases
        $alias = Alias->new($this->{DBH});

        # Check to see if the artist has an alias.
        $alias->{table} = "ArtistAlias";
        $artist = $alias->Resolve($artistname);
        if (defined $artist)
        {
            @row = $sql->GetSingleRow("Artist", 
                           [qw(id name GID modpending sortname)],
                           ["id", $artist]);
        }
   }
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

# Load an artist record given a sortname. The name must match exactly.
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromSortname
{
   my ($this, $sortname) = @_;
   my ($sql, @row);

   $sql = Sql->new($this->{DBH});
   @row = $sql->GetSingleRowLike("Artist", 
                                 [qw(id name GID modpending sortname)],
                                 ["sortname", $sql->Quote($sortname)]);
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

# Load an artist and all the aliases, albums, tracks, disc ids, tocs and TRM ids
# returns 1 on success, undef otherwise. 
sub LoadFull
{
   my ($this) = @_;
   my ($sql, @row, $ret, $alias, $al);

   if (!defined $this->GetId())
   {
       cluck "Artist::LoadFull is called with undef Id\n"; 
       return undef;
   }

   if ($this->GetId() == ModDefs::VARTIST_ID ||
       $this->GetId() == ModDefs::DARTIST_ID)
   {
       cluck "Artist::LoadFull cannot be used to load this artist.\n"; 
       return undef;
   }

   $ret = $this->LoadFromId();
   if (defined $ret)
   {
       $alias = Alias->new($this->{DBH});
       $alias->{table} = "ArtistAlias";
       $ret = $alias->LoadFull($this->GetId());
       if (defined $ret)
       {
           $this->{"_aliases"} = $ret;
       }

       $al = Album->new($this->{DBH});
       $ret = $al->LoadFull($this->GetId());
       if (defined $ret)
       {
           $this->{"_albums"} = $ret;

           return 1;
       }
   }
   return undef;
}

# Search for an artist by name. The name my be a substring match.
# returns an array of references to an array of artist id, name, sortname,
# The array is empty if there are no matches.
#sub SearchByName
#{
#   my ($this, $search) = @_;
#   my (@info, $query, $sql, $i, @row);
#
#   $sql = Sql->new($this->{DBH});
#   $query = $this->AppendWhereClause($search, qq/select id, name, sortname 
#                    from Artist where /, "name") . " order by sortname";
#   if ($sql->Select($query))
#   {
#       for(;@row = $sql->NextRow;)
#       {  
#           push @info, [$row[0], $row[1], $row[2]];
#       }
#   }
#   $sql->Finish;
#
#   return @info;
#};

# Pull back a section of artist names for the browse artist display.
# Given an index character ($ind), a page offset ($offset) and a page length
# ($max_items) it will return an array of references to an array
# of artistid, sortname, modpending. The array is empty on error.
sub GetArtistDisplayList
{
   my ($this, $ind, $offset, $max_items) = @_;
   my ($query, $num_artists, @info, @row, $sql, $ind_len); 

   $ind_len = length($ind);
   return undef if ($ind_len <= 0);

   $sql = Sql->new($this->{DBH});
   
   if ($ind =~ m/_/)
   {
      $ind =~ s/_/[^A-Za-z]/g;
      $ind = "^$ind";

      if ($sql->Select("select count(*) from Artist where sortname ~ '$ind'"))
      {
          @row = $sql->NextRow();
          $sql->Finish();
          $num_artists = $row[0];
      }
      return undef if (!defined $num_artists);

      $query = qq/select id, sortname, modpending 
                  from   Artist 
                  where  sortname ~ '$ind'
                  order  by sortname 
                  limit  $max_items offset $offset/;
   }
   else
   {
      ($num_artists) =  $sql->GetSingleRowLike("Artist", ["count(*)"], 
                               ["substring(sortname from 1 for $ind_len)", 
                                $sql->Quote($ind)]);
      return undef if (!defined $num_artists);

      $query = qq/select id, sortname, modpending 
                    from Artist 
                   where substring(sortname from 1 for $ind_len) ilike '$ind' 
                order by sortname 
                   limit $max_items offset $offset/;
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
                       Album where artist=$this->{id} order by name/))
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
       Album.modpending, Album.gid from Track, Album, AlbumJoin 
       where Track.Artist = 
       $this->{id} and AlbumJoin.track = Track.id and AlbumJoin.album = 
       Album.id and Album.artist = / . ModDefs::VARTIST_ID ." order by 
       Album.name"))
   {
        while(@row = $sql->NextRow)
        {
            $album = Album->new($this->{DBH});
            $album->SetId($row[0]);
            $album->SetName($row[1]);
            $album->SetModPending($row[2]);
            $album->SetArtist(ModDefs::VARTIST_ID);
            $album->SetMBId($row[3]);
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
   if ($sql->Select(qq/select id, name, modpending 
                         from Album 
                        where name ilike $name and 
                              artist = $this->{id}/))
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

# Checks to see if an album by the given name exists. If no exact match is
# found, then it will attempt a fuzzy match
sub HasAlbum
{
   my ($this, $albumname, $threshold) = @_;
   my (@albums, $sql, @row, $album, @matches, $sim);

   # First, pull in the single artist albums
   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq/select id, name from 
                       Album where artist=$this->{id} order by name/))
   {
        while(@row = $sql->NextRow)
        {
            if (lc($row[1]) eq lc($albumname))
            {
                push @matches, { id=>$row[0], match=>1, name=>$row[1] };
            }
            else
            {
                $sim = similarity($albumname, $row[1]);
                if ($sim >= $threshold)
                {
                    push @matches, { id=>$row[0], match=>$sim, name=>$row[1] };
                }
            }
        }
        $sql->Finish;
   }

   # then, pull in the multiple artist albums
   if ($sql->Select(qq/select distinct AlbumJoin.album, Album.name
                         from Track, Album, AlbumJoin 
                        where Track.Artist = $this->{id} and 
                              AlbumJoin.track = Track.id and 
                              AlbumJoin.album = Album.id and 
                              Album.artist = / . ModDefs::VARTIST_ID .
                   " order by Album.name"))
   {
        while(@row = $sql->NextRow)
        {
            if (lc($row[1]) eq lc($albumname))
            {
                push @matches, { id=>$row[0], match=>1, name=>$row[1] };
            }
            else
            {
                $sim = similarity($albumname, $row[1]);
                if ($sim >= $threshold)
                {
                    push @matches, { id=>$row[0], match=>$sim, name=>$row[1] };
                }
            }
        }
        $sql->Finish;
   }

   return @matches;
} 
