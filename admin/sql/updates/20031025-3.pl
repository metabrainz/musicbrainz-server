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

# Abstract: set votes.superseded to 'false' where it's currently NULL

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});

# One-off scan, doesn't take too long
$| = 1;
print localtime() . " : Finding range of NULL superseded rows\n";
my $r = $sql->SelectSingleRowArray(
	"SELECT MIN(id), MAX(id) FROM votes WHERE superseded IS NULL",
);
my ($minid, $maxid) = @$r;
print(localtime() . " : Nothing to do!\n"), exit
	unless $maxid;
print localtime() . " : Min=$minid Max=$maxid\n";

my $bitesize = 1000;
my $upd = 0;

for (my $id = $minid; $id < $maxid; $id += $bitesize)
{
	my $id2 = $id + $bitesize - 1;
	print localtime() . " : Doing $id - $id2\n";

	$sql->Begin;
	$upd += $sql->Do(
		"UPDATE votes SET superseded = FALSE WHERE superseded IS NULL
			AND id BETWEEN ? AND ?",
		$id, $id2,
	);
	$sql->Commit;
}

print localtime() . " : Updated $upd rows\n";

print localtime() . " : Altering table...\n";
$sql->Begin;
$sql->Do("ALTER TABLE votes ALTER COLUMN superseded SET NOT NULL");
$sql->Commit;
print localtime() . " : Done\n";

# eof 20031025-3.pl
