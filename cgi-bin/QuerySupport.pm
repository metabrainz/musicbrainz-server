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

sub PrintData
{
     my ($note, @data) = @_;

     print STDERR "$note\n";
     print STDERR "    Name: $data[0]\n";
     print STDERR "  Artist: $data[1]\n";
     print STDERR "   Album: $data[2]\n";
     print STDERR "     Seq: $data[3]\n";
     print STDERR "    GUID: $data[4]\n";
     print STDERR "Filename: $data[5]\n";
     print STDERR "    Year: $data[6]\n";
     print STDERR "   Genre: $data[7]\n";
     print STDERR " Comment: $data[8]\n";
     print STDERR "Bitprint: $data[9]\n";
     print STDERR " First20: $data[10]\n";
     print STDERR "  Length: $data[11]\n";
     print STDERR "AudioSHA: $data[12]\n";
     print STDERR "Duration: $data[13]\n";
     print STDERR "SampRate: $data[14]\n";
     print STDERR " BitRate: $data[15]\n";
     print STDERR "  Stereo: $data[16]\n";
     print STDERR "     VBR: $data[17]\n\n";
}

# Data array cross reference
#  0  Name
#  1  Artist
#  2  Album
#  3  Sequence
#  4  GUID
#  5  Filename
#  6  Year
#  7  Genre
#  8  Comment
#  9  Bitprint
#  10 First20
#  11 Length (bytes)
#  12 AudioSha1
#  13 Duration (ms)
#  14 SampleRate
#  15 BitRate
#  16 Stereo
#  17 VBR
sub ExchangeMetadata
{
   my ($dbh, $doc, $rdf, @data) = @_;
   my (@ids, $id, $gu, $pe, $tr, $rv, $ar);

   #PrintData("Incoming:", @data);

   if (!DBDefs::DB_READ_ONLY)
   {
       $ar = Artist->new($dbh);
       $gu = GUID->new($dbh);
       $pe = Pending->new($dbh);
       $tr = Track->new($dbh);

       # has this data been accepted into the database?
       $id = $gu->GetTrackIdsFromGUID($data[4]);
       $id = $ids[0];
       if (!defined $id || $id < 0)
       {
           # No it has not.
           @ids = $pe->GetIdsFromGUID($data[4]);
           if (!defined $ids[0])
           {
               if (defined $data[0] && $data[0] ne '' &&
                   defined $data[4] && $data[4] ne '' &&
                   defined $data[1] && $data[1] ne '' &&
                   defined $data[2] && $data[2] ne '')
               {
                   $pe->Insert(@data);
               }
           }
           else
           {
                # Do the metadata glom
                CheckMetadata($dbh, $rdf, $pe, \@data, \@ids); 
           }
       }
       else
       {
           my (@db_data, $i);

           # @db_data will contain 5 items, in the same order as shown above
           @db_data = $tr->GetMetadataFromIdAndAlbum($id, $data[2]);
           for($i = 0; $i < 5;  $i++)
           {
              if ((!defined $data[$i] || $data[$i] eq "") && 
                  defined $db_data[$i])
              {
                  $data[$i] = $db_data[$i] 
              }
           }
           #PrintData("Matched database (outgoing):", @data);
       }
   }

   return $rdf->CreateMetadataExchange(@data);
}

sub CheckMetadata
{
   my ($dbh, $rdf, $pe, $data, $ids) = @_;
   my ($artistid, $albumid, @db_data);
   my ($ar, $al, $tr, $gu, $trackid, $id);

   $ar = Artist->new($dbh);
   $al = Album->new($dbh);
   $tr = Track->new($dbh);
   $gu = GUID->new($dbh);
   for(;;)
   {
       $id = shift @$ids;
       return if !defined $id;
     
       # Is the data in the pending row we have the same as the data
       # that was just passed in?
       @db_data = $pe->GetData($id);
       #print STDERR "'$$data[0]' == '$db_data[0]'\n";
       #print STDERR "'$$data[1]' == '$db_data[1]'\n";
       #print STDERR "'$$data[2]' == '$db_data[2]'\n";
       #print STDERR "'$$data[3]' == '$db_data[3]'\n";
       #print STDERR "'$$data[12]' == '$db_data[12]'\n";
       if (defined $db_data[0] && defined $$data[0] && 
           $$data[0] eq $db_data[0] && 
           defined $db_data[1] && defined $$data[1] && 
           $$data[1] eq $db_data[1] &&
           defined $db_data[2] && defined $$data[2] && 
           $$data[2] eq $db_data[2] &&
           defined $db_data[3] && defined $$data[3] && 
           $$data[3] eq $db_data[3] &&
           defined $db_data[9] && defined $$data[9] && 
           $$data[9] ne $db_data[9])
       { 
           my @albumids;

           $ar->SetName($$data[1]);
           $ar->SetSortName($$data[1]);
           $artistid = $ar->Insert();
           $al->SetArtist($artistid);

           @albumids = $ar->GetAlbumsByName($$data[2]);
           if (defined $albumids[0])
           {
               $albumid = $albumids[0]->GetId();
           }
           else
           {
               $al->SetName($$data[2]);
               $albumid = $al->Insert();
           }
           $al->SetId($albumid);

           $tr->SetName($$data[0]);
           $tr->SetSequence($$data[3]);
           $tr->SetLength($$data[11]);
           $trackid = $tr->Insert($al, $ar);
           if (defined $trackid)
           {
               $gu->Insert($$data[4], $trackid);
           }
           $pe->DeleteByGUID($$data[4]);
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
