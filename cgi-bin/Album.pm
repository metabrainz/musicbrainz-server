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
                                                                               
package Album;
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

sub FindFromNameAndArtistId
{
   my ($this, $albumname, $artist) = @_;
   my ($sth, @ids);

   $albumname = $this->{DBH}->quote($albumname);
   $sth = $this->{DBH}->prepare(qq/select id from Album where 
                         name=$albumname and artist = $artist/);
   $sth->execute;
   if ($sth->rows)
   {
       my (@row);

       while(@row = $sth->fetchrow_array)
       {
           push @ids, $row[0];
       }
   }
   $sth->finish;

   return @ids;
}

sub GetTrackCountFromAlbum
{
   my ($this, $albumid) = @_;
   my ($sth, $count);

   $sth = $this->{DBH}->prepare(qq/select count(*) from AlbumJoin where 
                                   album=$albumid/);
   $sth->execute;
   if ($sth->rows)
   {
       my (@row, @row2);

       $count = ($sth->fetchrow_array)[0];
   }
   $sth->finish;

   return $count;
}

sub GetIdFromTrackId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $id = $this->{DBH}->quote($id);
   $sth = $this->{DBH}->prepare("select album from AlbumJoin where track=$id");
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

sub GetIdFromAlbumJoinId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $id = $this->{DBH}->quote($id);
   $sth = $this->{DBH}->prepare("select album from AlbumJoin where id=$id");
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

sub LoadFromId
{
   my ($this, $albumid) = @_;
   my ($sth, @row);

   $sth = $this->{DBH}->prepare(qq/select id, name, modpending from 
                                Album where id=$albumid/);
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
   }
   $sth->finish;

   return @row;
}

sub SearchByName
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select Album.id, Album.name,
               Artist.name, Artist.id from Album,Artist where Album.artist = 
               Artist.id and /, "Album.Name") . " order by Album.name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3]];
       }
   }
   $sth->finish;

   $sql = $this->AppendWhereClause($search, "select id, name " .
           "from Album where artist = 0 and ", "Name");
    $sql .= " order by name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], 'Various Artists', 0];
       }
   }
   $sth->finish;

   return @info;
};

sub Insert
{
    my ($this, $name, $artist) = @_;
    my ($album, $id);

    $id = $this->{DBH}->quote(($this->CreateNewGlobalId()));
    $name = $this->{DBH}->quote($name);
    $this->{DBH}->do(qq/insert into Album (name,artist,gid,modpending) 
                        values ($name,$artist, $id, 0)/);

    return $this->GetLastInsertId;
}

1;
