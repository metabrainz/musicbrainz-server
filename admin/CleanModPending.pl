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

use lib "../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;
use Moderation;

my $count = 0;

sub Clean
{
   my ($dbh, $al) = @_;
   my ($sth, @row, $guid, $id, $sth2, @row2);

   $dbh->do("update Artist set modpending = 0");
   $dbh->do("update Album set modpending = 0");
   $dbh->do("update AlbumJoin set modpending = 0");
   $dbh->do("update Track set modpending = 0");
   $dbh->do("update Genre set modpending = 0");
   $sth = $dbh->prepare("select rowid, tab from Changes where status = " .
                        Moderation::STATUS_OPEN);
   if ($sth->execute && $sth->rows > 0)
   {
       while(@row = $sth->fetchrow_array)
       {
          $dbh->do("update $row[1] set modpending = modpending + 1 where id = $row[0]");
          $count++;
       }
   }
   $sth->finish;
}

$mb = MusicBrainz->new;
$mb->Login;
$al = Album->new($mb);

print "Connected to database.\n";

Clean($mb->{DBH}, $al);

print "Set $count modpending indicators.\n";

# Disconnect
$mb->Logout;
