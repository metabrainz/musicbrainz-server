#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- The community music metadata project.
#
#   Copyright (C) 1998 Robert Kaye
#   Copyright (C) 2001 Luke Harless
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
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;
    my $count = 0;

    print "Missing artists:\n";
    $sth = $dbh->prepare(qq|select Album.id, Album.Artist 
                            from   Album left join Artist 
                            on     Album.artist = Artist.id 
                            WHERE  Artist.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Album $row[0] references non-existing artist $row[1].\n";
            $count++;
        }
    }
    $sth->finish;
    print "Found $count missing artists.\n\n";

    # --------------------------------------------------------------------

    print "Empty artists:\n";
    $sth = $dbh->prepare(qq|select Artist.id, Artist.name
                            from   Artist left join Track 
                            on     Artist.id = Track.artist 
                            WHERE  Track.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Artist $row[0] has no tracks.\n";
            $count++;

            $dbh->do("delete from Artist where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count empty artists.\n\n";

    # --------------------------------------------------------------------

    print "Empty track names:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Track.id, Track.artist
                            from   Track
                            where  Track.name = ""|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Track $row[0] by artist $row[1] has an " .
                  " empty track name.\n";
            $count++;

            $dbh->do("delete from Track where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count bad tracks.\n\n";

    # --------------------------------------------------------------------

    print "Empty albums:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Album.id
                            from   Album|);
    if ($sth->execute() && $sth->rows())
    {
        my (@row, @row2, $sth2);

        while(@row = $sth->fetchrow_array())
        {
            $sth2 = $dbh->prepare(qq|select count(*)
                                     from   AlbumJoin
                                     where  Album = $row[0]|);
            if ($sth2->execute() && $sth2->rows())
            {
                @row2 = $sth2->fetchrow_array();
                if ($row2[0] == 0)
                {
                    print "  Album $row[0] has no tracks.\n";
                    $count++;

                    if ($fix)
                    {
                        $dbh->do("delete from Album where id = $row[0]");
                        $dbh->do("delete from Diskid where album = $row[0]");
                    }
                }
            }
        }
    }
    $sth->finish;
    print "Found $count empty albums.\n\n";

    # --------------------------------------------------------------------
    
    print "Orphaned diskids:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Diskid.id, Diskid.Disk, Diskid.Album
                            from   Diskid left join Album 
                            on     Diskid.album = Album.id 
                            WHERE  Album.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Diskid $row[1] references non-existing album $row[2].\n";
            $count++;

            $dbh->do("delete from Diskid where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned diskids.\n\n";

    # --------------------------------------------------------------------
    
    print "Orphaned TOCs:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select TOC.id, TOC.Diskid, TOC.Album
                            from   TOC left join Album 
                            on     TOC.album = Album.id 
                            WHERE  Album.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  TOC $row[1] references non-existing album $row[2].\n";
            $count++;

            $dbh->do("delete from TOC where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned TOCs.\n\n";

    # --------------------------------------------------------------------
    
    print "Orphaned albumjoins:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select AlbumJoin.id, AlbumJoin.album
                            from   AlbumJoin left join Album 
                            on     AlbumJoin.album = Album.id 
                            WHERE  Album.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  AlbumJoin $row[0] references non-existing album $row[1].\n";
            $count++;

            $dbh->do("delete from AlbumJoin where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned albumjoins.\n\n";

    # --------------------------------------------------------------------
    
    print "Invalid albumjoins:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select AlbumJoin.id, AlbumJoin.track 
                              from AlbumJoin left join Track 
                                on AlbumJoin.track = Track.id 
                             where Track.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  AlbumJoin $row[0] references non-existing track $row[1].\n";
            $count++;

            $dbh->do("delete from AlbumJoin where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count invalid albumjoins.\n\n";

    # --------------------------------------------------------------------
    
    print "Orphaned trmids:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select GUIDJoin.id, GUIDJoin.guid, GUIDJoin.track
                            from   GUIDJoin left join Track 
                            on     GUIDJoin.track = Track.id 
                            WHERE  Track.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  TRM Id $row[0] references non-existing track $row[2].\n";
            $count++;

            $dbh->do("delete from GUIDJoin where id = $row[0]") if ($fix);
            $dbh->do("delete from GUID where id = $row[1]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned trmids.\n\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
