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

		require Album;
		$release = Album->new($self->{DBH});
		$release = $release->GetOrInsertNonAlbum($artist->GetId);
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
	my $hastrackartist = $release->GetArtist == &ModDefs::VARTIST_ID or 
						 $release->HasMultipleTrackArtists;
	if (not $artistid)
	{
		$artistid = $artist->GetId if ($artist);
		$artistid = $release->GetArtist if ($release);
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
		AlbumId => $release->GetId,
		ArtistId => $artistid
	);

	# If the insert of the release is pending, add a dependency on it.
	unless ($nonalbum)
	{
		my $sql = Sql->new($self->{DBH}); 
		(my $albummodid) = $sql->SelectSingleValue(
			"SELECT id FROM moderation_open WHERE type = " 
			. &ModDefs::MOD_ADD_ALBUM
			. " AND rowid = ?", $self->GetRowId,
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
		artistid=> $artistid, 
		albumid	=> $release->GetId,
		tracks => [ \%trackinfo ],
	);

	# insert the track.
	require Insert;
	my $in = Insert->new($self->{DBH});
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
	$new{"AlbumId"} = $release->GetId;
	$new{"ArtistId"} = $artistid; # use track artist (or release artist if no track artist)
	$new{"NewArtistId"} = $newartistid if ($newartistid);

	$self->SetTable("track");
	$self->SetColumn("name");
	$self->SetArtist($artistid); # use track artist (or release artist if no track artist)
	$self->SetRowId($newtrackid);
	$self->SetPrev($release->GetName);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
		
	# extract trackid, albumid from new_unpacked hash
	my $new = $self->{'new_unpacked'};

	($self->{"trackid"}, $self->{"checkexists-track"}) = ($new->{'TrackId'}, 1);
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{'AlbumId'}, 1);
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

	require Track;
	my $track = Track->new($self->{DBH});
	$track->SetId($trackid);
	$track->SetAlbum($releaseid);

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
	require Album;
	my $release = Album->new($self->{DBH});
	$release->SetId($releaseid);
	if ($release->LoadFromId)
	{
		$release->Remove
			if ($release->IsNonAlbumTracks and 
				$release->LoadTracks == 0);
	}

	if (my $artistid = $new->{"NewArtistId"})
	{
		require Artist;
		my $artist = Artist->new($self->{DBH});
		$artist->SetId($artistid);
		$artist->Remove;
	}
}

1;
# eof MOD_ADD_TRACK_KV.pm
