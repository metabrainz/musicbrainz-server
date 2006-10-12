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

package MusicBrainz::Server::Moderation::MOD_CHANGE_RELEASE_LOCK;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Lock/Unlock Release" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $release = $opts{'release'} or die;

    # 1 to lock the album, 0 to unlock
	my $action = $opts{'action'};

	$self->SetArtist($release->GetArtist);
	$self->SetPrev(!$action);
	$self->SetNew($action);
	$self->SetTable("album");
	$self->SetColumn("locked");
	$self->SetRowId($release->GetId);
}

sub PostLoad
{
	my $self = shift;

	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->GetRowId, 1);
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

	# Check that it hasn't been locked
	if ($release->IsLocked && $self->GetNew)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release is already locked.");
		return STATUS_FAILEDPREREQ;
	}

	# Check that it hasn't been unlocked
	if ($release->IsUnlocked && $self->GetNew == 0)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release is already unlocked.");
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{_release} = $release;

	undef;
}

sub ApprovedAction
{
	my $this = shift;

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $release = $this->{_release};
	$release->SetLocked($this->GetNew);
	$release->UpdateLock;

	STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_RELEASE_LOCK.pm
