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
                                                                               
use strict;
use CGI;
use DBI;
use DBDefs;
use MusicBrainz;

my ($o, $cd); 
my ($dbh, $sth);

sub PrintStat 
{
   my $query = $_[0];
   my $title = $_[1];

	$sth = $dbh->prepare($query);
   if ($sth->execute)
   {
       my @row;
   
       @row = $sth->fetchrow_array;
       print "<tr><TD valign=top>$title</TD>";
       print "<TD valign=top>$row[0]</td></tr>\n";

       $sth->finish;
   }
}

sub PrintAlbums 
{
	$sth = $dbh->prepare("select Album.name, Artist.name from Album, " .
                        "Artist where Album.artist = Artist.id order by Album.name");
   if ($sth->execute)
   {
       my @row;
   
       while(@row = $sth->fetchrow_array)
       {
           print "<tr><TD valign=top>$row[0]</TD>";
           print "<TD valign=top>$row[1]</td></tr>\n";
       }

       $sth->finish;
   }
}

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Database statistics');

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "<font size=+1 color=red>Sorry, the database is currently ";
    print "not available. Please try again in a few minutes.</font>";
    print "(Error: ",$DBI::errstr,")";
} 
else
{
    print "<font size=+1>Stats</font><br>\n";
    print "<table border=0>\n";
    PrintStat("select count(*) from Album", "Number of Albums:");
    PrintStat("select count(*) from Diskid", "Number of Disk Ids:");
    PrintStat("select count(*) from Artist", "Number of Artists:");
    PrintStat("select count(*) from Track", "Number of Tracks:");
    PrintStat("select count(*) from Pending", "Number of Pending metadata items:");
    print "</table>\n";
    print "<br>Server Version: " . DBDefs::VERSION;
}

if ($dbh)
{
    $dbh->disconnect();
}

$cd->Footer;
