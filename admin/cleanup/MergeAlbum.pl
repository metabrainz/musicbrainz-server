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
use GUID;
use Artist;
use Diskid;
use Track;
require "Main.pl";

sub Arguments
{
    return "<merge into album id> <merge album id> ...";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet, @list) = @_;
    my ($al);

    if (scalar(@list) < 2)
    {
        print "At least two albums must be given.\n\n";
        Usage();
        return;
    }

    if (!$fix)
    {
        print "This script cannot be tested first.\n";
        return;
    }

    $al = Album->new($dbh);
    $al->SetId(shift @list);
    if (defined $al->LoadFromId())
    {
        if (defined $al->MergeAlbums(@list))
        {
            print "Merged albums\n";
        }
        else
        {
            print "Failed to merge albums\n";
        }
    }
    else
    {
        print "Invalid album id specified\n";
    }
}

Main(2);
