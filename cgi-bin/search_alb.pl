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
                                                                               
use CGI;
use DBI;
use DBDefs; 
use strict;
use MusicBrainz;

my ($o, $cd); 
my $i;
my ($dbh, $sth, $sql); 

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Album Search Results');

my $search;
  
$search = $o->param('album');
if (!defined $search)
{
print <<END;

	 <FONT SIZE=+1 COLOR=RED>
	 Note:
	 </FONT>
   Please enter some text into the search field. Click on the
   Back button in your browser and try again.
	 <p>
   </td></tr></table>
END
   print $o->end_html;
   exit;
}

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "<font size=+1 color=red>Sorry, the database is currently ";
    print "not available. Please try again in a few minutes.</font>";
    print "(Error: ".$DBI::errstr.")";
}
else
{
    my @row;
    my $found = 0;

    print"Click on the artist or album name to see all information for that ";
    print"item, or click on one of the edit links to edit the name of the";
    print" item:<p><font size=+1>Single Artist Albums:</font><p>";
  
    $sql = $cd->AppendWhereClause($search, "select Album.id, Album.name, " .
           "Artist.id, Artist.name from Album, Artist where " .
           "Album.artist = Artist.id and ", "Album.Name");
    $sql .= " order by Album.name";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    if ($sth->rows > 0)
    {
        print"<table><tr><td><b>Album Name:</b></td>\n";
        print"<td><b>Artist:</b></td>\n";
        print"<td><b>Options:</b></td></tr>\n";
        while(@row = $sth->fetchrow_array)
        {
           print"<tr><td><a href=\"hget.pl?albumid=$row[0]\">";
           print $o->escapeHTML($row[1]),"</a></td>\n";
           print"<td><a href=\"showartist.pl?artistid=$row[2]\">";
           print $o->escapeHTML($row[3]),"</a></td><td>\n";
           print"<a href=\"editalbum.pl?albumid=$row[0]\">Edit Album</a>\n";
           print"<a href=\"editartist.pl?artistid=$row[2]\">Edit Artist</a>\n";
           print"</td></tr>\n";
        }
        print"</table>\n";

        $found = 1;
    }
    else
    {
        print("There were no items found.");
    }
    $sth->finish;

    print "<p><br><font size=+1>Multiple Artist Albums:</font><p>";

    $sql = $cd->AppendWhereClause($search, "select id, name " .
           "from Album where artist = 0 and ", "Name");
    $sql .= " order by name";

    $sth = $dbh->prepare($sql);
    $sth->execute();
    if ($sth->rows > 0)
    {
        print"<table><tr><td><b>Album Name:</b></td>\n";
        print"<td><b>Options:</b></td></tr>\n";
        while(@row = $sth->fetchrow_array)
        {
           print"<tr><td><a href=\"hget.pl?albumid=$row[0]\">";
           print $o->escapeHTML($row[1]),"</a></td><td>\n";
           print"<a href=\"editalbum.pl?albumid=$row[0]\">Edit Album</a>\n";
           print"</td></tr>\n";
        }
        print"</table>\n";

    }
    else
    {
        print("There were no items found.");
        
        if (!$found)
        {
            print(" Please try again:<p>");
            print $cd->SearchForm();
        }
    }
    $sth->finish;
    $dbh->disconnect;
}

$cd->Footer;
