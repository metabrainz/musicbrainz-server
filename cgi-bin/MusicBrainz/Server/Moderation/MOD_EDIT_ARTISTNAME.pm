#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

use ModDefs qw( :modstatus :artistid MODBOT_MODERATOR MOD_MERGE_ARTIST );
use base 'Moderation';

sub Name { "Edit Artist Name" }
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
				type	=> MOD_MERGE_ARTIST,
				source	=> $ar,
				target	=> $newar,
			);
			$self->SuppressInsert;
		}
	}
}

sub IsAutoMod
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->GetPrev, $this->GetNew);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->GetRowId;

	if ($rowid == VARTIST_ID or $rowid == DARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't rename this artist!");
		return STATUS_ERROR;
	}

	# Load the artist by ID
	my $ar = Artist->new($self->{DBH});
	$ar->SetId($rowid);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed
	if ($ar->GetName ne $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# Avert duplicate index entries: check for this name already existing
	my $dupar = Artist->new($self->{DBH});
	if ($dupar->LoadFromName($self->GetNew))
	{
	 	# Check to see if they are exact, including case
	  	if ($self->GetNew eq $dupar->GetName)
		{
			my $url = "http://" . &DBDefs::WEB_SERVER
				. "/showartist.html?artistid=" . $dupar->GetId;

		 	$self->InsertNote(
				MODBOT_MODERATOR,
			 	"This edit moderation clashes with the existing artist"
				. " '" . $dupar->GetName . "': "
				. $url
			);

			return STATUS_ERROR;
		}
	}
	
	# Save for ApprovedAction
	$self->{_artist} = $ar;

	undef;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $artist = $this->{_artist};
	$artist->UpdateName($this->GetNew)
		or die "Failed to update artist in MOD_EDIT_ARTISTNAME";

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTNAME.pm
