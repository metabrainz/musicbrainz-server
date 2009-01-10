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

	$self->artist($artist->id);
	$self->previous_data($artist->quality);
	$self->new_data($quality);
	$self->table("artist");
	$self->column("quality");
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
	my $artist = MusicBrainz::Server::Artist->new($self->dbh);
	$artist->id($self->row_id);
	unless ($artist->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that it hasn't been locked
	if ($artist->quality == $self->new_data)
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

    return $self->new_data  > $self->previous_data;
}   

sub AdjustModPending
{
	my ($self, $adjust) = @_;

	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
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
	$artist->quality($this->new_data);
	$artist->UpdateQuality;

	STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_ARTIST_QUALITY.pm
