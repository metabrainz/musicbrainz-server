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

	$self->SetArtist($tr->GetArtist);
	$self->SetPrev($tr->GetName . "\n" . $al->GetId);
	$self->SetTable("track");
	$self->SetColumn("name");
	$self->SetRowId($tr->GetId);
}

sub PostLoad
{
	my $this = shift;
	
	@$this{qw( prev.name prev.albumid )} = split /\n/, $this->GetPrev;
}

sub ApprovedAction
{
	my $this = shift;

	# Remove the album join for this track
 	my $sql = Sql->new($this->{DBH});
	$sql->Do(
		"DELETE FROM albumjoin WHERE album = ? AND track = ?",
 		$this->{'prev.albumid'},
		$this->GetRowId,
	);

	# Now remove the track. The track will only be removed
   	# if there are no more references to it.
  	my $tr = Track->new($this->{DBH});
 	$tr->SetId($this->GetRowId);

	unless ($tr->Remove)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track could not be removed");
		# TODO should this be "STATUS_ERROR"?  Why would the Remove call fail?
		return STATUS_FAILEDDEP;
	}

	# Try to remove the album if it's a "non-album" album
	my $al = Album->new($this->{DBH});
	$al->SetId($this->{'prev.albumid'});
	if ($al->LoadFromId)
	{
		$al->Remove
			if $al->IsNonAlbumTracks
			and $al->LoadTracks == 0;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_TRACK.pm
