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
    my ($new, $count);

    $count = 0;

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq\select id, sortname from Artist\);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.

            if ($row[1] =~ /^the /i)
            {
                $new = $row[1];
                $new =~ s/^the //i;
                $new .= ", The";

                print "$row[1] --> $new\n" if (! $quiet);

                $new = $dbh->quote($new);
                $dbh->do(qq\update Artist set SortName = $new 
                            where id = $row[0]\) if ($fix);
                $count++;
            }
        }
    }
    $sth->finish;

    print "\n$count artists converted.\n" if ($fix);
    print "\n$count artists apply.\n" if (! $fix);
}

Main(0);
