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

use FindBin;
use lib "$FindBin::Bin/../../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
require "$FindBin::Bin/Main.pl";

# This function gets invoked when the usage statement is printed out.
sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;

    RemoveFromDiskId($dbh, $fix, $quiet);
    RemoveFromTOC($dbh, $fix, $quiet);
}

sub RemoveFromDiskId
{
    my ($dbh, $fix, $quiet) = @_;
    my $last = "";
    my $count = 0;

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq|select id, disc
                            from   Discid 
                            order  by disc|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.

            if ($last eq $row[1])
            {
                print "Duplicate DiskId: $row[0] $row[1]\n";
                if ($fix)
                {
                   $dbh->do(qq\delete from Discid where id = $row[0]\); 
                   $count++;
                }
            }

            $last = $row[1];
        }
    }
    $sth->finish;

    print "\nDeleted $count disk ids\n" if ($fix);
}

sub RemoveFromTOC
{
    my ($dbh, $fix, $quiet) = @_;
    my $last = "";
    my $count = 0;

    # Here is a basic select loop for you to work with.
    $sth = $dbh->prepare(qq|select id, discid
                            from   TOC 
                            order  by discid|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            # Do something with the returned row. Make sure to
            # keep the user informed as to what the script is doing.

            if ($last eq $row[1])
            {
                print "Duplicate TOC: $row[0] $row[1]\n";
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

    print "\nDeleted $count TOCs\n" if ($fix);
}


# Call main with the number of arguments that you are expecting
Main(0);
