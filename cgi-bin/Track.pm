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
                                                                               
package Track;
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

my $load_columns =  qq/Track.id, Track.name, Track.artist, 
                       AlbumJoin.sequence, Track.length, 
                       Track.year, Track.genre, Track.filename, 
                       Track.comment, Track.modpending/;

sub GetIdFromNameAlbumAndSeq
{
   my ($this, $name, $album, $seq) = @_;
   my ($sth, $rv);

   return -1 if (!defined $name || !defined $album || !defined $seq);

   $name = $this->{DBH}->quote($name);
   $sth = $this->{DBH}->prepare(qq/select Track.id from Track, AlbumJoin 
                                   where name=$name and AlbumJoin.track = 
                                   Track.id and AlbumJoin.album = $album and 
                                   AlbumJoin.sequence=$seq/);
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

sub GetTracksFromAlbumId
{
   my ($this, $albumid) = @_;
   my (@info, $sth, $ref, $track);

   $sth = $this->{DBH}->prepare(qq/select $load_columns from 
                         Track, AlbumJoin where AlbumJoin.track = Track.id
                         and AlbumJoin.album = $albumid order by 
                         AlbumJoin.sequence/);
   if ($sth->execute())
   {
       for(;$ref = $sth->fetchrow_arrayref;)
       {  
           $track = new Track;
           $track->{data} = [@$ref];
           push @info, $track;
       }
   }
   $sth->finish;

   return @info;
}

sub GetTracksFromMultipleArtistAlbumId
{
   my ($this, $albumid) = @_;
   my (@info, $sth, $ref, $track);

   $sth = $this->{DBH}->prepare(qq/select $load_columns, Artist.name from 
                Track, AlbumJoin, Artist where AlbumJoin.track = Track.id 
                and AlbumJoin.album = $albumid and Track.Artist = Artist.id 
                order by AlbumJoin.sequence/);
   if ($sth->execute())
   {
       my @row;
       my $i;

       for(;$ref = $sth->fetchrow_arrayref;)
       {  
           $track = new Track;
           $track->{data} = [@$ref];
           push @info, $track;
       }
   }
   $sth->finish;

   return @info;
}

sub LoadFromId
{
   my ($this, $trackid) = @_;
   my ($sth, $ok);

   $ok = 0;
   $sth = $this->{DBH}->prepare(qq/select $load_columns from Track 
                                   where id=$trackid/);
   $sth->execute;
   if ($sth->rows)
   {
        $this->{data} = $sth->fetchrow_arrayref;
        $ok = 1;
   }
   $sth->finish;

   return $ok;
}

sub SearchByName
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select Track.id, Track.Name, 
                  Album.id, Album.name, Artist.id, Artist.name from Track, 
                  AlbumJoin, Album, Artist where Track.artist = Artist.id and 
                  AlbumJoin.track = Track.id and AlbumJoin.album = Album.id 
                  and /, "Track.Name") .  " order by Track.name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3], $row[4], $row[5]];
       }
   }
   $sth->finish;

   return @info;
};

sub Insert
{
    my ($this, $name, $artist, $album, $seq, $length, $year, $genre, 
        $filename, $comment) = @_;
    my ($track, $id, $query, $values);

    $track = GetIdFromNameAlbumAndSeq($this, $name, $album, $seq);
    if ($track < 0)
    {
        $name = $this->{DBH}->quote($name);
        $id = $this->{DBH}->quote(($this->CreateNewGlobalId()));
        $query = "insert into Track (name,gid,artist,modpending";
        $values = "values ($name, $id, $artist, 0";

        if (defined $length && $length != 0)
        {
            $query .= ",length";
            $values .= ",$length";
        }
        if (defined $year && $year != 0)
        {
            $query .= ",year";
            $values .= ",$year";
        }
        if (defined $genre && $genre ne "")
        {
            $query .= ",genre";
            $values .= "," . $this->{DBH}->quote($genre);
        }
        if (defined $filename && $filename ne '')
        {
            $query .= ",filename";
            $values .= "," . $this->{DBH}->quote($filename);
        }
        if (defined $comment && $comment ne '')
        {
            $query .= ",comment";
            $values .= "," . $this->{DBH}->quote($comment);
        }

        $this->{DBH}->do("$query) $values)");
        $track = $this->GetLastInsertId();

        $this->{DBH}->do(qq/insert into AlbumJoin (album, track, sequence) 
                            values ($album, $track, $seq)/);
    }

    return $track;
}

sub GetFromId
{
    my ($this, $id) = @_;
    my (@row, $sth, $artist, $album);

    $artist = "Unknown";
    $album = "Unknown";

    $sth = $this->{DBH}->prepare("select name, guid, artist, album, length, year, genre, filename, comment from Track where id=$id");
    $sth->execute;
    if ($sth->rows)
    {
         @row = $sth->fetchrow_array;
    }
    $sth->finish;

    $sth = $this->{DBH}->prepare("select name from Artist where id=$row[2]");
    $sth->execute;
    if ($sth->rows)
    {
         $artist = ($sth->fetchrow_array)[0];
    }
    $sth->finish;

    $sth = $this->{DBH}->prepare("select name from Album where id=$row[3]");
    $sth->execute;
    if ($sth->rows)
    {
         $album = ($sth->fetchrow_array)[0];
    }
    $sth->finish;

    return ($row[0], $row[1], $artist, $album, $seq, $row[4],
            $row[5], $row[6], $row[7]);
}

1;
