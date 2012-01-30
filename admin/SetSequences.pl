#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

use FindBin;
use lib "$FindBin::Bin/../lib";

use DBDefs;
use MusicBrainz::Server::Context;
use Sql;

sub SetSequence
{
    my ($sql, $table, $max) = @_;

    my $seq = $table . "_id_seq";

    eval
    {
        $sql->Begin;

        if (not defined $max)
        {
                $max = $sql->GetColumnRange($table);
        }

        $max++;

        $sql->SelectSingleValue("SELECT SETVAL(?, ?)", $seq, $max);
        $sql->Commit;

        printf "%12d  %s\n", $max, $seq;
    };
    if ($@)
    {
        $sql->Rollback;
    }
}

my $c = MusicBrainz::Server::Context->new;
my $sql = Sql->new($c->conn);

SetSequence($sql, "album");
SetSequence($sql, "albumjoin");
# album_amazon_asin - not a serial column
SetSequence($sql, "album_cdtoc");
# albummeta - not a serial column
# albumwords - no unique integer column
SetSequence($sql, "annotation");
SetSequence($sql, "artist");
SetSequence($sql, "artist_relation");
SetSequence($sql, "artistalias");
# artistwords - no unique column
SetSequence($sql, "automod_election");
SetSequence($sql, "automod_election_vote");
SetSequence($sql, "cdtoc");
SetSequence($sql, "clientversion");
SetSequence($sql, "country");
SetSequence($sql, "currentstat");
SetSequence($sql, "historicalstat");
SetSequence($sql, "l_album_album");
SetSequence($sql, "l_album_artist");
SetSequence($sql, "l_album_label");
SetSequence($sql, "l_album_track");
SetSequence($sql, "l_album_url");
SetSequence($sql, "l_artist_artist");
SetSequence($sql, "l_artist_label");
SetSequence($sql, "l_artist_track");
SetSequence($sql, "l_artist_url");
SetSequence($sql, "l_label_label");
SetSequence($sql, "l_label_track");
SetSequence($sql, "l_label_url");
SetSequence($sql, "l_track_track");
SetSequence($sql, "l_track_url");
SetSequence($sql, "l_url_url");
SetSequence($sql, "label");
SetSequence($sql, "labelalias");
# labelwords - no unique column
SetSequence($sql, "language");
SetSequence($sql, "link_attribute");
SetSequence($sql, "link_attribute_type");
SetSequence($sql, "lt_album_album");
SetSequence($sql, "lt_album_artist");
SetSequence($sql, "lt_album_label");
SetSequence($sql, "lt_album_track");
SetSequence($sql, "lt_album_url");
SetSequence($sql, "lt_artist_artist");
SetSequence($sql, "lt_artist_label");
SetSequence($sql, "lt_artist_track");
SetSequence($sql, "lt_artist_url");
SetSequence($sql, "lt_label_label");
SetSequence($sql, "lt_label_track");
SetSequence($sql, "lt_label_url");
SetSequence($sql, "lt_track_track");
SetSequence($sql, "lt_track_url");
SetSequence($sql, "lt_url_url");
# moderation_closed - see below
# moderation_note_closed - see below
# moderation_note_open - see below
# moderation_open - see below
SetSequence($sql, "moderator");
SetSequence($sql, "moderator_preference");
SetSequence($sql, "moderator_subscribe_artist");
SetSequence($sql, "moderator_subscribe_label");
SetSequence($sql, "puid");
SetSequence($sql, "puidjoin");
SetSequence($sql, "puidjoin_stat");
SetSequence($sql, "puid_stat");
SetSequence($sql, "release");
SetSequence($sql, "replication_control");
SetSequence($sql, "script");
SetSequence($sql, "script_language");
SetSequence($sql, "stats");
SetSequence($sql, "tag");
SetSequence($sql, "track");
# trackwords - no unique column
SetSequence($sql, "url");
# vote_closed - see below
# vote_open - see below
SetSequence($sql, "wordlist");

# For the three pairs of open/closed tables (moderation, moderation_note
# and vote), it is possible that the largest ID is actually in the closed
# table, not the open one.  So we need to find the largest ID across both
# tables, then set the "open" sequence based on that.  (There is no "closed"
# sequence).

$_ = "moderation";
SetSequence($sql, "${_}_open", scalar $sql->GetColumnRange(["${_}_open", "${_}_closed"]));
$_ = "moderation_note";
SetSequence($sql, "${_}_open", scalar $sql->GetColumnRange(["${_}_open", "${_}_closed"]));
$_ = "vote";
SetSequence($sql, "${_}_open", scalar $sql->GetColumnRange(["${_}_open", "${_}_closed"]));

# eof SetSequences.pl
