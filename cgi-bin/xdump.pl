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
use QuerySupport;

my $o; 
my ($dbh, $sth);

$o = new CGI;

#print("Content-type: text/plain\n\n");

$dbh = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
if (!$dbh)
{
    print "Sorry, the database is currently\n";
    print "not available. Please try again in a few minutes.\n";
    print "(Error: ".$DBI::errstr.")";
} 
else
{
    my $i;

    $sth = $dbh->prepare("select id from Album");
    $sth->execute;
    my @row;

    while(@row = $sth->fetchrow_array)
    {
         print QuerySupport::GenerateCDInfoObjectFromAlbumId($dbh, $row[0], 0);
    }
    $sth->finish;

    print "\n\n";
}

if ($dbh)
{
    $dbh->disconnect();
}
