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
use Discid;
use TableBase;
use Artist;
use Track;
use Lyrics;
use UserStuff;
use Moderation;
use TRM;  
use FreeDB;  
use Insert;  
use SearchEngine;  
use RDFStore::Parser::SiRPAC;  
use Digest::SHA1 qw(sha1_hex);
use Apache::Session::File;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use constant EXTRACT_TOC_QUERY => "http://musicbrainz.org/mm/mm-2.0#toc [] http://musicbrainz.org/mm/mm-2.0#sectorOffset";
use constant EXTRACT_NUMTRACKS_QUERY => "http://musicbrainz.org/mm/mm-2.0#lastTrack";

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

sub Extract
{
   my ($triples, $currentURI, $ordinal, $queryarg) = @_;
   my ($triple, $found, @querylist, $query);

   @querylist = split /\s/, $queryarg;
   foreach $query (@querylist)
   {
       $found = 0;
       #print STDERR "Query: $query\n";
       foreach $triple (@$triples)
       {
           #print STDERR "  ",$triple->subject->getLabel, " == $currentURI\n";
           if ($triple->subject->getLabel eq $currentURI &&
               ($triple->predicate->getLabel eq $query ||
               (exists $triple->{ordinal} && $triple->{ordinal} == $ordinal)))
           {
               $currentURI = $triple->object->getLabel;
               $found = 1;
               last;
           }
       }
       #print STDERR "Not found\n" if (!$found);
       return undef if (!$found);
   }
   #print STDERR "found: '$currentURI'\n";
   return $currentURI;
}

sub GenerateCDInfoObjectFromDiscid
{
   my ($dbh, $doc, $rdf, $id, $numtracks, $toc) = @_;
   my ($di);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $id);

   # Check to see if the album is in the main database
   $di = Discid->new($dbh);
   return $di->GenerateAlbumFromDiscid($rdf, $id, $numtracks, $toc);
}

sub AssociateCDFromAlbumId
{
   my ($dbh, $doc, $rdf, $Discid, $toc, $albumid) = @_;

   my $di = Discid->new($dbh);
   $di->Insert($Discid, $albumid, $toc);
}

sub GetCDInfoMM2
{
   my ($dbh, $triples, $rdf, $id, $numtracks) = @_;
   my ($sql, @row, $album, $di, $toc, $i, $currentURI);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $id);

   if (defined $numtracks)
   {
      $toc = "1 $numtracks ";
      $currentURI = $$triples[0]->subject->getLabel;
      for($i = 1; $i <= $numtracks + 1; $i++)
      {
          $toc .= QuerySupport::Extract($triples, $currentURI, $i, EXTRACT_TOC_QUERY) . " ";
      }
   }

   # Check to see if the album is in the main database
   $di = Discid->new($dbh);
   return $di->GenerateAlbumFromDiscid($rdf, $id, $numtracks, $toc);
}

sub AssociateCDMM2
{
   my ($dbh, $triples, $rdf, $Discid, $albumid) = @_;
   my ($numtracks, $di, $toc, $i, $currentURI);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $Discid);
   
   $currentURI = $$triples[0]->subject->getLabel;
   $numtracks = QuerySupport::Extract($triples, $currentURI, $i, EXTRACT_NUMTRACKS_QUERY);
   $toc = "1 $numtracks ";
   for($i = 1; $i <= $numtracks + 1; $i++)
   {
       $toc .= QuerySupport::Extract($triples, $currentURI, $i, EXTRACT_TOC_QUERY) . " ";
   }

   # Check to see if the album is in the main database
   $di = Discid->new($dbh);
   $di->Insert($Discid, $albumid, $toc);
}

# returns artistList
sub FindArtistByName
{
   my ($dbh, $doc, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 25 if not defined $limit;

   my $engine = SearchEngine->new;
   $engine->Table('Artist');
   $engine->AllWords(1);
   $engine->Limit($limit);
   $engine->Search($search);

   while (my $row = $engine->NextRow) 
   {
       push @ids, $row->[0];
   }

   return $rdf->CreateArtistList($doc, @ids);
}

# returns albumList
sub FindAlbumByName
{
   my ($dbh, $doc, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No album search criteria given.") 
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 25 if not defined $limit;

   my $engine = SearchEngine->new;
   $engine->Table('Album');
   $engine->AllWords(1);
   $engine->Limit($limit);
   $engine->Search($search);

   while (my $row = $engine->NextRow) 
   {
       push @ids, $row->[0];
   }

   return $rdf->CreateAlbumList(@ids);
}

# returns trackList
sub FindTrackByName
{
   my ($dbh, $doc, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No track search criteria given.") 
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 25 if not defined $limit;

   my $engine = SearchEngine->new;
   $engine->Table('Track');
   $engine->AllWords(1);
   $engine->Limit($limit);
   $engine->Search($search);

   while (my $row = $engine->NextRow) 
   {
       push @ids, $row->[0];
   }

   return $rdf->CreateTrackList(@ids);
}

# returns TRMList
sub FindDistinctTRM
{
   my ($dbh, $doc, $rdf, $name, $artist) = @_;
   my ($sql, $query, @ids, @row);

   return $rdf->ErrorRDF("No name or artist search criteria given.")
      if (!defined $name && !define $artist);
   return undef if (!defined $dbh);

   if ((defined $name && $name ne '') && 
       (defined $artist && $artist ne '') )
   {
      $sql = Sql->new($dbh);

      # This query finds single track id by name and artist
      $name = $sql->Quote($name);
      $artist = $sql->Quote($artist);
      $query = qq/select distinct TRM.TRM from Track, Artist, TRMJoin, TRM 
                   where Track.artist = Artist.id and 
                         TRMJoin.track = Track.id and
                         TRM.id = TRMJoin.TRM and
                         Artist.name ilike $artist and 
                         Track.Name ilike $name/;

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

   return $rdf->CreateTRMList(@ids);
}

# returns artistList
sub GetArtistByGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, $artist);

   return $rdf->ErrorRDF("No artist id given.") 
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

   return $rdf->ErrorRDF("No album id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($album) = $sql->GetSingleRowLike("Album", ["id"], ["gid", $id]);

   return $rdf->CreateAlbum(0, $album);
}

# returns trackList
sub GetTrackByGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, $query, @row, @ids);

   return $rdf->ErrorRDF("No track id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleRowLike("Album, Track, AlbumJoin", 
                                 ["Track.id"], 
                                 ["Track.gid", $id,
                                  "AlbumJoin.track", "Track.id",
                                  "AlbumJoin.album", "Album.id"]);

   return $rdf->CreateTrackList(@ids);
}

# returns trackList
sub GetTrackByTRM
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No track id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleRowLike("TRM, TRMJoin",
                                 ["Track"], 
                                 ["TRM.TRM", $id,
                                 "TRMJoin.TRM", "TRM.id"]);

   return $rdf->CreateTrackList(@ids);
}

# returns albumList
sub GetAlbumsByArtistGlobalId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @row, @ids);

   return $rdf->ErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @ids = $sql->GetSingleColumnLike("Album, Artist", "Album.id", 
                                    ["Artist.gid", $id,
                                     "Album.artist", "Artist.id"]);

   return $rdf->CreateAlbumList(@ids);
}

sub LookupMetadata
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my (@ids, $gu, $tr);

   #PrintData("Lookup:", $id);

   $gu = TRM->new($dbh);
   $tr = Track->new($dbh);

   # has this data been accepted into the database?
   @ids = $gu->GetTrackIdsFromTRM($id);
   if (scalar(@ids) > 0)
   {
      my (@data, $i);

      # @data will contain 5 items, in the same order as shown above
      @data = $tr->GetMetadataFromIdAndAlbum($ids[0]);
      if (scalar(@data) > 0)
      {
          #PrintData("Matched database (outgoing):", @data);
          return $rdf->CreateMetadataExchange(@data);
      }
   }
   return $rdf->CreateStatus(0);
}

sub PrintData
{
     my ($note, @data) = @_;

     print STDERR "$note\n";
     print STDERR "    Name: $data[0]\n";
     print STDERR "  Artist: $data[1]\n";
     print STDERR "   Album: $data[2]\n";
     print STDERR "     Seq: $data[3]\n";
     print STDERR "    TRM: $data[4]\n";
     print STDERR "Filename: $data[5]\n";
     print STDERR "    Year: $data[6]\n";
     print STDERR "   Genre: $data[7]\n";
     print STDERR " Comment: $data[8]\n";
     print STDERR "Duration: $data[9]\n";
     print STDERR "Bitprint: $data[10]\n";
     print STDERR " First20: $data[11]\n" if (defined $data[11]);
     print STDERR "  Length: $data[12]\n" if (defined $data[12]);
     print STDERR "AudioSHA: $data[13]\n" if (defined $data[13]);
     print STDERR "SampRate: $data[14]\n" if (defined $data[14]);
     print STDERR " BitRate: $data[15]\n" if (defined $data[15]);
     print STDERR "  Stereo: $data[16]\n" if (defined $data[16]);
     print STDERR "     VBR: $data[17]\n\n" if (defined $data[17]);
}

# Data array cross reference
#  0  Name
#  1  Artist
#  2  Album
#  3  Sequence
#  4  TRM
#  5  Filename
#  6  Year
#  7  Genre
#  8  Comment
#  9  Duration (ms)
#  10 Bitprint/Sha1
#  Bitzi data items (not available on MetadataExchangeLite)
#  11 First20
#  12 Length (bytes)
#  13 AudioSha1
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
       $gu = TRM->new($dbh);
       $tr = Track->new($dbh);

       # has this data been accepted into the database?
       @ids = $gu->GetTrackIdsFromTRM($data[4]);
       if (scalar(@ids) > 0)
       {
           my (@db_data, $i);

           # @db_data will contain 5 items, in the same order as shown above
           @db_data = $tr->GetMetadataFromIdAndAlbum($ids[0], $data[2]);
           if (scalar(@db_data) > 0)
           {
              for($i = 0; $i < 5;  $i++)
              {
                 if (defined $db_data[$i] && 
                    (!defined $data[$i] || $data[$i] eq ''))
                 {
                     $data[$i] = $db_data[$i] 
                 }
              }
           }
       }
   }

   return $rdf->CreateMetadataExchange(@data);
}

sub CheckMetadata
{
   my ($dbh, $rdf, $pe, $data, $ids) = @_;
   my ($artistid, $albumid, @db_data);
   my ($in, $trackid, $id);

   $in = Insert->new($dbh);
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
       if (defined $db_data[0] && defined $$data[0] && 
           $$data[0] eq $db_data[0] && 
           defined $db_data[1] && defined $$data[1] && 
           $$data[1] eq $db_data[1] &&
           defined $db_data[2] && defined $$data[2] && 
           $$data[2] eq $db_data[2] &&
           defined $db_data[3] && defined $$data[3] && 
           $$data[3] eq $db_data[3] &&
           defined $db_data[10] && defined $$data[10] && 
           $$data[10] ne $db_data[10])
       { 
           my (@albumids, %info);

           if ($$data[2] =~ /^unknown$/i)
           {
               print STDERR "Skipping insert of $$data[0] by $$data[1] on $$data[2]\n";
               next;
           }

           $info{artist} = $$data[1];
           $info{sortname} = $$data[1];
           $info{album} = $$data[2];
           $info{tracks} = 
             [
               {
                  track => $$data[0],
                  tracknum => $$data[3],
                  duration => $$data[9],
                  trmid => $$data[4]
               }
             ];

           if (!defined $in->Insert(\%info))
           {
               print STDERR "Insert failed: " . $in->GetError() . "\n";
           }
           else
           {
               my ($ref, $ref2);

               #print STDERR "Inserted $$data[0] by $$data[1] on $$data[2]\n";

               $ref = $info{tracks};
               $ref2 = $$ref[0];
               $pe->InsertIntoInsertHistory($ref2->{track_insertid});
           }
           $pe->DeleteByTRM($$data[4]);
           return;
       }
   }
}

sub SubmitTrack
{
   my ($dbh, $doc, $rdf, $name, $TRM, $artist, $album, $seq,
       $len, $year, $genre, $comment) = @_;
   my (@albumids, %info, $in, $ret);

   if (!defined $name || $name eq '' ||
       !defined $album || $album eq '' ||
       !defined $seq || $seq eq '' ||
       !defined $artist || $artist eq '')
   {
       return $rdf->ErrorRDF("Incomplete track information submitted.") 
   }

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $in = Insert->new($dbh);

   $info{artist} = $artist;
   $info{sortname} = $artist;
   $info{album} = $album;
   $info{tracks} = 
     [
       {
          track => $name,
          tracknum => $seq,
          duration => $len, 
          trmid => $TRM
       }
     ];

   $ret = $in->Insert(\%info);
   return $rdf->ErrorRDF($in->GetError()) 
      if (!defined $ret);

   return $rdf->CreateStatus(0);
}

sub SubmitTRMList
{
   my ($dbh, $triples, $rdf) = @_;
   my (@ids, @ids2, $sql, $gu, $tr);
   my ($i, $trmid, $trackid, $uri);

   return undef if (!defined $dbh);

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $sql = Sql->new($dbh);
   $gu = TRM->new($dbh);

   $uri = (@$triples)[0]->subject->getLabel;
   for($i = 1; ; $i++)
   {
       $trackid = Extract($triples, $uri, $i, 
          "http://musicbrainz.org/mm/mm-2.0#trmList [] " . 
          "http://musicbrainz.org/mm/mm-2.0#trackid");
       $trmid = Extract($triples, $uri, $i, 
          "http://musicbrainz.org/mm/mm-2.0#trmList [] " .
          "http://musicbrainz.org/mm/mm-2.0#trmid");
       if (!defined $trackid || $trackid eq '' ||
           !defined $trmid || $trmid eq '')
       {
            last if ($i > 1);
            return $rdf->ErrorRDF("Incomplete trackid and trmid submitted.") 
       } 
       print STDERR "trackid: $trackid\n";
       print STDERR "trmid: $trmid\n";

       $trackid = $sql->Quote($trackid);

       #lookup the IDs associated with the $trackGID
       @ids = $sql->GetSingleRowLike("Album, Track, AlbumJoin", 
                                     ["Track.id"], 
                                     ["Track.gid", $trackid,
                                      "AlbumJoin.track", "Track.id",
                                      "AlbumJoin.album", "Album.id"]);
       if (scalar(@ids) == 0 || !defined($ids[0]))
       {
           print STDERR "Invalid MB Track Id: $trackid\n";
       }
       else
       {
           $gu->Insert($trmid,$ids[0]);
       }
   }
   print STDERR "\n";

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
       return $rdf->ErrorRDF("Incomplete synctext information submitted.") 
   }

   if (! DBDefs->USE_LYRICS) 
   {  
       return $rdf->EmitRDFError("This server does not accept lyrics.");
   }

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $tr = Track->new($dbh);
   $ly = Lyrics->new($dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($gid);
   ($trackid) = $sql->GetSingleRow("Track", ["id"], ["gid", $id]);
   if (!defined($trackid)) 
   {
       return $rdf->ErrorRDF("Unknown track id.") 
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
       return $rdf->ErrorRDF("Synctext information already submitted.") 
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

   return $r->ErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   ($trackid) = $sql->GetSingleRow("Track", ["id"], ["gid", $id]);
   if (!defined($trackid)) {
       return $r->ErrorRDF("Unknown track id.") 
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

   return $r->ErrorRDF("No track id given.") 
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

sub AuthenticateQuery
{
   my ($dbh, $doc, $rdf, $username) = @_;
   my ($session_id, $challenge, $us, $data);
   my ($uid, $digest, $chal_size, $i, $pass);

   if (!defined $username || $username eq '')
   {
       return $rdf->ErrorRDF("Invalid/missing user name.") 
   }

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $us = UserStuff->new($dbh);
   ($pass, $uid) = $us->GetUserPasswordAndId($username);
   if (!defined $pass)
   {
       return $rdf->ErrorRDF("Unknown user.") 
   }

   srand;
   $chal_size = int(rand 16) + 16;
   for($i = 0; $i < $chal_size; $i++)
   {
       $challenge .= sprintf("%02x", int(rand 256));
   }

   $data = $challenge . $username . $pass;
   $digest = sha1_hex($data);

   my %session;
   tie %session, 'Apache::Session::File', undef, {
                 Directory => DBDefs::SESSION_DIR,
                 LockDirectory   => DBDefs::LOCK_DIR};
   $session{session_key} = $digest;
   $session{uid} = $uid;
   $session{moderator} = $username;
   $session{expire} = time + 3600;
   $session_id = $session{_session_id};
   untie %session;
   print STDERR "Start session: $session_id\n";

   return $rdf->CreateAuthenticateResponse($session_id, $challenge);
}

sub QuickTrackInfoFromTRMId
{
   my ($dbh, $doc, $rdf, $id) = @_;
   my ($sql, @data, $out);

   return $rdf->ErrorRDF("No trm id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id = $sql->Quote($id);
   @data = $sql->GetSingleRowLike(
      "TRM, TRMJoin, Track, AlbumJoin, Album, Artist", 
      ["Track.name", "Artist.name", "Album.name", 
       "AlbumJoin.sequence", "Track.GID", "Track.Length"],
      ["TRM.TRM", $id,
       "TRMJoin.TRM", "TRM.id",
       "TRMJoin.track", "Track.id",
       "Track.id", "AlbumJoin.track",
       "Album.id", "AlbumJoin.album",
       "Track.Artist", "Artist.id"]);

   $out = $rdf->BeginRDFObject;
   $out .= $rdf->BeginDesc("mq:Result");
   $out .= $rdf->Element("mq:status", "OK");
   $out .= $rdf->Element("mq:artistName", $data[1]);
   $out .= $rdf->Element("mq:albumName", $data[2]);
   $out .= $rdf->Element("mq:trackName", $data[0]);
   $out .= $rdf->Element("mm:trackNum", $data[3]);
   $out .= $rdf->Element("mm:trackid", $data[4]);
   if ($data[5] != 0)
   {
       $out .= $rdf->Element("mm:duration", $data[5]);
   }
   $out .= $rdf->EndDesc("mq:Result");
   $out .= $rdf->EndRDFObject;

   #print STDERR "$out";

   return $out;
}

sub QuickTrackInfoFromTrackId
{
   my ($dbh, $doc, $rdf, $tid, $aid) = @_;
   my ($sql, @data, $out);

   return $rdf->ErrorRDF("No track id given.") 
      if (!defined $tid || $tid eq '' || !defined $aid || $aid eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $tid = $sql->Quote($tid);
   $aid = $sql->Quote($aid);
   @data = $sql->GetSingleRowLike(
      "Track, AlbumJoin, Album, Artist", 
      ["Track.name", "Artist.name", "Album.name", 
       "AlbumJoin.sequence", "Track.Length"],
      ["Track.gid", $tid,
       "AlbumJoin.album", "Album.id",
       "Album.gid", $aid,
       "Track.id", "AlbumJoin.track",
       "Album.id", "AlbumJoin.album",
       "Track.Artist", "Artist.id"]);

   $out = $rdf->BeginRDFObject;
   $out .= $rdf->BeginDesc("mq:Result");
   $out .= $rdf->Element("mq:status", "OK");
   $out .= $rdf->Element("mq:artistName", $data[1]);
   $out .= $rdf->Element("mq:albumName", $data[2]);
   $out .= $rdf->Element("mq:trackName", $data[0]);
   $out .= $rdf->Element("mm:trackNum", $data[3]);
   if ($data[4] != 0) 
   {
        $out .= $rdf->Element("mm:duration", $data[4]);
   }
   $out .= $rdf->EndDesc("mq:Result");
   $out .= $rdf->EndRDFObject;

   return $out;
}
