#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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
use GUID;
use Pending;
require "Main.pl";

sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;
    my ($sth, $al, $ar, $tr, $gu, @tracks, $track, $count, $pe);

    $gu = GUID->new($dbh);
    $pe = Pending->new($dbh);
   
    if (! $fix)
    {
        print "Sorry this script cannot do preview.\n";
        return;
    }

    $count = 0;
    $sth = $dbh->prepare(qq\select * from Pending 
                            order by artist, album\);
    if ($sth->execute() && $sth->rows)
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            if ($gu->AssociateGUID($row[5], $row[1], $row[2], $row[3]))
            {
                $dbh->do("delete from Pending where id = $row[0]");
                print "$row[2] -- $row[3] -- $row[1]\n" if (! $quiet);
                shift @row;
                $pe->InsertIntoBitziArchive(@row);
                $count++;
            }
        }
    }
    $sth->finish;

    print "Found $count matching tracks.\n";
}

Main(0);
