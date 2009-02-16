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

package MusicBrainz::Server::Moderation::MOD_REMOVE_TRACK;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Track" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $al = $opts{'album'} or die;

	$self->artist($tr->artist->id);
	$self->previous_data($tr->name . "\n" . $al->id . "\n" . $al->IsNonAlbumTracks . "\n" . $tr->sequence . "\n" . $tr->length);
	$self->table("track");
	$self->column("name");
	$self->row_id($tr->id);
}

sub PostLoad
{
	my $self = shift;
	
	@$self{qw( prev.trackname 
			   prev.albumid 
			   prev.isnonalbumtracks 
			   prev.trackseq 
			   prev.tracklength)} = split /\n/, $self->previous_data;

	# attempt to load the release/track entities from the values
	# stored in this edit type. (@see Moderation::ShowModType method)
	($self->{"trackid"}, $self->{"checkexists-track"}) = ($self->row_id, 1);
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->{'prev.albumid'}, 1);

	# store value for the trackname, in case the track can't be loaded from 
	# the db (e.g. edit was applied)
	$self->{"trackname"} = $self->{"prev.trackname"};    
}

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	$rel->id($self->{albumid});
	if ($rel->LoadFromId())
	{
        return $rel->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $this = shift;

	require MusicBrainz::Server::Track;
	my $track = MusicBrainz::Server::Track->new($this->dbh);
	$track->id($this->row_id);
	$track->release($this->{'prev.albumid'});

	# Remove the album join for this track
	$track->RemoveFromAlbum;

	# Now remove the track. The track will only be removed
	# if there are no more references to it.
	unless ($track->Remove)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track could not be removed");
		# TODO should this be "STATUS_ERROR"?  Why would the Remove call fail?
		return STATUS_FAILEDDEP;
	}

	# Try to remove the release if it's a "non-album" release
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($this->dbh);
	$release->id($this->{'prev.albumid'});
	if ($release->LoadFromId)
	{
		$release->Remove
			if $release->IsNonAlbumTracks
			and $release->LoadTracks == 0;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_TRACK.pm
