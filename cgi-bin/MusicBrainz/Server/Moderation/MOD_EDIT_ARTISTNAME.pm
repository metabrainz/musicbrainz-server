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

package MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTNAME;

use ModDefs;
use base 'Moderation';

sub Name { "Edit Artist Name" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'artist'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	die if $ar->GetId == &ModDefs::VARTIST_ID;
	die if $ar->GetId == &ModDefs::DARTIST_ID;

	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($newname);
	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetRowId($ar->GetId);

	# Check to see if we already have the artist that we're supposed
	# to edit to. If so, change this mod to a MERGE_ARTISTNAME.
	my $newar = Artist->new($self->{DBH});

	if ($newar->LoadFromName($newname))
	{
		if ($newar->GetId != $ar->GetId)
		{
			$self->InsertModeration(
				type	=> &ModDefs::MOD_MERGE_ARTIST,
				source	=> $ar,
				target	=> $newar,
			);
			$self->SuppressInsert;
		}
	}
}

# TODO insert note if clash (ApprovedAction)

=head

=cut

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

	return &ModDefs::STATUS_ERROR
		if $rowid == &ModDefs::VARTIST_ID
		or $rowid == &ModDefs::DARTIST_ID;

	my $current = $sql->SelectSingleValue(
		"SELECT name FROM artist WHERE id = ?",
		$rowid,
	);

	defined($current)
		or return &ModDefs::STATUS_ERROR;
	
	$current eq $this->GetPrev
		or return &ModDefs::STATUS_FAILEDDEP;

	# Special case: If this edit is an artist edit, make sure that we
	# don't attempt to insert a duplicate artist. So, search for the artist
	# and use its it, if found. Otherwise edit the artist.

	my $ar = Artist->new($this->{DBH});
	if (defined $ar->LoadFromName($this->GetNew()))
	{
	 	# Check to see if the are exact, including case
	  	if ($this->GetNew() eq $ar->GetName())
	   	{
			use HTML::Mason::Tools qw( html_escape );
		 	$this->InsertModerationNote(
				$this->GetId,
				&ModDefs::MODBOT_MODERATOR,
			 	"This edit moderation clashes with the existing artist "
				. "<a href='/showartist.html?artistid=${\ $ar->GetId }'>"
				. html_escape($ar->GetName)
				. "</a>"
			);

			return &ModDefs::STATUS_ERROR;
	   }
   }
	
	my $al = Artist->new($this->{DBH});
	my $page = $al->CalculatePageIndex($this->GetNew);

	$sql->Do(
		"UPDATE artist SET name = ?, page = ? WHERE id = ?",
		$this->GetNew,
		$page,
		$rowid,
	);

	# Update the search engine
	my $artist = Artist->new($this->{DBH});
	$artist->SetId($this->GetRowId);
	$artist->LoadFromId;
	$artist->RebuildWordList;

	# This code was in the old mod system, but personally I think it's quite
	# possibly a bad idea.
	# ruaok says: "That feature was put in place to prevent the automatic
	# duplication of artists where we were doing automatic data collection."
	# Ideally I'd like to have the option (at the time the mod is inserted)
	# as to whether this should happen.
	
	#	my $al = Alias->new($this->{DBH});
	#	$al->SetTable("ArtistAlias");
	#	$al->Insert($this->GetRowId, $this->GetPrev);

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTNAME.pm
