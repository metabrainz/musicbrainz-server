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

my ($o, $error, $ip); 
my ($tracks, $i, $artist, $artistname, $toc);
my ($title, $album, $singleartist, $id, $cd);
my ($sth, $rv, $sql);

$cd = new MusicBrainz;  
$o = new CGI;
$cd->Header('New CD Submission Completed');

# Do a bunch of error checking

$cd->CheckArgs('id', 'tracks');
$tracks = $o->param('tracks');

$error = 0;
for($i = 0; $i < $tracks; $i++)
{
    if ($o->param("track$i") eq '')
    {
       $error = 1;
    }
    if ($o->param("artist$i") eq '')
    {
       $error = 1;
    }
}

# TODO
# Get gotta have it mark the missing fields and let the user try
# again, instead of giving them a lame 'press the back button' excuse.
if ($error)
{
print <<END;

    <FONT SIZE=+1 COLOR=RED>
    Error:
    </FONT>
    Please make sure that you fill out all the fields in the form.
    Please press the Back button in your Browser and try again.
    </TD></TR></TABLE>
END
    print $o->end_html;
    exit;
}

$cd->Login(); 

$tracks = $o->param('tracks');
$title = $o->param('title');
$id = $o->param('id');
$toc = $o->param('toc');

$album = $cd->GetAlbumId($title, 0, $tracks);
if ($album < 0)
{
    $album = $cd->InsertAlbum($title, 0);
    if ($album < 0)
    {
       print "Cannot insert a new album into the database.\n<br>";  
    }

    for($i = 0; $i < $tracks; $i++)
    {
       $artistname = $o->param("artist$i");
       $artist = $cd->InsertArtist($artistname);
       if ($artist >= 0)
       {
           $title = $o->param("track$i");
           $cd->InsertTrack($title, $artist, $album, $i);
       }
       else
       {
           printf "Cannot insert a new artist into the database.\n";
       }

    }

    $cd->InsertDiskId($id, $album, $toc);

    print "Thank you for your submission. ",$o->p;
    print "You will ";
    print "now be able to request the information for this CD.";
}
else
{
    print "That CD already exists in the CD Index. If this is ";
    print "a different CD, please vary the title of the CD slightly to indicate how";
    print " this CD is different from the existing CD.";
}

print $o->end_html;

$cd->Logout; 
$cd->Footer; 
