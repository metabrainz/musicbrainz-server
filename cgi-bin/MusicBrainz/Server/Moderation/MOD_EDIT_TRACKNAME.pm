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

package MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME;

use ModDefs;
use base 'Moderation';

sub Name { "Edit Track Name" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	$self->SetArtist($tr->GetArtist);
	$self->SetPrev($tr->GetName);
	$self->SetNew($newname);
	$self->SetTable("track");
	$self->SetColumn("name");
	$self->SetRowId($tr->GetId);
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

	my $current = $sql->SelectSingleValue(
		"SELECT name FROM track WHERE id = ?",
		$this->GetRowId,
	);

	defined($current)
		or return &ModDefs::STATUS_ERROR;
	
	$current eq $this->GetPrev
		or return &ModDefs::STATUS_FAILEDDEP;
	
	$sql->Do(
		"UPDATE track SET name = ? WHERE id = ?",
		$this->GetNew,
		$this->GetRowId,
	);

	# Now remove the old name from the word index, and then
	# add the new name to the index
	my $engine = SearchEngine->new($this->{DBH}, { Table => 'Track' });
	$engine->RemoveObjectRefs($this->GetRowId);
	$engine->AddWordRefs($this->GetRowId, $this->GetNew);

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKNAME.pm
