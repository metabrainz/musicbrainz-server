#____________________________________________________________________________
#
#   MusicBrainz -- the internet music database
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
                                                                               
package QuerySupport;

use strict;
use XML::Parser;
use XML::DOM;
use XML::XQL;
use RDFOutput;
use DBDefs;
use Unicode::String;
use TableBase;
use MusicBrainz;
use UserStuff;
use Album;
use Diskid;
use TableBase;
use Artist;
use Genre;
use Pending;
use Track;
use Lyrics;
use UserStuff;
use Moderation;
use GUID;  
use FreeDB;  

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

my %LyricTypes =
(
   unknown        => 0,
   lyrics         => 1,
   artistinfo     => 2,
   albuminfo      => 3,
   trackinfo      => 4,
   funny          => 5
);

# This reverse table is a hack -- I'm running out of time!
my %TypesLyric =
(
   0 => "unknown",
   1 => "lyrics",
   2 => "artistinfo",
   3 => "albuminfo",
   4 => "trackinfo",
   5 => "funny"
);

sub SolveXQL
{
    my ($doc, $xql) = @_;
    my ($data, $node, @result);

    @result = XML::XQL::solve ($xql, $doc);
    $node = $result[0];

    if (defined $node)
    {
        if ($node->getNodeType == XML::DOM::ELEMENT_NODE)
        {
            $data = $node->getFirstChild->getData
                if (defined $node->getFirstChild);
        }
        elsif ($node->getNodeType == XML::DOM::ATTRIBUTE_NODE)
        {
            $data = $node->getValue
                if (defined $node->getNodeType);
        }
    }

    if (defined $data)
    {
       my $u;
       $u = Unicode::String::utf8($data);
       $data = $u->latin1;
    }

    return $data;
}

sub GenerateCDInfoObjectFromDiskId
{
   my ($dbh, $doc, $rdf, $id, $numtracks, $toc) = @_;
   my ($sql, @row, $album, $di);

   return $rdf->EmitErrorRDF("No DiskId given.") if (!defined $id);

   # Check to see if the album is in the main database
   $di = Diskid->new($dbh);
   return $di->GenerateAlbumFromDiskId($doc, $rdf, $id, $numtracks, $toc);
}

sub AssociateCDFromAlbumId
{
   my ($dbh, $doc, $rdf, $diskid, $toc, $albumid) = @_;

   my $di = Diskid->new($dbh);
   $di->InsertDiskId($diskid, $albumid, $toc);
}

# returns artistList
sub FindArtistByName
{
   my ($dbh, $doc, $rdf, $search) = @_;
   my ($sql, $query, @row, @ids, $tb);

   return $rdf->EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $dbh);

   $tb = TableBase->new($dbh);
   $query = $tb->AppendWhereClause($search, "select id from Artist where ", 
                                 "Name");
   $query .= " order by name";

   $sql = Sql->new($dbh);
   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow())
        {
            push @ids, $row[0];
        }
        $sql->Finish;
   }

   return $rdf->CreateArtistList($doc, @ids);
}

# returns an albumList
sub FindAlbumsByArtistName
{
   my ($dbh, $doc, $rdf, $search) = @_;
   my ($query, $sql, @row, @ids);

   return $rdf->EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $dbh);

   # This query finds single artist albums
   my $tb = TableBase->new($dbh);
   $query = $tb->AppendWhereClause($search, qq/select Album.id from Album, 
                  Artist where Album.artist = Artist.id and /, "Artist.Name");
   $query .= " order by Album.name";

   $sql = Sql->new($dbh);
   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow())
        {
            push @ids, $row[0];
        }
        $sql->Finish;
   }

   # This query finds multiple artist albums
   $query = $tb->AppendWhereClause($search, qq/select Album.id from Album, 
          Artist,Track,AlbumJoin where Album.artist = / . 
          Artist::VARTIST_ID . qq/ and Track.Artist = 
          Artist.id and AlbumJoin.track = Track.id and AlbumJoin.album = 
          Album.id and Artist.name and /, "Artist.name");
   $query .= " order by Album.name";

   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow())
        {
            push @ids, $row[0];
        }
        $sql->Finish;
   }

   return $rdf->CreateAlbumList(@ids);
}

# returns albumList
sub FindAlbumByName
{
   my ($dbh, $doc, $rdf, $search, $artist) = @_;
   my ($sql, $query, @row, @ids);

   return $rdf->EmitErrorRDF("No album search criteria given.") 
      if (!defined $search && !defined $artist);
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   my $tb = TableBase->new($dbh);
   if (defined $artist && $artist ne '')
   {
       $artist = $sql->Quote($artist);
       if (defined $search)
       {
           $query = $tb->AppendWhereClause($search, "select Album.id from Album, Artist where Artist.name = $artist and Artist.id = Album.artist and " , "Album.Name");
       }
       else
       {
           $query = "select Album.id from Album, Artist where ".
                  "Album.artist=Artist.id and Artist.name = $artist";
       }
   }
   else
   {
       $query = $tb->AppendWhereClause($search, "select Album.id from Album, Artist where Album.artist = Artist.id and ", "Album.Name");
   }

   $query .= " order by Album.name";   

   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow())
        {
            push @ids, $row[0];
        }
        $sql->Finish;
   }

   return $rdf->CreateAlbumList(@ids);
}

# returns trackList
sub FindTrackByName
{
   my ($dbh, $doc, $rdf, $search, $album, $artist) = @_;
   my ($query, $sql, @row, $count, @ids);

   return $rdf->EmitErrorRDF("No track search criteria given.") 
      if (!defined $search && !defined $artist && !defined $album);
   return undef if (!defined $dbh);

   my $tb = TableBase->new($dbh);
   if (defined $search)
   {
       if (!defined $album && !defined $artist)
       {
           $query = $tb->AppendWhereClause($search,
             qq/select Track.id from Track, Album, Artist, AlbumJoin where 
                Track.artist = Artist.id and AlbumJoin.track = Track.id 
                and AlbumJoin.album = Album.id and /,
                "Track.Name") .  " order by Track.name";
       }
       else
       {
           if (defined $artist  && !defined $album)
           {
               $artist = $sql->Quote($artist);
               $query = $tb->AppendWhereClause($search,
                 qq/select Track.id from Track, Album, Artist, AlbumJoin 
                    where Track.artist = Artist.id and AlbumJoin.track = 
                    Track.id and AlbumJoin.album = Album.id and Artist.name = 
                    $artist and /, "Track.Name") . " order by Track.name";

           }
           else
           {
               $album = $sql->Quote($album);
               $query = $tb->AppendWhereClause($search,
                 qq/select Track.id from Track, Album, Artist, AlbumJoin
                 where Track.artist = Artist.id and AlbumJoin.track = 
                 Track.id and AlbumJoin.album = Album.id and Album.name = 
                 $album and /, "Track.Name") .  " order by Track.name";
           }
       }
   }
   else
   {
       if (defined $album && defined $artist)
       {
           $artist = $sql->Quote($artist);
           $album = $sql->Quote($album);
           $query = qq/select Track.id from Track, Album, Artist where 
                     Track.Artist = Artist.id and AlbumJoin.track = Track.id 
                     and AlbumJoin.album = Album.id and Album.name = $album 
                     and Artist.name = $artist/;
       }
       else
       {
           return $rdf->EmitErrorRDF("Invalid track search criteria given.") 
       }
   }

   $sql = Sql->new($dbh);
   if ($sql->Select($query))
   {
        while(@row = $sql->NextRow())
        {
            push @ids, $row[0];
        }
        $sql->Finish;
   }

   return $rdf->CreateTrackList(@ids);
}

# returns GUIDList
sub FindDistinctGUID
{
   my ($dbh, $doc, $rdf, $name, $artist) = @_;
   my ($sql, $query, @ids, @row);

   return $rdf->EmitErrorRDF("No name or artist search criteria given.")
      if (!defined $name && !define $artist);
   return undef if (!defined $dbh);

   if ((defined $name && $name ne '') && 
       (defined $artist && $artist ne '') )
   {
      $sql = Sql->new($dbh);

      # This query finds single track id by name and artist
      $name = $sql->Quote($name);
      $artist = $sql->Quote($artist);
      $query = qq/select distinct GUID.guid from Track, Artist, GUIDJoin, GUID 
                where Track.artist = Artist.id and 
                GUIDJoin.track = Track.id and
                GUID.id = GUIDJoin.guid and
                lower(Artist.name) = lower($artist) and 
                lower(Track.Name) = lower($name)/;

      if ($sql->Select($query))
      {
         for(; @row = $sql->NextRow();)
         {
             if (!defined $row[0] || $row[0] eq '')
             {
                 next;
             }
             push @ids, $row[0];
         }
         $sql->Finish;
      }
   }

   return $rdf->CreateGUIDList(@ids);
}

# returns artistList
sub GetArtistByGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, $artist);

   return $rdf->EmitErrorRDF("No artist id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);
   
   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($artist) = $sql->GetSingleRow("Artist", ["id"], ["gid", $id]);

   return $rdf->CreateArtistList($doc, $artist);
}

# returns album
sub GetAlbumByGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @row, $album);

   return $rdf->EmitErrorRDF("No album id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($album) = $sql->GetSingleRow("Album", ["id"], ["gid", $id]);

   return $rdf->CreateAlbum(0, $album);
}

# returns trackList
sub GetTrackByGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, $query, @row, @ids);

   return $rdf->EmitErrorRDF("No track id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleRow("Album, Track, AlbumJoin", 
                             ["Track.id"], 
                             ["Track.gid", $id,
                              "AlbumJoin.track", "Track.id",
                              "AlbumJoin.album", "Album.id"]);

   return $rdf->CreateTrackList(@ids);
}

# returns trackList
sub GetTrackByGUID
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @ids);

   return $rdf->EmitErrorRDF("No track id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleRow("GUID, GUIDJoin",
                             ["Track"], 
                             ["GUIDJoin.GUID", "GUID.id",
                              "GUID.GUID", $id]);

   return $rdf->CreateTrackList(@ids);
}

# returns albumList
sub GetAlbumsByArtistGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @row, @ids);

   return $rdf->EmitErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleColumn("Album, Artist", "Album.id", 
                                ["Artist.gid", $id,
                                 "Album.artist", "Artist.id"]);

   return $rdf->CreateAlbumList(@ids);
}

sub SaveBitprint
{
   my ($this, $doc, $pending_id, $filename) = @_;
   my ($bitprint, $first20, $length, $audio_sha1, $duration, $samplerate,
       $bitrate, $stereo, $vbr);
   
   $bitprint  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@bitprint');
   $first20  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@first20');
   $length  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@length');
   $audio_sha1  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@audioSha1');
   $duration  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@duration');
   $samplerate  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@sampleRate');
   $bitrate  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@bitRate');
   $stereo  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@stereo');
   $vbr  = SolveXQL($doc, 
                  '/rdf:RDF/rdf:Description/DC:Identifier@vbr');

   print STDERR "Save:\n$bitprint\n$first20\n$length\n$audio_sha1\n$duration\n";
   print STDERR "$samplerate\n$bitrate\n$stereo\n$vbr\n\n";
}

sub ExchangeMetadata
{
   my ($dbh, $doc, $rdf, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment) = @_;
   my (@ids, $id, $gu, $pe, $tr, $rv, $ar);

   if (!DBDefs::DB_READ_ONLY)
   {
       $ar = Artist->new($dbh);
       $gu = GUID->new($dbh);
       $pe = Pending->new($dbh);
       $tr = Track->new($dbh);
       # has this data been accepted into the database?
       $id = $gu->GetTrackIdFromGUID($guid);
       if (!defined $id || $id < 0)
       {
           # No it has not.
           @ids = $pe->GetIdsFromGUID($guid);
           if (!defined $ids[0])
           {
               if (defined $name && $name ne '' &&
                   defined $guid && $guid ne '' &&
                   defined $artist && $artist ne '' &&
                   defined $album && $album ne '')
               {
                   my $pending_id;

                   $pending_id = $pe->Insert($name, $guid, $artist, $album, 
                                             $seq, $len, $year, $genre, 
                                             $filename, $comment);
                   $this->SaveBitprint($doc, $pending_id, $filename);
               }
           }
           else
           {
                # Do the metadata glom
                CheckMetadata($dbh, $rdf, $pe, $name, $guid, $artist, 
                              $album, $seq, $len, $year, $genre, $filename, 
                              $comment, @ids);
           }
       }
       else
       {
           my ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
               $db_len, $db_year, $db_genre, $db_filename, $db_comment);
    
           # Yes, it has. Retrieve the data and return it
           # Fill in, don't override...
           ($db_name, $db_guid, $db_artist, $db_album, $db_seq, $db_len, 
            $db_year, $db_genre, $db_filename, $db_comment) = 
                $tr->GetMetadataFromIdAndAlbum($id, $album);
    
           $name = $db_name 
               if (!defined $name || $name eq "") && defined $db_name;
           $artist = $db_artist 
               if (!defined $artist || $artist eq "") && defined $db_artist;
           $album = $db_album 
               if (!defined $album || $album eq "") && defined $db_album;
           $seq = $db_seq 
               if (!defined $seq || $seq == 0) && defined $db_seq;
           $len = $db_len 
               if (!defined $len || $len == 0) && defined $db_len;
           $year = $db_year 
               if (!defined $year || $year == 0) && defined $db_year;
           $genre = $db_genre 
               if (!defined $genre || $genre eq "") && defined $db_genre;
       }
   }

   return $rdf->CreateMetadataExchange($name, $guid, $artist, $album, 
                                       $seq, $len , $year, $genre, $comment);
}

sub CheckMetadata
{
   my ($id, $dbh, $rdf, $pe, $artistid, $albumid);
   my ($name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment);
   my ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
       $db_len, $db_year, $db_genre, $db_filename, $db_comment);
   my ($ar, $al, $tr, $gu, $trackid);

   $dbh = shift; $rdf = shift; $pe = shift; $name = shift; $guid = shift; 
   $artist = shift; $album = shift; $seq = shift; $len = shift; $year = shift;
   $genre = shift; $filename = shift; $comment = shift;

   $ar = Artist->new($dbh);
   $al = Album->new($dbh);
   $tr = Track->new($dbh);
   $gu = GUID->new($dbh);
   for(;;)
   {
       $id = shift;
       return if !defined $id;
      
       ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
        $db_len, $db_year, $db_genre, $db_filename, $db_comment) =
         $pe->GetData($id);

       if (defined $db_name && defined $name && $name eq $db_name && 
           defined $db_artist && defined $artist && $artist eq $db_artist &&
           defined $db_album && defined $album && $album eq $db_album)
       { 
           my @albumids;

           $ar->SetName($artist);
           $ar->SetSortName($artist);
           $artistid = $ar->Insert();
           $al->SetArtist($artistid);

           @albumids = $ar->GetAlbumsByName($album);
           if (defined $albumids[0])
           {
               $albumid = $albumids[0]->GetId();
           }
           else
           {
               $al->SetName($album);
               $albumid = $al->Insert();
           }
           $al->SetId($albumid);

           $seq = 0 unless 
               defined $seq && defined $db_seq && $seq == $db_seq;
           $len = 0 unless 
               defined $len && defined $db_len && $len == $db_len;
           $year = 0 unless 
               defined $year && defined $db_year && $year == $db_year;
           $genre = undef unless 
               defined $genre && defined $db_genre && $genre eq $db_genre;
           $comment = undef unless 
               defined $comment && defined $db_comment && 
               $comment eq $db_comment;

           $tr->SetName($name);
           $tr->SetSequence($seq);
           $tr->SetLength($len);
           $trackid = $tr->Insert($al, $ar);
           if (defined $trackid)
           {
               $gu->Insert($guid, $trackid);
           }
           $pe->DeleteByGUID($guid);
           return;
       }
   }
}

sub SubmitTrack
{
   my ($dbh, $doc, $rdf, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $comment) = @_;
   my ($i, $ts, $text, $artistid, $albumid, $trackid, $type, $id);
   my ($al, $ar, $tr, $ly, $gu, @albumids);

   if (!defined $name || $name eq '' ||
       !defined $album || $album eq '' ||
       !defined $seq || $seq eq '' ||
       !defined $artist || $artist eq '')
   {
       return $rdf->EmitErrorRDF("Incomplete track information submitted.") 
   }

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->EmitErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $ar = Artist->new($dbh);
   $al = Album->new($dbh);
   $tr = Track->new($dbh);
   $ly = Lyrics->new($dbh);
   $gu = GUID->new($dbh);

   $artistid = $ar->Insert($artist, $artist);
   return $rdf->EmitErrorRDF("Cannot insert artist into database.") 
      if (!defined $artistid || $artistid < 0);

   @albumids = $al->FindFromNameAndArtistId($album, $artistid);
   if (defined @albumids && scalar(@albumids) > 0)
   {
      $albumid = $albumids[0];
   }
   else
   {
      $albumid = $al->Insert($album, $artistid, -1);
   }
   print STDERR "Insert album failed!!!!!!!!!!!\n"
      if (!defined $albumid || $albumid < 0);
   
   return $rdf->EmitErrorRDF("Cannot insert album into database.") 
      if (!defined $albumid || $albumid < 0);

   $trackid = $tr->Insert($name, $artistid, $albumid, $seq, 
                          $len, $year, $genre, $comment);
   return $rdf->EmitErrorRDF("Cannot insert track into database.") 
      if (!defined $trackid || $trackid < 0);

   if (defined $trackid && (defined $guid && $guid ne ''))
   {
       $gu->Insert($guid, $trackid);
   }

   return $rdf->CreateStatus(0);
}

# NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
# From here to the end of the file, the RDF has not been seperated out
# into the RDFOutput object. Johan, can you please take care of this?
# NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
sub SubmitSyncText
{
   my ($dbh, $doc, $rdf, $gid, $sync_contrib, $sync_type) = @_;
   my ($i, $ts, $text, $synctextid, $trackid, $type, $id);
   my ($tr, $ly, $sql);

   if (!defined $gid || $gid eq '' ||
       !defined $sync_contrib || $sync_contrib eq '' )
   {
       return $rdf->EmitErrorRDF("Incomplete synctext information submitted.") 
   }

   if (! DBDefs->USE_LYRICS) 
   {  
       return $rdf->EmitRDFError("This server does not accept lyrics.");
   }

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->EmitErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $tr = Track->new($dbh);
   $ly = Lyrics->new($dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($gid);
   ($trackid) = $sql->GetSingleRow("Track", ["id"], ["gid", $id]);
   if (!defined($trackid)) 
   {
       return $rdf->EmitErrorRDF("Unknown track id.") 
   }
   if (!defined $sync_type || !exists $LyricTypes{$sync_type}) 
   { 
       $type = 0;
   } else 
   {
       $type = $LyricTypes{$sync_type};
   }

   # only accept entry if it is not already present with same type for 
   # same person
   $id = $ly->GetSyncTextId($trackid, $type, $sync_contrib);
   if ($id < 0) 
   {
       $synctextid = $ly->InsertSyncText($trackid, $type, '', $sync_contrib);
       for($i = 0;; $i++) {
           $ts = SolveXQL($doc, "/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/rdf:Seq/rdf:li[$i]" . '/rdf:Description/MM:SyncText/@ts');
           $text = SolveXQL($doc, "/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/rdf:Seq/rdf:li[$i]/rdf:Description/MM:SyncText");
           last if (!defined $ts || !defined $text);

           if ($ts =~ /:/) {
               $ts = ($1 * 3600 + $2 * 60 + $3) * 1000 + $4
                   if ($ts =~ /(\d*):(\d*):(\d*)\.(\d*)/);
               $ts = ($1 * 60 + $2) * 1000 + $3
                   if ($ts =~ /(\d*):(\d*)\.(\d*)/);
           }
     
           $id = $ly->InsertSyncEvent($synctextid, $ts, $text);
       }
   } 
   else 
   {
       return $rdf->EmitErrorRDF("Synctext information already submitted.") 
   }

   return $rdf->CreateStatus(0);
}

# returns synctext
sub GetSyncTextByTrackGlobalId
{
   my ($dbh, $doc, $r, $id) = @_;
   my ($rdf, $sql, @row, $count, $trackid);

   $count = 0;

   if (! DBDefs->USE_LYRICS)
   {  
       return $r->EmitRDFError("This server does not support synctext.");
   }

   return $r->EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($trackid) = $sql->GetSingleRow("Track", ["id"], ["gid", $id]);
   if (!defined($trackid)) {
       return $r->EmitErrorRDF("Unknown track id.") 
   }

   my $ly= Lyrics->new($dbh);
   $rdf  = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;
   $rdf .= $r->CreateTrackRDFSnippet(1, $trackid);
   $rdf .= $r->BeginElement("MM:SyncEvents");
   $rdf .= $r->BeginSeq;

   #get all synctext ID entries for this track
   my @id=$ly->GetSyncTextList($trackid);

   foreach $id (@id) 
   {
      last if (!defined $id);

      #read the table SyncText for this id
      (my $type, my $url, my $contributor, my $date) =
         ($ly->GetSyncTextData($id))[1..4];

      if ($contributor eq '' ||			#invalid record
          $url         eq '' ||
          $date        eq '' ) { next }		#TODO: log error
     

      $rdf .= $r->BeginLi($url);
      $rdf .= $r->Element("DC:Contributor", $contributor); 
      $rdf .= $r->Element("DC:Type", "", type=>($TypesLyric{$type}));
      $rdf .= $r->Element("DC:Date", $date);
      $rdf .= $r->BeginSeq;
    
      my @events=$ly->GetSyncEventList($id);	#get text & timestamps
     
      while(scalar(@events) > 2) {
         shift @events;				#read away the ID
         my $ts=shift(@events);
         my $text=shift(@events);
         $rdf .= $r->BeginLi;
         $rdf .= $r->Element("MM:SyncText", $text, ts=>$ts);
         $rdf .= $r->EndLi;
      }
      $rdf .= $r->EndSeq;
      $rdf .= $r->EndLi;
      $count++;
   }
   $rdf .= $r->EndSeq;
   $rdf .= $r->EndElement("MM:SyncEvents");
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}

# returns lyrics
#TODO: use the methods defined by Lyrics.pm to access the data.
sub GetLyricsByGlobalId
{
   my ($dbh, $doc, $r, $id) = @_;
   my ($sql, $rdf, @row, $count, $trackid);

   $count = 0;
   if (! DBDefs->USE_LYRICS)
   {  
       return $r->EmitRDFError("This server does not support lyrics.");
   }

   return $r->EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($trackid) = $sql->GetSingleRow("Track", ["id"], ["gid", $id]);
   if (defined $trackid)
   {
        #JOHAN: bugfix, do not use id but Track in the where clause.
        if ($sql->Select(qq\select type, url, submittor, submitted, id 
                            from SyncText where Track = $trackid\))
        {
            @row = $sql->NextRow();
            $sql->Finish;
    
            $rdf .= $r->CreateTrackRDFSnippet(1, $trackid);
            $rdf .= $r->BeginElement("MM:SyncEvents");
            $rdf .= $r->BeginDesc($row[1]);
            $rdf .= $r->Element("DC:Contributor", $row[2]); 
            $rdf .= $r->Element("DC:Type", "", type=>($TypesLyric{$row[0]}));
            $rdf .= $r->Element("DC:Date", $row[3]);
            $rdf .= $r->BeginSeq;
    
            if ($sql->Select(qq\select ts, text from SyncEvent where 
                                SyncText = $row[4]\))
            {
                while(@row = $sql->NextRow())
                {
                   $rdf .= $r->BeginLi;
                   $rdf .= $r->Element("MM:SyncText", $row[1], ts=>$row[0]);
                   $rdf .= $r->EndLi;
                }
                $sql->Finish();
            }
            $rdf .= $r->EndSeq;
            $rdf .= $r->EndDesc;
            $rdf .= $r->EndElement("MM:SyncEvents");
            $count++;
        }
   }

   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}
