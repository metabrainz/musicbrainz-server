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

# To convert on fatman:
# alter table Diskid drop index DiskIndex;
# alter table Diskid add unique index DiskIndex (Disk);
# alter table TOC drop index DiskIndex;
# alter table TOC add unique index DiskIndex (Diskid);

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;
    my $last = "";
    my $count = 0;

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq|select id, diskid
                            from   TOC 
                            order  by diskid|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.

            if ($last eq $row[1])
            {
                print "Duplicate: $row[0] $row[1]\n";
                if ($fix)
                {
                   $dbh->do(qq\delete from TOC where id = $row[0]\); 
                   $count++;
                }
            }

            $last = $row[1];
        }
    }
    $sth->finish;

    print "\nDeleted $count disk ids\n" if ($fix);
}

# Call main with the number of arguments that you are expecting
Main(0);
