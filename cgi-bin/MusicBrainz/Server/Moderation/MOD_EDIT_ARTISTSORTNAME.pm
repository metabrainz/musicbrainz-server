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

	die if $ar->GetId == VARTIST_ID;
	die if $ar->GetId == DARTIST_ID;

	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetSortName);
	$self->SetNew($newname);
	$self->SetTable("artist");
	$self->SetColumn("sortname");
	$self->SetRowId($ar->GetId);
}

sub IsAutoMod
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->GetPrev, $this->GetNew);
	$old eq $new;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $rowid = $this->GetRowId;

	if ($rowid == VARTIST_ID or $rowid == DARTIST_ID)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist cannot be edited");
		return STATUS_ERROR;
	}

	my $current = $sql->SelectSingleValue(
		"SELECT sortname FROM artist WHERE id = ?",
		$rowid,
	);

	unless (defined $current)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($current eq $this->GetPrev)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist's sortname has already been changed");
		return STATUS_FAILEDDEP;
	}

	my $al = Artist->new($this->{DBH});
	my $page = $al->CalculatePageIndex($this->GetNew);

	$sql->Do(
		"UPDATE artist SET sortname = ?, page = ? WHERE id = ?",
		$this->GetNew,
		$page,
		$rowid,
	);

	# Update the search engine
	my $artist = Artist->new($this->{DBH});
	$artist->SetId($rowid);
	$artist->LoadFromId;
	$artist->RebuildWordList;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTSORTNAME.pm
