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

use lib "../../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;
require "Main.pl";

sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet) = @_;
    my ($last_num, $last_name, $last_id);
    my ($tid, $ajid, $name, $album, $num);

    $last_tid = -1;
    $last_ajid = -1;
    $last_num = -1;
    $last_name = "";
    $last_artist = "";

    $sth = $dbh->prepare(qq\select * from Track, AlbumJoin, Artist where AlbumJoin.Track = Track.id and Track.Artist = Artist.id order by Artist.name, AlbumJoin.Album, Track.Name\);
    $sth->execute();
    if ($sth->rows)
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            $tid = $row[0];
            $ajid = $row[13];
            $name = $row[1];
            $num = $row[16];
            $artist = $row[19];
            if ($name eq $last_name && 
                ($num == 0 || $last_num == 0 || $num == $last_num))
            {
                if ($last_num == 0)
                {
                    print "$last_artist: $last_num $last_name " 
                        if (!$quiet);
                    print "($last_tid, $last_ajid)\n" 
                        if (!$quiet);
                    $dbh->do("delete from Track where id = $last_tid") 
                        if ($fix);
                    $dbh->do("delete from AlbumJoin where id = $last_ajid") 
                        if ($fix);
                }
                else
                {
                    print "$artist: $num $name ($tid, $ajid)\n" 
                        if (!$quiet);
                    $dbh->do("delete from Track where id = $tid") 
                        if ($fix);
                    $dbh->do("delete from AlbumJoin where id = $ajid") 
                        if ($fix);
                }

                $last_artist = $artist;
            }

            $last_num = $num;
            $last_name = $name;
            $last_tid = $tid;
            $last_ajid = $ajid;
        }
    }
    $sth->finish;
}

Main(0);
