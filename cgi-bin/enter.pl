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
use MusicBrainz;

my ($o, $cd); 
my ($tracks, $i, $artist, $artistname);
my ($dbh, $sth, $rv);

$cd = new MusicBrainz;
$o = $cd->GetCGI;
$cd->Header('Enter CD Information');
$cd->CheckArgs('id', 'tracks', 'toc');  

$cd->Login();
$tracks = $o->param('tracks');
$artist = $o->param('artist');

if (defined $artist)
{
   $artistname = $cd->GetArtistName($artist);
   if (!defined $artistname)
   {
       $artistname = 'Tabasco bondage action';
   } 
}
print $o->start_form(-action=>'done.pl'),"\n";

print "Please enter the CD information below:",$o->p,"\n";

print "<b>Note:</b> 'Use Last, First name' e.g. 'Beatles, The'<br>";
print("and enter <i>[Data Track]</i> for data tracks on a CD.<p>");

print "<table>";
if (!defined $artist)
{
    print "<tr><td>Artist:</td><td>";
    print $o->textfield(-name=>'artistname', -size=>30),"</td></tr>\n";
}
else
{
    print "<tr><td>Artist:</td><td> ";
    print $o->escapeHTML($artistname);
    print $o->hidden(-name=>'artist', -default=>"$artist"),"</td></tr>\n";
}

print "<tr><td>CD Title:</td><td>";
print $o->textfield(-name=>'title',-size=>30),"</td></tr>\n";

for($i = 0; $i < $tracks; $i++)
{
    print "<tr><td>Track ";
    print $i + 1;
    print ":</td><td>";
    print $o->textfield(-name=>"track$i",-size=>30),"</td></tr>\n";
}
print("</table>");


print $o->hidden(-name=>'id', -default=>"$o->param('id')"),"\n";
print $o->hidden(-name=>'tracks', -default=>"$o->param('tracks')"),"\n";
print $o->hidden(-name=>'toc',-default=>$o->param('toc'));
print $o->p,$o->submit('Next >>'),"\n";

print $o->end_form,"\n";

$cd->Logout;
$cd->Footer;  
