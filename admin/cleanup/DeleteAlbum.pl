#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
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
use Album;
use Track;
use Artist;
use Alias;
use TRM;

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
    my ($al);

    if ($fix)
    {
        $al = Album->new($dbh);
        $al->SetId($thenum);
        $ret = $al->Remove();
        if (!$quiet)
        {
            if (defined $ret)
            {
                print "Album $thenum deleted.\n";
            }
            else
            {
                print "Album coulnd not be deleted.\n";
            }
        }
    }
}

Main(1);
