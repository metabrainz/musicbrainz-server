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
    my ($sth2, @row2, @skipped_list, $count, $skipped, $found);

    $count = $found = $skipped = 0;
    # Check to make sure all the albums are present.
    $sth = $dbh->prepare(qq\select id, name from Album order by id\);
    if ($sth->execute() && $sth->rows())
    {
        my (@row, $new, $disc);

        $count = $sth->rows;
        while(@row = $sth->fetchrow_array())
        {
            if ($row[1] =~ /^(.*)(\(|\[)\s*(disc|cd)\s*(\d+)(\)|\])$/i)
            {
                $new = $1;
                $disc = $4;
                $new =~ s/\s*[:,.-]*\s*$//;
                $new .= " (disc $disc)";
            }
            elsif ($row[1] =~ /^(.*)(disc|cd)\s*(\d+)$/i)
            {
                $new = $1;
                $disc = $3;
                $new =~ s/\s*[:,.-]*\s*$//;
                $new .= " (disc $disc)";
            }
            else
            {
                next;
            }

            if ($new ne $row[1])
            {
                $found++;
                print "From: $row[1]\n";
                print "  To: $new\n\n";

                $new = $dbh->quote($new);
                $dbh->do("update Album set name = $new where id = $row[0]")
                   if ($fix);
            }
            else
            {
                $skipped++;
            }
        }
    }
    $sth->finish;

    print "Updated $found album names\n";
    print "$skipped albums didn't need changing.\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
