#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- The community music metadata project.
#
#   Copyright (C) 1998 Robert Kaye
#   Copyright (C) 2001 Luke Harless
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

use lib "../../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;
use Track;
use GUID;
use SearchEngine;
require "Main.pl";

sub Arguments
{
    return "";
}

# This function gets invoked to carry out a cleanup task. 
# Args: $dbh   - the database handle to do database work
#       $fix   - if this is non-zero, make changes to the DB. IF THIS IS
#                ZERO, THEN DO NO MAKE CHANGES TO THE DB!
#       $quiet - if non-zero then execute quietly (produce no output)
#       ...    - the arguments that the user passed on the command line
sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;
    my ($new, $count, $tr);

    $count = 0;

    $tr = Track->new($dbh);
    $sth = $dbh->prepare(qq\select Track.id, Track.name, Artist.name
                       from Track, AlbumJoin, Artist
                      where Track.id = AlbumJoin.track and
                            Track.artist = Artist.id and
                            AlbumJoin.sequence = 0\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "Remove '$row[1]' by '$row[2]'\n" if (! $quiet);

            if ($fix)
            {
                $dbh->do("delete from AlbumJoin where track = $row[0]");
                #$dbh->do("delete from Track where id = $row[0]");
                $tr->SetId($row[0]);
                if (not defined $tr->Remove())
                {
                    print "Remove failed.\n";
                }
            }
            $count++;
        }
    }
    $sth->finish;

    print "\n$count tracks converted.\n" if ($fix);
    print "\n$count tracks apply.\n" if (! $fix);
}

Main(0);
