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

sub GetLyricsFromTrackId
{
   my ($this, $trackid) = @_;
   my ($sth, @row);

   $sth = $this->{DBH}->prepare("select Text, Writer from Lyrics where Track=$trackid");
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
   }
   $sth->finish;
 
   return @row;
}

sub GetLyricsIdFromTrackId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $rv = -1;

   $sth = $this->{DBH}->prepare("select Id from Lyrics where Track=$id");
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

sub GetSyncTextId
{
   my ($this, $id, $type, $contrib) = @_;
   my ($sth, $rv);

   $rv = -1;

   $contrib = $this->{DBH}->quote($contrib);
   $sth = $this->{DBH}->prepare("select Id from SyncText where track=$id and type=$type and submittor=$contrib");
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

sub GetSyncTextList
{
   my ($this, $id) = @_;
   my ($sth, @ids);

   $sth = $this->{DBH}->prepare("select Id from SyncText where track=$id");
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

sub GetSyncTextData
{
    my ($this, $id) = @_;
    my (@row, $sth);

    $sth = $this->{DBH}->prepare("select track, type, url, submittor, submitted, id from SyncText where id = $id");
    $sth->execute;
    if ($sth->rows)
    {
         @row = $sth->fetchrow_array;
    }
    $sth->finish;
 
    return @row;
}

sub GetSyncEventList
{
   my ($this, $lyricid) = @_;
   my ($sth, @ids_ts_text);

   $sth = $this->{DBH}->prepare("select id, ts, text from SyncEvent " .
                                "where synctext=$lyricid order by ts");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @ids_ts_text, $row[0];
            push @ids_ts_text, $row[1];
            push @ids_ts_text, $row[2];
        }
   }
   $sth->finish;

   return @ids_ts_text;
}

sub InsertLyrics
{
    my ($this, $trackid, $lines, $writer) = @_;
    my ($id);

    $id = GetLyricsId($this, $trackid);
    if ($id < 0)
    {
         $lines = $this->{DBH}->quote($lines);
         $writer = $this->{DBH}->quote($writer);
         $this->{DBH}->do("insert into Lyrics (track, text, writer) values 
                            ($trackid, $lines, $writer)");

         $id = $this->GetLastInsertId($this);
    } 
    return $id;
}

sub InsertSyncText
{
    my ($this, $trackid, $type, $url, $contrib) = @_;
    my ($id);

    $id = GetSyncTextId($this, $trackid, $type, $contrib);
    if ($id < 0)
    {
         $url = $this->{DBH}->quote($url);				#Even the lookup is now done safely
         $contrib = $this->{DBH}->quote($contrib);
         $this->{DBH}->do("insert into SyncText (track, type, url, submittor, submitted) values ($trackid, $type, $url, $contrib, now())");

         $id = $this->GetLastInsertId($this);
    } 
    return $id;
}

sub InsertSyncEvent
{
    my ($this, $lyricid, $ts, $text) = @_;
    my ($id);

    $text = $this->{DBH}->quote($text);
    $this->{DBH}->do("insert into SyncEvent (synctext, ts, text) values ($lyricid, $ts, $text)");

    $id = $this->GetLastInsertId($this);
    return $id;
}

1;
