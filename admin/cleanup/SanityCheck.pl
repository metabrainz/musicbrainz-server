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

sub Cleanup
{
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;
    my $count = 0;

    $sth = $dbh->prepare(qq|select Album.id, Album.Artist 
                            from   Album left join Artist 
                            on     Album.artist = Artist.id 
                            WHERE  Artist.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "Album $row[0] references non-existing artist $row[1].\n";
            $count++;
        }
    }
    $sth->finish;
    print "Found $count missing artists.\n";

    $count = 0;
    $sth = $dbh->prepare(qq|select Track.id, Track.artist
                            from   Track
                            where  Track.name = ""|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "Track $row[0] by artist $row[1] has an empty track name.\n";
            $count++;
        }
    }
    $sth->finish;
    print "Found $count bad tracks.\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
