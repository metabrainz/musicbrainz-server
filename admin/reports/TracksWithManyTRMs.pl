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
<& /comp/sidebar, title => 'Tracks with many TRMs' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    This report lists tracks with at least 10 TRMs.
</p>

<table>
	<caption>Tracks with at least 10 TRMs</caption>
	<thead>
		<tr>
			<th>Track</th>
			<th>Artist</th>
			<th>TRMs</th>
		</tr>
	</thead>
	<tbody>
EOF

my $rows = $sql->SelectListOfLists("
	SELECT t.id, t.name, a.id, a.name, trmcount
	FROM (
		SELECT track, COUNT(*) AS trmcount
		FROM trmjoin
		GROUP BY track
		HAVING COUNT(*) >= 10
	) tmp
	INNER JOIN track t ON t.id = tmp.track
	INNER JOIN artist a ON a.id = t.artist
	ORDER BY trmcount DESC
");

for my $row (@$rows)
{
	my $t = html_escape($row->[1]);
	my $a = html_escape($row->[3]);
	print <<EOF;
		<tr>
			<td><a href="/showtrack.html?trackid=$row->[0]">$t</a></td>
			<td><a href="/showartist.html?artistid=$row->[2]">$a</a></td>
			<td>$row->[4]</td>
		</tr>
EOF
}

print <<EOF;
	</tbody>
</table>

<p>End of report; found ${\ scalar @$rows } tracks.</p>

<& /comp/footer &>
EOF

# eof TracksWithManyTRMs.pl
