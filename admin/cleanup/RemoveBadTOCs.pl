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

sub CheckTOC
{
    my ($toc) = @_;

    return 0 if ($toc eq '1');

    my @parts = split / /, $toc;

    return 0 if $parts[0] != 1;
    return 0 if $parts[1] < 1;
    return 0 if $parts[1] > 99;
    return 0 if $parts[1] != scalar(@parts) - 3;
    return 0 if $parts[2] <= $parts[scalar(@parts) - 1]; 

    for (3 .. (scalar(@parts) - 2))
    {
        return 0 if ($parts[$_] >= $parts[$_ + 1]);
    }

    return 1;
}

# This function gets invoked when the usage statement is printed out.
sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;

    my $last = "";
    my $bad = 0;
    my $good = 0;

    $sth = $dbh->prepare(qq|select toc, disc, album
                            from   discid|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            if (!CheckTOC($row[0]))
            {
                print "TOC '$row[0]' is bad ($row[1] $row[2])\n";
                if ($fix)
                {
                   $dbh->do(qq\delete from TOC where discid = '$row[1]'\); 
                   $dbh->do(qq\delete from discid where disc = '$row[1]'\); 
                   $dbh->do(qq\update track set length = 0 where id in (select albumjoin.track from albumjoin where album = $row[2])\);
                }
                $bad++;
            }
            else
            {
                $good++;
            }
            $last = $row[1];
        }
    }
    $sth->finish;

    print "\n$bad bad tocs, $good good tocs\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
