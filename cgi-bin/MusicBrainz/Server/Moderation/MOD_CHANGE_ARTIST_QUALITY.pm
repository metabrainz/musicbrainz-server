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
#   $Id: MOD_EDIT_ALBUMNAME.pm 8492 2006-09-26 22:44:39Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Moderation::MOD_CHANGE_ARTIST_QUALITY;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Change Artist Quality" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $artist = $opts{'artist'} or die;
	my $quality = $opts{'quality'};

	$self->SetArtist($artist->GetId);
	$self->SetPrev($artist->GetQuality);
	$self->SetNew($quality);
	$self->SetTable("artist");
	$self->SetColumn("quality");
	$self->SetRowId($artist->GetId);
}

sub PostLoad
{
	my $self = shift;

	($self->{"artistid"}, $self->{"checkexists-artist"}) = ($self->GetRowId, 1);
} 

sub CheckPrerequisites
{
	my $self = shift;

	# Load the album by ID
	require Artist;
	my $artist = Artist->new($self->{DBH});
	$artist->SetId($self->GetRowId);
	unless ($artist->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that it hasn't been locked
	if ($artist->GetQuality == $self->GetNew)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist is already set to quality level " . ModDefs::GetQualityText($artist->GetQuality));
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{_artist} = $artist;

	undef;
}

sub ApprovedAction
{
	my $this = shift;

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $artist = $this->{_artist};
	$artist->SetQuality($this->GetNew);
	$artist->UpdateQuality;

	STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_ARTIST_QUALITY.pm
