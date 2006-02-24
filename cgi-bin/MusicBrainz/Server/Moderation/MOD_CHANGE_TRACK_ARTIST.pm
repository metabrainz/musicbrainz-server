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

	my $nar;
	# load track name
	require Track;
	my $tr = Track->new($this->{DBH});
	$tr->SetId($this->GetRowId);
	if ($tr->LoadFromId)
	{
		$this->{'trackname'} = $tr->GetName;

		# try to guess the artist id for old moderations which only had the
		# name in 'newvalue'
		if (!$this->{'new.exists'})
		{
			require Artist;
			$nar = Artist->new($this->{DBH});
			$nar->SetId($tr->GetArtist);
			if ($nar->LoadFromId 
				&& $nar->GetName eq $this->{'new.name'})
			{
				$this->{'new.id'} = $nar->GetId;
				$this->{'new.exists'} = 1;
				$this->{'new.sortname'} = $nar->GetSortName;
			}
		}
	}

	
	# load artist resolutions if new artist name = old artist name
	my $pat = $this->GetPrev;
	if ($this->{'new.name'} =~ /^\Q$pat\E$/i)
	{
		require Artist;
		my $oar = Artist->new($this->{DBH});
		# the old one ...
		$oar->SetId($this->GetArtist);
		$oar->LoadFromId
			and $this->{'old.res'} = $oar->GetResolution;

		# ... and the new resolution if artist is in the DB
		# TODO what if new artist with res is created with this mod?
		#      (currently not possible, but might be in the future)
		if ($this->{'new.exists'})
		{
			if (!defined $nar)
			{
				$nar = Artist->new($this->{DBH});
				$nar->SetId($this->{'new.id'});
				$nar->LoadFromId;
			}
			my $res = $nar->GetResolution;
			$this->{'new.res'} = ($res eq '' ? undef : $res);
		}
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->GetRowId;

	# Load the track by ID
	require Track;
	my $tr = Track->new($self->{DBH});
	$tr->SetId($rowid);
	unless ($tr->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($tr->GetArtist != $self->GetArtist)
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
	my $tr = Track->new($this->{DBH});
	$tr->SetId($this->GetRowId);
	$tr->SetArtist($artistid);
	$tr->UpdateArtist
		or die "Failed to update track in MOD_CHANGE_TRACK_ARTIST";

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_TRACK_ARTIST.pm
