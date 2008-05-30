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
use Apache::Session::File;

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
   my ($session_id, $challenge, $us, $data);
   my ($uid, $digest, $chal_size, $i, $pass);

   if (!defined $username || $username eq '')
   {
       return $rdf->ErrorRDF("Invalid/missing user name.")
   }

   if (&DBDefs::DB_READ_ONLY)
   {
       return $rdf->ErrorRDF(&DBDefs::DB_READ_ONLY_MESSAGE)
   }

   require UserStuff;
   $us = UserStuff->new($dbh);
   ($pass, $uid) = $us->GetUserPasswordAndId($username);
   if (not defined($pass) or $pass eq UserStuff->LOCKED_OUT_PASSWORD)
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
                 Directory => &DBDefs::SESSION_DIR,
                 LockDirectory   => &DBDefs::LOCK_DIR};

   $session{session_key} = $digest;
   $session{uid} = $uid;
   $session{moderator} = $username;
   $session{expire} = time + &DBDefs::RDF_SESSION_SECONDS_TO_LIVE;

   $session_id = $session{_session_id};
   untie %session;
   # print STDERR "Start session: $username $session_id\n";

   return $rdf->CreateAuthenticateResponse($session_id, $challenge);
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

1;
# eof QuerySupport.pm
