#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

use FindBin;
use lib "$FindBin::Bin/../../lib";

use strict;
use warnings;

package AlbumsToConvert;
use base qw( MusicBrainz::Server::ReportScript );

use MusicBrainz::Server::Release;
use MusicBrainz::Server::Artist;

sub GatherData
{
	my $self = shift;

	$self->Log("Querying database");

	my $albums = $self->SqlObj->SelectListOfLists("
		SELECT 
			m.id, 
			m.tracks, 
			COUNT(*)
		FROM 
			albummeta m, albumjoin j, track t
		WHERE 
			j.album = m.id
			AND j.track = t.id
			AND t.name ~* '[^\\d]-[^\\d]'
		GROUP BY 
			m.id, m.tracks
		HAVING COUNT(*) = m.tracks
	");
		
	my $albums2 = $self->SqlObj->SelectListOfLists("
		SELECT 
			m.id, 
			m.tracks, 
			COUNT(*)
		FROM 
			albummeta m, albumjoin j, track t
		WHERE 
			j.album = m.id
			AND j.track = t.id
			AND t.name LIKE '%/%'
		GROUP BY 
			m.id, m.tracks
		HAVING COUNT(*) = m.tracks
	");

	my @album_ids = do {
		my %t;
		@t{ map { $_->[0] } @$albums } = ();
		@t{ map { $_->[0] } @$albums2 } = ();
		keys %t;
	};

	my %artists;
	my $count = 0;

	for my $album (@album_ids)
	{
		my $al = MusicBrainz::Server::Release->new($self->{dbh});
		$al->SetId($album);
		$al->LoadFromId or next;

		my $ar = $artists{ $al->GetArtist };

		unless ($ar)
		{
			$ar = MusicBrainz::Server::Artist->new($self->DBH);
			$ar->SetId($al->GetArtist);
			$ar->LoadFromId or next;

			$ar->{_sort_} = MusicBrainz::Server::Validation::NormaliseSortText($ar->GetSortName);
			$ar->{_albums_} = [];

			$artists{ $al->GetArtist } = $ar;
		}

		$al->{_sort_} = MusicBrainz::Server::Validation::NormaliseSortText($al->GetName);
		#print STDERR "$al->{_sort_} by $ar->{_sort_}\n" if -t;

		my @t = $al->LoadTracks;
		my $aid = $al->GetArtist;
		next if grep { $_->GetArtist != $aid } @t;
		$al->{tracks} = \@t;

		push @{ $ar->{_albums_} }, $al;
		++$count;
	}

	$self->Log("Saving results");
	my $report = $self->PagedReport;

	for my $artist (sort { $a->{_sort_} cmp $b->{_sort_} } values %artists)
	{
		my @a = @{ $artist->{_albums_} }
			or next;

		my $albums = $artist->{_albums_};
		@$albums = sort { $a->{_sort_} cmp $b->{_sort_} } @$albums;

		for my $al (sort { $a->{_sort_} cmp $b->{_sort_} } @$albums)
		{
			$report->Print(
				{
					artist_id			=> $artist->GetId,
					artist_mbid			=> $artist->GetMBId,
					artist_name			=> $artist->GetName,
					artist_sortname		=> $artist->GetSortName,
					artist_modpending	=> $artist->GetModPending,
					artist_resolution	=> $artist->GetResolution,
					album_id			=> $al->GetId,
					album_mbid			=> $al->GetMBId,
					album_name			=> $al->GetName,
					album_modpending	=> $al->GetModPending,
					tracks				=> [
						map {
							+{
								track_id	=> $_->GetId,
								track_mbid	=> $_->GetMBId,
								track_seq	=> $_->GetSequence,
								track_name	=> $_->GetName,
							}
						} @{ $al->{tracks} }
					],
				},
			);
		}
	}

}

__PACKAGE__->new->RunReport;

# eof AlbumsToConvert.pl
