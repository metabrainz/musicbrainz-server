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
                                                                               
package GUID;
use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = (TableBase);
@EXPORT = '';

use strict;
use CGI;
use DBI;
use DBDefs;

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub GetTrackIdFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, $rv);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare(qq/select track from GUIDJoin, GUID where 
                           GUID.guid=$guid and GUID.id = GUIDJoin.guid/);
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetIdFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, $rv);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare(qq/select id from GUID where guid=$guid/);
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

sub GetGUIDFromTrackId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $sth = $this->{DBH}->prepare(qq/select GUID.guid from GUIDJoin, GUID where 
                GUIDJoin.track = $id and GUIDJoin.guid = GUID.id/);
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

sub Insert
{
    my ($this, $guid, $trackid) = @_;
    my ($id);

    $id = $this->GetIdFromGUID($guid);
    if (!defined $id)
    {
        $guid = $this->{DBH}->quote($guid);
        if ($this->{DBH}->do(qq/insert into GUID (guid) values ($guid)/))
        {
            $id = $this->GetLastInsertId;
        }
    }
    if (defined $id && defined $trackid)
    {
        $this->{DBH}->do(qq/insert into GUIDJoin (guid, track) values 
                           ($id, $trackid)/);
    }
    return $id;
}
1;
