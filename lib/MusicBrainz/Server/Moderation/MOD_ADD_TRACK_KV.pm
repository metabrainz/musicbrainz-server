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

use strict;

package MusicBrainz::Server::Moderation::MOD_ADD_TRACK_KV;

use ModDefs;
use base 'Moderation';
use Carp qw( croak );

sub Name { "Add Track" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	# Passed-in Instantiated entities
	my $release = $opts{'album'};
	my $artist = $opts{'artist'};

	# First check if it is a non-album track release we're
	# working on.
	my $nonalbum = not $release;
	if ($nonalbum)
	{
		$artist or die;

		require MusicBrainz::Server::Release;
		$release = MusicBrainz::Server::Release->new($self->GetDBH);
		$release = $release->GetOrInsertNonAlbum($artist->id);
		$nonalbum = 1;
	} 
	else 
	{
		die if ($artist);
	}
	
	# Track 
	my $trackname = $opts{'trackname'};
	my $tracknum = $opts{'tracknum'};
	my $tracklength = $opts{'tracklength'};
	my $artistid = $opts{'artistid'};
	
	# TrackArtist
	my $hastrackartist = $release->artist == &ModDefs::VARTIST_ID or 
						 $release->HasMultipleTrackArtists;
	if (not $artistid)
	{
		$artistid = $artist->id if ($artist);
		$artistid = $release->artist if ($release);
	}
	die if ($hastrackartist and not $artistid);
	
	# Make sure we do not have an empty track title.
	$trackname =~ /\S/ or die;

	# Track number is set here (the passed in value is ignored) if this is a
	# "non-album tracks" album.
	$tracknum = $release->GetNextFreeTrackId if ($nonalbum);
	$tracknum or die;
	
	# sanitize track length
	$tracklength = 0 + $tracklength;

	# prepare hash for the edit display.
	my %new = (
		TrackName => $trackname,
		TrackNum => $tracknum,
		TrackLength	=> $tracklength,
		AlbumId => $release->id,
		ArtistId => $artistid
	);

	# If the insert of the release is pending, add a dependency on it.
	unless ($nonalbum)
	{
		my $sql = Sql->new($self->GetDBH); 
		(my $albummodid) = $sql->SelectSingleValue(
			"SELECT id FROM moderation_open WHERE type = " 
			. &ModDefs::MOD_ADD_RELEASE
			. " AND rowid = ?", $self->row_id,
		);
		$new{'Dep0'} = $albummodid if ($albummodid);
	}

	# Prepare track insert hash. this has changed:
	# -- always pass in artistid of the track, since Insert.pm now
	#    handles the track artists.
	my %trackinfo = (
		track => $trackname,
		tracknum => $tracknum,
		duration => $tracklength,
		artistid => $artistid
	);
	my %info = (
		artistid => $artistid, 
		albumid	=> $release->id,
		tracks => [ \%trackinfo ],
	);

	# insert the track.
	require Insert;
	my $in = Insert->new($self->GetDBH);
	unless (defined $in->Insert(\%info))
	{
		$self->SetError($in->GetError);
		die $self;
	}

	# handle results of the Insert.pm call, e.g. the ID of 
	# the inserted entities.
	my $newtrackid = $trackinfo{'track_insertid'};
	my $newartistid = $trackinfo{'artist_insertid'};
	if (not $newtrackid)
	{
		$self->SetError("Track insert failed - possible duplicate track.");
		die $self;
	}
	
	$new{"TrackId"} = $newtrackid;
	$new{"AlbumId"} = $release->id;
	$new{"ArtistId"} = $artistid; # use track artist (or release artist if no track artist)
	$new{"NewArtistId"} = $newartistid if ($newartistid);

	$self->table("track");
	$self->column("name");
	$self->artist($artistid); # use track artist (or release artist if no track artist)
	$self->row_id($newtrackid);
	$self->previous_data($release->name);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
		
	# extract trackid, albumid from new_unpacked hash
	my $new = $self->{'new_unpacked'};

	($self->{"trackid"}, $self->{"checkexists-track"}) = ($new->{'TrackId'}, 1);
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{'AlbumId'}, 1);
} 

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->GetDBH);
	$rel->id($self->{albumid});
	if ($rel->LoadFromId())
	{
        return $rel->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $trackid = $new->{"TrackId"}
		or croak "Missing TrackId";
		
	my $releaseid = $new->{"AlbumId"}
		or croak "Missing AlbumId";

	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($self->GetDBH);
	$track->id($trackid);
	$track->release($releaseid);

	unless ($track->LoadFromId)
	{
		$self->InsertNote(
			&ModDefs::MODBOT_MODERATOR,
			"This track has been deleted",
		);
		return;
	}

	$track->RemoveFromAlbum
		or die "Failed to remove track";

	# Remove the track itself (only if it's now unused)
	$track->Remove;

	# Try to remove the album if it's a "non-album" album
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->GetDBH);
	$release->id($releaseid);
	if ($release->LoadFromId)
	{
		$release->Remove
			if ($release->IsNonAlbumTracks and 
				$release->LoadTracks == 0);
	}

	if (my $artistid = $new->{"NewArtistId"})
	{
		require MusicBrainz::Server::Artist;
		my $artist = MusicBrainz::Server::Artist->new($self->GetDBH);
		$artist->id($artistid);
		$artist->Remove;
	}
}

1;
# eof MOD_ADD_TRACK_KV.pm
