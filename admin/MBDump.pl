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

sub DumpTable
{
    my ($name, $dir) = @_;
    my ($cmd, $dsn);

    print "Dumping table $name..\n";

    $dsn = DBDefs->DSN;
    $dsn =~ s/^dbi://;

    $cmd = "sql2xml.pl -sn localhost -driver ";
    $cmd .= $dsn;
    $cmd .= " -uid ";
    $cmd .= DBDefs->DB_USER;
    if (length(DBDefs->DB_PASSWD) > 0)
    {
        $cmd .= " -pwd ";
        $cmd .= DBDefs->DB_PASSWD;
    }
    $cmd .= " -table $name -output $dir/$name.xml"; 
    system($cmd);

    return 1;
}

sub DumpAllTables
{
    my ($dir) = @_;

    DumpTable("Artist", $dir) or return 0;
    DumpTable("Album", $dir) or return 0;
    DumpTable("Track", $dir) or return 0;
    DumpTable("GUID", $dir) or return 0;
    DumpTable("AlbumJoin", $dir) or return 0;
    DumpTable("GUIDJoin", $dir) or return 0;
    DumpTable("Genre", $dir) or return 0;
    DumpTable("Pending", $dir) or return 0;
    DumpTable("Diskid", $dir) or return 0;
    DumpTable("TOC", $dir) or return 0;
    DumpTable("GlobalId", $dir) or return 0; 
    if (DBDefs->USE_LYRICS)
    {
       DumpTable("Lyrics", $dir) or return 0;
       DumpTable("SyncText", $dir) or return 0;
       DumpTable(SyncEvent, $dir) or return 0;
    }
    else
    {
       print "Skipping dumping of lyrics tables.\n";
    }

    print "\nDumped tables successfully.\n";

    return 1;
}

my ($outfile, $dir, @tinfo, $timestring);

@tinfo = localtime;
$timestring = "mbdump-" . (1900 + $tinfo[5]) . "-".($tinfo[4]+1)."-$tinfo[3]";

$outfile = shift;
if (defined $outfile && ($outfile eq "-h" || $outfile eq "--help"))
{
    print "Usage: Dump.pl <dumpfile>\n\n";
    print "Make sure to have plenty of diskspace on /tmp!\n";
    exit(0);
}
$outfile = "$timestring.tar.gz" if (!defined $outfile);

@tinfo = localtime;
$dir = "/tmp/$timestring";

system("rm -rf $dir");

mkdir($dir, 0700)
  or die("Cannot create tmp directory $dir.\n");

if (DumpAllTables($dir))
{
    (!(system("tar -C /tmp -czf $outfile $timestring") >> 8))
       or die("Cannot write outputfile.\n");
}

system("rm -rf $dir");
