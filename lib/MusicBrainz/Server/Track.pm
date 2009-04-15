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
use MusicBrainz::Server::PUID;
use MusicBrainz::Server::Validation qw( unaccent );

sub LinkEntityName { "track" }
sub entity_type { "track" }

sub _id_cache_key
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
sub artist
{
    my ($self, $new_artist) = @_;

    if (defined $new_artist) { $self->{artist} = $new_artist; }
    return $self->{artist};
}

sub release
{
    my ($self, $new_release) = @_;

    if (defined $new_release) { $self->{album} = $new_release; }
    return $self->{album};
}

sub sequence
{
    my ($self, $new_sequence) = @_;

    if (defined $new_sequence) { $self->{sequence} = $new_sequence; }
    return $self->{sequence};
}

sub sequence_id
{
    my ($self, $new_sequence) = @_;

    if (defined $new_sequence) { $self->{sequenceid} = $new_sequence; }
    return $self->{sequenceid};
}

sub length
{
    my ($self, $new_length) = @_;

    if (defined $new_length) { $self->{length} = $new_length; }
    return $self->{length};
}

sub rating
{
    my ($self, $new_rating) = @_;

    if (defined $new_rating) { $self->{rating} = $new_rating; }
    return $self->{rating};
}

sub rating_count
{
    my ($self, $new_rating_count) = @_;

    if (defined $new_rating_count) { $self->{rating_count} = $new_rating_count; }
    return $self->{rating_count};
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
	my $sql = Sql->new($this->dbh);

	my $t = $sql->SelectSingleRowArray(
		"SELECT track, album FROM albumjoin WHERE id = ?",
		$albumjoinid,
	) or return undef;

	$this->id($t->[0]);
	$this->release($t->[1]);
	return $this->LoadFromId();
}

# Load a track. Set the track id and the album id via the id and release
# Accessor functions. Return true on success, undef otherwise
sub LoadFromId
{
	my ($this) = @_;

	my $id = $this->id;
	my $mbid = $this->mbid;

	if (not $id and not $mbid)
	{
		carp "No ID / MBID specified";
		return undef;
	}

	my $sql = Sql->new($this->dbh);
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
			$this->id($newid);
			$this->mbid(undef);
			return $this->LoadFromId;
		}
	}

	$row or return undef;

    my $artist = MusicBrainz::Server::Artist->new($this->dbh);
    $artist->id($row->[5]);

    $this->artist($artist);
    $this->id($row->[0]);
    $this->name($row->[1]);
    $this->mbid($row->[2]);
    $this->sequence($row->[3]);
    $this->length($row->[4]);
    $this->has_mod_pending($row->[6]);
    $this->SetAlbumJoinModPending($row->[7]);
    $this->sequence_id($row->[8]);
    $this->release($row->[9]);

	1;
}

sub GetMetadataFromIdAndAlbum
{
    my ($this, $id, $albumname) = @_;
    my (@row, $sql, $artist, $album, $seq);

    $artist = "Unknown";
    $album = "Unknown";
    $seq = 0;

    $this->id($id);
    if (!defined $this->LoadFromId())
    {
         return ();
    }

    require MusicBrainz::Server::Artist;
    my $ar = $this->artist;
    if (!defined $ar->LoadFromId())
    {
         return ();
    }

    $sql = Sql->new($this->dbh);
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

    return ($this->name(), $ar->name(), $album, $seq, "");
}

# This function inserts a new track. A properly initialized/loaded album
# must be passed in. If this is a multiple artist album, a fully
# inited/loaded artist must also be passed in. The new track id is returned
sub Insert
{
    my ($this, $al, $ar) = @_;
    $this->{new_insert} = 0;

	my $name = $this->name;
	MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
	if (not defined $name or $name eq "")
	{
		carp "Missing track name in Insert";
		return undef;
	}

    my $album = $al->id;
    
	# we allow releases attributed to other artists
	# than VARTIST_ID to have different track artists.
	# If an artist is given, we assume that this one
	# should be used to attribute the track to.
	# -- (keschte)    
    my $artist = ($al->artist() == &ModDefs::VARTIST_ID or
    			  defined $ar) ? $ar->id() : $al->artist();

	if (not $artist)
	{
		carp "Missing artist ID in Insert";
		return undef;
	}

    my $sql = Sql->new($this->dbh);

	my $track = $sql->SelectSingleValue(
		"SELECT	track.id
		FROM	track, albumjoin
		WHERE	albumjoin.album = ?
		AND		albumjoin.sequence = ?
		AND		track.id = albumjoin.track
		AND		LOWER(track.name) = LOWER(?)",
		$album,
		$this->sequence,
		$this->name,
	);
	return $track if $track;

	my %row = (
		gid => $this->CreateNewGlobalId,
		name => $this->name,
		artist => $artist,
		modpending	=> 0,
	);

	if (my $l = $this->length)
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

	my $id = $self->id
		or croak "Missing track ID in UpdateName";
	my $name = $self->name;
	defined($name) && $name ne ""
		or croak "Missing track name in UpdateName";

    MusicBrainz::Server::Validation::TrimInPlace($name);

	my $sql = Sql->new($self->dbh);
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
    my $engine = SearchEngine->new($this->dbh, 'track');
    $engine->AddWordRefs(
		$this->id,
		$this->name,
		1, # remove other words
    );
}

sub UpdateArtist
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	$sql->Do(
		"UPDATE track SET artist = ? WHERE id = ?",
		$self->artist->id,
		$self->id,
	);
}

sub UpdateLength
{
        my $self = shift;
	my $sql = Sql->new($self->dbh);

	$sql->Do(
		"UPDATE track SET length = ? WHERE id = ?",
		$self->length,
		$self->id,
	);
} 

sub UpdateSequence
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	$sql->Do(
		"UPDATE albumjoin SET sequence = ? WHERE id = ?",
		$self->sequence,
		$self->sequence_id,
	);
}

sub RemoveFromAlbum
{
	my $self = shift;

	my $id = $self->id
		or croak "Missing track ID in RemoveFromAlbum";
	my $alid = $self->release
		or croak "Missing album ID in RemoveFromAlbum";

	my $sql = Sql->new($self->dbh);
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

    return undef if (!defined $this->id());

    my $sql = Sql->new($this->dbh);

    my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM albumjoin WHERE track = ?",
		$this->id,
    );
    if ($refcount > 0)
    {
        print STDERR "DELETE: refcount = $refcount on track delete " .
                     $this->id() . "\n";
        return undef
    }

    my $puid = MusicBrainz::Server::PUID->new($this->dbh);
    $puid->remove_by_track($this);

	# Remove relationships
	require MusicBrainz::Server::Link;
	my $link = MusicBrainz::Server::Link->new($this->dbh);
	$link->RemoveByTrack($this->id());

    # Remove tags
	require MusicBrainz::Server::Tag;
	my $tag = MusicBrainz::Server::Tag->new($sql->{dbh});
	$tag->RemoveTracks($this->id);

	# Remove references from track words table
	require SearchEngine;
	my $engine = SearchEngine->new($this->dbh, 'track');
	$engine->RemoveObjectRefs($this->id());

    $this->RemoveGlobalIdRedirect($this->id, &TableBase::TABLE_TRACK);

    print STDERR "DELETE: Remove track " . $this->id() . "\n";
    $sql->Do("DELETE FROM track WHERE id = ?", $this->id);

    return 1;
}

sub GetAlbumInfo
{
   my ($this) = @_;
   my ($sql, @row, @info);

   $sql = Sql->new($this->dbh);
   if ($sql->Select(qq|select album, name, sequence, GID, attributes, quality
                         from AlbumJoin, Album
                        where AlbumJoin.album = Album.id and
                              track = | . $this->id()))
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
		$this->mbid,
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
