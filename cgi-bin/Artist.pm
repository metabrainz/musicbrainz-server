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
                                                                               
package Artist;

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

sub GetIdFromName
{
   my ($this, $artistname) = @_;
   my ($sth, $rv);

   $artistname = $this->{DBH}->quote($artistname);
   $sth = $this->{DBH}->prepare("select id from Artist where name=$artistname");
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

sub LoadFromId
{
   my ($this, $artistid) = @_;
   my ($sth, @row, $ok);

   $ok = 0;
   $sth = $this->{DBH}->prepare(qq/select id, name, sortname, modpending from 
                                   Artist where id=$artistid/);
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
        $ok = 1;
   }
   $sth->finish;

   return $ok;
}

sub LoadFromAlbumId
{
   my ($this, $albumid) = @_;
   my ($sth, $ok, @row);

   $ok = 0;
   $sth = $this->{DBH}->prepare(qq/select Artist.id, Artist.name, 
             Artist.sortname, Artist.modpending from Album, Artist where 
             Album.id=$albumid and Album.artist = Artist.id/);
   $sth->execute;
   if ($sth->rows)
   {
       $this->{data} = $sth->fetchrow_arrayref;
       $ok = 1
   }
   else
   {
       $sth->finish;
       $sth = $this->{DBH}->prepare(qq/select artist from Album where id =
                 $albumid/);
       $sth->execute;
       if ($sth->rows)
       {
           @row = $sth->fetchrow_array;
           if ($row[0] == 0)
           {
               $this->{data} = [0, 'Various Artists', 'Various Artists', 0];
               $ok = 1
           }
       }
   }
   $sth->finish;

   return $ok;
} 

sub SearchByName
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select id, name, sortname 
               from Artist where /, "name") . " order by sortname";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2]];
       }
   }
   $sth->finish;

   return @info;
};

sub GetArtistDisplayList
{
   my ($this, $ind, $offset, $max_items) = @_;
   my ($sth, $num_artists, @info); 

   $sth = $this->{DBH}->prepare(qq/select count(*) from Artist where 
                       left(sortname, 1) = '$ind'/);
   $sth->execute();
   $num_artists = ($sth->fetchrow_array)[0];
   $sth->finish;   

   $sth = $this->{DBH}->prepare(qq/select id, sortname, modpending from Artist 
                      where left(sortname, 1) = '$ind' order by sortname limit 
                      $offset, $max_items/);
   $sth->execute();  
   if ($sth->rows > 0)
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {
           push @info, [$row[0], $row[1], $row[2]];
       }
   }
   $sth->finish;   

   return ($num_artists, @info);
}

sub Insert
{
    my ($this, $name, $sortname) = @_;
    my ($artist, $id);

    $sortname = $name if (!defined $sortname);
    $artist = GetIdFromName($this, $name);
    if ($artist < 0)
    {
         $id = $this->{DBH}->quote(($this->CreateNewGlobalId()));
         $name = $this->{DBH}->quote($name);
         $sortname = $this->{DBH}->quote($sortname);
         $this->{DBH}->do(qq/insert into Artist (name, sortname, gid, 
                          modpending) values ($name, $sortname, $id, 0)/);

         $artist = $this->GetLastInsertId;
    } 
    return $artist;
}

sub GetAlbumList
{
   my ($this, $id) = @_;
   my ($sth, @idsalbums);

   $sth = $this->{DBH}->prepare(qq/select id, name, modpending from 
                                Album where artist=$id/);
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @idsalbums, $row[0];
            push @idsalbums, $row[1];
            push @idsalbums, $row[2];
        }
   }
   $sth->finish;

   return @idsalbums;
} 

sub GetMultipleArtistAlbumList
{
   my ($this, $id) = @_;
   my ($sth, @idsalbums);

   $sth = $this->{DBH}->prepare(qq/select distinct AlbumJoin.album, Album.name, 
       Album.modpending from Track, Album, AlbumJoin where Track.Artist = 
       $id and AlbumJoin.track = Track.id and AlbumJoin.album = Album.id 
       and Album.artist = 0 order by Album.name/);
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @idsalbums, $row[0];
            push @idsalbums, $row[1];
            push @idsalbums, $row[2];
        }
   }
   $sth->finish;

   return @idsalbums;
} 

sub FindArtist
{
   my ($this, $search) = @_;
   my (@names, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select name, sortname 
               from Artist where /, "name") . " order by sortname";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @names, $row[0];
           push @names, $row[1];
       }
   }
   $sth->finish;

   return @names;
};

1;
