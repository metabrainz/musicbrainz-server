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

package MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Track Number" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $track = $opts{'track'} or die;
	my $newseq = $opts{'newseq'} or die;

	$self->SetArtist($track->GetArtist);
	$self->SetPrev($track->GetSequence);
	$self->SetNew(0+$newseq);
	$self->SetTable("albumjoin");
	$self->SetColumn("sequence");
	$self->SetRowId($track->GetSequenceId);
}

sub PostLoad
{
	my $self = shift;
	
	# load track and release object
	require Track;
	my $track = Track->new($self->{DBH});
	
	if ($self->{'trackexists'} = $track->LoadFromAlbumJoin($self->GetRowId))
	{
		$self->{'trackid'} = $track->GetId;
		$self->{'trackname'} = $track->GetName;
 
		require Album;
		my $release = Album->new($self->{DBH});
		$release->SetId($track->GetAlbum);
		if ($self->{'albumexists'} = $release->LoadFromId)
		{
			$self->{'albumid'} = $release->GetId;
			$self->{'albumname'} = $release->GetName;
		}
	}
}

sub DetermineQuality
{
	my $self = shift;

    # see if we loaded the album
	if ($self->{'albumexists'})
	{
        my $rel = Album->new($self->{DBH});
        $rel->SetId($self->{albumid});
        if ($rel->LoadFromId())
        {
            return $rel->GetQuality();        
        }
    }

    # if that fails, go by the artist
    my $ar = Artist->new($self->{DBH});
    $ar->SetId($self->{artist});
    if ($ar->LoadFromId())
    {
        return $ar->GetQuality();        
    }

    print STDERR __PACKAGE__ . ": quality not determined\n";
    return &ModDefs::QUALITY_UNKNOWN;
}

sub ApprovedAction
{
	my $this = shift;

	require Track;
	my $track = Track->new($this->{DBH});
	unless ($track->LoadFromAlbumJoin($this->GetRowId))
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	unless ($track->GetSequence == $this->GetPrev)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has already been renumbered");
		return STATUS_FAILEDDEP;
	}

	# TODO check no other track exists with the new sequence?
	# (but if you do that, it makes it very hard to swap/rotate
	# tracks within an album).

	$track->SetSequence($this->GetNew);
	$track->UpdateSequence;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKNUM.pm
