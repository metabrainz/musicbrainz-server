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
use DBI;
use DBDefs;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

sub GetGenreId
{
   my ($this, $genrename) = @_;
   my ($sql, $rv);

   $sql = Sql->new($this->{DBH});
   $genrename = $sql->Quote($genrename);
   if ($sql->Select("select id from Genre where name=$genrename"))
   {
        my @row;

        @row = $sql->NextRow();
        $rv = $row[0];
        $sql->Finish;
   }

   return $rv;
}

sub InsertGenre
{
    my ($this, $name, $desc) = @_;
    my ($genre, $id, $sql);

    $sql = Sql->new($this->{DBH});
    $genre = GetGenreId($this, $name);
    if (!defined $genre)
    {
         $name = $sql->Quote($name);
         $desc = $sql->Quote($desc);
         $sql->Do("insert into Genre (name, description) values ($name, $desc)");

         $genre = $sql->GetLastInsertId;
    } 
    return $genre;
}

1;
