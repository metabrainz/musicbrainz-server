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

package MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS;

use ModDefs;
use base 'Moderation';

sub Name { "Edit Artist Alias" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'alias'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	$self->SetArtist($al->GetRowId);
	$self->SetPrev($al->GetName);
	$self->SetNew($newname);
	$self->SetTable("artistalias");
	$self->SetColumn("name");
	$self->SetRowId($al->GetId);

	# Currently there's a unique index on artistalias.name.
	# Refuse to insert the mod if that index would be violated.
	my $test = Alias->new($self->{DBH}, 'artistalias');

	if (my $id = $test->Resolve($newname))
	{
		if ($id != $al->GetId)
		{
			$self->SetError(
				"There is already an alias called '$newname'"
				. " - duplicate aliases are not allowed (yet)"
			);
			die $self;
		}
	}
}

sub IsAutoMod
{
	my $self = shift;
	my ($old, $new) = $self->_normalise_strings($self->GetPrev, $self->GetNew);
	$old eq $new;
}

sub ApprovedAction
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $rowid = $self->GetRowId;

	my $current = $sql->SelectSingleValue(
		"SELECT name FROM artistalias WHERE id = ?",
		$rowid,
	);

	defined($current)
		or return &ModDefs::STATUS_ERROR;
	
	$current eq $self->GetPrev
		or return &ModDefs::STATUS_FAILEDDEP;

	# There's currently a unique index on artistalias.name
	# Try to detect likely violations of that index, and gracefully
	# add a note to offending moderations.

	my $test = Alias->new($self->{DBH}, 'artistalias');
	my $newname = $self->GetNew;

	if (my $id = $test->Resolve($newname))
	{
		if ($id != $self->GetRowId)
		{
			my $url = "http://" . &DBDefs::WEB_SERVER
				. "/showaliases.html?artistid=" . $id;

		 	$self->InsertNote(
				&ModDefs::MODBOT_MODERATOR,
				"There is already an alias called '$newname' (see $url)"
				. " - duplicate aliases are not allowed (yet)"
			);

			return &ModDefs::STATUS_ERROR;
		}
	}

	$sql->Do(
		"UPDATE artistalias SET name = ? WHERE id = ?",
		$self->GetNew,
		$rowid,
	);

	# Update the search engine
	my $artist = Artist->new($self->{DBH});
	$artist->SetId($self->GetArtist);
	$artist->LoadFromId;
	$artist->RebuildWordList;

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTALIAS.pm
