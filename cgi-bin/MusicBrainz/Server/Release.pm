#!/usr/bin/perl -w
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
#   Foundatiog, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#
# 	The function LoadTracks and LoadTracksFromMultipleArtistAlbum
# 	has been merged to allow the determination of various artists
# 	albums by the trackartists, not by using artistid=1
#___________________________________________________________________________

package MusicBrainz::Server::Release;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use Carp qw( cluck croak );
use DBDefs;
use ModDefs qw( VARTIST_ID );
use MusicBrainz::Server::Validation qw( unaccent );
use LocaleSaver;
use POSIX qw(:locale_h);
use Encode qw( decode );

use constant NONALBUMTRACKS_NAME => "[non-album tracks]";

use constant RELEASE_ATTR_NONALBUMTRACKS => 0;

use constant RELEASE_ATTR_ALBUM          => 1;
use constant RELEASE_ATTR_SINGLE         => 2;
use constant RELEASE_ATTR_EP             => 3;
use constant RELEASE_ATTR_COMPILATION    => 4;
use constant RELEASE_ATTR_SOUNDTRACK     => 5;
use constant RELEASE_ATTR_SPOKENWORD     => 6;
use constant RELEASE_ATTR_INTERVIEW      => 7;
use constant RELEASE_ATTR_AUDIOBOOK      => 8;
use constant RELEASE_ATTR_LIVE           => 9;
use constant RELEASE_ATTR_REMIX          => 10;
use constant RELEASE_ATTR_OTHER          => 11;

use constant RELEASE_ATTR_OFFICIAL       => 100;
use constant RELEASE_ATTR_PROMOTION      => 101;
use constant RELEASE_ATTR_BOOTLEG        => 102;
use constant RELEASE_ATTR_PSEUDO_RELEASE => 103;

use constant RELEASE_ATTR_SECTION_TYPE_START   => RELEASE_ATTR_ALBUM;
use constant RELEASE_ATTR_SECTION_TYPE_END     => RELEASE_ATTR_OTHER;
use constant RELEASE_ATTR_SECTION_STATUS_START => RELEASE_ATTR_OFFICIAL;
use constant RELEASE_ATTR_SECTION_STATUS_END   => RELEASE_ATTR_PSEUDO_RELEASE;

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
    102 => [ "Bootleg", "Bootlegs", "An unofficial/underground release that was not sanctioned by the artist and/or the record company."],
    103 => [ "Pseudo-Release", "PseudoReleases", "A pseudo-release is a duplicate release for translation/transliteration purposes."]
);

sub LinkEntityName { "album" }

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

sub SetLanguageId
{
   $_[0]->{language} = $_[1];
}

sub SetScriptId
{
   $_[0]->{script} = $_[1];
}

sub SetLanguageModPending
{
   $_[0]->{modpending_lang} = $_[1];
}

sub SetQualityModPending
{
   $_[0]->{modpending_qual} = $_[1];
}

sub GetQualityModPending
{
   return $_[0]->{modpending_qual};
}

sub SetQuality
{
   $_[0]->{quality} = $_[1];
}

sub GetQuality
{
   return $_[0]->{quality};
}

sub SetInfoURL
{
    $_[0]->{infourl} = $_[1];
}

sub GetInfoURL
{
   return $_[0]->{infourl};
}

sub SetCoverartURL
{
    $_[0]->{coverarturl} = $_[1];
}

# return the url to a coverart image on an amazon image server
sub GetCoverartURL
{
	my $coverurl = $_[0]->{coverarturl};

	if ($coverurl)
	{
		# older entries didn't include the protocol and server parts of the URL
		$coverurl = ("http://images.amazon.com" . $coverurl)
			if ($coverurl =~ m{^/});
	}
	
 	return $coverurl;
}

# Set the amazon cover art store associated with this release
sub SetCoverartStore
{
    $_[0]->{amazon_store} = $_[1];
}

# Return the amazon store that was associated with this release
sub GetCoverartStore
{
	my $self = $_[0];

    return $self->{amazon_store} if (exists $self->{amazon_store});
	return "amazon.com";
}

sub GetAsin
{
   return ($_[0]{asin}||"") =~ /(\S+)/ ? $1 : ""
}

sub SetAsin
{
    $_[0]->{asin} = $_[1];
}

sub GetLanguageId
{
	return $_[0]{language};
}

sub GetLanguage
{
	my $self = shift;
	my $id = $self->GetLanguageId or return undef;
	require MusicBrainz::Server::Language;
	return MusicBrainz::Server::Language->newFromId($self->{DBH}, $id);
}

sub GetScriptId
{
	return $_[0]{script};
}

sub GetScript
{
	my $self = shift;
	my $id = $self->GetScriptId or return undef;
	require MusicBrainz::Server::Script;
	return MusicBrainz::Server::Script->newFromId($self->{DBH}, $id);
}

sub GetLanguageModPending
{
	return $_[0]->{modpending_lang} || 0;
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
	my $attrs = shift || [ $self->GetAttributes ];
	my ($type, $status);
	for (@$attrs)
	{
		return () if $_ == RELEASE_ATTR_NONALBUMTRACKS;
		$type   = $_ if $_ >= RELEASE_ATTR_SECTION_TYPE_START   and $_ <= RELEASE_ATTR_SECTION_TYPE_END;
		$status = $_ if $_ >= RELEASE_ATTR_SECTION_STATUS_START and $_ <= RELEASE_ATTR_SECTION_STATUS_END;
	}
	($type, $status);
}

sub SetAttributes
{
   my $this = shift;
   $this->{attrs} = [ ${ $this->{attrs}}[0], grep { defined } @_ ];
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
   return (scalar(@attrs) == 2 && $attrs[1] == RELEASE_ATTR_NONALBUMTRACKS);
}

sub FindNonAlbum
{
	my ($this, $artist) = @_;
	$artist ||= $this->GetArtist;

	my $sql = Sql->new($this->{DBH});
	my $ids = $sql->SelectSingleColumnArray(
		"SELECT id FROM album WHERE artist = ?
		AND attributes[2] = " . &RELEASE_ATTR_NONALBUMTRACKS,
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
		my $temp = unaccent($_->GetName);
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
			$t->GetRelease,
		) or die sprintf 'Failed to move track %d from release %d to %d',
			$t->GetId, $t->GetRelease, $album->GetId;
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
	$this->SetAttributes(&RELEASE_ATTR_NONALBUMTRACKS);
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
    my ($this, $albumid) = @_;

    $this->{new_insert} = 0;
    return undef if (!exists $this->{artist} || $this->{artist} eq '');
    return undef if (!exists $this->{name} || $this->{name} eq '');

    my $sql = Sql->new($this->{DBH});
    my $id = $albumid ? $albumid : $this->CreateNewGlobalId();
    my $attrs = "{" . join(',', @{ $this->{attrs} }) . "}";
    my $page = $this->CalculatePageIndex($this->{name});
    my $lang = $this->GetLanguageId();
    my $script = $this->GetScriptId();

	$sql->Do(qq|INSERT INTO album
			(name, artist, gid, modpending, attributes, page, language, script)
			VALUES (?, ?, ?, 0, ?, ?, ?, ?)|,
		$this->{name},
		$this->{artist},
		$id,
		$attrs,
		$page,
		$lang, # can be undef
		$script, # can be undef
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
    require MusicBrainz::Server::ReleaseCDTOC;
	MusicBrainz::Server::ReleaseCDTOC->RemoveAlbum($this->{DBH}, $album);

    print STDERR "DELETE: Removed release where album was " . $album . "\n";
	require MusicBrainz::Server::ReleaseEvent;
	my $rel = MusicBrainz::Server::ReleaseEvent->new($sql->{DBH});
	$rel->RemoveByRelease($album);

    if ($sql->Select(qq|select AlbumJoin.track from AlbumJoin 
                         where AlbumJoin.album = $album|))
    {
		require MusicBrainz::Server::Track;
         my $tr = MusicBrainz::Server::Track->new($this->{DBH});
         while(@row = $sql->NextRow)
         {
             print STDERR "DELETE: Removed albumjoin " . $row[0] . "\n";
             $sql->Do("DELETE FROM albumjoin WHERE track = ?", $row[0]);
             $tr->SetId($row[0]);
             $tr->Remove();
         }
    }
	$sql->Finish;

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($this->{DBH});
	$link->RemoveByRelease($album);

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{DBH});
	$tag->RemoveReleases($this->GetId);

    # Remove ratings
	require MusicBrainz::Server::Rating;
	my $ratings = MusicBrainz::Server::Rating->new($sql->{DBH});
	$ratings->RemoveReleases($this->GetId);

    # Remove references from album words table
	require SearchEngine;
    my $engine = SearchEngine->new($this->{DBH}, 'album');
    $engine->RemoveObjectRefs($this->GetId());

    require MusicBrainz::Server::Annotation;
    MusicBrainz::Server::Annotation->DeleteRelease($this->{DBH}, $album);

    $this->RemoveGlobalIdRedirect($album, &TableBase::TABLE_RELEASE);

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
		$this->{puidcount} = $row->{puids};
		$this->{firstreleasedate} = $row->{firstreleasedate} || "";
		$this->{coverarturl} = $row->{coverarturl};
		$this->{asin} = $row->{asin};
		$this->{rating} = $row->{rating} || 0;
		$this->{rating_count} = $row->{rating_count} || 0;
	} else {
		cluck "No albummeta row for album #".$this->GetId;
		delete @$this{qw( trackcount discidcount puidcount firstreleasedate )};
		return 0;
	}

	return 1;
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

# Returns the number of PUIDs for this album or undef on error
sub GetPuidCount
{
   my ($this) = @_;
   my ($sql);

   return undef if (!exists $this->{id});
   if (!exists $this->{puidcount} || !defined $this->{puidcount})
   {
       $this->LoadAlbumMetadata();
   }

   return $this->{puidcount};
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
sub GetReleaseIdsFromTrackId
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
		cluck "MusicBrainz::Server::Release::LoadFromId called with no id or gid";
		return undef;
	}

	my $sql = Sql->new($this->{DBH});
	my $row = $sql->SelectSingleRowArray(
		"SELECT	a.id, name, gid, modpending, artist, attributes, "
		. "       language, script, modpending_lang, quality, modpending_qual"
		. ($loadmeta ? ", tracks, discids, firstreleasedate,coverarturl,asin,puids,rating,rating_count" : "")
		. " FROM album a"
		. ($loadmeta ? " INNER JOIN albummeta m ON m.id = a.id" : "")
		. " WHERE	a.$idcol = ?",
		$idval,
	);
	
	if (!$row)
	{
		return undef
			if ($idcol ne "gid");

		my $newid = $this->CheckGlobalIdRedirect($idval, &TableBase::TABLE_RELEASE)
			or return;
	
		$row = $sql->SelectSingleRowArray(
			"SELECT	a.id, name, gid, modpending, artist, attributes, "
			. "       language, script, modpending_lang, quality, modpending_qual"
			. ($loadmeta ? ", tracks, discids, firstreleasedate,coverarturl,asin,puids,rating,rating_count" : "")
			. " FROM album a"
			. ($loadmeta ? " INNER JOIN albummeta m ON m.id = a.id" : "")
			. " WHERE	a.id = ?",
			$newid)
			or return undef;
	}

	$this->{id}					= $row->[0];
	$this->{name}				= $row->[1];
	$this->{mbid}				= $row->[2];
	$this->{modpending}			= $row->[3];
	$this->{artist}				= $row->[4]; 
	$this->{attrs}				= [ $row->[5] =~ /(\d+)/g ];
	$this->{language}			= $row->[6];
	$this->{script}				= $row->[7];
	$this->{modpending_lang}	= $row->[8];
	$this->{quality}        	= $row->[9];
	$this->{modpending_qual}	= $row->[10];

	delete @$this{qw( trackcount discidcount firstreleasedate asin coverarturl puidcount )};
	delete @$this{qw( _discids _tracks )};

	if ($loadmeta)
	{
		$this->{trackcount}		= $row->[11];
		$this->{discidcount}	= $row->[12];
		$this->{firstreleasedate}=$row->[13] || "";
		$this->{coverarturl}=$row->[14] || "";
		$this->{asin}=$row->[15] || "";
		$this->{puidcount}		= $row->[16];
		$this->{rating}			= $row->[17];
		$this->{rating_count}	= $row->[18];
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
	my ($this, $loadmeta) = @_;
	my (@info, $query, $sql, @row, $track);

	$sql = Sql->new($this->{DBH});
  
	if (not wantarray)
	{
		return $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM albumjoin WHERE album = ?",
			$this->GetId,
		);
	}

	$query = qq/select 
					Track.id, 
					Track.name, 
					Track.artist, 
					AlbumJoin.sequence, 
					Track.length, 
					Track.modpending, 
					AlbumJoin.modpending, 
					Artist.name, 
					Track.gid,
					AlbumJoin.album
		/. ($loadmeta ? ", rating, rating_count" : "") .qq/
			from 
				Track, AlbumJoin, Artist 
		/. ($loadmeta ? ", track_meta" : "") .qq/
			where 
				AlbumJoin.track = Track.id and 
				AlbumJoin.album = ? and 
				Track.Artist = Artist.id
		/. ($loadmeta ? "and track.id = track_meta.id" : "") .qq/
			order by /;
	
	$query .= $this->IsNonAlbumTracks() ? " Track.name " : " AlbumJoin.sequence ";

	if ($sql->Select($query, $this->{id}))
	{
		for(;@row = $sql->NextRow();)
		{
			require MusicBrainz::Server::Track;
			$track = MusicBrainz::Server::Track->new($this->{DBH});
			$track->SetId($row[0]);
			$track->SetName($row[1]);
			$track->SetArtist($row[2]);
			$track->SetSequence($row[3]);
			$track->SetLength($row[4]);
			$track->SetModPending($row[5]);
			$track->SetAlbumJoinModPending($row[6]);
			$track->SetArtistName($row[7]);
			$track->SetMBId($row[8]);
			$track->SetRelease($row[9]);

            if (defined $loadmeta && $loadmeta)
            {
                $track->{rating} = $row[10];
                $track->{rating_cournt} = $row[11];
			}

			push @info, $track;
		}
	}
	$sql->Finish;

	return @info;
}


# Find all releases for this album.  Returns a list of M::S::Release objects.
sub ReleaseEvents
{
	my ($self, $loadlabels) = @_;
	require MusicBrainz::Server::ReleaseEvent;
	my $rel = MusicBrainz::Server::ReleaseEvent->new($self->{DBH});
	$rel->newFromRelease($self->GetId, $loadlabels);
}

sub GetDiscIDs
{
	my $self = shift;

	$self->{"_discids"} ||= do
	{
		require MusicBrainz::Server::ReleaseCDTOC;
		MusicBrainz::Server::ReleaseCDTOC->newFromRelease($self->{DBH}, $self);
	};
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

# Override the _isva flag to force the release to be displayed as VA release.
sub SetMultipleTrackArtists
{
   $_[0]->{_isva} = $_[1];
}

# Fetch the tracks from the database and check
# the track artist against each other and the
# release artist. If any are found, the release needs
# to be displayed as Various Artists.
sub HasMultipleTrackArtists
{
	my $self = shift;
	my ($tracks, %ar);
	
	unless (defined $self->{"_isva"})
	{
		# use release artist for comparison, for the unlikely
		# case that all the track artists are the same but
		# different than the release artist. we still diplay
		# the track artists in that case.
		
		$ar{$self->GetArtist} = 1;
		
		# get the list of tracks and get their respective
		# artistid.
		$tracks = $self->GetTracks;
		foreach my $t (@$tracks) 
		{
			$ar{$t->GetArtist} = 1;
		}
		$self->{"_isva"} = (keys %ar > 1);
	}
	$self->{"_isva"} || undef;
} 

# Fetch PUID counts for each track of the current album.
# Returns a reference to a hash, where the keys are track IDs and the values
# are the PUID counts.  Tracks with no PUIDs may or may not be in the hash.
sub LoadPUIDCount
{
 	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $counts = $sql->SelectListOfLists(
		"SELECT	albumjoin.track, COUNT(puidjoin.track) AS num_puid
		FROM	albumjoin, puidjoin
		WHERE	albumjoin.album = ?
		AND		albumjoin.track = puidjoin.track
	   	GROUP BY albumjoin.track",
		$this->GetId,
	);

	+{
		map {
			$_->[0] => $_->[1]
		} @$counts
	};
}

# Fetch annotations for each track of the current album.
# Returns a reference to a hash, where the keys are track IDs and the values
# are a 0 or 1 if track has annotation.  Tracks with no annotations may or may not be in the hash.
sub LoadLatestTrackAnnos
{
 	my $self = shift;
	my $sql = Sql->new($self->{DBH});
	
	my $annos = $sql->SelectListOfLists(
		"SELECT albumjoin.track, annotation.text != ''
		FROM    albumjoin, annotation
		WHERE   albumjoin.album = ?
		AND     albumjoin.track = annotation.rowid
		AND     annotation.type = " . &MusicBrainz::Server::Annotation::TRACK_ANNOTATION .
		"ORDER BY annotation.created ASC",
		$self->GetId,
	);

	+{
		map {
			$_->[0] => $_->[1]
		} @$annos
	};
}

# Given a list of albums, this function will merge the list of albums into
# the current album. All Discids and PUIDs are preserved in the process
sub MergeReleases
{
   my ($this, $opts) = @_;
   my $intoMAC = $opts->{'mac'};
   my @list = @{ $opts->{'albumids'} };
   my $merge_attributes = $opts->{'merge_attributes'};
   my $merge_langscript = $opts->{'merge_langscript'};

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

   my $old_attrs = join " ", $this->GetAttributes;
   my $old_langscript = join " ", ($this->GetLanguageId||0), ($this->GetScriptId||0);

   require MusicBrainz::Server::Release;
   $al = MusicBrainz::Server::Release->new($this->{DBH});
   
   require MusicBrainz::Server::Link;
   my $link = MusicBrainz::Server::Link->new($sql->{DBH});

	require MusicBrainz::Server::PUID;
	my $puid = MusicBrainz::Server::PUID->new($this->{DBH});

	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{DBH});

	require MusicBrainz::Server::Rating;
	my $ratings = MusicBrainz::Server::Rating->new($sql->{DBH});

   foreach $id (@list)
   {
       $al->SetId($id);
       next if (!defined $al->LoadFromId());

       @tracks = $al->LoadTracks();
       foreach $tr (@tracks)
       {
           if (exists $merged{$tr->GetSequence()})
           {
                # We already have that track. Move any existing PUIDs
                # to the existing track
				my $old = $tr->GetId;
				my $new = $merged{$tr->GetSequence()}->GetId;

				# Track duration
				if ($merged{$tr->GetSequence()}->GetLength == 0 && $tr->GetLength != 0)
				{
					$merged{$tr->GetSequence()}->SetLength($tr->GetLength);
					$merged{$tr->GetSequence()}->UpdateLength();
				}
				
				# Move PUIDs
				$puid->MergeTracks($old, $new);
				
				# Move relationships
				$link->MergeTracks($old, $new);

				# Move tags
				$tag->MergeTracks($old, $new);

				# Move ratings
				$ratings->MergeTracks($old, $new);

                $this->SetGlobalIdRedirect($old, $tr->GetMBId, $new, &TableBase::TABLE_TRACK);
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

		$this->MergeAttributesFrom($al) if $merge_attributes;
		$this->MergeLanguageAndScriptFrom($al) if $merge_langscript;

		# Also merge the Discids
		require MusicBrainz::Server::ReleaseCDTOC;
		MusicBrainz::Server::ReleaseCDTOC->MergeReleases($this->{DBH}, $id, $this->GetId);

		# And the releases
		require MusicBrainz::Server::ReleaseEvent;
		my $rel = MusicBrainz::Server::ReleaseEvent->new($sql->{DBH});
		$rel->MoveFromReleaseToRelease($id, $this->GetId);

		# And the annotations
		require MusicBrainz::Server::Annotation;
		MusicBrainz::Server::Annotation->MergeReleases($this->{DBH}, $id, $this->GetId, artistid => $this->GetArtist);

		# And the ARs
		$link->MergeReleases($id, $this->GetId);

		# ... and the tags
		$tag->MergeReleases($id, $this->GetId);

		# ... and the ratings
		$ratings->MergeReleases($id, $this->GetId);

        $this->SetGlobalIdRedirect($id, $al->GetMBId, $this->GetId, &TableBase::TABLE_RELEASE);

       # Then, finally remove what is left of the old album
       $al->Remove();
   }

   my $new_attrs = join " ", $this->GetAttributes;
   $this->UpdateAttributes if $new_attrs ne $old_attrs;

   my $new_langscript = join " ", ($this->GetLanguageId||0), ($this->GetScriptId||0);
   $this->UpdateLanguageAndScript if $new_langscript ne $old_langscript;

   return 1;
}

sub MergeAttributesFrom
{
	my ($self, $from) = @_;
	return if $self->IsNonAlbumTracks or $from->IsNonAlbumTracks;

	my @got = $self->GetReleaseTypeAndStatus;
	my @from = $from->GetReleaseTypeAndStatus;

	for (0..$#got)
	{
		$got[$_] ||= $from[$_];
	}

	$self->SetAttributes(@got);
}

sub MergeLanguageAndScriptFrom
{
	my ($self, $from) = @_;
	$self->SetLanguageId($from->GetLanguageId)
		unless $self->GetLanguageId;
	$self->SetScriptId($from->GetScriptId)
		unless $self->GetScriptId;
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
		SELECT	a.id, a.name as albumname, a.gid, a.modpending, 
				a.artist as artistid, ar.name as artistname,
                attributes, language, script, modpending_lang,
				tracks, discids, firstreleasedate, coverarturl, 
                asin, puids, a.quality, a.modpending_qual
   		FROM	album a, albummeta m, artist ar
	  	WHERE	a.page BETWEEN $page_min AND $page_max
		AND		m.id = a.id
		AND		a.artist = ar.id
	";
 
	$artists ||= "";
	$query .= " AND a.artist = " . VARTIST_ID if $artists eq "";
	$query .= " AND a.artist != " . VARTIST_ID if $artists eq "single";
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
		my $temp = unaccent($row->[1]); # name
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

		require MusicBrainz::Server::Release;
		my $al = MusicBrainz::Server::Release->new($this->{DBH});

		$al->{_debug_sortname} = shift @$row;

		$al->{id}				= $row->[0];
		$al->{name}				= $row->[1];
		$al->{mbid}				= $row->[2];
		$al->{modpending}		= $row->[3];
		$al->{artistid}			= $row->[4]; 
		$al->{artistname}		= $row->[5]; 
		$al->{attrs}			= [ $row->[6] =~ /(\d+)/g ];
		$al->{language}			= $row->[7];
		$al->{script}			= $row->[8];
		$al->{modpending_lang}	= $row->[9];

		$al->{trackcount}		= $row->[10];
		$al->{discidcount}		= $row->[11];
		$al->{firstreleasedate}	= $row->[12] || "";
		$al->{coverarturl}		= $row->[13] || "";
		$al->{asin}				= $row->[14] || "";
		$al->{puidcount}		= $row->[15] || 0;
		$al->{quality}		    = $row->[16] || 0;
		$al->{modpending_qual}  = $row->[17] || 0;

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

	MusicBrainz::Server::Validation::TrimInPlace($name);
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

sub UpdateQuality
{
	my $self = shift;

	my $id = $self->GetId
		or croak "Missing artist ID in UpdateQuality";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album SET quality = ? WHERE id = ?",
		$self->{quality},
		$id,
	);
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

sub UpdateLanguageAndScript
{
	my $this = shift;

	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"UPDATE album SET language = ?, script = ? WHERE id = ?",
		$this->GetLanguageId || undef,
		$this->GetScriptId || undef,
		$this->GetId,
	);

	# also adjust the language of all pending moderations for this album
	# current only add album mods
	$sql->Do(
		"UPDATE moderation_open SET language = ? "
		. "WHERE tab = 'album' AND rowid = ? AND type = ? ",
		$this->GetLanguageId || undef,
		$this->GetId,
		&ModDefs::MOD_ADD_RELEASE, 
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

sub UpdateLanguageModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->GetId
		or croak "Missing album ID in UpdateLanguageModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateLanguageModPending";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(<<'EOF', $adjust, $id);
		UPDATE	album
		SET		modpending_lang
					= NUMERIC_LARGER(COALESCE(modpending_lang,0)+?, 0)
		WHERE	id = ?
EOF
}

sub UpdateQualityModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->GetId
		or croak "Missing album ID in UpdateQualityModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateQualityModPending";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album SET modpending_qual = NUMERIC_LARGER(modpending_qual+?, 0) WHERE id = ?",
		$adjust,
		$id,
	);
}


sub GetTrackSequence
{
	my ($this, $trackid) = @_;

	unless ($trackid)
	{
        cluck "MusicBrainz::Server::Release::GetTrackSequence called with false trackid\n";
        return undef;
	}

	my $sql = Sql->new($this->{DBH});
	$sql->SelectSingleValue(
		"SELECT sequence FROM albumjoin WHERE album = ? AND track = ?",
		$this->GetId,
		$trackid,
	);
}

sub XML_URL
{
	my $this = shift;
	sprintf "http://%s/ws/1/release/%s?type=xml&inc=artist+counts+release-events+discs+tracks",
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
			if $tracknum < 1;

		# Can't add a track if we've already got a track with that number
		$@ = "This release already has a track $tracknum", return 0
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
		$@ = "You can't add track $tracknum - this release is meant to have exactly $t",
			return 0
			if $tracknum > $fixtracks;
		
		$@ = "", return 1;
	}

	# Otherwise, as for "can we add any tracks at all"... yes, if there's a
	# gap in the track sequence.
	my $gap = grep { not $havetracks->{$_} } 1 .. $fixtracks;

	$@ = "This release already has all of its tracks", return 0
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
	my $discids = $self->GetDiscIDs;
	@$discids
		or return +{};

	my %h;

	for (@$discids)
	{
		my $n = $_->GetCDTOC->GetTrackCount;
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

sub LoadLastUpdate
{
    my $self = shift;

	my $sql = Sql->new($self->{DBH});
	$self->{lastupdate} = $sql->SelectSingleValue("SELECT lastupdate FROM albummeta WHERE id = ?", $self->{id});
}

1;
# eof Album.pm
