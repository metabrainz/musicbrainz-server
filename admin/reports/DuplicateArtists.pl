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

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

print <<EOF;
<& /comp/sidebar, title => 'Possibly duplicate artists' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    This report aims to identify artists with very similar names,
    which might indicate that the artists need to be merged.
</p>

EOF

$sql->Select("SELECT id, name, sortname FROM artist")
    or die "sql error";

my %a;

while (my @row = $sql->NextRow)
{
    my $n = unac_string('UTF-8', $row[1]);
    $n = uc decode("utf-8", $n);
    $n =~ s/[\p{Punctuation}]//g;

    my @words = sort $n =~ /(\w+)/g;
    my $key = "@words";

    push @{ $a{$key} }, \@row;
}

$sql->Finish;

my $dupes = my $dupes2 = 0;

print <<EOF;
<table>
	<tr>
		<th>Artist Name</th>
		<th>Artist Sortname</th>
		<th style="text-align: right">Albums</th>
		<th style="text-align: right">Tracks</th>
	</tr>
EOF

while (my ($k, $v) = each %a)
{
    next unless @$v >= 2;

	for (@$v)
	{
		my $na = $sql->SelectSingleValue("SELECT COUNT(*) FROM album WHERE artist = ?", $_->[0]);
		my $nt = $sql->SelectSingleValue("SELECT COUNT(*) FROM track WHERE artist = ?", $_->[0]);
		
		print <<EOF;
	<tr>
		<td>
			<a href='/showartist.html?artistid=$_->[0]'
				>${\ html_escape($_->[1]) }</a>
		</td>
		<td>
			${\ html_escape($_->[2]) }
		</td>
		<td style="text-align: right">$na</td>
		<td style="text-align: right">$nt</td>
	</tr>
EOF
	}
		
    print "<tr><td>&nbsp;</td></tr>\n";

    ++$dupes;
    $dupes2 += @$v;
}

print "</table>\n\n";

print "<p>End of report; found $dupes2 artists in $dupes combinations.</p>\n\n";

print "<& /comp/footer &>\n";

# eof DuplicateArtists.pl
