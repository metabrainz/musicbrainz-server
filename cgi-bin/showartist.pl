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

use CGI::Pretty qw/:standard/;
use DBI;
use DBDefs;
use strict;
use MusicBrainz;

my ($o, $cd); 
my ($dbh, $sth, $rv, $sql); 

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Show Artist Albums');
$cd->CheckArgs('artistid');  

my $artist = $o->param('artistid');

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "<font size=+1 color=red>Sorry, the database is currently ";
    print "not available. Please try again in a few minutes.</font>";
    print "(Error: ".$DBI::errstr.")";
} 
else
{
    $sth = $dbh->prepare("select name from Artist where id = $artist");
    if ($sth->execute())
    {
        my @row;

        @row = $sth->fetchrow_array; 
        print '<font size=+1>'. $o->escapeHTML($row[0]) . '</font><p>';
        $sth->finish;
    }

    $sth = $dbh->prepare("select id, name from Album where Artist = " .
                         "$artist order by name");
    if ($sth->execute())
    {
        my @row;
        my $i;

        for(;@row = $sth->fetchrow_array;) 
        {
            print "<a href=\"hget.pl?albumid=$row[0]\">",$o->escapeHTML($row[1]),"</a> ";
            print "(<a href=\"xget.pl?albumid=$row[0]\">XML</a>):\n";
            print "<p><table><tr><td></td><td>Track No:</td>";
            print "<td>Track Title</td></tr>\n";

            my ($sth2, @row2);
            $sth2 = $dbh->prepare("select id, name, Sequence from Track " .
                                  "where Album = $row[0] order by Sequence ");
            if ($sth2->execute())
            {
                while(@row2 = $sth2->fetchrow_array)
                {
                    print "<tr><td>&nbsp;&nbsp;</td><td align=center>";
                    print $row2[2]+1;
                    print "</td><td>",$o->escapeHTML($row2[1]),"</td></tr>\n";
                }
            }
            $sth2->finish();
            print '</table><p>';
        }

        $sth->finish();
    }
    else
    {
        print "Query failed: " . $DBI::errstr . $o->p;
    }

    print '<font size=+1>Multiple Artist Albums:</font><p>';
    $sth = $dbh->prepare("select Album.id, Track.name, Album.name, sequence ".
                         "from Track, Album where Track.Artist = $artist and " .
                         "Album.artist = 0 and Track.album = Album.id " .
                         "order by Track.name");
    if ($sth->execute())
    {
        my @row;
        my $i;

        if ($sth->rows > 0)
        {
            print "<p><table><tr><td></td><td>Track No:</td>";
            print "<td>Track Title</td><td>Album:</td></tr>\n";
        
            for(;@row = $sth->fetchrow_array;) 
            {
                print "<tr><td>&nbsp;&nbsp;</td><td align=center>";
                print $row[3]+1;
                print "</td><td>",$o->escapeHTML($row[1]),"</td><td>\n";
                print "<a href=\"hget.pl?albumid=$row[0]\">",$o->escapeHTML($row[2]);
                print "</a></tr>\n";
            }
            print '</table><p>';
        }
        else
        {
            print 'None.';
        }

        $sth->finish();
    }
    else
    {
        print "Query failed: " . $DBI::errstr . $o->p;
    }
}

if ($dbh)
{
    $dbh->disconnect();
}

$cd->Footer;
