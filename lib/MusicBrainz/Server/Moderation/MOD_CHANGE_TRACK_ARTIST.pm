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

	$self->table("track");
	$self->column("artist");
	$self->row_id($tr->id);
	$self->artist($ar->id);
	$self->previous_data($ar->name);
	$self->new_data($sortname . "\n" . $name . "\n" . $newartistid);
}

sub PostLoad
{
	my $this = shift;
	
	# parse new into fields
	my ($sortname, $name, $newid) = split /\n/, $this->new_data;
	$name = $sortname if not defined $name;

	@$this{qw( new.sortname new.name new.id )} = ($sortname, $name, $newid);
}

sub DetermineQuality
{
	my $self = shift;

    my $level = &ModDefs::QUALITY_UNKNOWN_MAPPED;

	my $ar = MusicBrainz::Server::Artist->new($self->dbh);

    # Check the old artist
	$ar = $self->{artist};
	if ($ar->LoadFromId())
	{
		$level = $ar->quality > $level ? $ar->quality : $level;
        return $level if ($level == &ModDefs::QUALITY_HIGH);
    }
    # Check the new artist
	$ar->id($self->{'new.id'});
	if ($ar->LoadFromId())
	{
        $level = $ar->quality > $level ? $ar->quality : $level;        
        return $level if ($level == &ModDefs::QUALITY_HIGH);
    }

    # Check any releases that this track is attached to
	my $tr = MusicBrainz::Server::Track->new($self->dbh);
	$tr->id($self->{rowid});
    my @albums = $tr->GetAlbumInfo();
    if (@albums)
    {
        for (@albums)
        {
            $level = $_->[5] > $level ? $_->[5] : $level;        
        }
    }

    return $level;
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
	$this->{"trackid"} = $this->row_id;
	$this->{"exists-track"} = 0;
	$this->{"checkexists-track"} = 0;

	# load track name, and try to guess the artist id for old
	# edits which only had the name in 'newvalue'
	require MusicBrainz::Server::Track;
	my $newartist;
	my $track = MusicBrainz::Server::Track->new($this->dbh);
	$track->id($this->{"trackid"});
	if ($track->LoadFromId)
	{
		$this->{"trackname"} = $track->name;
		$this->{"exists-track"} = 1;

		# since the track exists, we can see if can load the
		# corresponding release.
		$this->{"albumid"} = $track->release;
		$this->{"checkexists-album"} = 1;

		my $artist = $track->artist;

		# try to guess artist id.
		if (!$this->{'new.exists'})
		{
			$newartist = $track->artist;
			if ($newartist->LoadFromId and
				$newartist->name eq $this->{'new.name'})
			{
				$this->{'new.id'} = $newartist->id;
				$this->{'new.sortname'} = $newartist->sort_name;
				$this->{'new.resolution'} = $newartist->resolution;
				$this->{'new.exists'} = 1;
			}
		}
	}

	# load artists, to see if we got resolutions to display.
	require MusicBrainz::Server::Artist; 

	# the old one ...
	my $oldartist = MusicBrainz::Server::Artist->new($this->dbh);
	$oldartist = $this->artist;
	if ($this->{"old.exists"} = $oldartist->LoadFromId)
	{
		$this->{"old.resolution"} = $oldartist->resolution;
		$this->{"old.sortname"} = $oldartist->sort_name;
		$this->previous_data($oldartist);
	}

	# ... and the new resolution if artist is in the DB
	if ($this->{'new.exists'})
	{
		if (!defined $newartist)
		{
			$newartist = MusicBrainz::Server::Artist->new($this->dbh);
			$newartist->id($this->{'new.id'});
			$this->{'new.exists'} = $newartist->LoadFromId;
		}
		if ($this->{'new.exists'})
		{
			my $res = $newartist->resolution;
			$this->{'new.resolution'} = ($res eq "" ? undef : $res);
			$this->new_data($newartist);
		}
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->row_id;

	# Load the track by ID
	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($self->dbh);
	$track->id($rowid);
	unless ($track->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($track->artist->id != $self->artist)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has already been moved to another artist");
		return STATUS_FAILEDPREREQ;
	}

    # Check to make sure that the destination artist still exists
    my ($sortname, $name, $newid) = @$self{qw( new.sortname new.name new.id )};
	if (defined $newid && $newid > 0)
	{
		require MusicBrainz::Server::Artist;
		my $ar = MusicBrainz::Server::Artist->new($self->dbh);
		$ar->id($newid);
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
		require MusicBrainz::Server::Artist;
		my $ar = MusicBrainz::Server::Artist->new($this->dbh);
		$ar->name($name);
		$ar->sort_name($sortname);
		$artistid = $ar->Insert(no_alias => 1);
	}

	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($this->dbh);
	$track->id($this->row_id);
	$track->artist->id($artistid);
	$track->UpdateArtist
		or die "Failed to update track in MOD_CHANGE_TRACK_ARTIST";

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_TRACK_ARTIST.pm
