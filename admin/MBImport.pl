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

use strict;

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use Getopt::Long;
use DBI;
use MusicBrainz;
use DBDefs;
use Sql;

my $dbname = DBDefs::DB_NAME;
my $dbuser = DBDefs::DB_USER;
my $sql;

sub ImportTable
{
    my ($name, $dir) = @_;
    my ($cmd, $dsn);

    my $rows = eval { $sql->SelectSingleValue("SELECT 1 FROM $name LIMIT 1") };

    if ($rows)
    {
	    print STDERR "Warning: table '$name' already contains data, skipping import\n";
	    return;
    }

    if (-e "$dir/$name")
    {
        $cmd = "pg_restore -U $dbuser -S postgres -O -a -t $name -d $dbname $dir/$name"; 

		printf "%s: %s\n", scalar(localtime), $cmd;
        my $ret = system($cmd) >> 8;

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

    ImportTable("artist", $dir);
    ImportTable("artistalias", $dir);
    ImportTable("album", $dir);
    ImportTable("track", $dir);
    ImportTable("albumjoin", $dir);
    ImportTable("clientversion", $dir);
    ImportTable("trm", $dir);
    ImportTable("trmjoin", $dir);
    ImportTable("discid", $dir);
    ImportTable("toc", $dir);
    ImportTable("albummeta", $dir);

    ImportTable("moderator", $dir);
    ImportTable("moderator_sanitised", $dir);
    ImportTable("moderation", $dir);
    ImportTable("moderationnote", $dir);
    ImportTable("votes", $dir);

    ImportTable("wordlist", $dir);
    ImportTable("artistwords", $dir);
    ImportTable("albumwords", $dir);
    ImportTable("trackwords", $dir);
    ImportTable("stats", $dir);
    ImportTable("currentstat", $dir);
    ImportTable("historicalstat", $dir);

    ImportTable("artist_relation", $dir);

    return 1;
}

my ($fHelp, $tmpdir);

GetOptions(
	"help|h"       => \$fHelp,
);

if (not @ARGV or $fHelp)
{
    print "Usage: MBImport.pl dumpfile [dumpfile ...]\n\n";
    print "or:    MBImport.pl dir [dir ...]\n\n";
    print "Make sure to have plenty of diskspace on /tmp!\n";
    exit(0);
}

my $mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

$tmpdir = "/tmp/mbdump";

for my $arg (@ARGV)
{
	if (-d $arg)
	{
		ImportAllTables($arg);
	} else {
		print "Unpacking $arg ...\n";
		(!(system("tar -C /tmp -vxjf $arg") >> 8))
			or die("Cannot untar/unzip the database dump.\n");
		ImportAllTables($tmpdir);
	}
}
 
printf "%s: import finished\n", scalar localtime;

system("rm -rf $tmpdir") if -d $tmpdir;

# vi: set ts=4 sw=4 :
