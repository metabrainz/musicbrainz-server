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

package MusicBrainz::Server::Moderation::MOD_EDIT_ALBUMNAME;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Release Name" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $release = $opts{'album'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	$self->SetArtist($release->GetArtist);
	$self->SetPrev($release->GetName);
	$self->SetNew($newname);
	$self->SetTable("album");
	$self->SetColumn("name");
	$self->SetRowId($release->GetId);
}

sub PostLoad
{
	my $self = shift;

	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->GetRowId, 1);
} 

sub IsAutoEdit
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->GetPrev, $this->GetNew);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	# Load the album by ID
	require Album;
	my $release = Album->new($self->{DBH});
	$release->SetId($self->GetRowId);
	unless ($release->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed
	if ($release->GetName ne $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# FIXME utf-8 length required
	if (length($self->GetNew) > 255)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This name is too long - the maximum allowed length is 255 characters");
		return STATUS_ERROR;
	}

	# Save for ApprovedAction
	$self->{_album} = $release;

	undef;
}

sub ApprovedAction
{
	my $this = shift;

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $release = $this->{_album};
	$release->SetName($this->GetNew);
	$release->UpdateName;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ALBUMNAME.pm
