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
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

package MusicBrainz::Server::Track;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;

use Carp qw( carp croak );
use DBDefs;
use ModDefs;
use MusicBrainz::Server::Validation qw( unaccent );

sub LinkEntityName { "track" }

sub _GetIdCacheKey
{
    my ($class, $id) = @_;
    "track-id-" . int($id);
}

sub _GetMBIDCacheKey
{
    my ($class, $mbid) = @_;
    "track-mbid-" . lc $mbid;
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

sub GetRelease
{
   return $_[0]->{album};
}

sub SetRelease
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
	my $sql = Sql->new($this->{DBH});

	my $t = $sql->SelectSingleRowArray(
		"SELECT track, album FROM albumjoin WHERE id = ?",
		$albumjoinid,
	) or return undef;

	$this->SetId($t->[0]);
	$this->SetRelease($t->[1]);
	return $this->LoadFromId();
}

# Load a track. Set the track id and the album id via the SetId and SetRelease
# Accessor functions. Return true on success, undef otherwise
sub LoadFromId
{
	my ($this) = @_;

	my $id = $this->GetId;
	my $mbid = $this->GetMBId;

	if (not $id and not $mbid)
	{
		carp "No ID / MBID specified";
		return undef;
	}

	my $sql = Sql->new($this->{DBH});
	my $row;

	if (my $albumid = $this->{album})
	{
		if ($id)
		{
			$row = $sql->SelectSingleRowArray(
				"SELECT t.id, t.name, t.gid, j.sequence, t.length, t.artist, t.modpending,
						j.modpending, j.id, j.album
				FROM	track t, albumjoin j
				WHERE	j.track = t.id
				AND		j.track = ?
				AND		j.album = ?",
				$id,
				$albumid,
			);
		}
		elsif ($mbid)
		{
			$row = $sql->SelectSingleRowArray(
				"SELECT t.id, t.name, t.gid, j.sequence, t.length, t.artist, t.modpending,
						j.modpending, j.id, j.album
				FROM	track t, albumjoin j
				WHERE	j.track = t.id
				AND		t.gid = ?
				AND		j.album = ?",
				$mbid,
				$albumid,
			);
		} else {
			croak "No ID / MBID specified";
		}
	}
	else
	{
		# FIXME this will fail when tracks appear on more than one album
		if ($id)
		{
			$row = $sql->SelectSingleRowArray(
				"SELECT t.id, t.name, t.gid, j.sequence, t.length, t.artist, t.modpending,
						j.modpending, j.id, j.album
				FROM	track t, albumjoin j
				WHERE	j.track = t.id
				AND		j.track = ?",
				$id,
			);
		}
		elsif ($mbid)
		{
			$row = $sql->SelectSingleRowArray(
				"SELECT t.id, t.name, t.gid, j.sequence, t.length, t.artist, t.modpending,
						j.modpending, j.id, j.album
				FROM	track t, albumjoin j
				WHERE	j.track = t.id
				AND		t.gid = ?",
				$mbid,
			);
		} else {
			croak "No ID / MBID specified";
		}
	}

	if (!$row && $mbid)
	{
		my $newid = $this->CheckGlobalIdRedirect($mbid, &TableBase::TABLE_TRACK);
		if ($newid)
		{
			$this->SetId($newid);
			$this->SetMBId(undef);
			return $this->LoadFromId;
		}
	}

	$row or return undef;

	@$this{qw(
		id name mbid sequence length artist modpending
		albumjoinmodpending sequenceid album
	)} = @$row;

	1;
}

sub GetMetadataFromIdAndAlbum
{
    my ($this, $id, $albumname) = @_;
    my (@row, $sql, $artist, $album, $seq);

    $artist = "Unknown";
    $album = "Unknown";
    $seq = 0;

    $this->SetId($id);
    if (!defined $this->LoadFromId())
    {
         return ();
    }

	require MusicBrainz::Server::Artist;
    my $ar = MusicBrainz::Server::Artist->new($this->{DBH});
    $ar->SetId($this->GetArtist());
    if (!defined $ar->LoadFromId())
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
                 $albumname = unaccent($albumname);
                 $albumname = lc decode("utf-8", $albumname);
             }

             while(@row = $sql->NextRow)
             {
                my $temp = unaccent($row[0]);
                $temp = lc decode("utf-8", $temp);

                if (not defined $albumname || $temp eq $albumname)
                {
                   $seq = $row[1];
                   $album = $row[0];
                   last;
                }
             }
         }
    }
	$sql->Finish;

    return ($this->GetName(), $ar->GetName(), $album, $seq, "");
}

# This function inserts a new track. A properly initialized/loaded album
# must be passed in. If this is a multiple artist album, a fully
# inited/loaded artist must also be passed in. The new track id is returned
sub Insert
{
    my ($this, $al, $ar, $trackid) = @_;
    $this->{new_insert} = 0;

	my $name = $this->GetName;
	MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
	if (not defined $name or $name eq "")
	{
		carp "Missing track name in Insert";
		return undef;
	}

    my $album = $al->GetId;
    
	# we allow releases attributed to other artists
	# than VARTIST_ID to have different track artists.
	# If an artist is given, we assume that this one
	# should be used to attribute the track to.
	# -- (keschte)    
    my $artist = ($al->GetArtist() == &ModDefs::VARTIST_ID or
    			  defined $ar) ? $ar->GetId() : $al->GetArtist();

	if (not $artist)
	{
		carp "Missing artist ID in Insert";
		return undef;
	}

    my $sql = Sql->new($this->{DBH});

	my $track = $sql->SelectSingleValue(
		"SELECT	track.id
		FROM	track, albumjoin
		WHERE	albumjoin.album = ?
		AND		albumjoin.sequence = ?
		AND		track.id = albumjoin.track
		AND		LOWER(track.name) = LOWER(?)",
		$album,
		$this->GetSequence,
		$this->GetName,
	);
	return $track if $track;

	my %row = (
		gid => $trackid ? $trackid : $this->CreateNewGlobalId,
		name => $this->GetName,
		artist => $artist,
		modpending	=> 0,
	);

	if (my $l = $this->GetLength)
	{
		$row{'length'} = $l;
	}

	$track = $sql->InsertRow("track", \%row);
	$this->{new_insert} = $track;
    $this->{id} = $track;

	$sql->Do(
		"INSERT INTO albumjoin (album, track, sequence, modpending)
			values (?, ?, ?, 0)",
		$album,
		$track,
		$this->{sequence},
	);

    # Add search engine tokens.
	$this->RebuildWordList;

    return $track;
}

sub UpdateName
{
	my $self = shift;

	my $id = $self->GetId
		or croak "Missing track ID in UpdateName";
	my $name = $self->GetName;
	defined($name) && $name ne ""
		or croak "Missing track name in UpdateName";

    MusicBrainz::Server::Validation::TrimInPlace($name);

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE track SET name = ? WHERE id = ?",
		$name,
		$id,
	);

	# Now remove the old name from the word index, and then
	# add the new name to the index
	$self->RebuildWordList;
}

# The track name has changed.  Rebuild the words for this track.

sub RebuildWordList
{
    my ($this) = @_;

    require SearchEngine;
    my $engine = SearchEngine->new($this->{DBH}, 'track');
    $engine->AddWordRefs(
		$this->GetId,
		$this->GetName,
		1, # remove other words
    );
}

sub UpdateArtist
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE track SET artist = ? WHERE id = ?",
		$self->GetArtist,
		$self->GetId,
	);
}

sub UpdateLength
{
        my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE track SET length = ? WHERE id = ?",
		$self->GetLength,
		$self->GetId,
	);
} 

sub UpdateSequence
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE albumjoin SET sequence = ? WHERE id = ?",
		$self->GetSequence,
		$self->GetSequenceId,
	);
}

sub RemoveFromAlbum
{
	my $self = shift;

	my $id = $self->GetId
		or croak "Missing track ID in RemoveFromAlbum";
	my $alid = $self->GetRelease
		or croak "Missing album ID in RemoveFromAlbum";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM albumjoin WHERE track = ? AND album = ?",
		$id,
		$alid,
	);
}

# Remove a track from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;

    return undef if (!defined $this->GetId());

    my $sql = Sql->new($this->{DBH});

    my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM albumjoin WHERE track = ?",
		$this->GetId,
    );
    if ($refcount > 0)
    {
        print STDERR "DELETE: refcount = $refcount on track delete " .
                     $this->GetId() . "\n";
        return undef
    }

	require MusicBrainz::Server::PUID;
    my $puid = MusicBrainz::Server::PUID->new($this->{DBH});
    $puid->RemoveByTrackId($this->GetId());

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($this->{DBH});
	$link->RemoveByTrack($this->GetId());

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{DBH});
	$tag->RemoveTracks($this->GetId);

	# Remove references from track words table
	require SearchEngine;
	my $engine = SearchEngine->new($this->{DBH}, 'track');
	$engine->RemoveObjectRefs($this->GetId());

    $this->RemoveGlobalIdRedirect($this->GetId, &TableBase::TABLE_TRACK);

    print STDERR "DELETE: Remove track " . $this->GetId() . "\n";
    $sql->Do("DELETE FROM track WHERE id = ?", $this->GetId);

    return 1;
}

sub GetAlbumInfo
{
   my ($this) = @_;
   my ($sql, @row, @info);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select album, name, sequence, GID, attributes, quality
                         from AlbumJoin, Album
                        where AlbumJoin.album = Album.id and
                              track = | . $this->GetId()))
   {
       for(;@row = $sql->NextRow();)
       {
           push @info, [@row];
       }
   }
	$sql->Finish;

   return @info;
}

sub XML_URL
{
	my $this = shift;
	sprintf "http://%s/ws/1/track/%s?type=xml&inc=artist+releases",
		&DBDefs::RDF_SERVER,
		$this->GetMBId,
	;
}

sub FormatTrackLength
{
	my $ms = shift;

	$ms or return "?:??";
	$ms >= 1000 or return "$ms ms";

	my $length_in_secs = int($ms / 1000.0 + 0.5);
	sprintf "%d:%02d",
		int($length_in_secs / 60),
		($length_in_secs % 60),
		;
}

sub UnformatTrackLength
{
	my $length = shift;
	my $ms = -1;
	
	if ($length =~ /^\s*\?:\?\?\s*$/)
	{
		$ms = 0;
	}
	elsif ($length =~ /^\s*(\d{1,3}):(\d{1,2})\s*$/ && $2 < 60)
	{
		$ms = ($1 * 60 + $2) * 1000;
	}
	elsif ($length =~ /^\s*(\d+)\s+ms\s*$/)
	{
		$ms = $1;
	}
	else
	{
		$ms = -1;
	}
	
	return $ms;

}

1;
# eof Track.pm
