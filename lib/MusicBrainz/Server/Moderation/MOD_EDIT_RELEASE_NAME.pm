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

package MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_NAME;

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

	$self->artist($release->artist);
	$self->previous_data($release->name);
	$self->new_data($newname);
	$self->table("album");
	$self->column("name");
	$self->row_id($release->id);
}

sub PostLoad
{
	my $self = shift;

	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->row_id, 1);
} 

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->GetDBH);
	$rel->id($self->{albumid});
	if ($rel->LoadFromId())
	{
        return $rel->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub IsAutoEdit
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->previous_data, $this->new_data);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	# Load the album by ID
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->GetDBH);
	$release->id($self->row_id);
	unless ($release->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed
	if ($release->name ne $self->previous_data)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# FIXME utf-8 length required
	if (length($self->new_data) > 255)
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
	$release->name($this->new_data);
	$release->UpdateName;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_RELEASE_NAME.pm
