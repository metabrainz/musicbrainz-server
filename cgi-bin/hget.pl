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
my ($tracks, $i, $artist, $artistname, $title, $album, $albumid, $id);
my ($dbh, $sth, $rv);

sub DumpAlbum
{
   my $albumid = $_[0];
   my $sth;
   my $artistid;
   my $albumname;
   my $artistname;
   my $i;

   $sth = $dbh->prepare("select name,artist from Album where id='$albumid'");
   if ($sth->execute)
   {
       my @row;
   
       @row = $sth->fetchrow_array;
       $albumname = defined $row[0] ? $row[0] : "(Unknown)";
       $artistid = defined $row[1] ? $row[1] : "(Unknown)";
    
       $sth->finish;

       if ($artistid)
       {
           $sth = $dbh->prepare("select name from Artist where id='$artistid'");
           if ($sth->execute)
           {
               @row = $sth->fetchrow_array;
               $artistname = defined $row[0] ? $row[0] : "(Unknown)";
    
               $sth->finish;
           }
       }
       else
       {
           $artistname = "(various)";
       }

       print "<tr><td>Artist:</td><td>";
       
       if ($artistid) 
       {
           print "<a href=\"showartist.pl?artistid=$artistid\">";
       }
       print $o->escapeHTML($artistname);
       if ($artistid) 
       {
           print "</a>";
       }
       print "</td><td>";
       if ($artistid) 
       {
           print "<a href=\"editartist.pl?artistid=$artistid\">Edit</a>";
       }
       print "</td></tr><tr><td>Album:</td><td>";
       print $o->escapeHTML($albumname);
       print "</td><td><a href=\"editalbum.pl?albumid=$albumid\">Edit</a>";
       print " <a href=\"xget.pl?albumid=$albumid\">XML</a>";
       print "</td></tr>";
       print "\n";

       my (@tracks, @artists, @artistids, @trackids);

       $sth = $dbh->prepare("select id, name,artist from Track where " . 
                            "album='$albumid' order by sequence");
       if ($sth->execute)
       {
           print "<tr><td>Number of tracks:</td><td> " . $sth->rows . 
                 "</td><td>&nbsp;</td></tr>\n";
           $i = 0;
           while(@row = $sth->fetchrow_array)
           {
               $trackids[$i] = $row[0]; 
               $tracks[$i] = $row[1]; 
               $artistids[$i] = $row[2]; 
               $i++;
           }
       } 
       $sth->finish;

       if ($artistid == 0)
       {
           $i = 0;
           for($i = 0; $i < scalar(@tracks); $i++)
           {
               print "<tr><td>Track ";
               print $i + 1;
               print ":</td><td>",$o->escapeHTML($tracks[$i]),"</td><td>\n";
               print "<a href=\"edittrack.pl?trackid=$trackids[$i]\">";
               print "Edit</a></td></tr>\n";

               $sth = $dbh->prepare("select id, name from Artist where " . 
                                "id='$artistids[$i]'");
               if ($sth->execute)
               {
                   @row = $sth->fetchrow_array;
                   print "<tr><td>Artist";
                   print $i + 1;
                   print ":</td><td><a href=\"showartist.pl?artistid=";
                   print "$row[0]\">",$o->escapeHTML($row[1]),"</a></td>\n";
                   print "<td><a href=\"editartist.pl?artistid=$row[0]\">";
                   print "Edit</a></td></tr>\n";
               } 
               $sth->finish;

           }
       }
       else
       {
           for($i = 0; $i < scalar(@tracks); $i++)
           {
               print "<tr><td>Track";
               print $i + 1;
               print ":</td><td>",$o->escapeHTML($tracks[$i]),"</td><td>\n";
               print "<a href=\"edittrack.pl?trackid=$trackids[$i]\">";
               print "Edit</a></td></tr>\n";
           }
           print "<br><p>CDindex also has a list of all the CDs by ";
           print "<a href=\"showartist.pl?artistid=$artistid\">";
           print $o->escapeHTML($artistname);
           print "</a> which are in our database.</p>"; 
       }
   }
}

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Get CD Information');

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "<font size=+1 color=red>Error:Sorry, the database is currently ";
    print "not available. Please try again in a few minutes.</font>";
    print "(Error: ".$DBI::errstr.")";
} 
else
{
    if (defined $o->param('id'))
    {
        $id = $o->param('id');
        $sth = $dbh->prepare("select Album from Diskid where disk='$id'");
        $sth->execute;
        if ($sth->rows)
        {
            my @row;

            print "<table><tr>\n";
            print "<td>NumMatches: </td><td>" . $sth->rows;
            print "</td><td>&nbsp;</td></tr>\n";
            while(@row = $sth->fetchrow_array)
            {
                DumpAlbum($row[0]);
            } 
            print "</table>";
        }
        else
        {

            if ($o->param('tracks') ne '' && $o->param('toc') ne '')
            {
                my $toc;
                my (@fuzzy, $alb);

                $toc = $o->param('toc');
                @fuzzy = $cd->FindFuzzy($dbh, $o->param('tracks'), $toc);
                if (scalar(@fuzzy) == 0)
                {
                    print "That CD was not found."; 

                    $toc =~ tr/ /+/;
                    print " You can <a href=\"submit.pl?id=$id&tracks=", $o->param('tracks');
                    print "&toc=$toc\">Submit this CD</a> to CDindex for next time.";
                }
                else
                {
                    print "There were no exact matches. Please check the ";
                    print "following albums to see if they match the album ";
                    print "you are looking for:<p>";
              
                    print "<table width=100%>\n";
                    while(defined($alb = pop @fuzzy))
                    {
                         DumpAlbum($alb);
                         print "<tr><td colspan=4><hr></td></tr>";
                    }
                    print "</table>"; 
                }
            }
            else
            {
                print "That CD was not found."; 
            }
        }
        $sth->finish;
    }
    else
    {
        if ($o->param('albumid') ne '')
        {
            print "<table><tr>\n";
            print "<td>NumMatches: </td><td>1";
            print "</td><td>&nbsp;</td></tr>\n";
            DumpAlbum($o->param('albumid'));
            print "</table>";
        }
        else
        {
            print "That CD was not found."; 
        }
    }
}

print '  </TD>',"\n";
print '</TR>',"\n";
print '</TABLE>',"\n";

print $o->end_html;

if ($dbh)
{
    $dbh->disconnect();
}
