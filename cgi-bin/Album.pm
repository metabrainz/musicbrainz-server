#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
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
{ our @ISA = qw( TableBase ) }

use strict;
use Carp qw( cluck croak );
use DBDefs;
use ModDefs qw( VARTIST_ID );
use Text::Unaccent;
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode );

use constant NONALBUMTRACKS_NAME => "[non-album tracks]";

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
    0 => [ "Non-Album Track", "Non-Album Tracks", "(Special case)"],
    1 => [ "Album", "Albums", "An album release primarily consists of previously unreleased material. This includes album re-issues, with or without bonus tracks."],
    2 => [ "Single", "Singles", "A single typically has one main song and possibly a handful of additional tracks or remixes of the main track. A single is usually named after its main song."],
    3 => [ "EP", "EPs", "An EP is an Extended Play release and often contains the letters EP in the title."],
    4 => [ "Compilation", "Compilations", "A compilation is a collection of previously released tracks by one or more artists."],
    5 => [ "Soundtrack", "Soundtracks", "A soundtrack is the musical score to a movie, TV series, stage show, computer game etc."],
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
	my $class = shift;
	my $self = $class->SUPER::new(@_);
	$self->{attrs} = [ 0 ];
	$self;
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

sub GetCoverartURL
{
   return "/images/no_coverart.png" unless $_[0]->{coverarturl};
   return "http://images.amazon.com" . $_[0]->{coverarturl};
}

sub GetAsin
{
   return ($_[0]{asin}||"") =~ /(\S+)/ ? $1 : ""
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
   my @attrs = @{ $_[0]->{attrs}};

   # Shift off the mod pending indicator
   shift @attrs;

   return @attrs;
}

sub GetReleaseTypeAndStatus
{
	my $self = shift;
	my @attrs = $self->GetAttributes;
	my ($type, $status);
	for ($self->GetAttributes)
	{
		return () if $_ == ALBUM_ATTR_NONALBUMTRACKS;
		$type   = $_ if $_ >= ALBUM_ATTR_SECTION_TYPE_START   and $_ <= ALBUM_ATTR_SECTION_TYPE_END;
		$status = $_ if $_ >= ALBUM_ATTR_SECTION_STATUS_START and $_ <= ALBUM_ATTR_SECTION_STATUS_END;
	}
	($type, $status);
}

sub SetAttributes
{
   my $this = shift @_;
   $this->{attrs} = [ ${ $this->{attrs}}[0], @_ ];
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

sub FindNonAlbum
{
	my ($this, $artist) = @_;
	$artist ||= $this->GetArtist;

	my $sql = Sql->new($this->{DBH});
	my $ids = $sql->SelectSingleColumnArray(
		"SELECT id FROM album WHERE artist = ?
		AND attributes[2] = " . &ALBUM_ATTR_NONALBUMTRACKS,
		$artist,
	);

	map {
		my $id = $_;
		my $o = $this->new($this->{DBH});
		$o->SetId($id);
		$o->LoadFromId
			or die;
		$o;
	} @$ids;
}

sub CombineNonAlbums
{
	my ($class, @albums) = @_;

	$_->{_tracks} = [ $_->LoadTracks ]
		for @albums;

	# The obvious algorithm is to keep the one with the most tracks.
	@albums = sort {
		@{$b->{_tracks}} <=> @{$a->{_tracks}}
	} @albums;

	my @tracks = map { @{ $_->{_tracks} } } @albums;

	for (@tracks)
	{
		my $temp = unac_string('UTF-8', $_->GetName);
		$temp = lc decode("utf-8", $temp);
		$_->{_name} = $temp;
	}

	# Sort tracks alphabetically
	@tracks = sort {
		$a->{_name} cmp $b->{_name}
			or
		$a->GetId <=> $b->GetId
	} @tracks;

	$tracks[$_-1]{_new_sequence} = $_
		for 1..@tracks;

	# Move all the tracks onto the first album
	my $album = shift @albums;
	my $sql = Sql->new($album->{DBH});

	for my $t (@tracks)
	{
		$sql->Do(
			"UPDATE albumjoin SET album = ?, sequence = ?
				WHERE track = ? AND album = ?",
			$album->GetId,
			$t->{_new_sequence},
			$t->GetId,
			$t->GetAlbum,
		) or die;
	}

	# Delete the other albums
	for my $del (@albums)
	{
		$del->LoadTracks == 0 or die;
		$del->Remove;
	}

	$album;
}

sub GetOrInsertNonAlbum
{
	my ($this, $artist) = @_;
	$artist ||= $this->GetArtist;

	my @albums = $this->FindNonAlbum($artist);

	if (@albums)
	{
		@albums = (ref $this)->CombineNonAlbums(@albums)
			if @albums > 1;
		return $albums[0];
	}

	# There doesn't seem to be a non-album for this artist, so we'll
	# insert one.
	$this->SetArtist($artist);
	$this->SetName(&NONALBUMTRACKS_NAME);
	$this->SetAttributes(&ALBUM_ATTR_NONALBUMTRACKS);
	my $id = $this->Insert;

	$this->LoadFromId
		or die;
	return $this;
}

sub GetNextFreeTrackId
{
	my $self = shift;
	$self->IsNonAlbumTracks or die;

	my $sql = Sql->new($self->{DBH});
	my $used = $sql->SelectSingleColumnArray(
		"SELECT sequence FROM albumjoin WHERE album = ?",
		$self->GetId,
	);
	my %used = map { $_=>1 } @$used;

	# This is probably adequate for a while to come.
	for (my $seq = 1; ; ++$seq)
	{
		return $seq unless $used{$seq};
	}
}

# Insert an album that belongs to this artist. The Artist object should've
# been loaded with a LoadFromXXXX call, or the id of this artist must be
# set before this function is called.
sub Insert
{
    my ($this) = @_;

    $this->{new_insert} = 0;
    return undef if (!exists $this->{artist} || $this->{artist} eq '');
    return undef if (!exists $this->{name} || $this->{name} eq '');

    my $sql = Sql->new($this->{DBH});
    my $id = $this->CreateNewGlobalId();
    my $attrs = "{" . join(',', @{ $this->{attrs} }) . "}";
    my $page = $this->CalculatePageIndex($this->{name});

    # No need to check for an insert clash here since album name is not unique
    $sql->Do(
		"INSERT INTO album (name, artist, gid, modpending, attributes, page)
			VALUES (?, ?, ?, 0, ?, ?)",
		$this->{name},
		$this->{artist},
		$id,
		$attrs,
		$page,
	);

    my $album = $sql->GetLastInsertId('Album');
    $this->{new_insert} = 1;

    $this->{id} = $album;

    # Add search engine tokens.
    # TODO This should be in a trigger if we ever get a real DB.

	unless ($this->IsNonAlbumTracks)
	{
		$this->RebuildWordList;
	}

    return $album;
}

# Remove an album from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql, $album, @row);

    $album = $this->GetId();
    return if (!defined $album);
  
    $sql = Sql->new($this->{DBH});
    print STDERR "DELETE: Removed TOC where album was " . $album . "\n";
    $sql->Do("DELETE FROM toc WHERE album = ?", $album);
    print STDERR "DELETE: Removed Discid where album was " . $album . "\n";
    $sql->Do("DELETE FROM discid WHERE album = ?", $album);

    print STDERR "DELETE: Removed release where album was " . $album . "\n";
	require MusicBrainz::Server::Release;
	my $rel = MusicBrainz::Server::Release->new($sql->{DBH});
	$rel->RemoveByAlbum($album);

    if ($sql->Select(qq|select AlbumJoin.track from AlbumJoin 
                         where AlbumJoin.album = $album|))
    {
		require Track;
         my $tr = Track->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             print STDERR "DELETE: Removed albumjoin " . $row[0] . "\n";
             $sql->Do("DELETE FROM albumjoin WHERE track = ?", $row[0]);
             $tr->SetId($row[0]);
             $tr->Remove();
         }
    }
	$sql->Finish;

    # Remove references from album words table
	require SearchEngine;
    my $engine = SearchEngine->new($this->{DBH}, 'album');
    $engine->RemoveObjectRefs($this->GetId());

    print STDERR "DELETE: Removed Album " . $album . "\n";
    $sql->Do("DELETE FROM album WHERE id = ?", $album);

    return 1;
}

sub LoadAlbumMetadata
{
 	my ($this) = @_;
	my $sql = Sql->new($this->{DBH});

	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM albummeta WHERE id = ?",
		$this->GetId,
	);

	if ($row)
	{
		$this->{trackcount} = $row->{tracks};
		$this->{discidcount} = $row->{discids};
		$this->{trmidcount} = $row->{trmids};
		$this->{firstreleasedate} = $row->{firstreleasedate} || "";
	} else {
		warn "No albummeta row for album #".$this->GetId."\n";
		delete @$this{qw( trackcount discidcount trmidcount firstreleasedate )};
	}
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

# Returns the first release date for this album or undef on error
# If there is no first release date (i.e. there are no releases), then the
# empty string is returned.
sub GetFirstReleaseDate
{
	my ($this) = @_;
	$this->{id} or return undef;

	$this->LoadAlbumMetadata
		unless defined $this->{firstreleasedate};

 	$this->{firstreleasedate};
}

# Fetches the first release date as a triple of integers.  Missing parts are
# zero.
sub GetFirstReleaseDateYMD
{
	map { 0+$_ } split '-', ($_[0]->GetFirstReleaseDate || "0-0-0");
}

# This function takes a track id and returns an array of album ids
# on which this track appears. The array is empty on error.
sub GetAlbumIdsFromTrackId
{
	my ($this, $trackid) = @_;
	my $sql = Sql->new($this->{DBH});

	my $r = $sql->SelectSingleColumnArray(
		"SELECT	a.id
		FROM	album a, albumjoin j
		WHERE	j.track = ?
		AND		j.album = a.id
		ORDER BY a.attributes[1]",
		$trackid,
	);

	@$r;
}

# Load an album record. Set the album id via the SetId accessor
# returns 1 on success, undef otherwise. Access the artist info via the
# accessor functions.
sub LoadFromId
{
	my ($this, $loadmeta) = @_;
	my ($idcol, $idval);

	if ($this->GetId)
	{
		$idcol = "id";
		$idval = $this->GetId;
	}
	elsif ($this->GetMBId)
	{
		$idcol = "gid";
		$idval = $this->GetMBId;
	}
	else
	{
		cluck "Album::LoadFromId called with no id or gid";
		return undef;
	}

	my $sql = Sql->new($this->{DBH});
	my $row = $sql->SelectSingleRowArray(
		"SELECT	a.id, name, gid, modpending, artist, attributes"
		. ($loadmeta ? ", tracks, discids, trmids, firstreleasedate,coverarturl,asin" : "")
		. " FROM album a"
		. ($loadmeta ? " INNER JOIN albummeta m ON m.id = a.id" : "")
		. " WHERE	a.$idcol = ?",
		$idval,
	) or return undef;

	$this->{id}			= $row->[0];
	$this->{name}		= $row->[1];
	$this->{mbid}		= $row->[2];
	$this->{modpending}	= $row->[3];
	$this->{artist}		= $row->[4]; 
	$this->{attrs}		= [ $row->[5] =~ /(\d+)/g ];

	delete @$this{qw( trackcount discidcount trmidcount firstreleasedate asin coverarturl )};
	delete @$this{qw( _discids _tracks )};

	if ($loadmeta)
	{
		$this->{trackcount}		= $row->[6];
		$this->{discidcount}	= $row->[7];
		$this->{trmidcount}		= $row->[8];
		$this->{firstreleasedate}=$row->[9] || "";
		$this->{coverarturl}=$row->[10] || "";
		$this->{asin}=$row->[11] || "";
	}

	1;
}

# This function returns a list of album ids for a given artist and album name.
sub GetAlbumListFromName
{
   my ($this, $name) = @_;
   my (@info, $sql, @row);

   return undef if (!exists $this->{artist} || $this->{artist} eq '');

   $sql = Sql->new($this->{DBH});
   if ($sql->Select("select gid, name
                         from Album
                        where name = ? and
                              artist = ?",
		$name, $this->{artist},
    ))
   {
       while(@row = $sql->NextRow())
       {
           push @info, { mbid=>$row[0], name=>$row[1] };
       }
   }
   $sql->Finish;

   return @info;
}

# Load tracks for current album. Returns an array of Track references
# The array is empty if there are no tracks or on error
sub LoadTracks
{
	my ($this) = @_;
	my $sql = Sql->new($this->{DBH});
   
	if (not wantarray)
	{
		return $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM albumjoin WHERE album = ?",
			$this->GetId,
		);
	}

   my (@info, $query, $query2, @row, $track, $trm);

   require TRM;
   $trm = TRM->new($this->{DBH});
   $query = qq|select Track.id, Track.name, Track.artist,
                      AlbumJoin.sequence, Track.length,
                      Track.modpending, AlbumJoin.modpending, Track.GID 
               from   Track, AlbumJoin 
               where  AlbumJoin.track = Track.id
                      and AlbumJoin.album = ?
             order by AlbumJoin.sequence|;

   if ($sql->Select($query, $this->{id}))
   {
       for(;@row = $sql->NextRow();)
       {
		   require Track;
           $track = Track->new($this->{DBH});
           $track->SetId($row[0]);
           $track->SetName($row[1]);
           $track->SetAlbum($this->{id});
           $track->SetArtist($row[2]);
           $track->SetSequence($row[3]);
           $track->SetLength($row[4]);
           $track->SetModPending($row[5]);
           $track->SetAlbumJoinModPending($row[6]);
           $track->SetMBId($row[7]);
           push @info, $track;
       }
   }

   $sql->Finish;

   return @info;
}

# Find all releases for this album.  Returns a list of M::S::Release objects.
sub Releases
{
	my $self = shift;
	require MusicBrainz::Server::Release;
	my $rel = MusicBrainz::Server::Release->new($self->{DBH});
	$rel->newFromAlbum($self->GetId);
}

sub GetDiscIDs
{
	my $self = shift;

	unless (defined $self->{"_discids"})
	{
		require Discid;
		my $di = Discid->new($self->{DBH});
		my $ret = $di->LoadFull($self->GetId);
		$self->{"_discids"} = ($ret || 0);
	}

	$self->{"_discids"} || undef;
}

sub GetTracks
{
	my $self = shift;

	unless (defined $self->{"_tracks"})
	{
		my @tracks = $self->LoadTracks;
		$self->{"_tracks"} = \@tracks;
	}

	$self->{"_tracks"} || undef;
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
                      AlbumJoin.album = ? and 
                      Track.Artist = Artist.id
             order by AlbumJoin.sequence/;
   if ($sql->Select($query, $this->{id}))
   {
       for(;@row = $sql->NextRow();)
       {
		   require Track;
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
   }
   $sql->Finish;

   return @info;
}

# Fetch TRM counts for each track of the current album.
# Returns a reference to a hash, where the keys are track IDs and the values
# are the TRM counts.  Tracks with no TRMs may or may not be in the hash.
sub LoadTRMCount
{
 	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $counts = $sql->SelectListOfLists(
		"SELECT	albumjoin.track, COUNT(trmjoin.track) AS num_trm
		FROM	albumjoin, trmjoin
		WHERE	albumjoin.album = ?
		AND		albumjoin.track = trmjoin.track
	   	GROUP BY albumjoin.track",
		$this->GetId,
	);

	+{
		map {
			$_->[0] => $_->[1]
		} @$counts
	};
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
		$sql->Do(
			"UPDATE album SET artist = ? WHERE id = ?",
			VARTIST_ID,
			$this->GetId,
		);
   }

   require Album;
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
				my $old = $tr->GetId;
				my $new = $merged{$tr->GetSequence()}->GetId;

				$sql->Do(
					"DELETE FROM trmjoin WHERE track = ?
						AND trm IN (SELECT trm FROM trmjoin WHERE track = ?)",
					$old,
					$new,
				);

                $sql->Do(
					"UPDATE trmjoin SET track = ? WHERE track = ?",
					$new,
					$old,
				);
           }
           else
           {
                # We don't already have that track
                $sql->Do(
					"UPDATE albumjoin SET album = ? WHERE track = ?",
					$this->GetId,
					$tr->GetId,
				);
                $merged{$tr->GetSequence()} = $tr;
           }

           if (!$intoMAC)
           {
                # Move that the track to the target album's artist
                $sql->Do(
					"UPDATE track SET artist = ? WHERE id = ?",
					$this->GetArtist,
					$tr->GetId,
				);
           }                
       }

       # Also merge the Discids
		$sql->Do(
			"UPDATE discid SET album = ? WHERE album = ?",
			$this->GetId,
			$id,
		);
		$sql->Do(
			"UPDATE toc SET album = ? WHERE album = ?",
			$this->GetId,
			$id,
		);

		# And the releases
		require MusicBrainz::Server::Release;
		my $rel = MusicBrainz::Server::Release->new($sql->{DBH});
		$rel->MoveFromAlbumToAlbum($id, $this->GetId);

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
 	my ($this, $ind, $offset, $limit, $reltype, $relstatus, $artists) = @_;

	# Build a query to fetch the things we need
	my ($page_min, $page_max) = $this->CalculatePageIndex($ind);
	my $query = "
		SELECT	a.id, name, gid, modpending, artist, attributes,
				tracks, discids, trmids, firstreleasedate, coverarturl, asin
   		FROM	album a, albummeta m
	  	WHERE	a.page BETWEEN $page_min AND $page_max
		AND		m.id = a.id
	";

	$artists ||= "";
	$query .= " AND artist = " . VARTIST_ID if $artists eq "";
	$query .= " AND artist != " . VARTIST_ID if $artists eq "single";
	# the other recognised value is "all".

	$query .= " AND (attributes[2] = $reltype   OR attributes[3] = $reltype  )" if $reltype;
	$query .= " AND (attributes[3] = $relstatus OR attributes[2] = $relstatus)" if $relstatus;

	# TODO if we had an album.sortname, we could get the database to do all
	# the sorting and filtering for us.  e.g. ORDER BY sortname LIMIT 100,25
	# But for now, we always retrieve all the matching albums (ugh), sort them
	# ourselves, then apply the range filter.

	my $sql = Sql->new($this->{DBH});
	my $rows = $sql->SelectListOfLists($query);
	my $num_albums = @$rows;

	# Add a sortname to each row
	for my $row (@$rows)
	{
		my $temp = unac_string('UTF-8', $row->[1]); # name
		$temp = lc decode("utf-8", $temp);

		# Remove all non alpha characters to sort cleaner
		$temp =~ s/[^[:alnum:][:space]]//g;
		$temp =~ s/[[:space:]]+/ /g;

		unshift @$row, $temp;
	}

	# Sort by that sortname
	{
		# Here we could "use locale" etc, but we seem to get the best results
		# by unaccenting and then using a non-locale sort.
		@$rows = sort { $a->[0] cmp $b->[0] } @$rows;
	}

	# Limit the rows we return
	splice @$rows, 0, $offset;
	splice @$rows, $limit if @$rows > $limit;

	# Turn each one into an Album object
	my @albums = map {
		my $row = $_;

		require Album;
		my $al = Album->new($this->{DBH});

		$al->{_debug_sortname} = shift @$row;

		$al->{id}			= $row->[0];
		$al->{name}			= $row->[1];
		$al->{mbid}			= $row->[2];
		$al->{modpending}	= $row->[3];
		$al->{artist}		= $row->[4]; 
		$al->{attrs}		= [ $row->[5] =~ /(\d+)/g ];

		$al->{trackcount}		= $row->[6];
		$al->{discidcount}		= $row->[7];
		$al->{trmidcount}		= $row->[8];
		$al->{firstreleasedate}	= $row->[9] || "";
		$al->{coverarturl}		= $row->[10] || "";
		$al->{asin}				= $row->[11] || "";

		$al;
	} @$rows;

 	return ($num_albums, \@albums);
}

sub UpdateName
{
	my $self = shift;

	my $id = $self->GetId
		or croak "Missing album ID in RemoveFromAlbum";
	my $name = $self->GetName;
	defined($name) && $name ne ""
		or croak "Missing album name in RemoveFromAlbum";

	MusicBrainz::TrimInPlace($name);
	my $page = $self->CalculatePageIndex($name);

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album SET name = ?, page = ? WHERE id = ?",
		$name,
		$page,
		$id,
	);

	# Now remove the old name from the word index, and then
	# add the new name to the index
	$self->RebuildWordList;
}

# The album name has changed.  Rebuild the words for this album.

sub RebuildWordList
{
    my ($this) = @_;

    require SearchEngine;
    my $engine = SearchEngine->new($this->{DBH}, 'album');
    $engine->AddWordRefs(
		$this->GetId,
		$this->GetName,
		1, # remove other words
    );
}

sub UpdateAttributes
{
	my ($this) = @_;

	my $attr = join ',', @{ $this->{attrs} };
	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE album SET attributes = ? WHERE id = ?",
		"{$attr}",
		$this->GetId,
	);
}

sub UpdateModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->GetId
		or croak "Missing album ID in UpdateModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateModPending";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
		$adjust,
		$id,
	);
}

sub UpdateAttributesModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->GetId
		or croak "Missing album ID in UpdateAttributesModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateAttributesModPending";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album SET attributes[1] = NUMERIC_LARGER(attributes[1]+?, 0) WHERE id = ?",
		$adjust,
		$id,
	);
}

sub GetTrackSequence
{
	my ($this, $trackid) = @_;

	unless ($trackid)
	{
        cluck "Album::GetTrackSequence called with false trackid\n";
        return undef;
	}

	my $sql = Sql->new($this->{DBH});
	$sql->SelectSingleValue(
		"SELECT sequence FROM albumjoin WHERE album = ? AND track = ?",
		$this->GetId,
		$trackid,
	);
}

sub RDF_URL
{
	my $this = shift;
	sprintf "http://%s/mm-2.1/album/%s",
		&DBDefs::RDF_SERVER,
		$this->GetMBId,
	;
}

# These two subs deal with locking down the tracks on an album once it has
# valid, non-conflicting disc ids.  In each case the track number may be
# specified (can the operation be applied to this particular track), or
# missing/undef (in which case the answer is the logical OR across all tracks,
# effectively).

sub CanAddTrack
{
	my ($self, $tracknum) = @_;

	$@ = "", return 1
		if $self->IsNonAlbumTracks;

	my $toctracks = $self->_GetTOCTracksHash;
	my $havetracks = $self->_GetTrackNumbersHash;

	if (defined $tracknum)
	{
		$tracknum = int $tracknum;

		# Sanity checks on track number
		$@ = "$tracknum is not a valid track number", return 0
			if $tracknum < 1 or $tracknum > 99;

		# Can't add a track if we've already got a track with that number
		$@ = "This album already has a track $tracknum", return 0
			if $havetracks->{$tracknum};
	}

	# If we have no disc ids, or if we do, but they suggest a conflicting
	# number of tracks, then we don't know what to suggest (yet).
	unless (keys(%$toctracks) == 1)
	{
		$@ = "", return 1;
	}

	(my $fixtracks) = keys %$toctracks;

	# For a specified track number, just disallow tracks outside of the TOC
	# range.
	if (defined $tracknum)
	{
		my $t = (($fixtracks == 1) ? "one track" : "$fixtracks tracks");
		$@ = "You can't add track $tracknum - this album is meant to have exactly $t",
			return 0
			if $tracknum > $fixtracks;
		
		$@ = "", return 1;
	}

	# Otherwise, as for "can we add any tracks at all"... yes, if there's a
	# gap in the track sequence.
	my $gap = grep { not $havetracks->{$_} } 1 .. $fixtracks;

	$@ = "This album already has all of its tracks", return 0
		if not $gap;

	$@ = "", return 1;
}

sub CanRemoveTrack
{
	my ($self, $tracknum) = @_;

	$@ = "", return 1
		if $self->IsNonAlbumTracks;

	my $toctracks = $self->_GetTOCTracksHash;
	my $havetracks = $self->_GetTrackNumbersHash;

	# Can't remove a track that's not there
	$@ = "There is no track $tracknum on this album", return 0
		if defined $tracknum and not $havetracks->{$tracknum};

	# If we have no disc ids, or if we do, but they suggest a conflicting
	# number of tracks, then we don't know what to suggest (yet).
	unless (keys(%$toctracks) == 1)
	{
		$@ = "", return 1;
	}

	(my $fixtracks) = keys %$toctracks;

	if (defined $tracknum)
	{
		# Disallow removal of a track if it's within the TOC range, and it's not a
		# duplicate.
		my $t = (($fixtracks == 1) ? "one track" : "$fixtracks tracks");
		$@ = "You can't remove track $tracknum - this album is meant to have exactly $t",
			return 0
			if $tracknum >= 1 and $tracknum <= $fixtracks
				and $havetracks->{$tracknum} == 1;

		# Otherwise (outside of TOC range, or inside but duplicated)
		$@ = "", return 1;
	}

	# Otherwise, as for "can we remove any tracks at all"...
	# Yes, if there's a duplicate track number somewhere.
	$@ = "", return 1 if grep { $_ > 1 } values %$havetracks;
	# Yes, if there's a track outside of the TOC range
	$@ = "", return 1 if grep { $_ < 1 or $_ > $fixtracks } keys %$havetracks;
	# Otherwise no
	$@ = "None of the tracks on this album is eligible for removal", return 0;
}

sub _GetTOCTracksHash
{
	my $self = shift;
	my $discids = $self->GetDiscIDs
		or return +{};

	my %h;

	for (@$discids)
	{
		(my $n) = $_->GetTOC =~ /^\d+ (\d+)/;
		++$h{$n};
	}

	\%h;
}

sub _GetTrackNumbersHash
{
	my $self = shift;
	my $tracks = $self->GetTracks
		or return +{};

	my %h;

	for (@$tracks)
	{
		++$h{$_->GetSequence};
	}

	\%h;
}

1;
# eof Album.pm
