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
    return $sql->GetSingleRow("Pending", [qw(Name Artist Album Sequence GUID 
         Filename Year Genre Comment Bitprint First20 Length AudioSha1 
         Duration Samplerate Bitrate Stereo VBR)], ["id", $id]);
}

sub DeleteByGUID
{
    my ($this, $guid) = @_;
    
    my $sql = Sql->new($this->{DBH});
    $sql->Do("delete from Pending where guid=" . $sql->Quote($guid));
}

sub Insert
{
    my ($this, @data) = @_;
    my (@ids, $id, $sql, $query);

    $sql = Sql->new($this->{DBH});
    @ids = GetIdsFromGUID($this, $data[4]);
    if (!defined $ids[0])
    {
         $sql = Sql->new($this->{DBH});
         $data[0] = $sql->Quote($data[0]);
         $data[1] = $sql->Quote($data[1]);
         $data[2] = $sql->Quote($data[2]);
         $data[4] = $sql->Quote($data[4]);
         $data[5] = $sql->Quote($data[5]);
         $data[6] = $sql->Quote($data[6]);
         $data[7] = $sql->Quote($data[7]);
         $data[8] = $sql->Quote($data[8]);
         $data[9] = $sql->Quote($data[9]);
         $data[10] = $sql->Quote($data[10]);
         $data[12] = $sql->Quote($data[12]);

         $query = "insert into Pending (Name, Artist, Album, Sequence, GUID, Filename, Year, Genre, Comment, Bitprint, First20, Length, AudioSha1, Duration, Samplerate, Bitrate, Stereo, VBR) values (";
         $query .= join ", ", @data;
         $query .= ")";
         $sql->Do($query);
         $id = $sql->GetLastInsertId;
    } 
    return $id;
}

sub GetPendingList
{
   my ($this, $offset, $max_items, $guid) = @_;
   my ($sth, $num_pending, @info, $sql, $query); 

   $sql = Sql->new($this->{DBH});
   $guid = $sql->Quote($guid);

   if (!defined $guid || $guid eq '')
   {
       ($num_pending) = $sql->GetSingleRow("Pending", 
                                           ["count(*)"], []);
                    
       $query = qq/select guid, artist, album, name,
                   sequence, length, genre from Pending order by artist 
                   limit $offset, $max_items/;
   }
   else
   {
       ($num_pending) = $sql->GetSingleRow("Pending", 
                                           ["count(*)"], 
                                           ["guid", $guid]);

       $query = qq/select guid, artist, album, name,
                   sequence, length, genre from Pending where 
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
