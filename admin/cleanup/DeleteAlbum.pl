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

# TODO: Make this script take multiple arguments so we can delete a whole
#       list of albums at once
sub Arguments
{
    return "<album id> | <album id file>";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet, $arg) = @_;
    my ($id, $name, $album);

    if (!defined $arg)
    {
        print "Incorrect number arguments given.\n\n";
        Usage();
        return;
    }

    if (-e $arg)
    {
        open FILE, "< $arg"
           or die "Cannot open file $arg.\n";
 
        while(defined($id = <FILE>))
        {
            DeleteAlbum($dbh, $fix, $quiet, $id);
        }
        close(FILE);
    }
    else
    {
        DeleteAlbum($dbh, $fix, $quiet, $arg);
    }
}

sub DeleteAlbum
{
    my ($dbh, $fix, $quiet, $thenum) = @_;
    my ($id, $name, $album);

    # RAK: If the fix flag is not given, we should really print out
    #      human understandable output. 

    #This query selects the tracks associated with the given album number
    $sth = $dbh->prepare(qq\SELECT track FROM AlbumJoin WHERE (((AlbumJoin.Album)=$thenum))\);
    $sth->execute();

    #Loop through the returned queryset and make the sql to delete the tracks
    if ($sth->rows)
    {
        my @row;

        @row = $sth->fetchrow_array();
        $track=$row[0];
        $thetrack="DELETE from Track WHERE id=$track";
        while(@row = $sth->fetchrow_array())
        {
            $thetrack .= " OR id=$row[0]";
        }
    }
    $sth->finish;

    #Delete the tracks
    print "$thetrack\n" if (!$quiet);
    $dbh->do(qq\$thetrack\) if ($fix);

    #Delete the album from albumjoin
    print(qq/DELETE FROM AlbumJoin WHERE ALBUM=$thenum\n/) if (!$quiet);
    $dbh->do(qq\DELETE FROM AlbumJoin WHERE ALBUM=$thenum\) if ($fix);

    # RAK: Need to delete album from album table too!
    print(qq/DELETE FROM Album WHERE ID=$thenum\n/) if (!$quiet);
    $dbh->do(qq\DELETE FROM Album WHERE ID=$thenum\) if ($fix);

    # RAK: It would be nice if the artist was deleted after the
    #      last album was deleted.

    print "\nAlbum deleted.\n" if ($fix);
}

Main(1);
