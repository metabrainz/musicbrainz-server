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
use QuerySupport;
use MusicBrainz;

my $o; 
my ($diskid, $id);
my ($cd);

$cd = new MusicBrainz;
$o = $cd->GetCGI;   

print("Content-type: text/plain\n\n");

if (!defined $o->param('id') && !defined $o->param('albumid')) 
{
print <<END;

    Error:
    You must specify the 'id' or 'albumid' arguments as part of the 
    URL for this page.
END
    exit;
}

if (! $cd->Login(1))
{
    print "Cannot access the database.";
    exit(0);
}

if (defined $o->param('id'))
{
   $id = $o->param('id');

   $diskid = $cd->GetAlbumFromDiskId($id);
   if ($diskid)
   {
       print "That CD was not found.";
   }
   else
   {
       print QuerySupport::GenerateCDInfoObjectFromAlbumId($cd, $diskid, 0, $o);
   }
}
else
{
   if ($o->param('albumid') ne '')
   {
       print QuerySupport::GenerateCDInfoObjectFromAlbumId($cd, 
                                    $o->param('albumid'), 0, $o);
   }
   print "\n\n";
}

$cd->Logout;
