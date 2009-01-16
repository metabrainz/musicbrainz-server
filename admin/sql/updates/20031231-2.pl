#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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

# Abstract: Splitting the moderation data into "open" and "closed" tables.
# Abstract: Part 2: scan the old tables and load the data into the new tables

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;
use Time::HiRes qw( gettimeofday tv_interval );

$| = 1 if -t STDOUT;

my $mb1 = MusicBrainz->new; $mb1->Login;
my $mb2 = MusicBrainz->new; $mb2->Login;
my $mb3 = MusicBrainz->new; $mb3->Login;
my $dbh_read = $mb1->{dbh};
my $dbh_true = $mb2->{dbh};
my $dbh_false = $mb3->{dbh};
my $sql_read = Sql->new($dbh_read);
my $sql_true = Sql->new($dbh_true);
my $sql_false = Sql->new($dbh_false);

# Transfer all moderation rows into moderation_open or moderation_closed,
# depending on 'status'.  Keep a list of the open moderation IDs.
my %open_mod_ids;
transfer_split(
	"moderation",
	"moderation_open",
	"moderation_closed",
	sub {
		my $is_open = ($_[6] == 1 or $_[6] == 8);
		$open_mod_ids{ $_[0] } = 1 if $is_open;
		$is_open;
	},
);

# Transfer all moderationnote rows into _open or _closed, depending on
# %open_mod_ids.
transfer_split(
	"moderationnote",
	"moderation_note_open",
	"moderation_note_closed",
	sub { $open_mod_ids{ $_[1] } },
);
# Ditto for votes
transfer_split(
	"votes",
	"vote_open",
	"vote_closed",
	sub { $open_mod_ids{ $_[2] } },
);

sub transfer_split
{
	my ($from_table, $true_table, $false_table, $tester) = @_;

	# Read all rows from $from_table.
	# For each row, split into columns and call $tester.
	# Insert row into $true_table or $false_table depending on the return
	# value from $tester.

	my $estrows = $sql_read->SelectSingleValue(
		"SELECT reltuples FROM pg_class WHERE relname = ? LIMIT 1",
		$from_table,
	) || 1;

	$sql_read->AutoCommit;
	$sql_true->Begin;
	$sql_false->Begin;

	$sql_read->Do("COPY $from_table TO stdout");
	$sql_true->Do("COPY $true_table FROM stdin");
	$sql_false->Do("COPY $false_table FROM stdin");

	my $buffer;
	my $rows = 0;
	my $truerows = 0;

	my $t1 = [gettimeofday];
	my $interval;

	my $p = sub {
		my ($pre, $post) = @_;
		no integer;
		printf $pre."%-30.30s %9d %9d %3d%% %9d".$post,
			$from_table, $rows, $truerows, int(100 * $rows / $estrows),
			$rows / ($interval||1);
	};

	$p->("", "") if -t STDOUT;
	# This has to be at least as large as the longest line given
	# by "copy table to stdout".
	# Currently the largest value I can see is a row in the moderation
	# table which is approx 215,000 bytes.
	my $max = 250_000; my $maxline = __LINE__;

	while ($dbh_read->func($buffer, $max, "getline"))
	{
		die "\nProbable data truncation!  See $0 line $maxline"
			if length($buffer) >= $max-1;

		my $true = &$tester(split /\t/, $buffer, -1);
		($true ? $dbh_true : $dbh_false)->func($buffer."\n", "putline") or die;

		++$rows;
		++$truerows if $true;
		unless ($rows & 0xFFF)
		{
			$interval = tv_interval($t1);
			$p->("\r", "") if -t STDOUT;
		}
	}

	$dbh_read->func("endcopy") or die;

	$dbh_true->func("\\.\n", "putline") or die;
	$dbh_true->func("endcopy") or die;
	$dbh_false->func("\\.\n", "putline") or die;
	$dbh_false->func("endcopy") or die;

	$interval = tv_interval($t1);
	$p->("\r", sprintf(" %.2f sec\n", $interval));

	$sql_true->Commit;
	$sql_false->Commit;
}

# eof 20031231-2.pl
