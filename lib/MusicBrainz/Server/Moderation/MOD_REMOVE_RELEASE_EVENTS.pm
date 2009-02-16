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
#   $Id: MOD_MERGE_RELEASE_MAC.pm 7397 2006-05-01 12:56:48Z keschte $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE_EVENTS;

use ModDefs;
use base qw(
	MusicBrainz::Server::Moderation::MOD_EDIT_RELEASE_EVENTS_OLD
);

sub Token() { "MOD_REMOVE_RELEASE_EVENTS" }
sub Type() { &ModDefs::MOD_REMOVE_RELEASE_EVENTS }
sub Name { "Remove Release Events" }

(__PACKAGE__)->RegisterHandler;

# MOD_EDIT_RELEASE_EVENTS_OLD does all the work

1;
# eof MOD_REMOVE_RELEASE_EVENTS.pm
