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
                                                                               
package Pending;
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

sub GetIdsFromGUID
{
    my ($this, $guid) = @_;
    my ($sql);

    $sql = Sql->new($this->{DBH});
    return $sql->GetSingleColumn("Pending", "id", ["guid", $sql->Quote($guid)]);
}

sub GetData
{
    my ($this, $id) = @_;
    my ($sql, @row);

    $sql = Sql->new($this->{DBH});
    return $sql->GetSingleRow("Pending", [qw(name guid artist album sequence 
                           length  year  genre  filename  comment)],
                           ["id", $id]);
}

sub DeleteByGUID
{
    my ($this, $guid) = @_;
    
    my $sql = Sql->new($this->{DBH});
    $sql->Do("delete from Pending where guid=" . $sql->Quote($guid));
}

sub Insert
{
    my ($this, $name, $guid, $artist, $album, $seq, $length, $year,
        $genre, $filename, $comment) = @_;
    my (@ids, $id, $sql);

    $sql = Sql->new($this->{DBH});
    @ids = GetIdsFromGUID($this, $guid);
    if (!defined $ids[0])
    {
         $name = $sql->Quote($name);
         $guid = $sql->Quote($guid);
         $artist = $sql->Quote($artist);
         $album = $sql->Quote($album);
         $genre = $sql->Quote($genre);
         $filename = $sql->Quote($filename);
         $comment = $sql->Quote($comment);
         $sql = Sql->new($this->{DBH});
         $sql->Do("insert into Pending (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");
         $sql->Do("insert into PendingArchive (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");

         $id = $sql->GetLastInsertId;
    } 
    return $id;
}

sub GetPendingList
{
   my ($this, $offset, $max_items, $guid, $archive) = @_;
   my ($sth, $num_pending, @info, $sql, $query); 

   $sql = Sql->new($this->{DBH});
   $guid = $sql->Quote($guid);

   $archive = (defined $archive && $archive) ? "Archive" : "";
   if (!defined $guid || $guid eq '')
   {
       ($num_pending) = $sql->GetSingleRow("Pending$archive", 
                                           ["count(*)"], []);
                    
       $query = qq/select guid, artist, album, name,
                   sequence, length, genre from Pending$archive order by artist 
                   limit $offset, $max_items/;
   }
   else
   {
       ($num_pending) = $sql->GetSingleRow("Pending$archive", 
                                           ["count(*)"], 
                                           ["guid", $guid]);

       $query = qq/select guid, artist, album, name,
                   sequence, length, genre from Pending$archive where 
                   guid = $guid order by artist limit $offset, $max_items/;
   }

   if ($sql->Select($query))
   {
       my @row;

       for(;@row = $sql->NextRow();)
       {
           push @info, [@row];
       }
       $sql->Finish;   
   }

   return ($num_pending, @info);
}
