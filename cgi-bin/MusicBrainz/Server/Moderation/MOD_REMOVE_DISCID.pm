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

package MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Disc ID" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $di = $opts{discid} or die;

	$self->SetTable("discid");
	$self->SetColumn("disc");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($di->GetId);
	$self->SetPrev($di->GetDiscid);
	$self->SetNew("");
}

sub ApprovedAction
{
	my $this = shift;

	require Discid;
	my $di = Discid->new($this->{DBH});

	unless ($di->Remove($this->GetPrev))
	{
		$this->InsertNote(MODBOT_MODERATOR, "This disc ID could not be removed");
		# TODO should this be "STATUS_ERROR"?  Why would the Remove call fail?
		return STATUS_FAILEDDEP;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_DISCID.pm
