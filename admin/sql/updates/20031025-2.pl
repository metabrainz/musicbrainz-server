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

# Abstract: set votes.superseded to true where appropriate

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});

$sql->Begin;

$sql->Do("LOCK TABLE votes IN EXCLUSIVE MODE");

$| = 1;
print localtime() . " : Finding duplicate votes\n";
my $dupes = $sql->SelectListOfLists(
	"SELECT uid, rowid, COUNT(*) AS freq
	FROM votes GROUP BY uid, rowid HAVING COUNT(*) > 1",
);

print localtime() . " : Marking votes as superseded\n";

my $upd = 0;

for (@$dupes)
{
	my ($uid, $modid, $freq) = @$_;

	my $latest = $sql->SelectSingleValue(
		"SELECT MAX(id) FROM votes WHERE uid = ? AND rowid = ?",
		$uid, $modid,
	);
	
	$upd += $freq-1;
	print $upd, "\r" if -t;
	$sql->Do(
		"UPDATE votes SET superseded = TRUE
		WHERE uid = ? AND rowid = ?
		AND id != ?",
		$uid, $modid, $latest,
	) or die;
}

print localtime() . " : Updated $upd rows\n";

$sql->Commit;

# eof 20031025-2.pl
