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

sub Name { "Add Track" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'album'};
	my $ar = $opts{'artist'};
	my $trackname = $opts{'trackname'};
	my $tracknum = $opts{'tracknum'};
	my $artistname = $opts{'artistname'};
	my $artistsortname = $opts{'artistsortname'};

	my $nonalbum = not $al;
	if ($nonalbum)
	{
		$ar or die;
		$al = Album->new($self->{DBH});
		$al = $al->GetOrInsertNonAlbum($ar->GetId);
		$nonalbum = 1;
	} else {
		die if $ar;
	}

	$trackname =~ /\S/ or die;

	# Track number is set here (the passed in value is ignored) if this is a
	# "non-album tracks" album.
	$tracknum = $al->GetNextFreeTrackId
		if $nonalbum;
	$tracknum or die;

	if ($al->GetArtist == &ModDefs::VARTIST_ID)
	{
		$artistname =~ /\S/ or die;
		$artistsortname =~ /\S/ or die;
	}

	my %new = (
		TrackName	=> $trackname,
		TrackNum	=> $tracknum,
	);

	unless ($nonalbum)
	{
		# If the insert of the album is pending, add a dependency on it

		my $sql = Sql->new($self->{DBH}); 
		(my $albummodid) = $sql->SelectSingleValue(
			"SELECT id FROM moderation_open WHERE type = " . &ModDefs::MOD_ADD_ALBUM
			. " AND rowid = ?",
			$self->GetRowId,
		);

		$new{'Dep0'} = $albummodid
			if $albummodid;
	}

	# Insert the track and maybe an artist

	my %trackinfo = (
		track	=> $trackname,
		tracknum=> $tracknum,
	);

	if ($al->GetArtist == &ModDefs::VARTIST_ID)
	{
		$trackinfo{'artist'} = $artistname;
		$trackinfo{'sortname'} = $artistsortname;
	}

	my %info = (
		artistid=> $al->GetArtist,
		albumid	=> $al->GetId,
		tracks	=> [ \%trackinfo ],
	);

	my $in = Insert->new($self->{DBH});

	unless (defined $in->Insert(\%info))
	{
		$self->SetError($in->GetError);
		die $self;
	}

	my $newtrack = $trackinfo{'track_insertid'};
	my $newartist = $trackinfo{'artist_insertid'};
	
	if (not $newtrack)
	{
		$self->SetError("Track insert failed - possible duplicate track.");
		die $self;
	}

	$new{"TrackId"} = $newtrack;
	$new{"AlbumId"} = $al->GetId;
	$new{"ArtistId"} = $newartist if $newartist;
	if ($al->GetArtist == &ModDefs::VARTIST_ID)
	{
		$new{'ArtistName'} = $artistname;
		$new{'SortName'} = $artistsortname
			if $artistsortname
			and $artistsortname ne $artistname;
	}

	$self->SetTable("track");
	$self->SetColumn("name");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($newtrack);
	$self->SetPrev($al->GetName);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	if (my $track = $new->{"TrackId"})
	{
		my $sql = Sql->new($self->{DBH});
		$sql->Do("DELETE FROM albumjoin WHERE track = ?", $track);

		# Remove the track itself (only if it's now unused)
		my $tr = Track->new($self->{DBH});
		$tr->SetId($track);
		$tr->Remove;
	}

	if (my $album = $new->{"AlbumId"})
	{
		# Try to remove the album if it's a "non-album" album
		my $al = Album->new($self->{DBH});
		$al->SetId($album);
		if ($al->LoadFromId)
		{
			$al->Remove
				if $al->IsNonAlbumTracks
				and $al->LoadTracks == 0;
		}
	}

	if (my $artist = $new->{"ArtistId"})
	{
		my $ar = Artist->new($self->{DBH});
		$ar->SetId($artist);
		$ar->Remove;
	}
}

1;
# eof MOD_ADD_TRACK_KV.pm
