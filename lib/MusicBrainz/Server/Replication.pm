#!/usr/bin/env perl

use warnings;
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

package MusicBrainz::Server::Replication;

# The possible values for DBDefs->REPLICATION_TYPE
use constant RT_MASTER => 1;
use constant RT_SLAVE => 2;
use constant RT_STANDALONE => 3;

use constant NON_REPLICATED_TABLES => qw(
    automod_election
    automod_election_vote
    moderation_closed
    moderation_note_closed
    moderation_note_open
    moderation_open
    moderator
    moderator_preference
    moderator_subscribe_artist
    puidjoin_stat
    puid_stat
    vote_closed
    vote_open
);

use Exporter;
{
    our @ISA = qw( Exporter );
    our %EXPORT_TAGS = (
        replication_type => [qw(
                RT_MASTER
                RT_SLAVE
                RT_STANDALONE
        )],
    );
    our @EXPORT_OK = do {
        my %seen;
        grep { not $seen{$_}++ } map { @$_ } values %EXPORT_TAGS
    };
    push @EXPORT_OK, qw(
        NON_REPLICATED_TABLES
    );
    $EXPORT_TAGS{'all'} = \@EXPORT_OK;
}

1;
# eof Replication.pm
