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

# This function gets invoked when the usage statement is printed out.
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
    my ($count, $missing, @missing_list, $sth2, @row2, $id, $fixed);

    $count = $missing = $fixed = 0;

    # Check for missing artists in the track table.
    $sth = $dbh->prepare(qq\select distinct artist from Track order by artist\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        $count = $sth->rows;
        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.
            $sth2 = $dbh->prepare(qq\select id from Artist where id = $row[0]\);
            if ($sth2->execute())
            {
                if ($sth2->rows() == 0)
                {
                   print "Track: Artist $row[0] is missing.\n";
                   push @missing_list, $row[0];
                   $missing++;
                }

                $sth2->finish;
            }
        }
    }
    $sth->finish;

    print "$count artists found, $missing artists missing from track table.\n" 
        if (!$quiet);
    if ($missing > 0)
    {
        $sth = $dbh->prepare(qq\select id from Artist where name='Unknown'\);
        if ($sth->execute() && $sth->rows())
        {
            my @row;
    
            @row = $sth->fetchrow_array();
            print "Setting missing artists to $row[0]\n";
            $sth->finish;

            if ($fix)
            {
                foreach $id (@missing_list)
                {
                    $dbh->do (qq/update Track set artist = $row[0] 
                                where artist = $id/); 
                    $fixed++;
                }
            }
        }
    }

    $count = $missing = 0;
    @missing_list = ();

    # Check for missing artists in the album table
    $sth = $dbh->prepare(qq\select distinct artist from Album order by artist\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        $count += $sth->rows;
        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.
            $sth2 = $dbh->prepare(qq\select id from Artist where id = $row[0]\);
            if ($sth2->execute())
            {
                if ($sth2->rows() == 0)
                {
                   print "Album: Artist $row[0] is missing.\n";
                   push @missing_list, $row[0];
                   $missing++;
                }

                $sth2->finish;
            }
        }
    }

    print "$count artists found, $missing artists missing from album table.\n" 
        if (!$quiet);
    if ($missing > 0)
    {
        $sth = $dbh->prepare(qq\select id from Artist where name='Unknown'\);
        if ($sth->execute() && $sth->rows())
        {
            my @row;
    
            @row = $sth->fetchrow_array();
            print "Setting missing artists to $row[0]\n";
            $sth->finish;

            if ($fix)
            {
                foreach $id (@missing_list)
                {
                    $dbh->do(qq/update Album set artist = $row[0] 
                                where artist = $id/);
                    $fixed++;
                }
            }
        }
    }

    print "\nFixed $fixed items.\n" if ($fix);
}

# Call main with the number of arguments that you are expecting
Main(0);
