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
my $postgres = "postgres";

use Getopt::Long;
use strict;

my $fEcho = 0;

my $sqldir = "$FindBin::Bin/sql";
-d $sqldir or die "Couldn't find SQL script directory";

sub RunSQLScript
{
	my ($file, $startmessage) = @_;
	$startmessage ||= "Running sql/$file";
	print localtime() . " : $startmessage ($file)\n";

	my $echo = ($fEcho ? "-e" : "");

	open(PIPE, "$psql $echo $opts -U $dbuser -f $sqldir/$file $dbname 2>&1 |")
		or die "exec '$psql': $!";
	while (<PIPE>)
	{
		print localtime() . " : " . $_;
	}
	close PIPE;

	die "Error during sql/$file" if ($? >> 8);
}

sub Create 
{
	unless ($dbuser eq "$postgres")
	{
		my $use = `
			echo "select 'EXISTS' from pg_shadow where usename = '$dbuser'" \\
			| $psql $opts -U $postgres -t template1 \\
			| grep EXISTS
		`;
		unless ($? == 0)
		{
			print localtime() . " : Creating user '$dbuser'\n";
			system "createuser $opts -U $postgres --no-adduser --no-createdb $dbuser";
			die "\nFailed to create user\n" if ($? >> 8);
		}
	}

	print localtime() . " : Creating database '$dbname'\n";
	system "createdb $opts -U $postgres -E UNICODE --owner=$dbuser $dbname";
	die "\nFailed to create database\n" if ($? >> 8);
	system "createlang $opts -U $postgres -d $dbname plpgsql";
	die "\nFailed to create language\n" if ($? >> 8);
}

sub Import
{
	RunSQLScript("CreateTables.sql", "Creating tables ...");

    {
		local $" = " ";
        system($^X, "$FindBin::Bin/MBImport.pl", "--ignore-errors", @_);
        die "\nFailed to import dataset.\n" if ($? >> 8);
    }

	RunSQLScript("CreatePrimaryKeys.sql", "Creating primary keys ...");
	RunSQLScript("CreateIndexes.sql", "Creating indexes ...");
	RunSQLScript("CreateFKConstraints.sql", "Adding foreign key constraints ...");

    print localtime() . " : Setting initial sequence values ...\n";
    system($^X, "$FindBin::Bin/SetSequences.pl");
    die "\nFailed to set sequences.\n" if ($? >> 8);

	RunSQLScript("CreateViews.sql", "Creating views ...");
	RunSQLScript("CreateFunctions.sql", "Creating functions ...");
	RunSQLScript("CreateTriggers.sql", "Creating triggers ...");

    print localtime() . " : Optimizing database ...\n";
    system("echo \"vacuum analyze\" | $psql $opts -U $dbuser $dbname");
    die "\nFailed to optimize database\n" if ($? >> 8);

    print localtime() . " : Initialized and imported data into the database.\n";
}

sub Clean
{
    my $ret;
    
	RunSQLScript("CreateTables.sql", "Creating tables ...");

	RunSQLScript("CreatePrimaryKeys.sql", "Creating primary keys ...");
	RunSQLScript("CreateFKConstraints.sql", "Adding foreign key constraints ...");
	RunSQLScript("CreateIndexes.sql", "Creating indexes ...");

	RunSQLScript("CreateViews.sql", "Creating views ...");
	RunSQLScript("CreateFunctions.sql", "Creating functions ...");
	RunSQLScript("CreateTriggers.sql", "Creating triggers ...");

	RunSQLScript("InsertDefaultRows.sql", "Adding default rows ...");

    print localtime() . " : Created a clean and empty database.\n";
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
     --psql=PATH      Specify the path to the "psql" utility
     --postgres=NAME  Specify the name of the system user
     --createdb       Create the database, PL/PGSQL language and user
  -i --import         Prepare the database and then import the data from 
                      the given files
  -c --clean          Prepare a ready to use empty database
     --[no]echo       When running the various SQL scripts, echo the commands
                      as they are run
  -h --help           This help

After the import option, you may specify one or more MusicBrainz data dump
files for importing into the database. Once this script runs to completion
without errors, the database will be ready to use. Or it *should* at least.

Since all non-option arguments are passed directly to MBImport.pl, you can
pass additional options to that script by using "--".  For example:

  InitDb.pl --createdb --echo --import -- --tmp-dir=/var/tmp *.tar.bz2

EOF
}

my $fCreateDB;
my ($fImport, $fClean) = (0, 0);

GetOptions(
	"psql=s"	=> \$psql,
	"postgres=s"=> \$postgres,
	"createdb"	=> \$fCreateDB,
	"import|i"	=> \$fImport,
	"clean|c"	=> \$fClean,
	"echo!"		=> \$fEcho,
	"help|h"	=> \&Usage,
) or exit 2;

Usage() if $fImport and $fClean;

SanityCheck();

print localtime() . " : InitDb.pl starting\n";
my $started = 1;

Create() if $fCreateDB;
Import(@ARGV) if $fImport;
Clean() if $fClean;

END {
	print localtime() . " : InitDb.pl "
		. ($? == 0 ? "succeeded" : "failed")
		. "\n"
		if $started;
}

# vi: set ts=4 sw=4 :
