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
    # Return the argument list that the Cleanup function should
    # expect after the dbh, fix and quiet aguments.
    # Eample:   <album id> [album id] ...
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
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;

    # Do your argument checking here. Make sure you have valid input...
    if (!defined $arg1 || $arg1 ne '')
    {
        print "Incorrect number orguments given.\n\n";
        Usage();
        return;
    }

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq\ \);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.


        }
    }
    $sth->finish;

    # Perhaps carry out some actions, if $fix is non-zero
    print " < some status output > " if (!$quiet);
    $dbh->do(qq\  \) if ($fix);

    print "\n < action completed output goes here >\n" if ($fix);
}

Main();
