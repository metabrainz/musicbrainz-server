#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2002 Robert Kaye
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

use Getopt::Long;
use strict;

sub Import
{
    my $file;

    system("psql -f sql/CreateTables.sql musicbrainz");
    die "\nFailed to create tables.\n" if ($? >> 8);

    system("psql -f sql/CreateFunctions.sql musicbrainz");
    die "\nFailed to create functions.\n" if ($? >> 8);

    foreach $file (@_)
    {
        system("./MBImport.pl $file");
        die "\nFailed to import dataset in $file.\n" if ($? >> 8);
    }

    system("./SetSequences.pl");
    die "\nFailed to set sequences.\n" if ($? >> 8);

    system("psql -f sql/CreateIndexes.sql musicbrainz");
    die "\nFailed to create indexes.\n" if ($? >> 8);

    system("psql -f sql/CreateViews.sql musicbrainz");
    die "\nFailed to create views.\n" if ($? >> 8);

    system("psql -f sql/CreateTriggers.sql musicbrainz");
    die "\nFailed to create triggers.\n" if ($? >> 8);

    system("echo \"vacuum analyze\" | psql musicbrainz");

    print "\nInitialized and imported data into the database.\n\n";
}

sub Clean
{
    my $ret;
    
    system("psql -f sql/CreateTables.sql musicbrainz");
    die "\nFailed to create tables.\n" if ($? >> 8);

    system("psql -f sql/CreateIndexes.sql musicbrainz");
    die "\nFailed to create indexes.\n" if ($? >> 8);

    system("psql -f sql/CreateViews.sql musicbrainz");
    die "\nFailed to create views.\n" if ($? >> 8);

    system("psql -f sql/CreateFunctions.sql musicbrainz");
    die "\nFailed to create functions.\n" if ($? >> 8);

    system("psql -f sql/CreateTriggers.sql musicbrainz");
    die "\nFailed to create triggers.\n" if ($? >> 8);

    system("psql -f sql/InsertDefaultRows.sql musicbrainz");
    die "\nFailed to insert default rows tables.\n" if ($? >> 8);

    print "\nCreated a clean and empty database.\n\n";
}

sub BuildText
{
    print "Build Text\n";
}

sub BuildOpt
{
    print "Build Opt\n";
}

sub SanityCheck
{
    die "The postgres psql application must be on your path for this script to work.\n"
       if (`which psql` eq '');
}

sub Usage
{
   die <<EOF;
Usage: InitDb.pl [options] <file> [file] ...

Options are:
  -i --import     Prepare the database and then import the data from 
                  the given files
  -c --clean      Prepare a ready to use empty database
  -t --build-text Build (or rebuild) text indexes for text searching
  -o --build-opt  Build (or rebuild) optimization tables (e.g. albummeta table)
  -h --help       This help

After the import option, you may specify one or more MusicBrainz data dump
files for importing into the database. Once this script runs to completion
without errors, the database will be ready to use. Or it *should* at least.

Before you use this script, you must create a database with the name 
'musicbrainz'. To do this, execute the following commands from an account
that has postgres privledges to create databases:

   > createdb -E UNICODE musicbrainz
   > createlang plpgsql musicbrainz
EOF
}

my ($fImport, $fClean, $fBuildText, $fBuildOpt, $fHelp, $fBuildAll) = (0,0,0,0,0,0);

GetOptions(
	"import|i"     => \$fImport,
	"clean|c"      => \$fClean,
	"build-text|t" => \$fBuildText,
	"build-opt|o"  => \$fBuildOpt,
	"build-all|a"  => \$fBuildAll,
	"help|h"       => \$fHelp,
);

Usage() if ($fHelp);

Usage() if ($fImport + $fClean + $fBuildText + $fBuildOpt + $fBuildAll != 1);

SanityCheck();

Import(@ARGV) if ($fImport);
Clean() if ($fClean);
BuildText() if ($fBuildText || $fBuildAll);
BuildOpt() if ($fBuildOpt || $fBuildAll);
