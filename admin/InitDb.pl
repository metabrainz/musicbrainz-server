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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use MusicBrainz;
use DBDefs;

my $dbname = DBDefs::DB_NAME;
my $dbuser = DBDefs::DB_USER;
my $psql = "psql";

use Getopt::Long;
use strict;

chdir $FindBin::Bin or die "cd $FindBin::Bin: $!";
-d "sql" or die "Couldn't find SQL script directory";

sub Create 
{
	system "createdb -U postgres -E UNICODE $dbname";
	system "createlang -U postgres -d $dbname plpgsql";

	return if $dbuser eq "postgres";

	system "createuser -U postgres $dbuser";

	# This is only here because you can't
	# "CREATE DATABASE ... WITH OWNER = ..."
	# under Postgres 7.2
	open(PSQL, "| $psql -U postgres $dbname");
	print PSQL 
		"UPDATE pg_database SET datdba = ("
		. "SELECT usesysid FROM pg_shadow WHERE usename = '$dbuser'"
		. ") WHERE datname = '$dbname';\n";
	close PSQL;
}

sub Import
{
    print "Creating tables ...\n";
    system("$psql -U $dbuser -f sql/CreateTables.sql $dbname");
    die "\nFailed to create tables.\n" if ($? >> 8);

    print "Creating functions ...\n";
    system("$psql -U $dbuser -f sql/CreateFunctions.sql $dbname");
    die "\nFailed to create functions.\n" if ($? >> 8);

    {
	local $" = " ";
        system($^X, "$FindBin::Bin/MBImport.pl", @_);
        die "\nFailed to import dataset.\n" if ($? >> 8);
    }

    system "echo 'select fill_moderator();' | $psql -U $dbuser $dbname";

    print "Setting initial sequence values ...\n";
    system($^X, "$FindBin::Bin/SetSequences.pl");
    die "\nFailed to set sequences.\n" if ($? >> 8);

    print "Creating indexes ...\n";
    system("$psql -U $dbuser -f sql/CreateIndexes.sql $dbname");
    die "\nFailed to create indexes.\n" if ($? >> 8);

    print "Creating views ...\n";
    system("$psql -U $dbuser -f sql/CreateViews.sql $dbname");
    die "\nFailed to create views.\n" if ($? >> 8);

    print "Creating triggers ...\n";
    system("$psql -U $dbuser -f sql/CreateTriggers.sql $dbname");
    die "\nFailed to create triggers.\n" if ($? >> 8);

    print "Optimizing database ...\n";
    system("echo \"vacuum analyze\" | $psql -U $dbuser $dbname");

    print "\nInitialized and imported data into the database.\n\n";
}

sub Clean
{
    my $ret;
    
    system("$psql -U $dbuser -f sql/CreateTables.sql $dbname");
    die "\nFailed to create tables.\n" if ($? >> 8);

    system("$psql -U $dbuser -f sql/CreateIndexes.sql $dbname");
    die "\nFailed to create indexes.\n" if ($? >> 8);

    system("$psql -U $dbuser -f sql/CreateViews.sql $dbname");
    die "\nFailed to create views.\n" if ($? >> 8);

    system("$psql -U $dbuser -f sql/CreateFunctions.sql $dbname");
    die "\nFailed to create functions.\n" if ($? >> 8);

    system("$psql -U $dbuser -f sql/CreateTriggers.sql $dbname");
    die "\nFailed to create triggers.\n" if ($? >> 8);

    system("$psql -U $dbuser -f sql/InsertDefaultRows.sql $dbname");
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
       if not -x $psql and (`which psql` eq '');
}

sub Usage
{
   die <<EOF;
Usage: InitDb.pl [options] [file] ...

Options are:
     --createdb   Create the database, PL/PGSQL language and user
  -i --import     Prepare the database and then import the data from 
                  the given files
  -c --clean      Prepare a ready to use empty database
  -t --build-text Build (or rebuild) text indexes for text searching
  -o --build-opt  Build (or rebuild) optimization tables (e.g. albummeta table)
  -h --help       This help

After the import option, you may specify one or more MusicBrainz data dump
files for importing into the database. Once this script runs to completion
without errors, the database will be ready to use. Or it *should* at least.

EOF
}

my $fCreateDB;
my ($fImport, $fClean, $fBuildText, $fBuildOpt, $fHelp, $fBuildAll) = (0,0,0,0,0,0);

GetOptions(
	"psql=s"	=>\$psql,
	"createdb"	=>\$fCreateDB,
	"import|i"     => \$fImport,
	"clean|c"      => \$fClean,
	"build-text|t" => \$fBuildText,
	"build-opt|o"  => \$fBuildOpt,
	"build-all|a"  => \$fBuildAll,
	"help|h"       => \$fHelp,
);

Usage() if ($fHelp);
Usage() if (($fCreateDB || $fImport) + $fClean + $fBuildText + $fBuildOpt + $fBuildAll != 1);

SanityCheck();

Create() if $fCreateDB;
Import(@ARGV) if ($fImport);
Clean() if ($fClean);
BuildText() if ($fBuildText || $fBuildAll);
BuildOpt() if ($fBuildOpt || $fBuildAll);
