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

package Track;
use TableBase;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Artist;
use Album;
use Alias;
use ModDefs;

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

# This is only used for tracks from multiple artist albums
sub GetArtistName
{
   return $_[0]->{artistname};
}

sub SetArtistName
{
   $_[0]->{artistname} = $_[1];
}

sub GetAlbum
{
   return $_[0]->{album};
}

sub SetAlbum
{
   $_[0]->{album} = $_[1];
}

sub GetSequence
{
   return $_[0]->{sequence};
}

sub SetSequence
{
   $_[0]->{sequence} = $_[1];
}

sub GetSequenceId
{
   return $_[0]->{sequenceid};
}

sub SetSequenceId
{
   $_[0]->{sequenceid} = $_[1];
}

sub GetLength
{
   return $_[0]->{length};
}

sub SetLength
{
   $_[0]->{length} = $_[1];
}

sub GetComment
{
   return $_[0]->{comment};
}

sub SetComment
{
   $_[0]->{comment} = $_[1];
}

sub GetGenre
{
   return $_[0]->{genre};
}

sub SetGenre
{
   $_[0]->{genre} = $_[1];
}

sub GetModPending
{
   return $_[0]->{modpending};
}

sub SetModPending
{
   $_[0]->{modpending} = $_[1];
}

sub GetAlbumJoinModPending
{
   return $_[0]->{albumjoinmodpending};
}

sub SetAlbumJoinModPending
{
   $_[0]->{albumjoinmodpending} = $_[1];
}

# Given an albumjoin id, determine the track id and load it
sub LoadFromAlbumJoin
{
   my ($this, $albumjoinid) = @_;
   my ($sql, $trackid);

   $sql = Sql->new($this->{DBH});
   ($trackid) = $sql->GetSingleRow("AlbumJoin", ["Track"], 
                                   ["AlbumJoin.id", $albumjoinid]);
   return undef if (!defined $trackid);

   $this->SetId($trackid);
   return $this->LoadFromId();
}

# Load a track. Set the track id and the album id via the SetId and SetAlbum
# Accessor functions. Return true on success, undef otherwise
sub LoadFromId
{
   my ($this) = @_;
   my ($sth, $sql, @row);

   if (!defined $this->GetId() && !defined $this->GetMBId())
   {
        return undef;
   }

   $sql = Sql->new($this->{DBH});
   if (exists $this->{album})
   {
       if (defined $this->GetId())
       {
           @row = $sql->GetSingleRow("Track, AlbumJoin", 
                             [qw(Track.id Track.name GID sequence length 
                                 Track.artist Track.modpending 
                                 AlbumJoin.modpending AlbumJoin.id)],
                             ["Track.id", $this->GetId(),
                              "AlbumJoin.track", "Track.id",
                              "AlbumJoin.album", $this->{album}]);
       }
       else
       {
           @row = $sql->GetSingleRow("Track, AlbumJoin", 
                             [qw(Track.id Track.name GID sequence length 
                                 Track.artist Track.modpending 
                                 AlbumJoin.modpending AlbumJoin.id)],
                             ["Track.gid", $sql->Quote($this->GetMBId()),
                              "AlbumJoin.track", "Track.id",
                              "AlbumJoin.album", $this->{album}]);
       }
   }
   else
   {
       if (defined $this->GetId())
       {
           @row = $sql->GetSingleRow("Track, AlbumJoin", 
                             [qw(Track.id Track.name GID sequence length 
                                 Track.artist Track.modpending 
                                 AlbumJoin.modpending AlbumJoin.id)],
                             ["Track.id", $this->GetId(),
                              "AlbumJoin.track", "Track.id"]);
       }
       else
       {
           @row = $sql->GetSingleRow("Track, AlbumJoin", 
                             [qw(Track.id Track.name GID sequence length 
                                 Track.artist Track.modpending 
                                 AlbumJoin.modpending AlbumJoin.id)],
                             ["Track.gid", $sql->Quote($this->GetMBId()),
                              "AlbumJoin.track", "Track.id"]);
       }
   }
   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{sequence} = $row[3];
        $this->{length} = $row[4];
        $this->{artist} = $row[5];
        $this->{modpending} = $row[6];
        $this->{albumjoinmodpending} = $row[7];
        $this->{sequenceid} = $row[8];
        return 1;
   }
   return undef;
}

sub GetMetadataFromIdAndAlbum
{
    my ($this, $id, $albumname) = @_;
    my (@row, $sql, $artist, $album, $seq, @TRM);
    my ($ar, $gu);

    $artist = "Unknown";
    $album = "Unknown";
    $seq = 0;

    $this->SetId($id);
    if (!defined $this->LoadFromId())
    {
         return ();
    }

    $ar = Artist->new($this->{DBH});
    $ar->SetId($this->GetArtist());
    if (!defined $ar->LoadFromId())
    {
         return ();
    }

    $gu = TRM->new($this->{DBH});
    @TRM = $gu->GetTRMFromTrackId($id);
    if (scalar(@TRM) == 0)
    {
         return ();
    }

    $sql = Sql->new($this->{DBH});
    if ($sql->Select(qq/select name, sequence 
                          from Album, AlbumJoin 
                         where AlbumJoin.track = $id and 
                               Album.id = AlbumJoin.album/))
    {
         # if this track appears on one album only, return that one
         if ($sql->Rows == 1)
         {
             @row = $sql->NextRow;
             $seq = $row[1];
             $album = $row[0];
         }
         else
         {
             if (defined $albumname)
             {
                 $albumname = unac_string("UTF-8", $albumname);
                 $albumname = lc decode("utf-8", $albumname);
             }
             
             while(@row = $sql->NextRow)
             {
                my $temp = unac_string("UTF-8", $row[0]);
                $temp = lc decode("utf-8", $temp);

                if (not defined $albumname || $temp eq $albumname)
                {
                   $seq = $row[1];
                   $album = $row[0];
                   last;
                }
             }
         }
         $sql->Finish;
    }

    return ($this->GetName(), $ar->GetName(), $album, $seq, $TRM[0]->{TRM}); 
}

# This function inserts a new track. A properly initialized/loaded album
# must be passed in. If this is a multiple artist album, a fully
# inited/loaded artist must also be passed in. The new track id is returned
sub Insert
{   
    my ($this, $al, $ar) = @_;
    my ($track, $id, $query, $values, $sql, $artist, $album, $name);

    return undef if ($this->GetName() eq '');
  
    $this->{new_insert} = 0;
    $album = $al->GetId();
    $artist = ($al->GetArtist() == ModDefs::VARTIST_ID) ? 
                $ar->GetId() : $al->GetArtist();

    return undef if (!defined $artist);

    $sql = Sql->new($this->{DBH});
    $name = $sql->Quote($this->{name});
    ($track) = $sql->GetSingleRowLike("Track, AlbumJoin", ["Track.id"],
                                      ["name", $name,
                                      "AlbumJoin.track", "Track.id",
                                      "AlbumJoin.album", $album,
                                      "AlbumJoin.sequence", $this->{sequence}]);
    if (!defined $track)
    {
        $id = $sql->Quote($this->CreateNewGlobalId());
        $query = "insert into Track (name,gid,artist,modpending";
        $values = "values ($name, $id, $artist, 0";

        if (exists $this->{length} && $this->{length} != 0)
        {
            $query .= ",length";
            $values .= ", $this->{length}";
        }
        if (exists $this->{year} && $this->{year} != 0)
        {
            $query .= ",year";
            $values .= ", $this->{year}";
        }
        if (exists $this->{genre} && $this->{genre} ne '')
        {
            $query .= ",genre";
            $values .= ", " . $sql->Quote($this->{genre});
        }
        if (exists $this->{filename} && $this->{filename} ne '')
        {
            $query .= ",filename";
            $values .= ", " . $sql->Quote($this->{filename});
        }
        if (exists $this->{comment} && $this->{comment} ne '')
        {
            $query .= ",comment";
            $values .= ", " . $sql->Quote($this->{comment});
        }

        $sql->Do("$query) $values)");

	$track = $sql->GetLastInsertId("Track");
	$this->{new_insert} = $track;
	$sql->Do(qq/insert into AlbumJoin (album, track, sequence,
		modpending) values ($album, $track, 
		$this->{sequence}, 0)/);
    }

    $this->{id} = $track;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    my $engine = SearchEngine->new($this->{DBH},  { Table => 'Track' } );
    $engine->AddWordRefs($track,$this->{name});

    return $track;
}

# Remove a track from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, @row, $refcount, $gu);

    return undef if (!defined $this->GetId());
  
    $sql = Sql->new($this->{DBH});
    ($refcount) = $sql->GetSingleRow("AlbumJoin", ["count(*)"],
                                     [ "AlbumJoin.track", $this->GetId()]);
    if ($refcount > 0)
    {
        print STDERR "DELETE: refcount = $refcount on track delete " .
                     $this->GetId() . "\n";
        return undef 
    }

    $gu = TRM->new($this->{DBH});
    $gu->RemoveByTrackId($this->GetId());

    print STDERR "DELETE: Remove track " . $this->GetId() . "\n";
    $sql->Do("delete from Track where id = " . $this->GetId());

    # Remove references from track words table
    my $engine = SearchEngine->new($this->{DBH},  { Table => 'Track' } );
    $engine->RemoveObjectRefs($this->GetId());

    return 1;
}

sub GetAlbumInfo
{
   my ($this) = @_;
   my ($sql, @row, @info);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select album, name, sequence, GID 
                         from AlbumJoin, Album 
                        where AlbumJoin.album = Album.id and 
                              track = | . $this->GetId()))
   {
       for(;@row = $sql->NextRow();)
       {
           push @info, [@row];
       }
       $sql->Finish;
   }

   return @info;
}

1;
