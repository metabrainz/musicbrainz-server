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

# Abstract: remove duplicate (trm, track) pairs from trmjoin

use FindBin;
use lib "$FindBin::Bin/../../../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

$sql->Begin;

#$sql->Do("LOCK TABLE trmjoin IN EXCLUSIVE MODE");

$| = 1;
print localtime() . " : Finding dupes\n";
my $dupes = $sql->SelectListOfHashes(
	"SELECT trm, track, join(id::VARCHAR) AS ids, COUNT(*) AS freq
	FROM trmjoin GROUP BY trm, track HAVING COUNT(*) > 1",
);
print localtime() . " : Done.  Deleting...\n";

my $del = 0;

for my $r (@$dupes)
{
	my @ids = split ' ', $r->{ids};
	shift @ids;
	print("."), ++$del, $sql->Do("DELETE FROM trmjoin WHERE id = ?", $_)
		for @ids;
}

print "\n" if $del;
print localtime() . " : Deleted $del rows\n";
$sql->Commit;

# eof RemoveDuplicateTRMJoins.pl
