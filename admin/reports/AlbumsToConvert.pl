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

print <<EOF;
<& /comp/sidebar, title => 'Albums to convert to Multiple Artists' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    This report aims to identify albums which need converting to
    "multiple artists".&nbsp;
    Currently it does this by looking for albums where every track
    contains "/" or "-".
</p>

EOF

my $albums = $sql->SelectListOfLists("
	SELECT m.id, m.tracks, COUNT(*)
	FROM albummeta m, albumjoin j, track t
	WHERE j.album = m.id
	AND j.track = t.id
	AND t.name LIKE '%-%'
	GROUP BY m.id, m.tracks
	HAVING COUNT(*) = m.tracks
	");
my $albums2 = $sql->SelectListOfLists("
	SELECT m.id, m.tracks, COUNT(*)
	FROM albummeta m, albumjoin j, track t
	WHERE j.album = m.id
	AND j.track = t.id
	AND t.name LIKE '%/%'
	GROUP BY m.id, m.tracks
	HAVING COUNT(*) = m.tracks
	");

my @album_ids = do {
	my %t;
	@t{ map { $_->[0] } @$albums } = ();
	@t{ map { $_->[0] } @$albums2 } = ();
	keys %t;
};

my %artists;
my $count = 0;

for my $album (@album_ids)
{
	my $al = Album->new($mb->{DBH});
	$al->SetId($album);
	$al->LoadFromId or next;

	my $ar = $artists{ $al->GetArtist };

	unless ($ar)
	{
		$ar = Artist->new($mb->{DBH});
		$ar->SetId($al->GetArtist);
		$ar->LoadFromId or next;

		$ar->{_sort_} = $ar->GetSortName;

		$artists{ $al->GetArtist } = $ar;
	}

	$al->{_sort_} = $al->GetName;
	#print STDERR "$al->{_sort_} by $ar->{_sort_}\n" if -t;

	my @t = $al->LoadTracksFromMultipleArtistAlbum;
	my $aid = $al->GetArtist;
	next if grep { $_->GetArtist != $aid } @t;
	$al->{tracks} = \@t;

	push @{ $ar->{_albums_} }, $al;
	++$count;
}

use MusicBrainz::Server::PagedReport;
my $report = MusicBrainz::Server::PagedReport->Save(
	"$FindBin::Bin/../../htdocs/reports/AlbumsToConvert"
);

for my $artist (sort { $a->{_sort_} cmp $b->{_sort_} } values %artists)
{
	my @a = @{ $artist->{_albums_} }
		or next;

	my $albums = $artist->{_albums_};
	@$albums = sort { $a->{_sort_} cmp $b->{_sort_} } @$albums;

	for my $al (sort { $a->{_sort_} cmp $b->{_sort_} } @$albums)
	{
		$report->Print(
			{
				artist_id			=> $artist->GetId,
				artist_name			=> $artist->GetName,
				artist_sortname		=> $artist->GetSortName,
				artist_modpending	=> $artist->GetModPending,
				album_id			=> $al->GetId,
				album_name			=> $al->GetName,
				album_modpending	=> $al->GetModPending,
				tracks				=> [
					map {
						+{
							track_id	=> $_->GetId,
							track_seq	=> $_->GetSequence,
							track_name	=> $_->GetName,
						}
					} @{ $al->{tracks} }
				],
			},
		);
	}

	next;

	my $id = $artist->GetId;
	my $n = html_escape($artist->GetName);
	print "<h3><a href='/showartist.html?artistid=$id'>$n</a></h3>\n\n";

	for my $album (sort { $a->{_sort_} cmp $b->{_sort_} } @a)
	{
		$id = $album->GetId;
		$n = html_escape($album->GetName);
		print "<p><a href='/showalbum.html?albumid=$id'>$n</a></p>\n";

		for (@{ $album->{tracks} })
		{
			printf " %d) %s<br>\n", $_->GetSequence, html_escape($_->GetName);
		}

		print "\n";
	}
}

my $artists = keys %artists;
print <<EOF;

<p>End of report; found $count albums by $artists artists.</p>

<& /comp/footer &>
EOF

# eof AlbumsToConvert.pl
