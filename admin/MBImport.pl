#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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

use lib "../cgi-bin";
use DBI;
use DBDefs;

sub ImportTable
{
    my ($name, $dir) = @_;
    my ($cmd, $dsn);

    print "Importing table $name..\n";

    $cmd = "mysqlimport -u root musicbrainz $dir/$name"; 
    $ret = system($cmd) >> 8;

    return !$ret;
}

sub ImportAllTables
{
    my ($dir) = @_;

    ImportTable("Artist", $dir) or return 0;
    ImportTable("Album", $dir) or return 0;
    ImportTable("Track", $dir) or return 0;
    ImportTable("GUID", $dir) or return 0;
    ImportTable("AlbumJoin", $dir) or return 0;
    ImportTable("GUIDJoin", $dir) or return 0;
    ImportTable("Diskid", $dir) or return 0;
    ImportTable("TOC", $dir) or return 0;
    ImportTable("ArtistAlias", $dir) or return 0;

    #ImportTable("Pending", $dir) or return 0;
    #ImportTable("ModeratorInfo", $dir) or return 0;
    #ImportTable("Changes", $dir) or return 0;
    #ImportTable("Votes", $dir) or return 0;
    #ImportTable("Genre", $dir) or return 0;

    if (DBDefs->USE_LYRICS)
    {
       ImportTable("Lyrics", $dir) or return 0;
       ImportTable("SyncText", $dir) or return 0;
       ImportTable(SyncEvent, $dir) or return 0;
    }
    else
    {
       print "Skipping importing of lyrics tables.\n";
    }

    print "\nImported tables successfully.\n";

    return 1;
}

my ($infile, $dir);

$infile = shift;
if (!defined $infile || $infile eq "-h" || $infile eq "--help")
{
    print "Usage: MBImport.pl <dumpfile>\n\n";
    print "Make sure to have plenty of diskspace on /tmp!\n";
    exit(0);
}

$dir = "/tmp/mbdump";

(!(system("tar -C /tmp -xIf $infile") >> 8))
   or die("Cannot untar/unzip the database dump.\n");
 
ImportAllTables($dir);

system("rm -rf $dir");
