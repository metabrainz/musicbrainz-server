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
                                                                               
package Album;
use TableBase;

BEGIN { require 5.8.0 }
use vars qw(@ISA @EXPORT);
@ISA    = (TableBase);
@EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Artist;
use Track;
use Discid;
use TRM;
use SearchEngine;
use ModDefs;
use Text::Unaccent;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode );

use constant ALBUM_ATTR_NONALBUMTRACKS => 0;

use constant ALBUM_ATTR_ALBUM          => 1;
use constant ALBUM_ATTR_SINGLE         => 2;
use constant ALBUM_ATTR_EP             => 3;
use constant ALBUM_ATTR_COMPILATION    => 4;
use constant ALBUM_ATTR_SOUNDTRACK     => 5;
use constant ALBUM_ATTR_SPOKENWORD     => 6;
use constant ALBUM_ATTR_INTERVIEW      => 7;
use constant ALBUM_ATTR_AUDIOBOOK      => 8;
use constant ALBUM_ATTR_LIVE           => 9;
use constant ALBUM_ATTR_REMIX          => 10;
use constant ALBUM_ATTR_OTHER          => 11;

use constant ALBUM_ATTR_OFFICIAL       => 100;
use constant ALBUM_ATTR_PROMOTION      => 101;
use constant ALBUM_ATTR_BOOTLEG        => 102;

use constant ALBUM_ATTR_SECTION_TYPE_START   => ALBUM_ATTR_ALBUM;
use constant ALBUM_ATTR_SECTION_TYPE_END     => ALBUM_ATTR_OTHER;
use constant ALBUM_ATTR_SECTION_STATUS_START => ALBUM_ATTR_OFFICIAL;
use constant ALBUM_ATTR_SECTION_STATUS_END   => ALBUM_ATTR_BOOTLEG;

my %AlbumAttributeNames = (
    0 => [ "Non Album Track", "Non Album Tracks", "(Special case)"],
    1 => [ "Album", "Albums", "An album release primarily consists of previously unreleased material."],
    2 => [ "Single", "Singles", "A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song."],
    3 => [ "EP", "EPs", "An EP is an Extended Play release which should contain the letters EP in the title. EP releases have become rare."],
    4 => [ "Compilation", "Compilations", "A compilation is a collection of previously released tracks by one or more artists."],
    5 => [ "Soundtrack", "Soundtracks", "A soundtrack is the musical score to a movie."],
    6 => [ "Spokenword", "Spokenword", "Non-music spoken word releases."],
    7 => [ "Interview", "Interviews", "An interview release contains an interview with the Artist."],
    8 => [ "Audiobook", "Audiobooks", "An audiobook is a book read by a narrator without music."],
    9 => [ "Live", "Live Releases", "A release that was recorded live."],
    10 => [ "Remix", "Remixes", "A release that was (re)mixed from previously released material."],
    11 => [ "Other", "Other Releases", "Any release that does not fit any of the categories above."],

    100 => [ "Official", "Official", "Any release officially sanctioned by the artist and/or their record company. (Most releases will fit into this category.)"],
    101 => [ "Promotion", "Promotions", "A giveaway release or a release intended to promote an upcoming official release. (e.g. prerelease albums or releases included with a magazine)"],
    102 => [ "Bootleg", "Bootlegs", "An unofficial/underground release that was not sanctioned by the artist and/or the record company."]
);

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   $this->{attrs} = [ 0 ];
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

sub GetAttributeName
{
   return $AlbumAttributeNames{$_[1]}->[0];
}

sub GetAttributeNamePlural
{
   return $AlbumAttributeNames{$_[1]}->[1];
}

sub GetAttributeDescription
{
   return $AlbumAttributeNames{$_[1]}->[2];
}

sub GetAttributes
{
   my @attrs = @{ $_[0]->{attrs }};

   # Shift off the mod pending indicator
   shift @attrs;

   return @attrs;
}

sub SetAttributes
{
   my $this = shift @_;
   $this->{attrs} = [ ${ $this->{attrs }}[0], @_ ];
}

sub GetAttributeList
{
   return \%AlbumAttributeNames;
}

sub GetAttributeModPending
{
   return ${$_[0]->{attrs}}[0]
}

sub IsNonAlbumTracks
{
   my @attrs = @{$_[0]->{attrs}};
   return (scalar(@attrs) == 2 && $attrs[1] == 0);
}

use Data::Dumper;

# Insert an album that belongs to this artist. The Artist object should've
# been loaded with a LoadFromXXXX call, or the id of this artist must be
# set before this function is called.
sub Insert
{
    my ($this) = @_;
    my ($album, $id, $sql, $name, $attrs, $page);

    $this->{new_insert} = 0;
    return undef if (!exists $this->{artist} || $this->{artist} eq '');
    return undef if (!exists $this->{name} || $this->{name} eq '');

    $sql = Sql->new($this->{DBH});
    $name = $sql->Quote($this->{name});
    $id = $sql->Quote($this->CreateNewGlobalId());
    $attrs = "'{" . join(',', @{ $this->{attrs} }) . "}'";
    $page = $this->CalculatePageIndex($this->{name});

    # No need to check for an insert clash here since album name is not unique
    if ($sql->Do(qq/insert into Album (name,artist,gid,modpending,attributes,page)
                values ($name,$this->{artist}, $id, 0, $attrs, $page)/))
    {
        $album = $sql->GetLastInsertId('Album');
        $this->{new_insert} = 1;
    }

    $this->{id} = $album;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

    my $engine = SearchEngine->new($this->{DBH}, { Table => 'Album' } );
    $engine->AddWordRefs($album,$this->{name});

    return $album;
}

# Remove an album from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $sql2, $album, @row, @row2);

    $album = $this->GetId();
    return if (!defined $album);
  
    $sql = Sql->new($this->{DBH});
    print STDERR "DELETE: Removed TOC where album was " . $album . "\n";
    $sql->Do("delete from TOC where album = $album");
    print STDERR "DELETE: Removed Discid where album was " . $album . "\n";
    $sql->Do("delete from Discid where album = $album");

    if ($sql->Select(qq|select AlbumJoin.track from AlbumJoin 
                         where AlbumJoin.album = $album|))
    {
         my $tr = Track->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             print STDERR "DELETE: Removed albumjoin " . $row[0] . "\n";
             $sql->Do("delete from AlbumJoin where track=$row[0]");
             $tr->SetId($row[0]);
             $tr->Remove();
         }
         $sql->Finish;
    }

    # Remove references from album words table
    my $engine = SearchEngine->new($this->{DBH},  { Table => 'Album' } );
    $engine->RemoveObjectRefs($this->GetId());

    print STDERR "DELETE: Removed Album " . $album . "\n";
    $sql->Do("delete from Album where id = $album");

    return 1;
}

sub LoadAlbumMetadata
{
   my ($this) = @_;
   my ($sql);

   $sql = Sql->new($this->{DBH});
   ($this->{trackcount}, $this->{discidcount}, $this->{trmidcount}) = 
         $sql->GetSingleRow("albummeta", ["tracks, discids, trmids"], ["id", $this->{id}]);
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
       $this->LoadAlbumMetadata();
   }

   return $this->{trackcount};
}

# Given an album, query the number of discids present in this album
# Returns the number of discids or undef on error
sub GetDiscidCount
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{discidcount} || !defined $this->{discidcount})
   {
       $this->LoadAlbumMetadata();
   }

   return $this->{discidcount};
}
# Returns the number of TRM ids for this album or undef on error
sub GetTrmidCount
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{trmidcount} || !defined $this->{trmidcount})
   {
       $this->LoadAlbumMetadata();
   }

   return $this->{trmidcount};
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
   my ($this, $loadmeta) = @_;
   my ($sth, $sql, @row, @where);

   if (!defined $this->GetId() && !defined $this->GetMBId())
   {
        return undef;
   }

   $sql = Sql->new($this->{DBH});
   if (defined $this->GetId())
   {
        @where = ("album.id", $this->{id});
   }
   else
   {
        @where = ("gid", $sql->Quote($this->GetMBId()));
   }
   if (defined $loadmeta && $loadmeta)
   {
        @row = $sql->GetSingleRow("Album, Albummeta", [qw(album.id name GID modpending 
                                  artist attributes tracks discids trmids)],
                                  [ @where, "album.id", "albummeta.id" ]);
   }
   else
   {
        @row = $sql->GetSingleRow("Album", [qw(album.id name GID modpending artist attributes)],
                                  \@where);
   }

   if (defined $row[0])
   {
        $this->{id} = $row[0];
        $this->{name} = $row[1];
        $this->{mbid} = $row[2];
        $this->{modpending} = $row[3];
        $this->{artist} = $row[4]; 
        $row[5] =~ s/^\{(.*)\}$/$1/;
        $this->{attrs} = [ split /,/, $row[5] ];
        if (defined $loadmeta && $loadmeta)
        {
            $this->{trackcount} = $row[6];
            $this->{discidcount} = $row[7];
            $this->{trmidcount} = $row[8];
        }

        return 1;
   }
   return undef;
}

# This function returns a list of album ids for a given artist and album name.
sub GetAlbumListFromName
{
   my ($this, $name) = @_;
   my (@info, $sql, @row);

   return undef if (!exists $this->{artist} || $this->{artist} eq '');

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select gid, name
                         from Album
                        where name = | . $sql->Quote($name) . qq| and
                              artist = | . $this->{artist}))
   {
       while(@row = $sql->NextRow())
       {
           push @info, { mbid=>$row[0], name=>$row[1] };
       }
       $sql->Finish;
   }

   return @info;
}

# Load tracks for current album. Returns an array of Track references
# The array is empty if there are no tracks or on error
sub LoadTracks
{
   my ($this, $full) = @_;
   my (@info, $query, $query2, $sql, $sql2, @row, @row2, $track, $trm);

   $sql = Sql->new($this->{DBH});
   $trm = TRM->new($this->{DBH});
   $query = qq|select Track.id, Track.name, Track.artist,
                      AlbumJoin.sequence, Track.length,
                      Track.modpending, AlbumJoin.modpending, Track.GID 
               from   Track, AlbumJoin 
               where  AlbumJoin.track = Track.id
                      and AlbumJoin.album = $this->{id} 
             order by AlbumJoin.sequence|;

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
           $track->SetMBId($row[7]);

           if (defined $full && $full)
           {
               my $ret = $trm->LoadFull($row[0]);
               if (defined $ret)
               {
                   $track->{"_trms"} = $ret;
               }
           }

           push @info, $track;
       }
       $sql->Finish;
   }

   return @info;
}

# Load tracks for the given artist. Returns a reference to an array of references to
# album objects, or undef if no albums or error
sub LoadFull
{
   my ($this, $artist) = @_;
   my (@info, $query, $sql, @row, $album, $di, $ret);

   $sql = Sql->new($this->{DBH});
   $di = Discid->new($this->{DBH});
   $query = qq|select id, name, artist, gid 
                 from Album 
                where artist = $artist 
                order by lower(name), name|;
   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
           $album = Album->new($this->{DBH});
           $album->SetId($row[0]);
           $album->SetName($row[1]);
           $album->SetArtist($row[2]);
           $album->SetMBId($row[3]);
           my @tracks = $album->LoadTracks(1);
           if (scalar(@tracks) > 0)
           {
               $album->{"_tracks"} = \@tracks;
           }

           $ret = $di->LoadFull($row[0]);
           if (defined $ret)
           {
               $album->{"_discids"} = $ret;
           }
           push @info, $album;
       }
       $sql->Finish;
   
       return \@info;
   }

   return undef;
}

sub LoadTracksFromMultipleArtistAlbum
{
   my ($this) = @_;
   my (@info, $query, $sql, @row, $track);

   $sql = Sql->new($this->{DBH});
   $query = qq/select Track.id, Track.name, Track.artist, AlbumJoin.sequence, 
                      Track.length, Track.modpending, AlbumJoin.modpending, 
                      Artist.name, Track.gid 
                 from Track, AlbumJoin, Artist 
                where AlbumJoin.track = Track.id and 
                      AlbumJoin.album = $this->{id} and 
                      Track.Artist = Artist.id
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
           $track->SetMBId($row[8]);
           push @info, $track;
       }
       $sql->Finish;
   }

   return @info;
}

# Load trmid counts for current album. Returns an array of Track references
# The array is empty if there are no tracks or on error
sub LoadTRMCount
{
   my ($this) = @_;
   my ($query, $sql, @row, %trmcount);

   $sql = Sql->new($this->{DBH});
   $query = qq|select AlbumJoin.track, count(TRMJoin.track) as num_trm 
                 from AlbumJoin, TRMJoin 
                where AlbumJoin.album = $this->{id} and 
                      AlbumJoin.track = TRMJoin.track 
             group by AlbumJoin.track, AlbumJoin.sequence, albumjoin.id 
             order by AlbumJoin.sequence, AlbumJoin.id|;

   if ($sql->Select($query))
   {
       for(;@row = $sql->NextRow();)
       {
           $trmcount{$row[0]} = $row[1];
       }
       $sql->Finish;
   }

   return \%trmcount;
}

# Given a list of albums, this function will merge the list of albums into
# the current album. All Discids and TRM Ids are preserved in the process
sub MergeAlbums
{
   my ($this, $intoMAC, @list) = @_;
   my ($al, $ar, $tr, @tracks, %merged, $id, $sql);
   
   return undef if (scalar(@list) < 1);

   @tracks = $this->LoadTracks();
   return undef if (scalar(@tracks) == 0);

   # Create a hash that contains the original album
   foreach $tr (@tracks)
   {
      $merged{$tr->GetSequence()} = $tr;
   }

   $sql = Sql->new($this->{DBH});
   # If we're merging into a MAC, then set this album to a MAC album
   if ($intoMAC)
   {
      $sql->Do("update Album set artist = " . ModDefs::VARTIST_ID . 
               " where id = " . $this->GetId());
   }

   $al = Album->new($this->{DBH});
   foreach $id (@list)
   {
       $al->SetId($id);
       next if (!defined $al->LoadFromId());

       @tracks = $al->LoadTracks();
       foreach $tr (@tracks)
       {
           if (exists $merged{$tr->GetSequence()})
           {
                # We already have that track. Move any existing TRMs
                # to the existing track
                $sql->Do("update TRMJoin set track = " .
                         $merged{$tr->GetSequence()}->GetId() . 
                         " where track = " . $tr->GetId());
           }
           else
           {
                # We don't already have that track
                $sql->Do("update AlbumJoin set Album = " . 
                         $this->GetId() . " where track = " . $tr->GetId());
                $merged{$tr->GetSequence()} = $tr;
           }

           if (!$intoMAC)
           {
                # Move that the track to the target album's artist
                $sql->Do("update Track set artist = " . $this->GetArtist() .
                         " where id = " . $tr->GetId());
           }                
       }

       # Also merge the Discids
       $sql->Do("update Discid set Album = " . $this->GetId() . 
                " where Album = $id");
       $sql->Do("update TOC set Album = " . $this->GetId() . 
                " where Album = $id");

       # Then, finally remove what is left of the old album
       $al->Remove();
   }

   return 1;
}


# Pull back a section of various artist albums for the browse various display.
# Given an index character ($ind), a page offset ($offset) and a page length
# ($max_items) it will return an array of references to an array
# of albumid, sortname, modpending. The array is empty on error.
sub GetVariousDisplayList
{
   my ($this, $ind, $offset) = @_;
   my ($query, $num_albums, @info, @row, $sql, $page, $page_max, $ind_max, $un); 

   return if length($ind) <= 0;

   $sql = Sql->new($this->{DBH});

   use locale;
   # TODO set LC_COLLATE too?
   my $saver = new LocaleSaver(LC_CTYPE, "en_US.UTF-8");
  
   $num_albums = 0;
   ($page, $page_max) = $this->CalculatePageIndex($ind);
   $query = qq|select id, name, modpending 
                    from Album 
                   where page >= $page and page <= $page_max and
                         album.artist = | . ModDefs::VARTIST_ID;
   if ($sql->Select($query))
   {
       $num_albums = $sql->Rows();
       for(;@row = $sql->NextRow;)
       {
           my $temp = unac_string('UTF-8', $row[1]);
	   $temp = lc decode("utf-8", $temp);

           # Remove all non alpha characters to sort cleaner
           $temp =~ tr/A-Za-z0-9 //cd;

           # Change space to 0 since perl has some FUNKY collate order
           $temp =~ tr/ /0/;
           push @info, [$row[0], $row[1], $row[2], $temp];
       }
       $sql->Finish;   

       @info = sort { $a->[3] cmp $b->[3] } @info;
       splice @info, 0, $offset;

       # Only return the three things we said we would
       splice(@$_, 3) for @info;
   }

   return ($num_albums, @info);
}

sub UpdateAttributes
{
   my ($this) = @_;
   my ($sql, $attr);

   # I got a 
   #   Use of uninitialized value in join or string at ../cgi-bin/Album.pm line 630
   # that needs to be investigated
   $attr = join ',', @{ $this->{attrs}};
   $sql = Sql->new($this->{DBH});
   $sql->Do("update Album set Attributes = '{$attr}' where id = $this->{id}");
}
