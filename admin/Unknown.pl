#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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

use lib "../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;

sub FindDuplicates
{
    my ($dbh) = @_;
    my ($id, $name, $album, $num);
    my (@tm, $last_artist);

    @tm = gmtime(time());

    print "<& /comp/sidebar, title=>'Tracks with too many capital letters' &>\n";
    printf "Generated on %d/%d/%d %02d:%02d GMT. ",
             $tm[4] + 1, $tm[3], $tm[5] + 1900, $tm[2], $tm[1];
    print 'All tracks which contain at least four sequential capital ';
    print "characters are listed below:<p><br>\n";

    $sth = $dbh->prepare(qq\select * from Track, AlbumJoin, Artist where AlbumJoin.Track = Track.id and Track.Artist = Artist.id order by Artist.name, AlbumJoin.Album, Track.Name\);
    $sth->execute();
    if ($sth->rows)
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            $id = $row[0];
            $name = $row[1];
            $album = $row[14];
            $num = $row[16];
            $artist = $row[19];

            if ($name =~ /unknown/i)
            {
                if ($artist ne $last_artist)
                {
                   print "<p><a href=\"/showartist.html?artistid=$row[18]\">";
                   print "<font size=\"+1\">$artist</font></a><br>";
                }

                print "&nbsp;&nbsp;&nbsp;";
                print "$num: <a href=\"/showtrack.html?trackid=$id\">";
                print "$name</a><br>\n";

                $last_artist = $artist;
            }
        }
    }
    $sth->finish;
}

my ($arg, $mb, $host);

$mb = MusicBrainz->new;
$mb->Login;

FindDuplicates($mb->{DBH}, $host);

# Disconnect
$mb->Logout;
