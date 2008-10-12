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

package MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNAME;

use strict;
use warnings;

use base 'Moderation';

use ModDefs qw( :modstatus MODBOT_MODERATOR );

sub Name { "Edit Track Name" }
sub id   { 4 }

sub edit_conditions
{
    return {
        ModDefs::QUALITY_LOW => {
            duration     => 4,
            votes        => 1,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },  
        ModDefs::QUALITY_NORMAL => {
            duration     => 14,
            votes        => 3,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },
        ModDefs::QUALITY_HIGH => {
            duration     => 14,
            votes        => 4,
            expireaction => ModDefs::EXPIRE_REJECT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },
    }
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $track = $opts{'track'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	$self->artist($track->artist->id);
	$self->SetPrev($track->name);
	$self->SetNew($newname);
	$self->table("track");
	$self->SetColumn("name");
	$self->row_id($track->id);
}

sub IsAutoEdit
{
	my $this = shift;
	my ($old, $new) = $this->_normalise_strings($this->GetPrev, $this->GetNew);
	$old eq $new;
}

sub PostLoad
{
	my $self = shift;

	# attempt to load the release/track entities from the values
	# stored in this edit type. (@see Moderation::ShowModType)
	# -- the album will be loaded from the album-track core
	#    relationship if the track was loaded successfully.
	($self->{"trackid"}, $self->{"checkexists-track"}) = ($self->row_id, 1);
	($self->{"albumid"}, $self->{"checkexists-album"}) = (undef, 1);	
	
	# TODO: what can we do that the release is loaded from this track object?
	# Track.LoadFromId without an albumid set, should load the albumid
	# from the albumjoin table, but it does not.	
}

sub DetermineQuality
{
	my $self = shift;

    # Attempt to find the right release this track is attached to.
	my $tr = MusicBrainz::Server::Track->new($self->{DBH});
    $tr->id($self->{trackid});
	if ($tr->LoadFromId())
	{
        my $rel = MusicBrainz::Server::Release->new($self->{DBH});
        $rel->id($tr->release());
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }

    # if that fails, go by the artist
    my $ar = $tr->artist;
    if ($ar->LoadFromId())
    {
        return $ar->quality;        
    }

    return &ModDefs::QUALITY_NORMAL;
}

sub CheckPrerequisites
{
	my $self = shift;

	# Load the track by ID
	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($self->{DBH});
	$track->id($self->row_id);
	unless ($track->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed
	if ($track->name ne $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# FIXME utf-8 length required
	if (length($self->GetNew) > 255)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This name is too long - the maximum allowed length is 255 characters");
		return STATUS_ERROR;
	}

	# Save for ApprovedAction
	$self->{_track} = $track;

	undef;
}

sub ApprovedAction
{
	my $this = shift;

	my $status = $this->CheckPrerequisites;
	return $status if $status;

	my $track = $this->{_track}
		or die;

	$track->name($this->GetNew);
	$track->UpdateName;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKNAME.pm
