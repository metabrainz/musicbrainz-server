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

my $dbname = &DBDefs::DB_NAME;
my $dbuser = &DBDefs::DB_USER;
my $opts = &DBDefs::DB_PGOPTS;
my $psql = "psql";

use Getopt::Long;
use strict;

my $sqldir = "$FindBin::Bin/sql";
-d $sqldir or die "Couldn't find SQL script directory";

sub RunSQLScript
{
	my ($file, $startmessage) = @_;
	$startmessage ||= "Running sql/$file";
	print localtime() . " : $startmessage\n";
	system("$psql $opts -U $dbuser -f $sqldir/$file $dbname");
	die "Error during sql/$file" if ($? >> 8);
}

sub Create 
{
	system "createuser $opts -U postgres $dbuser"
		unless $dbuser eq "postgres";

	system "createdb $opts -U postgres -E UNICODE --owner=$dbuser $dbname";
	system "createlang $opts -U postgres -d $dbname plpgsql";
}

sub Import
{
	RunSQLScript("CreateTables.sql", "Creating tables ...");
	RunSQLScript("CreateFunctions.sql", "Creating functions ...");

    {
		local $" = " ";
        system($^X, "$FindBin::Bin/MBImport.pl", "--ignore-errors", @_);
        die "\nFailed to import dataset.\n" if ($? >> 8);
    }

    print localtime() . " : Setting initial sequence values ...\n";
    system($^X, "$FindBin::Bin/SetSequences.pl");
    die "\nFailed to set sequences.\n" if ($? >> 8);

	RunSQLScript("CreateFKConstraints.sql", "Adding foreign key constraints ...");
	RunSQLScript("CreateIndexes.sql", "Creating indexes ...");
	RunSQLScript("CreateViews.sql", "Creating views ...");
	RunSQLScript("CreateTriggers.sql", "Creating triggers ...");

    print localtime() . " : Optimizing database ...\n";
    system("echo \"vacuum analyze\" | $psql $opts -U $dbuser $dbname");

    print localtime() . " : \nInitialized and imported data into the database.\n\n";
}

sub Clean
{
    my $ret;
    
	RunSQLScript("CreateTables.sql", "Creating tables ...");
	RunSQLScript("CreateFunctions.sql", "Creating functions ...");

	RunSQLScript("CreateFKConstraints.sql", "Adding foreign key constraints ...");
	RunSQLScript("CreateIndexes.sql", "Creating indexes ...");
	RunSQLScript("CreateViews.sql", "Creating views ...");
	RunSQLScript("CreateTriggers.sql", "Creating triggers ...");

	RunSQLScript("InsertDefaultRows.sql", "Adding default rows ...");

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

# vi: set ts=4 sw=4 :
