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

	$self->artist($track->artist->id);
	$self->previous_data($track->sequence);
	$self->new_data(0+$newseq);
	$self->table("albumjoin");
	$self->column("sequence");
	$self->row_id($track->sequence_id);
}

sub PostLoad
{
	my $self = shift;
	
	# load track and release object
	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($self->GetDBH);
	
	if ($self->{'trackexists'} = $track->LoadFromAlbumJoin($self->row_id))
	{
		$self->{'trackid'} = $track->id;
		$self->{'trackname'} = $track->name;
 
		require MusicBrainz::Server::Release;
		my $release = MusicBrainz::Server::Release->new($self->GetDBH);
		$release->id($track->release);
		if ($self->{'albumexists'} = $release->LoadFromId)
		{
			$self->{'albumid'} = $release->id;
			$self->{'albumname'} = $release->name;
		}
	}
}

sub DetermineQuality
{
	my $self = shift;

    # see if we loaded the album
	if ($self->{'albumexists'})
	{
        my $rel = MusicBrainz::Server::Release->new($self->GetDBH);
        $rel->id($self->{albumid});
        if ($rel->LoadFromId())
        {
            return $rel->quality;        
        }
    }

    # if that fails, go by the artist
    my $ar = MusicBrainz::Server::Artist->new($self->GetDBH);
    $ar->id($self->{artist});
    if ($ar->LoadFromId())
    {
        return $ar->quality;        
    }

    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $this = shift;

	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($this->GetDBH);
	unless ($track->LoadFromAlbumJoin($this->row_id))
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	unless ($track->sequence == $this->previous_data)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has already been renumbered");
		return STATUS_FAILEDDEP;
	}

	# TODO check no other track exists with the new sequence?
	# (but if you do that, it makes it very hard to swap/rotate
	# tracks within an album).

	$track->sequence($this->new_data);
	$track->UpdateSequence;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKNUM.pm
