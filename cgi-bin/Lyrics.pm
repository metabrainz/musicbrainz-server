#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye, Johan Pouwelse
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

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use DBI;
use DBDefs;
use Sql;

sub new
{
   my ($type, $mb) = @_;

   my $this = TableBase->new($mb);
   return bless $this, $type;
}

sub GetLyricsFromTrackId
{
   my ($this, $trackid) = @_;
   my ($sql, @row);

   $sql = Sql->new($this->{DBH});
   $trackid = $sql->Quote($trackid);
   return $sql->GetSingleRow("Lyrics", [qw(Text Writer)], ["Track", $trackid]);
}

sub GetLyricsIdFromTrackId
{
   my ($this, $id) = @_;
   my ($sql, $rv);

   $sql = Sql->new($this->{DBH});
   $id = $sql->Quote($id);
   ($rv) = $sql->GetSingleRow("Lyrics", ["Id"], ["Track", $id]);

   return $rv;
}

sub GetSyncTextId
{
   my ($this, $id, $type, $contrib) = @_;
   my ($sth, $rv, @row, $sql);

   $sql = Sql->new($this->{DBH});
   $type = $sql->Quote($type);
   $contrib = $sql->Quote($contrib);
   if ($sql->GetSingleRow("SyncText", ["Id"], ["track", $id, "type", $type,
                                               "submittor", $contrib]))
   {
        @row = $sql->NextRow();
        $rv = $row[0];
   }

   return $rv;
}

sub GetSyncTextList
{
   my ($this, $id) = @_;
   my ($sql, @ids);

   $sql = Sql->new($this->{DBH});
   return $sql->GetSingleColumn("SyncText", "Id", ["track", $id]);
}

sub GetSyncTextData
{
    my ($this, $id) = @_;
    my ($sql);

    $sql = Sql->new($this->{DBH});
    return $sql->GetSingleRow("SyncText", [qw(track type url submittor 
                              submitted id)], ["id", $id]);
}

sub GetSyncEventList
{
   my ($this, $lyricid) = @_;
   my ($sql, @ids_ts_text);

   $sql = Sql->new($this->{DBH});
   if ($sql->Select("select id, ts, text from SyncEvent " .
                    "where synctext=$lyricid order by ts"))
   {
        my @row;

        while(@row = $sql->NextRow())
        {
            push @ids_ts_text, $row[0];
            push @ids_ts_text, $row[1];
            push @ids_ts_text, $row[2];
        }
        $sql->Finish;
   }

   return @ids_ts_text;
}

sub InsertLyrics
{
    my ($this, $trackid, $lines, $writer) = @_;
    my ($id, $sql);

    $sql = Sql->new($this->{DBH});
    $id = GetLyricsIdFromTrackId($this, $trackid);
    if (!defined $id)
    {
         $lines = $sql->Quote($lines);
         $writer = $sql->Quote($writer);
         $sql->Do("insert into Lyrics (track, text, writer) values 
                   ($trackid, $lines, $writer)");

         $id = $sql->GetLastInsertId("Lyrics");
    } 
    return $id;
}

sub InsertSyncText
{
    my ($this, $trackid, $type, $url, $contrib) = @_;
    my ($id, $sql);

    $sql = Sql->new($this->{DBH});
    $id = GetSyncTextId($this, $trackid, $type, $contrib);
    if (!defined $id)
    {
         $url = $sql->Quote($url);
         #Even the lookup is now done safely
         $contrib = $sql->Quote($contrib);
         $sql->Do("insert into SyncText (track, type, url, submittor, submitted) values ($trackid, $type, $url, $contrib, now())");

         $id = $sql->GetLastInsertId("SyncText");
    } 
    return $id;
}

sub InsertSyncEvent
{
    my ($this, $lyricid, $ts, $text) = @_;
    my ($id, $sql);

    $sql = Sql->new($this->{DBH});
    $text = $sql->Quote($text);
    $sql->Do("insert into SyncEvent (synctext, ts, text) values ($lyricid, $ts, $text)");
    $id = $sql->GetLastInsertId("SyncEvent");

    return $id;
}

1;
