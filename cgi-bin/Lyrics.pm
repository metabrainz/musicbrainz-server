#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 2000 Robert Kaye
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
                                                                               
package Lyrics;

use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub GetLyricId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $rv = -1;

   $sth = $this->{DBH}->prepare("select Id from SyncLyrics where track=$id");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   $sth->finish;

   return $rv;
}

sub InsertLyrics
{
    my ($this, $trackid, $type, $url, $contrib) = @_;
    my ($id);

    $id = GetLyricId($this, $trackid);
    if ($id < 0)
    {
         $url = $this->{DBH}->quote($url);
         $contrib = $this->{DBH}->quote($contrib);
         $this->{DBH}->do("insert into SyncLyrics (track, type, url, submittor, submitted) values ($trackid, $type, $url, $contrib, now())");

         $id = $this->GetLastInsertId;
    } 
    return $id;
}

sub InsertSyncEvent
{
    my ($this, $lyricid, $ts, $text) = @_;
    my ($id);

    $text = $this->{DBH}->quote($text);
    $this->{DBH}->do("insert into SyncEvent (synctext, ts, text) values ($lyricid, $ts, $text)");

    $id = $this->GetLastInsertId;
    return $id;
}

1;
