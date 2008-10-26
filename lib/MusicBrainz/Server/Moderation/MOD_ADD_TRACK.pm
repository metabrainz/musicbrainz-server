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

package MusicBrainz::Server::Moderation::MOD_ADD_TRACK;

use ModDefs;
use base 'Moderation';

sub Name { "Add Track (old version)" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;
	die "MOD_ADD_TRACK moderations are no longer being accepted";
}

sub PostLoad
{
	my $self = shift;

	# artist[sort]name are only present where artist == VARTIST_ID
	# Even then artistsortname may be missing
	@$self{qw(
		new.trackname new.tracknum
		new.album
		new.artistname new.artistsortname
	)} = split /\n/, $self->new_data;
}

sub ApprovedAction
{
	warn "MOD_ADD_TRACK moderations are no longer being accepted";
	&ModDefs::STATUS_ERROR;
}

1;
# eof MOD_ADD_TRACK.pm
