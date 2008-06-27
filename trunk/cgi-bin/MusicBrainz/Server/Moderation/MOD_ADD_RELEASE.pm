#!/home/mbserver/cvs/mb_server/cgi-bin/perl -w
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

package MusicBrainz::Server::Moderation::MOD_ADD_RELEASE;

use ModDefs;
use base 'Moderation';

sub Name { "Add Release" }
(__PACKAGE__)->RegisterHandler;

sub _DecodeText
{
	my $t = $_[0];
	$t =~ s/\$2C/,/g;
	$t =~ s/\$26/\$/g;
	return $t;
}

sub PreInsert
{
	my ($self, %opts) = @_;

	# TODO check options and fill in %new
	my %new = %opts;
	
	$self->SetTable("album");
	$self->SetColumn("name");
	
	# Force a deliberately bad value to start with - this makes it obvious if
	# we somehow fail to insert a good value later on.
	$self->SetArtist(0);

	# keys in %new:
	# |--- EITHER self->artist OR Artist and Sortname
	# |--- HasMultipleTrackArtists (1|0) 
	#        override the VA release artist
	#        setting which directs if track artistid's are respected.
	# |--- AlbumName
	# |--- (CDIndexId && TOC) (EITHER BOTH OR NONE)
	# |--- NonAlbum (flag)
	# |--- Attributes (default: none) (OPTIONAL)
	# |--- Language (OPTIONAL)
	# |--- Script (OPTIONAL)
	# |--- ReleaseId (OPTIONAL -- only for MBID Submitters)
	# \--- for tracks 1..n:
	#      |--- Track/n/ 	- name
	#      |--- TrackID/n/ 	- name  (only used for MBID submitters)
	#      |--- Artist/n/ 	- ??? id or name ???
	#      \--- TrackDur/n/ 	- duration in ms ?
	#
	# Then for 1..m release dates:
	# \--- Release/n/ 	- , 
	#      |--- CountryId
	#      |--- Year-Month-Day
	#      |--- LabelId
	#      |--- CatNo
	#      \--- BarCode
	#	
	# The following keys are added to %new after the insert:
	#
	# |--- AlbumId
	# |--- ArtistId
	# |--- Discid
	# |--- _artistid
	# |--- _albumid
	# \--- for tracks 1..n:
	#      |--- Track/n/Id
	#      |--- Trm/n/Id
	#      \--- Artist/n/Id

	# Prepare %info - the control data for the "Insert" module.
	my %info = (
		# Prevent name clashes with existing albums
		forcenewalbum => 1,
		album => $new{'AlbumName'},
	);

	# TOD: Add a release to a non-existing artist, how is
	# that possible?
	if (defined $new{'artist'})
	{
	   	$self->SetArtist($info{'artistid'} = $new{'artist'});
	}
	else
	{
	   	$info{'artist'} = $new{"Artist"}; 
		$info{'sortname'} = $new{"Sortname"}; 
	}
	
	# TODO find out if it's possible to have a CDIndexId but no TOC
	if (exists $new{'CDIndexId'})
	{
	  	$info{'cdindexid'} = $new{'CDIndexId'};
	   	$info{'toc'} = $new{'TOC'};
	}
	if (exists $new{'ReleaseId'} && $new{'ReleaseId'})
	{
	  	$info{'albumid_supplied'} = $new{'ReleaseId'};
	}

	if ($new{'NonAlbum'})
	{
	  	$info{'attrs'} = [ 0 ];
	}
	else
	{
		my $attrs = $new{'Attributes'};
		$attrs = "" unless defined $attrs;
	 	$info{'attrs'} = [ grep { $_ } split /,/, $attrs ];

		my ($language, $script) = split(',', $new{'Language'} || '');
		$self->SetLanguageId($language) if $language;
		
		$info{'languageid'} = $language if (defined $language);
		$info{'scriptid'} = $script if (defined $script);
	}

	my @tracks;
	my $isva = ($new{"HasMultipleTrackArtists"} or
				($new{"artist"} && $new{"artist"} == &ModDefs::VARTIST_ID));

	for (my $i = 1;; $i++)
	{
		my $name = $new{"Track$i"};
		defined($name) or last;
		
	   	my %tmp = (
			track => $name,
			tracknum => $i,
		);

		if (exists $new{"TrackID$i"})
		{
			$tmp{trackid} = $new{"TrackID$i"};
		}
		
		if ($isva)
		{
			if (exists $new{"ArtistID$i"} && $new{"ArtistID$i"} != 0)
			{
			    $tmp{'artistid'} = $new{"ArtistID$i"};
			}
			else
			{
				# TODO: remove me.
			    $tmp{'artist'} = $new{"Artist$i"};
			    $tmp{'sortname'} = $new{"Sortname$i"};
			}
		}
		
		if (exists $new{"TrackDur$i"})
		{
		   	$tmp{'duration'} = $new{"TrackDur$i"};
		}
		
		push @tracks, \%tmp;
	}
   
	$info{'tracks'} = \@tracks;

	my @releases;
	for my $i (sort map { /^Release(\d+)$/ ? ($1) : () } keys %new)
	{
		my $release = $new{"Release$i"};
		my ($country, $date, $label, $catno, $barcode, $format) = split m/,/, $release;
		my ($year, $month, $day) = split m/-/, $date;

		$catno = _DecodeText($catno) if $catno;
		$barcode = _DecodeText($barcode) if $barcode;

		push @releases, {
			year	=> $year,
			month	=> $month,
			day		=> $day,
			country	=> $country,
			label	=> $label,
			catno	=> $catno,
			barcode	=> $barcode,
			format	=> $format,
		};
	}

	$info{'releases'} = \@releases;

	# Now we actually insert the album and tracks,
	# and maybe also some artists, a disc ID etc.
	{
		require Insert;
		my $in = Insert->new($self->{DBH});

		if (my $d = DebugLog->open)
		{
			$d->stamp;
			$d->dumper([$in, \%info], ['in', 'info']);
			$d->close;
		}
	
		unless (defined $in->Insert(\%info))
		{
			$self->SetError($in->GetError);
			die $self;
		}

		use DebugLog;
		if (my $d = DebugLog->open)
		{
			$d->stamp;
			$d->dumper([$in, \%info], ['in', 'info']);
			$d->close;
		}
	}

	# Store all the insert IDs

	# Previously this was conditional, but AFAICT not having a new album ID
	# must be a fatal error, right?
	{
		my $albumid = $info{'album_insertid'}
			or die;
		$new{"AlbumId"} = $albumid;
	}

	if (my $id = $info{artist_insertid})
	{
	  	$new{'ArtistId'} = $id;
	}

	if (my $id = $info{cdindexid_insertid})
	{
	  	$new{'Discid'} = $id;
	}

	for my $seq (1 .. @tracks)
	{
		my $track = $tracks[$seq-1];

		if (my $id = $track->{track_insertid})
		{
		  	$new{"Track${seq}Id"} = $id;
		}

		if (my $id = $track->{trm_insertid})
		{
		 	$new{"Trm${seq}Id"} = $id;
		}

	   	if (my $id = $track->{artist_insertid})
	  	{
	 		$new{"Artist${seq}Id"} = $id;
	 	}
	}

	for my $seq (1 .. @releases)
	{
		my $release = $releases[$seq-1];

		if (my $id = $release->{release_insertid})
		{
			$new{"Release${seq}Id"} = $id;
		}
	}

	$self->SetArtist($new{_artistid} = $info{_artistid} or die);
	$self->SetRowId($new{_albumid} = $info{_albumid} or die);

	# Add a dependency on a pending MOD_ADD_ARTIST if there is one

	my $sql = Sql->new($self->{DBH}); 
	(my $artistmodid) = $sql->SelectSingleValue(
		"SELECT id FROM moderation_open WHERE type = " . &ModDefs::MOD_ADD_ARTIST
		. " AND rowid = ?",
		$self->GetArtist,
	);

	$new{"Dep0"} = $artistmodid
		if $artistmodid;

	# Only one thing left to do...
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
		
	# extract albumid from new_unpacked hash
	my $new = $self->{'new_unpacked'};
	(my $releaseid) = grep { defined } (@$new{'AlbumId', '_albumid'}, 0);
	
	# attempt to load the release entitiy from the value
	# stored in this edit type. (@see Moderation::ShowModType)
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($releaseid, 1);

}

sub DetermineQuality
{
    my $self = shift;

    my $rel = MusicBrainz::Server::Release->new($self->{DBH});
    $rel->SetId($self->{rowid});
    if ($rel->LoadFromId())
    {
        return $rel->GetQuality();        
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

	if (my $album = $new->{'AlbumId'})
	{
		require MusicBrainz::Server::Release;
		my $al = MusicBrainz::Server::Release->new($self->{DBH});
		$al->SetId($album);
		$al->Remove;

		if (my $artist = $new->{'ArtistId'})
		{
			if ($artist != &ModDefs::VARTIST_ID)
			{
				require MusicBrainz::Server::Artist;
				my $ar = MusicBrainz::Server::Artist->new($self->{DBH});
				$ar->SetId($artist);
				$ar->Remove;
			}
		}
	}
}

1;
# eof MOD_ADD_RELEASE.pm
