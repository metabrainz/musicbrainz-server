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
                                                                               
package Genre;
use TableBase;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

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

sub GetGenreId
{
   my ($this, $genrename) = @_;
   my ($sth, $rv);

   $genrename = $this->{DBH}->quote($genrename);
   $sth = $this->{DBH}->prepare("select id from Genre where name=$genrename");
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

sub InsertGenre
{
    my ($this, $name, $desc) = @_;
    my ($genre, $id);

    $genre = GetGenreId($this, $name);
    if ($genre < 0)
    {
         $name = $this->{DBH}->quote($name);
         $desc = $this->{DBH}->quote($desc);
         $this->{DBH}->do("insert into Genre (name, description) values ($name, $desc)");

         $genre = $this->GetLastInsertId;
    } 
    return $genre;
}

1;
