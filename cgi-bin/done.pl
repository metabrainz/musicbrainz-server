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

my ($o, $cd, $error); 
my ($tracks, $i, $artist, $artistname);
my ($toc, $title, $album, $singleartist, $id);
my ($sth, $rv);

$cd = new MusicBrainz;
$o = $cd->GetCGI;
$cd->Header('New CD Submission Completed');
$cd->CheckArgs('id', 'tracks', 'toc'); 

# Do a bunch of error checking
$tracks = $o->param('tracks');

$error = 0;
if ((!defined $o->param('artist') && !defined $o->param('artistname')) ||
    !defined $o->param('title'))
{
   $error = 1;
}

for($i = 0; $i < $tracks; $i++)
{
    if (!defined $o->param("track$i"))
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
$singleartist = $o->param('singleartist');
$artistname = $o->param('artistname');
$artist = $o->param('artist');
$title = $o->param('title');
$id = $o->param('id');

if (defined $artistname)
{
    $artist = $cd->InsertArtist($artistname);
    if ($artist < 0)
    {
        print "Failed to insert a new artist into the database.<br>";
    }
}

if ($artist >= 0)
{
    if ($cd->GetAlbumId($title, $artist, $tracks) < 0)
    {
        $album = $cd->InsertAlbum($title, $artist, $tracks);
        if ($album < 0)
        {
            print "Failed to insert a new album into the database.<br>";
        }
        else
        {
           for($i = 0; $i < $tracks; $i++)
           {
               $cd->InsertTrack($o->param("track$i"), $artist,
                                    $album, $i);
           }

           $cd->InsertDiskId($id, $album, $o->param('toc'));
           $cd->InsertTOC($id, $album, $o->param('toc'));
    
           print "Thank you for your submission. ",$o->p;
           print "You will ";
           print "now be able to request the information for this CD.";
        }
     }
     else
     {
         print "That CD already exists in the CD Index. <p>If this is ";
         print "a different CD, please vary the title of the CD slightly ";
         print "to indicate how this CD is different from the existing CD.";
     }
}

$cd->Logout;
$cd->Footer;  
