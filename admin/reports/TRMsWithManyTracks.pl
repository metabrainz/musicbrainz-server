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

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../cgi-bin";

use Text::Unaccent;
use Encode qw( decode );
use HTML::Mason::Tools qw( html_escape );

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;
use Album;
use Artist;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

use MusicBrainz::Server::PagedReport;
my $report = MusicBrainz::Server::PagedReport->Save(
	"$FindBin::Bin/../../htdocs/reports/TRMsWithManyTracks"
);

print STDERR localtime() . " : Finding most-collided TRMs\n";
$sql->AutoCommit;
$sql->Do(<<EOF);
SELECT	trm, COUNT(*) AS freq
INTO TEMPORARY TABLE tmp_trm_collisions
FROM	trmjoin
GROUP BY trm
HAVING COUNT(*) >= 10
EOF

print STDERR localtime() . " : Sorting and retrieving\n";
my $rows = $sql->SelectListOfHashes("
	SELECT	trm.trm, lookupcount, id, freq
	FROM	trm, tmp_trm_collisions t
	WHERE	t.trm = trm.id
	ORDER BY freq desc, lookupcount desc, trm.trm
");

print STDERR localtime() . " : Finding tracks, and saving\n";
for my $row (@$rows)
{
	$row->{'tracks'} = $sql->SelectListOfHashes("
		SELECT	t.id AS track_id, t.name AS track_name,
				a.id AS artist_id, a.name AS artist_name, a.sortname AS artist_sortname,
				t.length
		FROM	trmjoin j
			INNER JOIN track t ON t.id = j.track
			INNER JOIN artist a ON a.id = t.artist
		WHERE	j.trm = ?
		ORDER BY a.sortname, t.name
		",
		$row->{'id'},
	);

	$report->Print($row);
}

$report->End;

print STDERR localtime() . " : Done\n";
system("cat $FindBin::Bin/TRMsWithManyTracks.inc");

# eof TRMsWithManyTracks.pl
