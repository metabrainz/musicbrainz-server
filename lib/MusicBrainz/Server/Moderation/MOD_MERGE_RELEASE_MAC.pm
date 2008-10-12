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

package MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE_MAC;

use strict;
use warnings;

use ModDefs;
use base qw(
	MusicBrainz::Server::Moderation::MOD_MERGE_RELEASE
);

# Workaround: when Moderation.pm evaluates these two methods it installs them
# as constants for speed.  However since it then installs our parent-class'
# values in the parent class, that means we don't get our own values.
# Workaround: specify our own values (as constants).
sub Token() { "MOD_MERGE_RELEASE_MAC" }
sub Type() { &ModDefs::MOD_MERGE_RELEASE_MAC }

sub Name { "Merge Releases (Various Artists)" }
sub moderation_id   { 25 }

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
            autoedit     => 0,
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

# MOD_MERGE_RELEASE does all the work

1;
# eof MOD_MERGE_RELEASE_MAC.pm
