#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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
use MusicBrainz;
use DBDefs;
use Sql;

my ($fHelp, $fIgnoreErrors);
my $tmpdir = "/tmp";
my $fProgress = -t STDOUT;

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
	exit;
}

$fHelp and usage();
@ARGV or usage();

my $mb = MusicBrainz->new;
$mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->{DBH});

for my $arg (@ARGV)
{
	-e $arg or die "'$arg' not found";
	next if -d _;
	-f _ or die "'$arg' is neither a regular file nor a directory";

	next unless $arg =~ /\.tar\.(gz|bz2)$/;

	my $mode = ($1 eq "gz" ? "gzip" : "bzip2");

	use File::Temp qw( tempdir );
	my $dir = tempdir("MBImport-XXXXXXXX", DIR => $tmpdir, CLEANUP => 1)
		or die $!;

	print localtime() . " : tar -C $dir --$mode -xvf $arg\n";
	system "tar -C $dir --$mode -xvf $arg";
	exit $? if $?;
	$arg = $dir;
}

print localtime() . " : Validating snapshot\n";

# We should have TIMESTAMP files, and they should all match.
my $timestamp = read_all_and_check("TIMESTAMP") || "";
# Old TIMESTAMP files used to have some blurb in front
$timestamp =~ s/^This snapshot was taken at //;
print localtime() . " : Snapshot timestamp is $timestamp\n";

# We should also have SCHEMA_SEQUENCE files, which match.  Plus they must
# match DBDefs::DB_SCHEMA_SEQUENCE.
my $SCHEMA_SEQUENCE = read_all_and_check("SCHEMA_SEQUENCE");
if (not defined $SCHEMA_SEQUENCE)
{
	print STDERR localtime() . " : No SCHEMA_SEQUENCE in import files - continuing anyway\n";
	print STDERR localtime() . " : Don't be surprised if this import fails\n";
	$| = 1, print(chr(7)), sleep 5
		if -t STDOUT;
} elsif ($SCHEMA_SEQUENCE != &DBDefs::DB_SCHEMA_SEQUENCE) {
	printf STDERR "%s : Schema sequence mismatch - codebase is %d, snapshot files are %d\n",
		scalar localtime,
		&DBDefs::DB_SCHEMA_SEQUENCE,
		$SCHEMA_SEQUENCE,
		;
	exit 1;
}

# We should have REPLICATION_SEQUENCE files, and they should all match too.
my $iReplicationSequence = read_all_and_check("REPLICATION_SEQUENCE");
$iReplicationSequence = "" if not defined $iReplicationSequence;
print localtime() . " : This snapshot corresponds to replication sequence #$iReplicationSequence\n"
	if $iReplicationSequence ne "";
print localtime() . " : This snapshot does not correspond to any replication sequence"
	. " - you will not be able to update this database using replication\n"
	if $iReplicationSequence eq "";

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


# Set replication_control.current_replication_sequence according to
# REPLICATION_SEQUENCE.
# This is necessary because if the server did an export --with-full-export
# --without-replication, then replication_control.current_replication_sequence
# would be invalid - we should trust the REPLICATION_SEQUENCE file instead.
# The current_schema_sequence /is/ valid, however.
$sql->AutoCommit;
$sql->Do(
	"UPDATE replication_control
	SET current_replication_sequence = ?,
	last_replication_date = ?",
	($iReplicationSequence eq "" ? undef : $iReplicationSequence),
	($iReplicationSequence eq "" ? undef : $timestamp),
);

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

		$p->("", "") if $fProgress;

		while (<LOAD>)
		{
			$dbh->func($_, "putline") or die;

			++$rows;
			unless ($rows & 0xFFF)
			{
				$interval = tv_interval($t1);
				$p->("\r", "") if $fProgress;
			}
		}

		$dbh->func("\\.\n", "putline") or die;
		$dbh->func("endcopy") or die;

		$interval = tv_interval($t1);
		$p->(($fProgress ? "\r" : ""), sprintf(" %.2f sec\n", $interval));

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
		album_amazon_asin
		album_amazon_asin_sanitised
		album_cdtoc
		albumjoin
		albummeta
		albumwords
		annotation
		artist
		artist_relation
		artistalias
		artistwords
		automod_election
		automod_election_vote
		cdtoc
		clientversion
		country
		currentstat
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
		replication_control
		stats
		track
		trackwords
		trm
		trmjoin
		trmjoin_stat
		trm_stat
		vote_closed
		vote_open
		wordlist
	)) {
		my $file = (find_file($table))[0];
		$file or print("No data file found for '$table', skipping\n"), next;

		if ($table =~ /^(.*)_sanitised$/)
		{
			my $basetable = $1;

			if (not empty($basetable))
			{
				warn "$basetable table already contains data; skipping $table\n";
				next;
			}

			print localtime() . " : loading $file into $basetable\n";
			ImportTable($basetable, $file) or next;

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
	my @r;

	for my $arg (@ARGV)
	{
		use File::Basename;
		push(@r, $arg), next if -f $arg and basename($arg) eq $table;
		push(@r, "$arg/$table"), next if -f "$arg/$table";
		push(@r, "$arg/mbdump/$table"), next if -f "$arg/mbdump/$table";
	}

	@r;
}

sub read_all_and_check
{
	my $file = shift;

	my @files = find_file($file);
	my %contents;
	my %uniq;

	for my $foundfile (@files)
	{
		open(my $fh, "<$foundfile") or die $!;
		my $contents = do { local $/; <$fh> };
		close $fh;
		$contents{$foundfile} = $contents;
		++$uniq{$contents};
	}

	chomp(my @v = sort keys %uniq);

	if (@v > 1)
	{
		print STDERR localtime(). " : Aborting import - your $file files don't match!\n";
		print STDERR localtime(). " : The different $file files follow:\n";
		print STDERR " $_\n" for @v;
		exit 1;
	}

	$v[0];
}

# vi: set ts=4 sw=4 :
