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
use strict;
use DBI;
use DBDefs;     
use MusicBrainz;

my ($o, $cd, $num_tracks, $i); 

$cd = new MusicBrainz;
$o = $cd->GetCGI;

$cd->Header('Found CD');
$cd->CheckArgs('id', 'toc', 'album');  

my $id = $o->param('id');
my $album = $o->param('album');
my $toc = $o->param('toc');

$cd->Login();
$cd->InsertDiskId($id, $album, $toc);
 
print "Thank you for your submission. ",$o->p;
print "A new association has been entered into the database. You will ";
print "now be able to request the information for this CD.";

$cd->Logout;
$cd->Footer;   
