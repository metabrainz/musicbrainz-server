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

my ($o, $cd, $num_tracks, $i, $sth, $sql); 
my ($search, $toc, $id, $tracks);
my (@row, @ids, %labels, @idslabels);

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Submit CD: Artist Search Results');
$cd->CheckArgs('id', 'toc', 'tracks'); 
  
$search = $o->param('search');
$toc = $o->param('toc');
$id = $o->param('id');
$tracks = $o->param('tracks');

if ($search eq '')
{
    $cd->PrintError("Please enter an artist name into the search field. " .
                    "Click on the Back button in your browser and try again.");
}

$cd->Login();

@idslabels = $cd->FindTextInColumn("Artist", "Name", $search);
if (defined @idslabels)
{
    print"Click on the artist name to display all the albums by that ";
    print"artist:<p>\n"; 

    for($i = 0; $i < scalar(@idslabels); $i++)
    {
        $ids[$i] = shift @idslabels;
        $labels{"$ids[$i]"} = $o->escapeHTML(shift @idslabels);
    }

    print $o->start_form(-action=>'album.pl');
    print $o->radio_group(-name=>'artist',
                          -default=>'-',
                          -"values"=>\@ids,
                          -labels=>\%labels,
                          -linebreak=>'true');
    print $o->hidden(-name=>'id',-default=>'$id');
    print $o->hidden(-name=>'tracks',-default=>'$tracks');
    print $o->hidden(-name=>'toc',-default=>$o->param('toc'));
    print $o->p,$o->submit('Select Artist>>');
    print $o->end_form;

    print("<p>If the artist is not listed above ");
    print("you may either try the search again, ");
    print("or click on 'New Artist' to enter the information for this ");
    print("CD. Please make sure to search carefully before you go ");
    print("through the effort to add a new CD.");
}
else
{
    print("There were no artists found given the keywords ");
    print("<b>'$search'</b>. You may either try again, ");
    print("or click on 'New Artist' to enter the information for this ");
    print("CD. Please make sure to search carefully before you go ");
    print("through the effort to add a new CD.");
}

print $o->start_form(-action=>'enter.pl');
print $o->hidden(-name=>'id',-default=>'$id');
print $o->hidden(-name=>'toc',-default=>$toc);
print $o->hidden(-name=>'tracks',-default=>'$tracks');
print $o->p,$o->submit('New Artist>>');
print $o->end_form;

print("<hr><b>Start another artist search:</b><p>\n");

print $o->start_form(-action=>'artist.pl');
print "Artist Name:<br>\n";
print $o->textfield(-name=>'search',size=>'30');
print $o->hidden(-name=>'id',-default=>'$id');
print $o->hidden(-name=>'toc',-default=>$toc);
print $o->hidden(-name=>'tracks',-default=>'$tracks');
print $o->p,$o->submit('Search');
print $o->end_form;
    
$cd->Logout;
$cd->Footer; 
