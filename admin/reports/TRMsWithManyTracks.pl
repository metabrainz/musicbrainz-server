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

use 5.8.0;
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

print <<EOF;
<& /comp/sidebar, title => 'TRMs with many tracks' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    This report lists TRMs which resolve to at least 5 tracks.
</p>

<table>
	<caption>TRMs with at least 5 tracks</caption>
	<thead>
		<tr>
			<th>TRM</th>
			<th>Track Count</th>
			<th>Track</th>
			<th>Artist</th>
		</tr>
	</thead>
	<tbody>
EOF

my $rows = $sql->SelectListOfLists("
		SELECT trm, COUNT(*) AS trackcount
		FROM trmjoin
		GROUP BY trm
		HAVING COUNT(*) >= 5
		ORDER BY trackcount DESC
");

for my $row (@$rows)
{
	my $trm = $sql->SelectSingleValue(
		"SELECT trm FROM trm WHERE id = ?",
		$row->[0],
	);

	my $tracks = $sql->SelectListOfLists("
		SELECT t.id, t.name, a.id, a.name, a.sortname
		FROM trmjoin j
		INNER JOIN track t ON t.id = j.track
		INNER JOIN artist a ON a.id = t.artist
		WHERE j.trm = ?
		ORDER BY a.sortname, t.name
		",
		$row->[0],
	);

	my $numtracks = scalar @$tracks;

	my $first = 1;

	for my $track (@$tracks)
	{
		my $t = html_escape($track->[1]);
		my $a = html_escape($track->[3]);

		print <<EOF;
		<tr>
EOF

		print <<EOF if $first;
			<td><a href="/showtrm.html?trm=$trm">$trm</a></td>
			<td style="text-align: center">$numtracks</td>
EOF

		print "<td></td><td></td>\n" unless $first;

		print <<EOF;
			<td><a href="/showtrack.html?trackid=$track->[0]">$t</a></td>
			<td><a href="/showartist.html?artistid=$track->[2]">$a</a></td>
		</tr>
EOF

		$first = 0;
	}

	print "<tr><td>&nbsp;</td></tr>\n";
}

print <<EOF;
	</tbody>
</table>

<p>End of report; found ${\ scalar @$rows } TRMs.</p>

<& /comp/footer &>
EOF

# eof TRMsWithManyTracks.pl
