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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;

use HTML::Mason::Tools qw( html_escape );

sub RunReport
{
    my ($dbh) = @_;

    print "<& /comp/sidebar, title=>'Tracks with no capital letters' &>\n";

    my $time = time;
    print "Generated on: <% \$m->comp('/comp/datetime', $time) %><br><br>";

    print 'All tracks which contain one of the lower case letters [a-z] ';
    print 'but do not contain an upper case letter [A-Z] ';
    print "are listed below:<p><br>\n";

    my $sth = $dbh->prepare(qq\select track.id, track.name, sequence, 
                                   track.artist, artist.name 
                              from Track, AlbumJoin, Artist 
                             where AlbumJoin.Track = Track.id and 
                                   Track.Artist = Artist.id 
				   and track.name !~ '[A-Z]'
				   and track.name ~ '[a-z]'
                          order by Artist.name, AlbumJoin.Album, Track.Name\);
    $sth->execute();
    if ($sth->rows)
    {
        my @row;
	my $last_artist;

        while(@row = $sth->fetchrow_array())
        {
            my $id = $row[0];
            my $name = $row[1];
            my $num = $row[2];
            my $artistid = $row[3];
            my $artist = $row[4];

	    $name =~ s/[\s(-]*$num[\s)-]*//;

	    next if $name =~ /
		\A
		[<\[\(]?
		(?:
			blank
			| data
			| data\ track
			| empty
			| silence
			| untitled
		)
		[>\]\)]?
		\z
	    /xi;

            {
                if ($artistid ne $last_artist)
                {
                   print "<p><a href=\"/showartist.html?artistid=$row[3]\">";
                   print "<font size=\"+1\">",
		   	html_escape($artist),
			"</font></a><br>";
		   $last_artist = $artistid;
                }

                print "&nbsp;&nbsp;&nbsp;";
                print "$num: <a href=\"/showtrack.html?trackid=$id\">";
		print html_escape($name), "</a><br>\n";
            }
        }
    }
    $sth->finish;
    print "<& /comp/footer &>\n";
}

my $mb = MusicBrainz->new;
$mb->Login;

RunReport($mb->{DBH});

# Disconnect
$mb->Logout;
