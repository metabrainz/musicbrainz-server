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

package MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTSORTNAME;

use ModDefs qw( :modstatus :artistid MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Artist Sortname" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'artist'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	die if $ar->id == VARTIST_ID;
	die if $ar->id == DARTIST_ID;

	$self->artist($ar->id);
	$self->previous_data($ar->sort_name);
	$self->new_data($newname);
	$self->table("artist");
	$self->column("sortname");
	$self->row_id($ar->id);
}

sub DetermineQuality
{
	my $self = shift;

	my $ar = MusicBrainz::Server::Artist->new($self->GetDBH);
	$ar->id($self->{rowid});
	if ($ar->LoadFromId())
	{
        return $ar->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub IsAutoEdit
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->previous_data, $this->new_data);
	$old eq $new;
}

sub ApprovedAction
{
	my $this = shift;

	my $rowid = $this->row_id;

	if ($rowid == VARTIST_ID or $rowid == DARTIST_ID)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist cannot be edited");
		return STATUS_ERROR;
	}

	require MusicBrainz::Server::Artist;
	my $artist = MusicBrainz::Server::Artist->new($this->GetDBH);
	$artist->id($rowid);

	unless ($artist->LoadFromId)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($artist->sort_name eq $this->previous_data)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist's sortname has already been changed");
		return STATUS_FAILEDDEP;
	}

	$artist->UpdateSortName($this->new_data)
		or die "Failed to update artist in MOD_EDIT_ARTISTSORTNAME";

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTSORTNAME.pm
