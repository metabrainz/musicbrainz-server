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
require "Main.pl";

sub Arguments
{
    # Return the argument list that the Cleanup function should
    # expect after the dbh, fix and quiet aguments.
    # Eample:   <album id> [album id] ...
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;
    my ($sth2, @row2, @missing_list, $count, $missing, $fixed);

    $count = $fixed = $missing = 0;
    # Check to make sure all the albums are present.
    $sth = $dbh->prepare(qq\select distinct album from AlbumJoin 
                            order by Album\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        $count = $sth->rows;
        while(@row = $sth->fetchrow_array())
        {
            $sth2 = $dbh->prepare(qq\select id from Album where id = $row[0]\);
            if ($sth2->execute())
            {
                if ($sth2->rows() == 0)
                {
                   print "AlbumJoin: Album $row[0] is missing.\n"
                       if (!$quiet);
                   push @missing_list, $row[0];
                   $missing++;
                }

                $sth2->finish;
            }
        }
    }
    $sth->finish;

    print "Found $count distinct albums, $missing missing.\n"
       if (!$quiet);

    $count = $missing = 0;
    # Check to make sure all the tracks are there.
    $sth = $dbh->prepare(qq\select distinct track from AlbumJoin 
                            order by track\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        $count = $sth->rows;
        while(@row = $sth->fetchrow_array())
        {
            $sth2 = $dbh->prepare(qq\select id from Track where id = $row[0]\);
            if ($sth2->execute())
            {
                if ($sth2->rows() == 0)
                {
                   print "AlbumJoin: Track $row[0] is missing.\n"
                       if (!$quiet);
                   push @missing_list, $row[0];
                   $missing++;
                }

                $sth2->finish;
            }
        }
    }
    $sth->finish;
    print "Found $count distinct tracks, $missing missing.\n"
       if (!$quiet);

    # Perhaps carry out some actions, if $fix is non-zero
    #$dbh->do(qq\  \) if ($fix);

    print "\nFix not implemented yet. (0 fixed).\n" if ($fix);
}

# Call main with the number of arguments that you are expecting
Main(0);
