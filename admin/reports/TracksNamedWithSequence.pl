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
<& /comp/sidebar, title => 'Tracks named with their own track number' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    This report aims to identify tracks whose names include their own
    sequence number, e.g. "1) Some Name" (instead of just "Some Name").
</p>

EOF

my $data = $sql->SelectListOfLists("
	SELECT a.artist, j.album, t.id, j.sequence, t.name
	FROM track t, albumjoin j, album a
	WHERE j.track = t.id
	AND a.id = j.album
	AND t.name ~ '^[0-9]'
	AND t.name ~ ('^0*' || j.sequence || '[^0-9]')
	ORDER BY a.artist, j.album, j.sequence
");

# Index the tracks by album-artist, album:

my $artists = {};

for (@$data)
{
	push @{ $artists->{ $_->[0] }{ALBUMS}{ $_->[1] }{TRACKS} }, $_;
}

my $al = Album->new($mb->{DBH});
my $ar = Artist->new($mb->{DBH});

for my $artistid (keys %$artists)
{
	my $albums = $artists->{$artistid}{ALBUMS};

	# Remove albums with two or fewer tracks like this
	for my $albumid (keys %$albums)
	{
		delete $albums->{$albumid}, next
			if @{ $albums->{$albumid}{TRACKS} } <= 2;

		$al->SetId($albumid);
		$al->LoadFromId;

		$albums->{$albumid}{ID} = $albumid;
		$albums->{$albumid}{NAME} = $al->GetName;
		$albums->{$albumid}{_sort_} = lc decode("utf-8", unac_string('UTF-8', $al->GetName));
	}

	# Remove the artists if we've removed all their albums
	delete $artists->{$artistid}, next
		unless keys %$albums;

	$ar->SetId($artistid);
	$ar->LoadFromId;

	$artists->{$artistid}{ID} = $artistid;
	$artists->{$artistid}{NAME} = $ar->GetName;
	$artists->{$artistid}{_sort_} = lc decode("utf-8", unac_string('UTF-8', $ar->GetSortName));
}

my ($nartists, $nalbums, $ntracks) = (0, 0, 0);

for my $artist (sort { $a->{_sort_} cmp $b->{_sort_} } values %$artists)
{
	print "<h2><a href='/showartist.html?artistid=$artist->{ID}'>"
		. html_escape($artist->{NAME}) . "</a></h2>\n";
	++$nartists;

	my $albums = $artist->{ALBUMS};

	for my $album (sort { $a->{_sort_} cmp $b->{_sort_} } values %$albums)
	{
		print "<h3><a href='/showalbum.html?albumid=$album->{ID}'>"
			. html_escape($album->{NAME}) . "</a></h3>\n";
		++$nalbums;

		print "<ul style='list-style: none'>\n";

		my $tracks = $album->{TRACKS};

		for my $t (@$tracks)
		{
			print "  <li><a href='/showtrack.html?trackid=$t->[2]'>"
				. html_escape($t->[4]) . "</a></li>\n";
			++$ntracks;
		}

		print "</ul>\n";
	}
}

print <<EOF;

<p>End of report; found $ntracks tracks, $nalbums albums, $nartists artists.</p>

<& /comp/footer &>
EOF

# eof TracksNamedWithSequence.pl
