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
use Artist;
use MusicBrainz;
require "Main.pl";

sub Arguments
{
    return "";
}

sub Cleanup
{
    my ($dbh, $fix, $quiet, $arg1, $arg2) = @_;
    my ($count, $sql);

    $sql = Sql->new($dbh);
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
            next if ($row[0] == ModDefs::DARTIST_ID); 
            next if ($row[0] == ModDefs::VARTIST_ID); 
            print "  Artist $row[0] has no tracks ";
            $count++;

            if ($fix)
            {
                eval 
                {
                   $sql->Begin(); 

                   $sql->Do("delete from ArtistAlias where ref = $row[0]"); 
                   $sql->Do("update Moderation set Artist = " . ModDefs::DARTIST_ID .
                           " where artist = $row[0]");
                   $sql->Do("delete from Artist where id = $row[0]"); 

                   $sql->Commit(); 
                   print " -- removed";
                };
                if ($@)
                {
                   print " -- error occurred during remove.";
                   $sql->Rollback();
                }
            }
            print "\n";
        }
    }
    $sth->finish;
    print "Found $count empty artists.\n\n";
}

# Call main with the number of arguments that you are expecting
Main(0);
