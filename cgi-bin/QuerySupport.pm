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
use DBDefs;
use TableBase;
use MusicBrainz;
use UserStuff;
use Album;
use Discid;
use TableBase;
use Artist;
use Track;
use UserStuff;
use Moderation;
use TRM;  
use FreeDB;  
use Insert;  
use SearchEngine;  
use RDFStore::Parser::SiRPAC;  
use Digest::SHA1 qw(sha1_hex);
use Apache::Session::File;
use TaggerSupport;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use constant EXTRACT_TOC_QUERY => "!mm!toc [] !mm!sectorOffset";
use constant EXTRACT_NUMTRACKS_QUERY => "!mm!lastTrack";
use constant EXTRACT_CLIENT_VERSION => "!mq!clientVersion";

sub IsValidUUID
{
    my ($uuid) = @_;

    return 0 if ($uuid eq '00000000-0000-0000-0000-000000000000');
    return 0 if (length($uuid) != 36);
    return 0 if (!($uuid =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/));

    return 1;
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

   my $ns = $rdf->GetMMNamespace(); 
   my $query = EXTRACT_TOC_QUERY;
   $query =~ s/!mm!/$ns/g;
   if (defined $numtracks)
   {
      $toc = "1 $numtracks ";
      $currentURI = $$triples[0]->subject->getLabel;
      for($i = 1; $i <= $numtracks + 1; $i++)
      {
          $toc .= QuerySupport::Extract($triples, $currentURI, $i, $query) . " ";
      }
   }

   # Check to see if the album is in the main database
   $di = Discid->new($dbh);
   $rdf->SetDepth(5);
   return $di->GenerateAlbumFromDiscid($rdf, $id, $numtracks, $toc);
}

sub AssociateCDMM2
{
   my ($dbh, $triples, $rdf, $Discid, $albumid) = @_;
   my ($numtracks, $di, $toc, $i, $currentURI);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $Discid);
   
   my $ns = $rdf->GetMMNamespace(); 
   my $toc_query = EXTRACT_TOC_QUERY;
   $toc_query =~ s/!mm!/$ns/g;
   my $num_query = EXTRACT_NUMTRACKS_QUERY;
   $num_query =~ s/!mm!/$ns/g;

   $currentURI = $$triples[0]->subject->getLabel;
   $numtracks = QuerySupport::Extract($triples, $currentURI, $i, $num_query);
   $toc = "1 $numtracks ";
   for($i = 1; $i <= $numtracks + 1; $i++)
   {
       $toc .= QuerySupport::Extract($triples, $currentURI, $i, $toc_query) . " ";
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

   $limit = 15 if not defined $limit;

   my $engine = SearchEngine->new($dbh);
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

   my $engine = SearchEngine->new($dbh);
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

   my $engine = SearchEngine->new($dbh);
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
   ($artist) = $sql->GetSingleRow("Artist", ["id"], ["gid", lc($id)]);

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
   ($album) = $sql->GetSingleRow("Album", ["id"], ["gid", lc($id)]);

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
   @ids = $sql->GetSingleRow("Album, Track, AlbumJoin", 
                             ["Track.id"], 
                             ["Track.gid", lc($id),
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
   @ids = $sql->GetSingleRow("TRM, TRMJoin",
                             ["Track"], 
                             ["TRM.TRM", lc($id),
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
   @ids = $sql->GetSingleColumn("Album, Artist", "Album.id", 
                                ["Artist.gid", lc($id),
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

sub SubmitTrack
{
   my ($dbh, $doc, $rdf, $name, $TRM, $artist, $album, $seq,
       $len, $year, $genre, $comment) = @_;
   my (@albumids, %info, $in, $ret);

   return $rdf->ErrorRDF("This feature is currently not enabled.");

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
   my ($dbh, $triples, $rdf, $session) = @_;
   my (@ids, @ids2, $sql, $gu, $tr);
   my ($i, $trmid, $trackid, $uri, $clientVer, $new, $index);

   return undef if (!defined $dbh);

   if (DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(DBDefs::DB_READ_ONLY_MESSAGE) 
   }

   $sql = Sql->new($dbh);
   $gu = TRM->new($dbh);

   my $ns = $rdf->GetMQNamespace(); 
   my $query = EXTRACT_CLIENT_VERSION;
   $query =~ s/!mq!/$ns/g;

   $uri = (@$triples)[0]->subject->getLabel;
   $clientVer = Extract($triples, $uri, 0, $query);
   if (not defined $clientVer)
   {
       return $rdf->ErrorRDF("Your MusicBrainz client must provide its version " .
                             "id string when submitting data to MusicBrainz.") 
   }

   $index = 0;
   $new = "ClientVersion=$clientVer\n";
   for($i = 1; ; $i++)
   {
       ($trackid, $trmid) = $rdf->GetTRMTrackIdPair($triples, $uri, $i);
       if (!defined $trackid || $trackid eq '' ||
           !defined $trmid || $trmid eq '')
       {
            last if ($i > 1);
            return $rdf->ErrorRDF("Incomplete trackid and trmid submitted.") 
       } 
       if (!IsValidUUID($trmid) || !IsValidUUID($trackid))
       {
           print STDERR "Invalid track/trm combination:\n";
           print STDERR "trackid: $trackid\n";
           print STDERR "trmid: $trmid\n\n";
           return $rdf->ErrorRDF("Invalid trackid or trmid submitted.") 
       } 

       $trackid =~ tr/A-Z/a-z/;
       $trackid = $sql->Quote($trackid);

       #lookup the IDs associated with the $trackGID
       @ids = $sql->GetSingleRow("Album, Track, AlbumJoin", 
                                 ["Track.id"], 
                                 ["Track.gid", $trackid,
                                  "AlbumJoin.track", "Track.id",
                                  "AlbumJoin.album", "Album.id"]);
       if (scalar(@ids) == 0 || !defined($ids[0]))
       {
           print STDERR "Unknown MB Track Id: $trackid\n";
       }
       else
       {
           $new .= "TRMId$index=$trmid\nTrackId$index=$ids[0]\n";
           $index++;
       }
   }
   print STDERR "\n";

   if ($index > 0)
   {
       my ($mod);

       $mod = Moderation->new($dbh);
       $mod = $mod->CreateModerationObject(ModDefs::MOD_ADD_TRMS);
       return $rdf->ErrorRDF("Cannot create moderation.") if (!defined $mod);

       $mod->SetTable('TRM');
       $mod->SetColumn('trm');
       $mod->SetPrev("");
       $mod->SetNew($new);
       $mod->SetType(ModDefs::MOD_ADD_TRMS);
       $mod->SetRowId(0);
       $mod->SetArtist(ModDefs::VARTIST_ID);
       $mod->SetModerator($session->{uid});
       $mod->SetDepMod(0);

       eval
       {
           $sql->Begin;
           $mod->InsertModeration();
           $sql->Commit;
       };
       if ($@)
       {
           print STDERR "Cannot insert TRM: $@\n";
           $sql->Rollback;
           return $rdf->ErrorRDF("Cannot write TRM Ids to database.") 
       }
       return $rdf->CreateStatus(0);
   }

   return $rdf->ErrorRDF("No valid TRM ids were submitted.") 
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
   print STDERR "Start session: $username $session_id\n";

   return $rdf->CreateAuthenticateResponse($session_id, $challenge);
}

sub TrackInfoFromTRMId
{
   my ($dbh, $doc, $rdf, $id, $artist, $album, $track, 
       $tracknum, $duration, $filename)=@_;
   my ($sql, @ids, $qid, $query);

   return $rdf->ErrorRDF("No trm id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id =~ tr/A-Z/a-z/;
   $qid = $sql->Quote($id);
   $query = qq|select track.gid
                 from TRM, TRMJoin, track
                where TRM.TRM = | . $qid . qq| and
                      TRMJoin.TRM = TRM.id and
                      TRMJoin.track = track.id|;
   if ($sql->Select($query))
   {
       my @row;

       # If this TRM generated any hits, update the lookup count
       if ($sql->Rows >= 1)
       {
           my ($trm, $sql2);

           $sql2 = Sql->new($dbh);
           $trm = TRM->new($dbh);
           eval
           {
               $sql2->Begin();
               $trm->IncrementLookupCount($id);
               $sql2->Commit();
           };
           if ($@)
           {
               $sql2->Rollback();
           }
       }
       while(@row = $sql->NextRow())
       {
           push @ids, $row[0];
       }
       $sql->Finish;

       return $rdf->CreateDenseTrackList(\@ids);
   }
   else
   {
       my (%lookup, $ts);

       $lookup{artist} = $artist; 
       $lookup{album} = $album; 
       $lookup{track} = $track; 
       $lookup{tracknum} = $tracknum; 
       $lookup{filename} = $filename; 
       $lookup{duration} = $duration; 

       $ts = TaggerSupport->new($dbh);
       my ($error, $result, $flags, $list) = $ts->Lookup(\%lookup, 3);
       if ($flags & TaggerSupport::ALBUMTRACKLIST)
       {
           my ($id);

           foreach $id (@$list)
           {
               my $sim;

               $sim = ($id->{sim_track} * .5) +
                      ($id->{sim_album} * .5);

               if ($sim >= .9)
               {
                   return $rdf->CreateDenseTrackList([$id->{trackid}]);
               }
           }
       }
       return $rdf->CreateStatus(0);
   }
}

sub QuickTrackInfoFromTRMId
{
   my ($dbh, $doc, $rdf, $id, $artist, $album, $track, 
       $tracknum, $duration, $filename)=@_;
   my ($sql, @data, $out, $qid);

   return $rdf->ErrorRDF("No trm id given.") 
      if (!defined $id || $id eq '');
   return undef if (!defined $dbh);

   $sql = Sql->new($dbh);
   $id =~ tr/A-Z/a-z/;
   $qid = $sql->Quote($id);

   my $query = qq|select Track.name, Artist.name, Album.name, 
                         AlbumJoin.sequence, Track.GID, Track.Length
                    from TRM, TRMJoin, Track, AlbumJoin, Album, Artist
                   where TRM.TRM = | . $qid . qq| and
                         TRMJoin.TRM = TRM.id and
                         TRMJoin.track = Track.id and
                         Track.id = AlbumJoin.track and
                         Album.id = AlbumJoin.album and
                         Track.Artist = Artist.id|;
   if ($sql->Select($query))
   {
       if ($sql->Rows == 1)
       {
           my ($trm, $sql2);

           @data = $sql->NextRow();
           $sql2 = Sql->new($dbh);
           $trm = TRM->new($dbh);
           eval
           {
               $sql2->Begin();
               $trm->IncrementLookupCount($id);
               $sql2->Commit();
           };
           if ($@)
           {
               $sql2->Rollback();
           }
       }
       else
       {
           print STDERR "TRM collision on: $id\n";
       }
       $sql->Finish;
   }
   else
   {
       my (%lookup, $ts);

       $lookup{artist} = $artist; 
       $lookup{album} = $album; 
       $lookup{track} = $track; 
       $lookup{tracknum} = $tracknum; 
       $lookup{filename} = $filename; 
       $lookup{duration} = $duration; 

       $ts = TaggerSupport->new($dbh);
       my ($error, $result, $flags, $list) = $ts->Lookup(\%lookup, 3);
       if ($flags & TaggerSupport::ALBUMTRACKLIST)
       {
           my ($id);

           foreach $id (@$list)
           {
               my $sim;

               $sim = ($id->{sim_track} * .5) +
                      ($id->{sim_album} * .5);

               if ($sim >= .9)
               {
                   $data[0] = $id->{name};
                   $data[1] = $id->{artist};
                   $data[2] = $id->{album};
                   $data[3] = $id->{tracknum};
                   $data[4] = $id->{mbid};
                   $data[5] = $id->{tracklen};;
                   last;
               }

           }
       }
   }

   $out = $rdf->BeginRDFObject;
   $out .= $rdf->BeginDesc("mq:Result");
   $out .= $rdf->Element("mq:status", "OK");
   $out .= $rdf->Element("mq:artistName", $data[1]);
   $out .= $rdf->Element("mq:albumName", $data[2]);
   $out .= $rdf->Element("mq:trackName", $data[0]);
   $out .= $rdf->Element("mm:trackNum", $data[3]);
   $out .= $rdf->Element("mm:trackid", $data[4]);
   if (defined $data[5] && $data[5] != 0)
   {
       $out .= $rdf->Element("mm:duration", $data[5]);
   }
   $out .= $rdf->EndDesc("mq:Result");
   $out .= $rdf->EndRDFObject;

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
   @data = $sql->GetSingleRow(
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

1;
