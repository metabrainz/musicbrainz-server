#!/usr/bin/perl -w
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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;

sub RunReport
{
    my ($dbh) = @_;

    print <<EOF;
<& /comp/sidebar, title=>'Tracks which might well be encoded using the wrong character set' &>

<p>Generated <% \$m->comp('/comp/datetime', ${\ time() }) %></p>

<p>
    When data is imported from FreeDB, it is meant to be in the
    iso-8859-1 ("Latin-1") character set.&nbsp;
    However, if the data was actually in a different character set
    - say, the Chinese "Big5" set - then the data which ends up in 
    MusicBrainz is corrupted.&nbsp;
    It's not worthless, though, because with a little effort
    the correct character set can be deduced, and the existing data
    converted into the correct form.
</p>

<p>
    All tracks which look like they might have been encoded
    using the wrong character set are listed below.&nbsp;
</p>

<p>
    (Specifically we're looking for tracks which only contain
    characters from the latin-1 character set, but which don't
    contain any of A-Z a-z 0-9.&nbsp;
    Finally we ignore a few track
    names which fit this category but which occur very often,
    e.g. ".", "?", "???" etc.)
</p>

EOF

    require Artist;
    my $a = Artist->new($dbh);

    my $sql = Sql->new($dbh);
    my $data = $sql->SelectListOfHashes(
	"
	SELECT j.album, t.id AS track, t.name, t.artist
	FROM track t, albumjoin j
	WHERE t.name !~ '[A-Za-z0-9]'
	AND t.name NOT IN ('.','...','---','?','???')
	AND j.track = t.id
	ORDER BY 1, 2
	",
    );

    my $last_artist = 0;

        for my $row (@$data)
        {
	    # Decode the name; ignore if it doesn't encode properly back into
	    # latin-1, i.e. if it actually has proper characters (e.g. Han,
	    # Thai etc).

	    eval {
		my $t = $row->{name};
		use Encode qw( from_to FB_CROAK );
		from_to($t, "utf-8", "latin-1", FB_CROAK);
		1;
	    } or next;

	    # So it only contains latin-1 characters, but none of A-Za-z0-9.
	    # A likely story!

            {
                if ($row->{artist} ne $last_artist)
                {
		    $a->SetId($row->{artist});
		    $a->LoadFromId;
		    my $n = $a->GetName;

		    print "<p><a href=\"/showartist.html?artistid=$row->{artist}\">";
		    print "<font size=\"+1\">$n</font></a><br>";
                }

                print "&nbsp;&nbsp;&nbsp;";
                print "<a href=\"/showtrack.html?trackid=$row->{track}\">";
                print "$row->{name}</a><br>\n";

                $last_artist = $row->{artist};
            }
        }

    print "<p>End of report; " . scalar(@$data) . " tracks found.</p>";

    print "<& /comp/footer &>\n";
}

my $mb = MusicBrainz->new;
$mb->Login;

RunReport($mb->{DBH});

# Disconnect
$mb->Logout;
