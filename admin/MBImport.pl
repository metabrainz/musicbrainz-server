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

use lib "../cgi-bin";
use DBI;
use DBDefs;

sub ImportTable
{
    my ($name, $dir) = @_;
    my ($cmd, $dsn);


    if (-e "$dir/$name")
    {
        my $dataonly = ($name eq 'moderator_sanitised') ? '' : '-a';
        print "Importing table $name..\n";
        $cmd = "pg_restore $dataonly -t $name -d musicbrainz $dir/$name"; 
        print "$cmd\n";
        $ret = system($cmd) >> 8;

        return !$ret;
    }
    else
    {
        print "Skipping table $name (no file present)\n";
        return 1;
    }
}

sub ImportAllTables
{
    my ($dir) = @_;

    ImportTable("artist", $dir) or return 0;
    ImportTable("artistalias", $dir) or return 0;
    ImportTable("album", $dir) or return 0;
    ImportTable("track", $dir) or return 0;
    ImportTable("albumjoin", $dir) or return 0;
    ImportTable("trm", $dir) or return 0;
    ImportTable("trmjoin", $dir) or return 0;
    ImportTable("discid", $dir) or return 0;
    ImportTable("toc", $dir) or return 0;
    ImportTable("clientversion", $dir) or return 0;
    ImportTable("albummeta", $dir) or return 0;

    ImportTable("moderator", $dir) or return 0;
    ImportTable("moderator_sanitised", $dir) or return 0;
    ImportTable("moderation", $dir) or return 0;
    ImportTable("moderationnote", $dir) or return 0;
    ImportTable("votes", $dir) or return 0;

    ImportTable("wordlist", $dir) or return 0;
    ImportTable("artistwords", $dir) or return 0;
    ImportTable("albumwords", $dir) or return 0;
    ImportTable("trackwords", $dir) or return 0;

    `echo "select fill_moderator();" | psql musicbrainz`;

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

(!(system("tar -C /tmp -xjf $infile") >> 8))
   or die("Cannot untar/unzip the database dump.\n");
 
ImportAllTables($dir);

system("rm -rf $dir");
