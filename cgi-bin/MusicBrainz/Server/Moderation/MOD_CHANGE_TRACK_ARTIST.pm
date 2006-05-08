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

package MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST;

use ModDefs qw( :artistid :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Change Track Artist" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $ar = $opts{'oldartist'} or die;
	my $name = $opts{'artistname'} or die;
	my $sortname = $opts{'artistsortname'} or die;
	my $newartistid = $opts{'artistid'} or die;

	$self->SetTable("track");
	$self->SetColumn("artist");
	$self->SetRowId($tr->GetId);
	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($sortname . "\n" . $name . "\n" . $newartistid);
}

sub PostLoad
{
	my $this = shift;
	
	# parse new into fields
	my ($sortname, $name, $newid) = split /\n/, $this->GetNew;
	$name = $sortname if not defined $name;

	@$this{qw( new.sortname new.name new.id )} = ($sortname, $name, $newid);
}

sub PreDisplay
{
	my $this = shift;
	
	# flag indicates: new artist already in DB
	$this->{'new.exists'} = (defined $this->{'new.id'} && $this->{'new.id'} > 0);
	
	# old mods had only the name in 'newvalue' which is assigned to new.sortname
	$this->{'new.name'} = $this->{'new.sortname'}
		unless (defined $this->{'new.name'});

	# set trackid for ShowModType, checkexists is set to 0,
	# because we'll check that in the next couple of lines.
	$this->{"trackid"} = $this->GetRowId;
	$this->{"exists-track"} = 0;
	$this->{"checkexists-track"} = 0;
	
	# load track name, and try to guess the artist id for old 
	# edits which only had the name in 'newvalue'
	require Track;
	my $newartist; 
	my $track = Track->new($this->{DBH});
	$track->SetId($this->{"trackid"});
	if ($track->LoadFromId)
	{
		$this->{"trackname"} = $track->GetName;
		$this->{"exists-track"} = 1;

		# since the track exists, we can see if can load the 
		# corresponding release.
		$this->{"albumid"} = $track->GetAlbum; 
		$this->{"checkexists-album"} = 1; 
				
		# try to guess artist id.
		if (!$this->{'new.exists'})
		{
			require Artist;
			$newartist = Artist->new($this->{DBH});
			$newartist->SetId($track->GetArtist);
			if ($newartist->LoadFromId and
				$newartist->GetName eq $this->{'new.name'})
			{
				$this->{'new.id'} = $newartist->GetId;
				$this->{'new.sortname'} = $newartist->GetSortName;
				$this->{'new.resolution'} = $newartist->GetResolution;
				$this->{'new.exists'} = 1;
			}
		}
	}

	# load artists, to see if we got resolutions to display.
	require Artist; 

	# the old one ...
	my $oldartist = Artist->new($this->{DBH});
	$oldartist->SetId($this->GetArtist);
	if ($this->{"old.exists"} = $oldartist->LoadFromId)
	{
		$this->{"old.resolution"} = $oldartist->GetResolution;
		$this->{"old.sortname"} = $oldartist->GetSortName;
	}

	# ... and the new resolution if artist is in the DB
	if ($this->{'new.exists'})
	{
		if (!defined $newartist)
		{
			$newartist = Artist->new($this->{DBH});
			$newartist->SetId($this->{'new.id'});
			$this->{'new.exists'} = $newartist->LoadFromId;
		}
		if ($this->{'new.exists'})
		{
			my $res = $newartist->GetResolution;
			$this->{'new.resolution'} = ($res eq "" ? undef : $res);
		}
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->GetRowId;

	# Load the track by ID
	require Track;
	my $track = Track->new($self->{DBH});
	$track->SetId($rowid);
	unless ($track->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($track->GetArtist != $self->GetArtist)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has already been moved to another artist");
		return STATUS_FAILEDPREREQ;
	}

    # Check to make sure that the destination artist still exists
    my ($sortname, $name, $newid) = @$self{qw( new.sortname new.name new.id )};
	if (defined $newid && $newid > 0)
	{
		require Artist;
		my $ar = Artist->new($self->{DBH});
		$ar->SetId($newid);
		unless ($ar->LoadFromId)
		{
			$self->InsertNote(MODBOT_MODERATOR, "The target artist has been deleted");
			return STATUS_FAILEDDEP;
		}
    }

	undef;
}

sub ApprovedAction
{
 	my ($this, $id) = @_;

	my ($sortname, $name, $newid) = @$this{qw( new.sortname new.name new.id )};

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $artistid;
	if (defined $newid && $newid > 0)
	{
        $artistid = $newid;
	}
	else
	{
		require Artist;
		my $ar = Artist->new($this->{DBH});
		$ar->SetName($name);
		$ar->SetSortName($sortname);
		$artistid = $ar->Insert(no_alias => 1);
	}

	require Track;
	my $track = Track->new($this->{DBH});
	$track->SetId($this->GetRowId);
	$track->SetArtist($artistid);
	$track->UpdateArtist
		or die "Failed to update track in MOD_CHANGE_TRACK_ARTIST";

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_TRACK_ARTIST.pm
