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
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

my $load_columns = "name, guid, artist, album, sequence, length, year, genre, filename, comment";

sub GetIdsFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, @ids);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare("select id from Pending where guid=$guid");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return @ids;
}

sub GetData
{
    my ($this, $id) = @_;
    my ($sth, @row);

    $sth = $this->{DBH}->prepare("select name, guid, artist, album, sequence, length, year, genre, filename, comment from Pending where id=$id");
    $sth->execute;
    if ($sth->rows)
    {
        @row = $sth->fetchrow_array;
    }
    $sth->finish;
 
    return @row;
}

sub DeleteByGUID
{
    my ($this, $guid) = @_;

    $guid = $this->{DBH}->quote($guid);
    $this->{DBH}->do("delete from Pending where guid=$guid");
}

sub Insert
{
    my ($this, $name, $guid, $artist, $album, $seq, $length, $year,
        $genre, $filename, $comment) = @_;
    my (@ids, $id);

    @ids = GetIdsFromGUID($this, $guid);
    if (scalar(@ids) == 0)
    {
         $name = $this->{DBH}->quote($name);
         $guid = $this->{DBH}->quote($guid);
         $artist = $this->{DBH}->quote($artist);
         $album = $this->{DBH}->quote($album);
         $genre = $this->{DBH}->quote($genre);
         $filename = $this->{DBH}->quote($filename);
         $comment = $this->{DBH}->quote($comment);
         $this->{DBH}->do("insert into Pending (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");
         $this->{DBH}->do("insert into PendingArchive (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");

         $id = $this->GetLastInsertId;
    } 
    return $id;
}

sub GetPendingList
{
   my ($this, $offset, $max_items, $guid, $archive) = @_;
   my ($sth, $num_pending, @info, $sql); 

   $archive = (defined $archive && $archive) ? "Archive" : "";
   if (!defined $guid || $guid eq '')
   {
       $sth = $this->{DBH}->prepare(qq/select count(*) from Pending$archive/);
       $sth->execute();
       $num_pending = ($sth->fetchrow_array)[0];
       $sth->finish;   

       $sql = qq/select guid, artist, album, name,
                 sequence, length, genre from Pending$archive order by artist 
                 limit $offset, $max_items/;
   }
   else
   {
       $guid = $this->{DBH}->quote($guid);
       $sth = $this->{DBH}->prepare(qq/select count(*) from Pending$archive
                                       where guid=$guid/);
       $sth->execute();
       $num_pending = ($sth->fetchrow_array)[0];
       $sth->finish;   

       $sql = qq/select guid, artist, album, name,
                 sequence, length, genre from Pending$archive where 
                 guid = $guid order by artist limit $offset, $max_items/;
   }

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();  
   if ($sth->rows > 0)
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {
           push @info, [@row];
       }
   }
   $sth->finish;   

   return ($num_pending, @info);
}

1;
