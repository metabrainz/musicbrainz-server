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
#   $Id: MOD_EDIT_RELEASE_NAME.pm 8492 2006-09-26 22:44:39Z robert $
#____________________________________________________________________________

package MusicBrainz::Server::Moderation::MOD_CHANGE_ARTIST_QUALITY;

use strict;
use warnings;

use base 'Moderation';

use ModDefs qw( :modstatus MODBOT_MODERATOR );

sub Name { "Change Artist Quality" }
sub moderation_id { 52 }

sub determine_edit_conditions
{
    my $self = shift;
    return $self->Moderation::GetQualityChangeDefs($self->GetQualityChangeDirection);
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $artist = $opts{'artist'} or die;
	my $quality = $opts{'quality'};

	$self->artist($artist->id);
	$self->SetPrev($artist->quality);
	$self->SetNew($quality);
	$self->table("artist");
	$self->SetColumn("quality");
	$self->row_id($artist->id);
}

sub PostLoad
{
	my $self = shift;

	($self->{"artistid"}, $self->{"checkexists-artist"}) = ($self->row_id, 1);
} 

sub CheckPrerequisites
{
	my $self = shift;

	# Load the album by ID
	require MusicBrainz::Server::Artist;
	my $artist = MusicBrainz::Server::Artist->new($self->{DBH});
	$artist->id($self->row_id);
	unless ($artist->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that it hasn't been locked
	if ($artist->quality == $self->GetNew)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist is already set to quality level " . ModDefs::GetQualityText($artist->quality));
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{_artist} = $artist;

	undef;
}

sub GetQualityChangeDirection
{
	my $self = shift;

    return $self->GetNew  > $self->GetPrev;
}   

sub AdjustModPending
{
	my ($self, $adjust) = @_;

	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($self->{DBH});
	$ar->id($self->row_id);
	$ar->LoadFromId;
	$ar->UpdateQualityModPending($adjust);
}

sub ApprovedAction
{
	my $this = shift;

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $artist = $this->{_artist};
	$artist->quality($this->GetNew);
	$artist->UpdateQuality;

	STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_ARTIST_QUALITY.pm
