#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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

use MusicBrainz::Server::Release; # for constants
use DBDefs;
use MusicBrainz::Server::Validation;
use MusicBrainz::Server::LogFile qw( lprint lprintf );
use MusicBrainz::Server::Replication ':replication_type';
use TaggerSupport; # for constants

use Carp qw( carp );
use Digest::SHA1 qw(sha1_hex);

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

sub GetCDInfoMM2
{
   my ($dbh, $parser, $rdf, $id, $numtracks) = @_;
   my ($sql, @row, $album, $di, $toc, $i, $currentURI);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $id);

   my $ns = $rdf->GetMMNamespace();
   if (defined $numtracks)
   {
      $toc = "1 $numtracks ";
      $currentURI = $parser->GetBaseURI();
      for($i = 1; $i <= $numtracks + 1; $i++)
      {
          $toc .= $parser->Extract($currentURI, "${ns}toc [$i] ${ns}sectorOffset") . " ";
      }
   }

   # Check to see if the album is in the main database
   require MusicBrainz::Server::ReleaseCDTOC;
   $di = MusicBrainz::Server::ReleaseCDTOC->new($dbh);
   $rdf->SetDepth(5);
   return $di->GenerateAlbumFromDiscid($rdf, $id, $toc);
}

sub AssociateCDMM2
{
   my ($dbh, $parser, $rdf, $Discid, $albumid) = @_;
   my ($numtracks, $di, $toc, $i, $currentURI);

   return $rdf->ErrorRDF("No Discid given.") if (!defined $Discid);

   my $ns = $rdf->GetMMNamespace();

   $currentURI = $parser->GetBaseURI();
   $numtracks = $parser->Extract($currentURI, "${ns}lastTrack");
   $toc = "1 $numtracks ";
   for($i = 1; $i <= $numtracks + 1; $i++)
   {
       $toc .= $parser->Extract($currentURI, "${ns}toc [$i] ${ns}sectorOffset") . " ";
   }

   # Check to see if the album is in the main database
   require MusicBrainz::Server::ReleaseCDTOC;
   $di = MusicBrainz::Server::ReleaseCDTOC->new($dbh);
   $di->Insert($albumid, $toc);
}

# returns artistList
sub FindArtistByName
{
   my ($dbh, $parser, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No artist search criteria given.")
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 15 if not defined $limit;

   require SearchEngine;
   my $engine = SearchEngine->new($dbh, 'artist');

    $engine->Search(
    query => $search,
    limit => $limit,
    );

   while (my $row = $engine->NextRow)
   {
       push @ids, $row->{'artistid'};
   }

   return $rdf->CreateArtistList($parser, @ids);
}

# returns albumList
sub FindAlbumByName
{
   my ($dbh, $parser, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No album search criteria given.")
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 25 if not defined $limit;

   require SearchEngine;
   my $engine = SearchEngine->new($dbh, 'album');

    $engine->Search(
    query => $search,
    limit => $limit,
    );

   while (my $row = $engine->NextRow)
   {
       push @ids, $row->{'albumid'};
   }

   return $rdf->CreateAlbumList(@ids);
}

# returns trackList
sub FindTrackByName
{
   my ($dbh, $parser, $rdf, $search, $limit) = @_;
   my ($sql, @ids);

   return $rdf->ErrorRDF("No track search criteria given.")
      if (!defined $search);
   return undef if (!defined $dbh);

   $limit = 25 if not defined $limit;

   require SearchEngine;
   my $engine = SearchEngine->new($dbh, 'track');

    $engine->Search(
    query => $search,
    limit => $limit,
    );

   while (my $row = $engine->NextRow)
   {
       push @ids, $row->{'trackid'};
   }

   return $rdf->CreateTrackList(@ids);
}

# returns artistList
sub GetArtistByGlobalId
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing artist GUID in GetArtistByGlobalId";
    return $rdf->ErrorRDF("No artist GUID given");
    }

    my $sql = Sql->new($dbh);
    my $artist = $sql->SelectSingleValue(
    "SELECT id FROM artist WHERE gid = ?",
    lc $id,
    );

    return $rdf->CreateArtistList($parser, $artist);
}

# returns album
sub GetAlbumByGlobalId
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing album GUID in GetAlbumByGlobalId";
    return $rdf->ErrorRDF("No album GUID given");
    }

    my $sql = Sql->new($dbh);
    my $album = $sql->SelectSingleValue(
    "SELECT id FROM album WHERE gid = ?",
    lc $id,
    );

    return $rdf->CreateAlbum(0, $album);
}

# returns trackList
sub GetTrackByGlobalId
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing track GUID in GetTrackByGlobalId";
    return $rdf->ErrorRDF("No track GUID given");
    }

    my $sql = Sql->new($dbh);
    my $ids = $sql->SelectSingleColumnArray(
    "SELECT id FROM track WHERE gid = ?",
    lc $id,
    );

    return $rdf->CreateTrackList(@$ids);
}

sub GoodRiddance
{
   my ($dbh, $parser, $rdf, $id) = @_;
   return $rdf->CreateStatus(0);
}

sub AuthenticateQuery
{
	my ($dbh, $parser, $rdf, $username) = @_;
    return $rdf->ErrorRDF("This Web Service call is no longer used.")
}

# returns artistList
sub GetArtistRelationships
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing artist GUID in GetArtistRelationships";
    return $rdf->ErrorRDF("No artist GUID given");
    }

    my $ar = MusicBrainz::Server::Artist->new($dbh);
    $ar->SetMBId($id);
    if (!$ar->LoadFromId())
    {
    carp "Invalid artist is given to GetTrackRelationships";
    return $rdf->ErrorRDF("Invalid artist GUID given");
    }

    my $sql = Sql->new($dbh);
    my @links = MusicBrainz::Server::Link->FindLinkedEntities($dbh, $ar->GetId, 'artist');

    return $rdf->CreateRelationshipList($parser, $ar, 'artist', \@links);
}

# returns albumList
sub GetAlbumRelationships
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing artist GUID in GetAlbumRelationships";
    return $rdf->ErrorRDF("No album GUID given");
    }

    my $al = MusicBrainz::Server::Release->new($dbh);
    $al->SetMBId($id);
    if (!$al->LoadFromId())
    {
    carp "Invalid album is given to GetTrackRelationships";
    return $rdf->ErrorRDF("Invalid album GUID given");
    }

    my $sql = Sql->new($dbh);
    my @links = MusicBrainz::Server::Link->FindLinkedEntities($dbh, $al->GetId, 'album');

    return $rdf->CreateRelationshipList($parser, $al, 'album', \@links);
}

# returns albumList
sub GetTrackRelationships
{
    my ($dbh, $parser, $rdf, $id) = @_;

    if (not defined $id or $id eq "")
    {
    carp "Missing artist GUID in GetTrackRelationships";
    return $rdf->ErrorRDF("No artist GUID given");
    }

    my $tr = MusicBrainz::Server::Track->new($dbh);
    $tr->SetMBId($id);
    if (!$tr->LoadFromId())
    {
    carp "Invalid artist is given to GetTrackRelationships";
    return $rdf->ErrorRDF("Invalid artist GUID given");
    }

    my $sql = Sql->new($dbh);
    my @links = MusicBrainz::Server::Link->FindLinkedEntities($dbh, $tr->GetId, 'track');

    return $rdf->CreateRelationshipList($parser, $tr, 'track', \@links);
}

sub TrackInfoFromTRMId
{
    my ($dbh, $parser, $rdf, $id, $artist, $album, $track,
        $tracknum, $duration, $filename)=@_;
    my ($sql, @ids, $query);
 
    return undef if (!defined $dbh);
 
    $sql = Sql->new($dbh);
    $id =~ tr/A-Z/a-z/;
 
    my (%lookup, $ts);
 
    $lookup{artist} = $artist;
    $lookup{album} = $album;
    $lookup{track} = $track;
    $lookup{tracknum} = $tracknum;
    $lookup{filename} = $filename;
    $lookup{duration} = $duration;
 
    require TaggerSupport;
    $ts = TaggerSupport->new($dbh);
    my ($error, $result, $flags, $list) = $ts->Lookup(\%lookup, 3);
    if ($flags & TaggerSupport::ALBUMTRACKLIST)
    {
        my ($id);

        foreach $id (@$list)
        {
            if ($id->{sim} >= .9)
            {
                my $out = $rdf->CreateDenseTrackList(1, [$id->{mbid}]);
                return $out;
            }
        }
    }

    return $rdf->CreateStatus(0);
}

# This function will also soon be depricated. As soon as MB Tagger 0.10.x becomes
# completely irrelevant this function can go.
sub QuickTrackInfoFromTrackId
{
   my ($dbh, $parser, $rdf, $tid, $aid) = @_;

   return $rdf->ErrorRDF("No track and/or album id given.")
      if (!defined $tid || $tid eq '' || !defined $aid || $aid eq '');
   return undef if (!defined $dbh);

    require MusicBrainz::Server::Release;
    my $album = MusicBrainz::Server::Release->new($dbh);
    $album->SetMBId($aid);
    unless ($album->LoadFromId)
    {
        return $rdf->ErrorRDF("Cannot load given album.");
    }

    my $sql = Sql->new($dbh);
    my $data = $sql->SelectSingleRowArray(
	"SELECT track.name,
	       	artist.name,
		album.name,
		albumjoin.sequence,
		track.length,
		album.artist,
		artist.gid,
		artist.sortname,
		album.attributes
	FROM	track, albumjoin, album, artist
	WHERE	track.gid = ?
	AND	album.gid = ?
	AND	albumjoin.album = album.id
	AND	albumjoin.track = track.id
	AND	artist.id = track.artist",
	$tid,
	$aid,
    );

    unless ($data)
    {
     	return $rdf->ErrorRDF("Cannot load given album.");
    }

    my @data = @$data;
   my @attrs = ( $data[8] =~ /(\d+)/g );
   shift @attrs;

   my $out = $rdf->BeginRDFObject;
   $out .= $rdf->BeginDesc("mq:Result");
   $out .= $rdf->Element("mq:status", "OK");
   $out .= $rdf->Element("mq:artistName", $data[1]);
   $out .= $rdf->Element("mm:artistid", $data[6]);
   $out .= $rdf->Element("mm:sortName", $data[7]);
   $out .= $rdf->Element("mq:albumName", $data[2]);
   $out .= $rdf->Element("mq:trackName", $data[0]);
   $out .= $rdf->Element("mm:trackNum", $data[3]);
   if ($data[4] != 0)
   {
        $out .= $rdf->Element("mm:duration", $data[4]);
   }

   # This is a total hack, RDF wise speaking. This is to bridge the gap
   # for the MB Tagger 0.10.0 series. Once the new cross platform tagger
   # is out, this function will go away.
   if ($data[5] == &ModDefs::VARTIST_ID)
   {
        $out .= $rdf->Element("mm:albumArtist", &ModDefs::VARTIST_MBID);
   }

   foreach my $attr (@attrs)
   {
       if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
           $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
       {
          $out .= $rdf->Element("mm:releaseType", "", "rdf:resource", $rdf->GetMMNamespace() .
                                 "Type" . $album->GetAttributeName($attr));
       }
       elsif ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START &&
              $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END)
       {
          $out .= $rdf->Element("mm:releaseStatus", "", "rdf:resource", $rdf->GetMMNamespace() .
                                 "Status" . $album->GetAttributeName($attr));
       }
   }

   my (@releases, $releasedate);
   @releases = $album->ReleaseEvents;
   if (@releases)
   {
       require MusicBrainz::Server::Country;
       my $country_obj = MusicBrainz::Server::Country->new($album->{DBH});

       $out .= $rdf->BeginDesc("mm:releaseDateList");
       $out .= $rdf->BeginSeq();
       for my $rel (@releases)
       {
            my $cid = $rel->GetCountry;
            my $c = $country_obj->newFromId($cid);
            my ($year, $month, $day) = $rel->GetYMD();

            $releasedate = $year;
            $releasedate .= sprintf "-%02d", $month if ($month != 0);
            $releasedate .= sprintf "-%02d", $day if ($day != 0);
            $out .= $rdf->BeginElement("rdf:li");
            $out .= $rdf->BeginElement("mm:ReleaseDate");
            $out .= $rdf->Element("dc:date", $releasedate);
            $out .= $rdf->Element("mm:country", $c ? $c->GetISOCode : "?");
            $out .= $rdf->EndElement("mm:ReleaseDate");
            $out .= $rdf->EndElement("rdf:li");
        }
        $out .= $rdf->EndSeq();
        $out .= $rdf->EndDesc("mm:releaseDateList");
   }

   $out .= $rdf->EndDesc("mq:Result");
   $out .= $rdf->EndRDFObject;

   return $out;
}
1;
# eof QuerySupport.pm
