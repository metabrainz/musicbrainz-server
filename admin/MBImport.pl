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

my ($fHelp, $fIgnoreErrors);
my $tmpdir = "/tmp";

GetOptions(
	"help|h"       		=> \$fHelp,
	"ignore-errors|i!"	=> \$fIgnoreErrors,
	"tmp-dir|t=s"		=> \$tmpdir,
);

sub usage
{
	print <<EOF;
Usage: MBImport.pl [options] FILE ...

        --help            show this help
    -i, --ignore-errors   if a table fails to import, continue anyway
    -t, --tmp-dir DIR     use DIR for temporary storage (default: /tmp)

FILE can be any of: a regular file in Postgres "copy" format (as produced
by ExportAllTables --nocompress); a gzip'd or bzip2'd tar file of Postgres
"copy" files (as produced by ExportAllTables); a directory containing
Postgres "copy" files; or a directory containing an "mbdump" directory
containing Postgres "copy" files.

If any "tar" files are named, they are firstly all
decompressed to temporary directories (under the directory named by
--tmp-dir).  These directories are removed on exit.

This script then proceeds through all of the MusicBrainz known table names,
and processes each as follows: firstly the file to load for that table
is identified, by considering each named argument in turn to see if it
provides a file for this table; if no file is available, processing of this
table ends.

Then, if the database table is not empty, a warning is generated, and
processing of this table ends.  Otherwise, the file is loaded into the table.
(Exception: the "moderator_santised" file, if present, is loaded into the
"moderator" table).

EOF
}

$fHelp and usage();
@ARGV or usage();

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

for my $arg (@ARGV)
{
	-e $arg or die "'$arg' not found";
	next if -d _;
	-f _ or die "'$arg' is neither a regular file nor a directory";

	next unless $arg =~ /\.tar\.(gz|bz2)$/;

	my $mode = ($1 eq "gz" ? "gzip" : "bzip2");

	my $dir = make_tmp_dir();
	print localtime() . " : tar -C $dir --$mode -xvf $arg\n";
	system "tar -C $dir --$mode -xvf $arg";
	exit $? if $? >> 8;
	$arg = $dir;
}

use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];
my $totalrows = 0;
my $tables = 0;
my $errors = 0;

print localtime() . " : starting import\n";

printf "%-30.30s %9s %4s %9s\n",
	"Table", "Rows", "est%", "rows/sec",
	;

ImportAllTables();

print localtime() . " : import finished\n";

my $dumptime = tv_interval($t0);
printf "Loaded %d tables (%d rows) in %d seconds\n",
	$tables, $totalrows, $dumptime;

exit($errors ? 1 : 0);



sub ImportTable
{
    my ($table, $file) = @_;

	print localtime() . " : load $table\n";

	my $rows = 0;

	my $t1 = [gettimeofday];
	my $interval;

	my $size = -s($file) || 1;

	my $p = sub {
		my ($pre, $post) = @_;
		no integer;
		printf $pre."%-30.30s %9d %3d%% %9d".$post,
			$table, $rows, int(100 * tell(LOAD) / $size),
			$rows / ($interval||1);
	};

	$| = 1;

	eval
	{
		open(LOAD, "<", $file) or die "open $file: $!";

		# If you're looking at this code because your import failed, maybe
		# with an error like this:
		#   ERROR:  copy: line 1, Missing data for column "automodsaccepted"
		# then the chances are it's because the data you're trying to load
		# doesn't match the structure of the database you're trying to load it
		# into.  Please make sure you've got the right copy of the server
		# code, as described in the INSTALL file.

		$sql->Begin;
		$sql->Do("COPY $table FROM stdin");
		my $dbh = $sql->{DBH};

		$p->("", "");

		while (<LOAD>)
		{
			$dbh->func($_, "putline") or die;

			++$rows;
			unless ($rows & 0xFFF)
			{
				$interval = tv_interval($t1);
				$p->("\r", "");
			}
		}

		$dbh->func("\\.\n", "putline") or die;
		$dbh->func("endcopy") or die;

		$interval = tv_interval($t1);
		$p->("\r", sprintf(" %.2f sec\n", $interval));

		close LOAD
			or die $!;

		$sql->Commit;

		die "Error loading data"
			if -f $file and empty($table);

		++$tables;
		$totalrows += $rows;

		1;
	};

	return 1 unless $@;
	warn "Error loading $file: $@";
	$sql->Rollback;

	++$errors, return 0 if $fIgnoreErrors;
	exit 1;
}

sub empty
{
	my $table = shift;

	my $oid = $sql->SelectSingleValue(
		"SELECT oid FROM $table LIMIT 1",
	);

	not defined $oid;
}

sub ImportAllTables
{
	for my $table (qw(
		album
		albumjoin
		albummeta
		albumwords
		artist
		artist_relation
		artistalias
		artistwords
		clientversion
		country
		currentstat
		discid
		historicalstat
		moderation_closed
		moderation_note_closed
		moderation_note_open
		moderation_open
		moderator
		moderator_sanitised
		moderator_preference
		moderator_subscribe_artist
		release
		stats
		toc
		track
		trackwords
		trm
		trmjoin
		vote_closed
		vote_open
		wordlist
	)) {
		my $file = find_file($table);
		$file or print("No data file found for '$table', skipping\n"), next;

		if ($table eq "moderator_sanitised")
		{
			if (not empty("moderator"))
			{
				warn "moderator table already contains data; skipping moderator_sanitised\n";
				next;
			}

			print localtime() . " : loading $file into moderator\n";
			ImportTable("moderator", $file) or next;

		} else {
			if (not empty($table))
			{
				warn "$table already contains data; skipping\n";
				next;
			}

			ImportTable($table, $file);
		}
	}

    return 1;
}

sub find_file
{
	my $table = shift;

	for my $arg (@ARGV)
	{
		use File::Basename;
		return $arg if -f $arg and basename($arg) eq $table;
		return "$arg/$table" if -f "$arg/$table";
		return "$arg/mbdump/$table" if -f "$arg/mbdump/$table";
	}

	undef;
}

{
	my @tmpdirs;

	END
	{
		use File::Path;
		rmtree(\@tmpdirs);
	}

	sub make_tmp_dir
	{
		for (my $i = 0; ; ++$i)
		{
			my $dir = "$tmpdir/mbimport-$$-$i";

			if (mkdir $dir)
			{
				push @tmpdirs, $dir;
				return $dir;
			}
			
			use Errno 'EEXIST';
			next if $! == EEXIST;

			die "Error creating temporary directory ($!)";
		}
	}
}

# vi: set ts=4 sw=4 :
