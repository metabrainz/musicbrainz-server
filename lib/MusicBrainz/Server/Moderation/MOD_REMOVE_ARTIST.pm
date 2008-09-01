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

package MusicBrainz::Server::Moderation::MOD_REMOVE_ARTIST;

use ModDefs qw( :modstatus :artistid MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Artist" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'artist'} or die;
	die if $ar->GetId == VARTIST_ID;
	die if $ar->GetId == DARTIST_ID;

	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetRowId($ar->GetId);
}

sub DetermineQuality
{
    my $self = shift;

    my $ar = MusicBrainz::Server::Artist->new($self->{DBH});
    $ar->SetId($self->{artist});
    if ($ar->LoadFromId())
    {
        return $ar->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $this = shift;

	my $rowid = $this->GetRowId;

	if ($rowid == VARTIST_ID or $rowid == DARTIST_ID)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist cannot be deleted");
		return STATUS_ERROR;
	}
   
	# Now remove the Artist. The Artist will only be removed
	# if there are not more references to it.
	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($this->{DBH});
	$ar->SetId($rowid);

	require UserSubscription;
	my $subs = UserSubscription->new($this->{DBH});
	$subs->ArtistBeingDeleted($ar, $this);

	unless (defined $ar->Remove)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This artist could not be removed");
		return STATUS_FAILEDDEP;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_ARTIST.pm
