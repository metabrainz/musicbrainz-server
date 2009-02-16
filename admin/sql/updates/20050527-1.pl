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

# Abstract: Fix rows and then install FKs between artist/album/track and *words

use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;

$| = 1 if -t STDOUT;
$SIG{INT} = sub { die "Interrupt\n" };

my $mb = MusicBrainz->new; $mb->Login(db => "READWRITE");
my $sql = Sql->new($mb->{dbh});

process("artist");
process("album");
process("track");

sub process
{
	my $table = shift;

	# Is the problem already fixed?
	my $constraint = "${table}words_fk_${table}id";

	if (do {
		$sql->SelectSingleValue(
			"SELECT 1 FROM pg_constraint WHERE conname = ?",
			$constraint,
		);
	}) {
		print localtime() . " : $constraint already exists - skipping\n";
		return;
	}

	# Step one: stop the problem getting any worse
	my $func = "after_del_${table}_delwords_func";
	my $trigger = "after_del_${table}_delwords_trig";

	print localtime() . " : Adding temporary function to $table\n";
	$sql->Begin;
	$sql->Do(<<EOF);
CREATE OR REPLACE FUNCTION $func () RETURNS trigger AS '
BEGIN
    DELETE FROM ${table}words WHERE ${table}id = OLD.id;
    RETURN NULL;
END;
' LANGUAGE 'plpgsql'
EOF
	print localtime() . " : Adding temporary trigger to $table\n";
	$sql->Do(<<EOF)
CREATE TRIGGER $trigger AFTER DELETE ON $table
    FOR EACH ROW EXECUTE PROCEDURE $func();
EOF
		unless $sql->SelectSingleValue(
			"SELECT 1 FROM pg_trigger WHERE tgname = ?", $trigger,
		);
	$sql->Commit;

	# Step two: nibble away at the existing rows, a few at a time,
	# deleting the bad rows.
	print localtime() . " : Finding maximum $table ID\n";
	my $maxid = $sql->SelectSingleValue(
		"SELECT id FROM $table ORDER BY 1 DESC LIMIT 1", # MAX(id)
	);
	print localtime() . " : $table maxid=$maxid\n";

	my $minid = 1;
	my $chunksize = 10000;
	while ($minid <= $maxid)
	{
		nibble($table, $minid, $minid+$chunksize-1);
		$minid += $chunksize;
	}

	# Step three: install foreign keys to fix the problem for good
	print localtime() . " : Adding permanent foreign key to ${table}words\n";
	$sql->Begin;
	$sql->Do(
		"ALTER TABLE ${table}words
		ADD CONSTRAINT $constraint
		FOREIGN KEY (${table}id)
		REFERENCES $table (id)
		ON DELETE CASCADE",
	) unless $sql->SelectSingleValue(
		"SELECT 1 FROM pg_constraint
		WHERE conname = ?", $constraint,
	);
	$sql->Commit;

	# Step four: remove the temporary fix we added earlier
	print localtime() . " : Removing temporary function/trigger from $table\n";
	$sql->Begin;
	$sql->Do("DROP TRIGGER $trigger ON $table");
	$sql->Do("DROP FUNCTION $func()");
	$sql->Commit;

	print localtime() . " : ${table}words fix complete\n";
}

sub nibble
{
	my ($table, $minid, $maxid) = @_;
	print localtime() . " : ${table} $minid - $maxid ...";
	$sql->Begin;
	my $n = $sql->Do(
		"DELETE FROM ${table}words
		WHERE ${table}id BETWEEN $minid AND $maxid
		AND ${table}id NOT IN (
			SELECT id FROM $table
			WHERE id BETWEEN $minid AND $maxid
		)",
	);
	print " $n deleted\n";
	$sql->Commit;
}

# eof 20050527-1.pl
