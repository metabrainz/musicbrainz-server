#!/usr/bin/perl -w
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

use lib "../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;
use Artist;
use ModDefs;
use Sql;

sub CollectStats
{
    my ($sql) = @_;

    my ($artists, $albums, $tracks, $discids, $trmids, $mods, $votes, $moderators);

    ($artists) = $sql->GetSingleColumn("artist", "count(*)", []);
    print "   Artists: $artists\n";

    ($albums) = $sql->GetSingleColumn("album", "count(*)", []);
    print "    Albums: $albums\n";

    ($tracks) = $sql->GetSingleColumn("track", "count(*)", []);
    print "    Tracks: $tracks\n";

    ($discids) = $sql->GetSingleColumn("discid", "count(*)", []);
    print "   DiscIds: $discids\n";

    ($trmids) = $sql->GetSingleColumn("trm", "count(*)", []);
    print "    TRMIds: $trmids\n";

    ($mods) = $sql->GetSingleColumn("Moderation", "count(*)", []);
    print "      Mods: $mods\n";

    ($votes) = $sql->GetSingleColumn("Votes", "count(*)", []);
    print "     Votes: $votes\n";

    ($moderators) = $sql->GetSingleColumn("Moderator", "count(*)", []);
    print "Moderators: $moderators\n";

    eval
    {
        $sql->Begin;
        $sql->Do(qq|insert into Stats (artists, albums, tracks, discids, trmids,
                    moderations, votes, moderators, timestamp) values
                    ($artists, $albums, $tracks, $discids, $trmids, $mods, 
                     $votes, $moderators, current_date())|);
        $sql->Commit;
    };
    if ($@)
    {
        $sql->Rollback;
        print "Failed to insert stats!\n($@)\n";
        return 0;
    }
    print "Inserted stats successfully.\n\n";

    return 1;
}

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

CollectStats($sql);

# Disconnect
$mb->Logout;
