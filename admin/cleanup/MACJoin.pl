#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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
    return "<album name> [0/1 -- convert to mac]";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet, $albumname, $ismac) = @_;
    my $albumid;
    my $usedalbumid;

#First select all the albums with the name given on the command line
    $mystring="select * from Album WHERE Name Like \'$albumname\'";
    print "$mystring\n";
    $sth = $dbh->prepare(qq\$mystring\);
    $sth->execute();


    if ($sth->rows)
    {
        my @row;
        @row = $sth->fetchrow_array();
        $albumid=$row[0];
        $usedalbumid=$row[0];
        $thetrack=" ALBUM=$albumid";
        while(@row = $sth->fetchrow_array())
        {
            $albumid = $row[0];
            $thetrack=$thetrack." OR ALBUM=$albumid";

        }
    }
#This Query updates the track associations in Albumjoin
#It converts all the other album numbers to the first album number returned in the first query

    $thetrack="Update AlbumJoin set album=".$usedalbumid." where".$thetrack;
    print "$thetrack\n" if (!$quiet);
    $dbh->do(qq\$thetrack\) if ($fix);

#This query deletes all the other (now orphaned) albums

    $thetrack="Delete from Album where id<>".$usedalbumid." and name like \'$albumname\'";
    print "$thetrack\n" if ($quiet);
    $dbh->do(qq\$thetrack\) if ($fix);

#If you put anything as the second command line option, this converts the album to a MAC (I Hope)
    if(defined $ismac)
    {
            $thetrack="UPDATE Album Set artist=1 where id=$usedalbumid";
            print "$thetrack\n" if (! $quiet);
            $dbh->do(qq\$thetrack\) if ($fix);
    }
    $sth->finish;

    print "Albums converted.\n" if (!$quiet);
}

Main();
