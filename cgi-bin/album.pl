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
use strict;
use MusicBrainz;

my ($o, $num_tracks, $i, $cd, $modpending); 
my ($toc, $id, $tracks, $artist);

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Submit CD: Select Album');
$cd->CheckArgs('id', 'toc', 'tracks'); 

$artist = $o->param('artist');
$toc = $o->param('toc');
$id = $o->param('id');
$tracks = $o->param('tracks');

if (!defined $artist || $artist eq '')
{
    $cd->PrintError("Please select an artist name. Click on the " . 
                    "Back button in your browser and try again.");
}

$cd->Login();

my (%unused, $first, $found, $artistname, @ids_tracks_seqs, @idsalbums);

$first = 1;
$found = 0;

($artistname, $modpending) = $cd->GetArtistName($artist);
print '<font size=+1>'. $o->escapeHTML($artistname) . '</font><p>';

@idsalbums = $cd->GetAlbumList($artist);
while(defined @idsalbums)
{
    my ($trackid, $albumid, $name, $seq, $ids_tracks_seqs, $albumname);
   
    $albumid = shift @idsalbums;
    $albumname = shift @idsalbums;
    @ids_tracks_seqs = $cd->GetTrackList($albumid);
 
    if (scalar(@ids_tracks_seqs) / 3 == $tracks)
    {
        print "Album: $albumname<br>";
        if ($first)
        {
           $first = 0;
           $found = 1;
           print("Please examine the albums listed below. If one of ");
           print("the track listings matches the CD that you are ");
           print("submitting, click on <b>Select Album</b> next to ");
           print("the matching album. If none of the listed albums ");
           print("match, click on <b>Album not listed</b>:<br>");
        }

        print $o->start_form(-action=>'found.pl');
        print "<table width=100%><tr><td><b>";
        print $o->escapeHTML($albumname);
        print "<b></td><td align=right>";
        print $o->p,$o->submit('Select Album>>');
        print "</td></tr></table>";

        print "<p><table><tr><td></td><td>Track No:</td>";
        print "<td>Track Title</td></tr>\n";

        while(defined @ids_tracks_seqs)
        {
            shift @ids_tracks_seqs;
            $name = shift @ids_tracks_seqs;
            $seq = shift @ids_tracks_seqs;
            print "<tr><td>&nbsp;&nbsp;</td><td align=center>";
            print $seq + 1;
            print "</td><td>";
            print $o->escapeHTML($name);
            print "</td></tr>\n";
        }
        print '</table><p>';

        print $o->hidden(-name=>'id',-default=>'$id');
        print $o->hidden(-name=>'album',-default=>"$albumid");
        print $o->hidden(-name=>'toc',-default=>$o->param('toc'));
        print $o->end_form;
    }
    else
    {
        $unused{"$albumname"}=scalar(@ids_tracks_seqs) / 3;
    }
}

if (scalar(keys(%unused)) > 0)
{
    print("The following albums in the CD Index are not applicable ");
    print("because they have a different number of tracks than ");
    print("than the album you are submitting:<p>");
    foreach $i (keys(%unused))
    {
        print "Album <b>";
        print $o->escapeHTML($i);
        print "</b> has " . $unused{"$i"} . " tracks.<br>";
    }
    print("<p>Even though there may be an album listed with the same ");
    print("name as you are submitting, there sometimes are different ");
    print("editions of the same album that have a different number ");
    print("of tracks.");
}

if (!$found) 
{
    print("There were no albums with $tracks tracks found. Please click ");
    print("on <b>Album not listed</b>:");
}

print $o->start_form(-action=>'enter.pl');
print $o->p,$o->submit('Album not listed>>');
print $o->hidden(-name=>'id',-default=>'$id');
print $o->hidden(-name=>'tracks',-default=>'$tracks');
print $o->hidden(-name=>'toc',-default=>$o->param('toc'));
print $o->hidden(-name=>'artist',-default=>$o->param('artist'));
print $o->end_form;

$cd->Logout;
$cd->Footer;  
