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

package MusicBrainz::Server::Moderation::MOD_EDIT_TRACKTIME;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Track Time" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $newlength = $opts{'newlength'};

	$self->SetArtist($tr->GetArtist);
	$self->SetPrev($tr->GetLength);
	$self->SetNew(0+$newlength);
	$self->SetTable("track");
	$self->SetColumn("length");
	$self->SetRowId($tr->GetId);
}

sub IsAutoMod
{
	my $self = shift;

	return $self->GetPrev == 0 && $self->GetNew != 0;
}

sub ApprovedAction
{
	my $self = shift;

	require Track;
	my $tr = Track->new($self->{DBH});
	$tr->SetId($self->GetRowId); 
	unless ($tr->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	unless ($tr->GetLength == $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "Track time has already been changed");
		return STATUS_FAILEDDEP;
	}
	
	$tr->SetLength($self->GetNew);
	$tr->UpdateLength;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKTIME.pm
