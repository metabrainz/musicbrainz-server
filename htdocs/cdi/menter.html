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
use MusicBrainz;

my $o; 
my ($tracks, $i, $artist, $artistname, $cd);

$o = new CGI;
$cd = new MusicBrainz;

$cd->Header('Enter CD Information');
$cd->CheckArgs('id', 'tracks');

$tracks = $o->param('tracks');

print $o->start_form(-action=>'mdone.pl'),"\n";
    
print "Please enter the CD information below:",$o->p,"\n";

print "What is the title of the CD?",$o->br,"\n";
print $o->textfield(-name=>'title',-size=>40),$o->p,"\n";

print "Please enter artist names as <br>'Last, First name' or ";
print "'Beatles, The'.",$o->p,"\n";
    
for($i = 0; $i < $tracks; $i++)
{
    print "Name of Track ";
    print $i + 1;
    print ":",$o->br,"\n";
    print $o->textfield(-name=>"track$i",-size=>40),$o->br,"\n";

    print "Artist of Track ";
    print $i + 1;
    print ":",$o->br,"\n";
    print $o->textfield(-name=>"artist$i",-size=>40),$o->p,"\n";
}

print $o->hidden(-name=>'id', -default=>"$o->param('id')"),"\n";
print $o->hidden(-name=>'tracks', -default=>"$o->param('tracks')"),"\n";
print $o->hidden(-name=>'toc',-default=>$o->param('toc'));
print $o->p,$o->submit('Next >>'),"\n";
    
print $o->end_form,"\n";

$cd->Footer;
