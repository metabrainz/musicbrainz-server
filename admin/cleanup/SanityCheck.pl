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

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use DBDefs;
use MusicBrainz::Server::Artist;
use ModDefs ':modstatus', 'DARTIST_ID';
use MusicBrainz;

# TODO ditch Main.pl
require "$FindBin::Bin/Main.pl";

sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;
    my $count;
    my $sth;

    print "Missing artists: (from album)\n";
    $count = 0;
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

            if ($fix)
            {
                $dbh->do("delete from Album where id = $row[0]"); 
            }
        }
    }
    $sth->finish;
    print "Found $count missing artists.\n\n";

    # --------------------------------------------------------------------

    print "Invalid tracks (Missing artists):\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Track.id, Track.Artist 
                            from   Track left join Artist 
                            on     Track.artist = Artist.id 
                            WHERE  Artist.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Track $row[0] references non-existing artist $row[1].\n";
            $count++;

            if ($fix)
            {
                $dbh->do("delete from Track where id = $row[0]"); 
            }
        }
    }
    $sth->finish;
    print "Found $count invalid tracks.\n\n";

    # --------------------------------------------------------------------

    print "Invalid artist aliases (Missing artists):\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select ArtistAlias.id, ArtistAlias.Ref 
                            from   ArtistAlias left join Artist 
                            on     ArtistAlias.ref = Artist.id 
                            WHERE  Artist.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  ArtistAlias $row[0] references non-existing artist $row[1].\n";
            $count++;

            if ($fix)
            {
                $dbh->do("delete from ArtistAlias where id = $row[0]"); 
            }
        }
    }
    $sth->finish;
    print "Found $count invalid aritst aliases.\n\n";

    # --------------------------------------------------------------------

    print "Empty artists:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Artist.id, Artist.name
                            from   Artist left join Track 
                            on     Artist.id = Track.artist 
                            WHERE  Track.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            next if ($row[0] == &ModDefs::DARTIST_ID); 
            next if ($row[0] == &ModDefs::VARTIST_ID); 
            print "  Artist $row[0] has no tracks.\n";
            $count++;

            if ($fix)
            {
                $dbh->do("delete from Artist where id = $row[0]"); 
                $dbh->do("update Moderations set Artist = " . &ModDefs::DARTIST_ID .
                         " where artist = $row[0]");
            }
        }
    }
    $sth->finish;
    print "Found $count empty artists.\n\n";

    # --------------------------------------------------------------------

    print "Empty track names:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select Track.id, Track.artist
                            from   Track
                            where  Track.name = ''|);
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
                        $dbh->do("delete from Discid where album = $row[0]");
                        $dbh->do("delete from TOC where album = $row[0]");
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
    $sth = $dbh->prepare(qq|select Discid.id, Discid.Disc, Discid.Album
                            from   Discid left join Album 
                            on     Discid.album = Album.id 
                            WHERE  Album.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Discid $row[1] references non-existing album $row[2].\n";
            $count++;

            $dbh->do("delete from Discid where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned diskids.\n\n";

    # --------------------------------------------------------------------
    
    print "Orphaned TOCs:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select TOC.id, TOC.Discid, TOC.Album
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
    
    print "Orphaned TOCs: (via Discid)\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select TOC.id, TOC.Discid, TOC.Album
                            from   TOC left join Discid 
                            on     TOC.discid = Discid.disc 
                            WHERE  Discid.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  TOC $row[1] references non-existing discid $row[1].\n";
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
    $sth = $dbh->prepare(qq|select TRMJoin.id, TRMJoin.trm, TRMJoin.track
                            from   TRMJoin left join Track 
                            on     TRMJoin.track = Track.id 
                            WHERE  Track.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  TRM Id $row[0] references non-existing track $row[2].\n";
            $count++;

            $dbh->do("delete from TRMJoin where id = $row[0]") if ($fix);
            $dbh->do("delete from TRM where id = $row[1]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count orphaned trmids.\n\n";

    # --------------------------------------------------------------------
    
    print "Invalid trmjoins:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select TRMJoin.id, TRMJoin.trm 
                              from TRMJoin left join TRM 
                                on TRMJoin.trm = TRM.id 
                             where TRM.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  TRMJoin $row[0] references non-existing TRM $row[1].\n";
            $count++;

            $dbh->do("delete from TRMJoin where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count invalid trmjoins.\n\n";

    # --------------------------------------------------------------------
 
    print "Invalid artists in Moderations:\n";
    $count = 0;
    $sth = $dbh->prepare(qq|select m.id, m.artist, m.status
                              from moderation_all m left join Artist 
                                on m.artist = Artist.id 
                             where Artist.id IS NULL|);
    if ($sth->execute() && $sth->rows())
    {
        my @row;

        while(@row = $sth->fetchrow_array())
        {
            print "  Moderation $row[0] references non-existing artist $row[1].\n";
            $count++;

	    my $openclosed = (
		($row[2] == STATUS_OPEN or $row[2] == STATUS_TOBEDELETED)
		? "open" : "closed"
	    );
            $dbh->do("update moderation_$openclosed set Artist = " . DARTIST_ID .
                     " where id = $row[0]") if ($fix);
        }
    }
    $sth->finish;
    print "Found $count invalid moderations.\n\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
