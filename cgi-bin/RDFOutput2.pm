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
                                                                               
package RDFOutput2;

use TableBase;
use strict;
use RDF2;
use GUID;
use DBDefs;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = qw(TableBase RDF2);
@EXPORT = @EXPORT = '';

sub new
{
    my ($type, $dbh) = @_;

    my $this = TableBase->new($dbh);
    return bless $this, $type;
}

sub SetBaseURI
{
    my ($this, $uri) = @_;

    $this->{baseuri} = $uri;
}

sub GetBaseURI
{
    return $_[0]->{baseuri};
}

sub SetDepth
{
    my ($this, $depth) = @_;

    $this->{depth} = $depth;
}

sub GetDepth
{
    return $_[0]->{depth};
}

sub ErrorRDF
{
   my ($this, $text) = @_;
   my ($rdf);

   $rdf = $this->BeginRDFObject;
   $rdf .= $this->BeginDesc("mq:Result");
   $rdf .= $this->Element("mq:error", $text);
   $rdf .= $this->EndDesc("mq:Result");
   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub CreateStatus
{
   my ($this, $count) = @_;
   my $rdf;

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc("mq:Result");
   $rdf .= $this->Element("mq:status", "OK");
   $rdf .= $this->EndDesc("mq:Result");
   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub CreateArtistList
{
   my ($this, $doc, @ids) = @_;

   return $this->CreateOutputRDF('artist', @ids);
}

sub CreateAlbumList
{
   my ($this, @ids) = @_;

   return $this->CreateOutputRDF('album', @ids);
}

sub CreateTrackList
{
   my ($this, @ids) = @_;

   return $this->CreateOutputRDF('track', @ids);
}

sub CreateGUIDList
{
   my ($this, @ids) = @_;

   return $this->CreateOutputRDF('trmid', @ids);
}

# Check for duplicates, then add if not already in cache
sub AddToCache
{
   my ($cache, $type, $id, $obj) = @_;
   my (%item, $i);

   # check to make sure this object does not already exist in the list
   foreach $i (@$cache)
   {
      return if ($i->{id} == $id && $i->{type} eq $type);
   }

   $item{type} = $type;
   $item{loaded} = defined $obj;
   $item{id} = $id;
   $item{obj} = $obj;
   push @$cache, \%item;
}

# Get an object from the cache, given its id
sub GetFromCache
{
   my ($cache, $type, $id) = @_;
   my ($i);

   # check to make sure this object does not already exist in the list
   foreach $i (@$cache)
   {
      return $i->{obj} if ($i->{id} == $id && $i->{type} eq $type);
   }
   return undef;
}

sub CreateOutputRDF
{
   my ($this, $type, @ids) = @_;
   my (@cache, %obj, $id, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   return $this->CreateStatus() if (scalar(@ids) == 0);

   $depth = $this->GetDepth();
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 1);

   # Create a cache of objects and add the passed object ids without
   # loading the actual objects
   foreach $id (@ids)
   {
      AddToCache(\@cache, $type, $id);
   }

   # For each depth
   for($i = 0; $i < $depth; $i++)
   {
      # Go through the object cache. If the object is loaded, skip it.
      # If not, load it and determine the references the object
      @newrefs = ();
      foreach $ref (@cache)
      {
         next if $ref->{loaded};
   
         $ref->{obj} = $this->LoadObject($ref);
         if (defined $ref->{obj})
         {
            print "Loaded object $ref->{obj}\n";
            $ref->{loaded} = 1;
            push @newrefs, $this->GetReferences($ref);
         } 
      }
      foreach $ref (@newrefs)
      {
         AddToCache(\@cache, $ref->{type}, $ref->{id}, $ref->{obj});
      }
   }

   # Now that we've compiled a list of objects, output the list and 
   # the actual objects themselves

   # Output the actual list of objects, making sure to only
   # include the first few objects in the cachce, not all of them.
   $total = scalar(@ids);
   for($i = 0; $i < $total; $i++)
   {
      push @gids, $cache[$i]->{obj}->GetMBId();
   }
   $out  = $this->BeginRDFObject();
   $out .= $this->OutputList($type, \@gids);
  
   # Output all of the referenced objects. Make sure to only output
   # the objects in the cache that have been loaded. The objects that
   # have not been loaded will not be output, even though they are
   # in the cache. (They would've been output if depth was one greater)
   $total = scalar(@cache);
   for($i = 0; $i < $total; $i++)
   {
      last if not $cache[$i]->{loaded};

      $out .= $this->OutputRDF(\@cache, $cache[$i]);
      $out .= "\n";
   }
   $out .= $this->EndRDFObject;

   return $out;
}

sub LoadObject
{
   my ($this, $ref) = @_;
   my $obj;

   if ($ref->{type} eq 'artist')
   {
      $obj = Artist->new($this->{DBH});
      $obj->SetId($ref->{id});
      return (defined $obj->LoadFromId()) ? $obj : undef;
   }
   elsif ($ref->{type} eq 'album')
   {
      $obj = Album->new($this->{DBH});
      $obj->SetId($ref->{id});
      return (defined $obj->LoadFromId()) ? $obj : undef;
   }
   elsif ($ref->{type} eq 'track')
   {
      $obj = Track->new($this->{DBH});
      $obj->SetId($ref->{id});
      return (defined $obj->LoadFromId()) ? $obj : undef;
   }
   return undef;
}

sub OutputList
{
   my ($this, $type, $list) = @_;
   my ($item, $rdf);

   $rdf  =   $this->BeginDesc("mq:Result");
   $rdf .=     $this->Element("mq:status", "OK");
   $rdf .=     $this->BeginDesc("mm:" . $type . "List");
   $rdf .=       $this->BeginSeq();
   foreach $item (@$list)
   {
      $rdf .=      $this->Li($this->{baseuri}. "/$type/$item");
   }
   $rdf .=       $this->EndSeq();
   $rdf .=     $this->EndDesc("mm:" . $type . "List");
   $rdf .=   $this->EndDesc("mq:Result");
   $rdf .= "\n";

   return $rdf;
}

sub GetReferences
{
   my ($this, $ref) = @_;

   return $this->GetArtistReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'artist');
   return $this->GetAlbumReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'album');
   return $this->GetTrackReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'track');

   # If this type is not supported return an empty list
   return ();
}

# Return the references that this object makes. 
# An artist makes no references, so return an empty hash
sub GetArtistReferences
{
   return ();
}

# An for an album, add the artist ref and a ref for each track
sub GetAlbumReferences
{
   my ($this, $ref, $album) = @_;
   my (@tracks, $track, @ret, %info, @trackids);

   @tracks = $album->LoadTracks();
   foreach $track (@tracks)
   {
      $info{type} = 'artist';
      $info{id} = $track->GetArtist();
      $info{obj} = undef;
      push @ret, {%info};

      $info{type} = 'track';
      $info{obj} = $track;
      $info{id} = $track->GetId();
      push @ret, {%info};

      push @trackids, $track->GetMBId();
   }
   $ref->{_album} = \@trackids;

   return @ret;
}

# An for a track, add the artist and album refs
sub GetTrackReferences
{
   my ($this, $ref, $track) = @_;
   my (@ret, %info);

   $info{type} = 'artist';
   $info{id} = $track->GetArtist();
   $info{obj} = undef;
   push @ret, {%info};

   $info{type} = 'album';
   $info{id} = $track->GetAlbum();
   $info{obj} = undef;
   push @ret, {%info};

   return @ret;
}

sub OutputRDF
{
   my ($this, $cache, $ref) = @_;

   if ($ref->{type} eq 'artist')
   {
      return $this->OutputArtistRDF($cache, $ref);
   }
   elsif ($ref->{type} eq 'album')
   {
      return $this->OutputAlbumRDF($cache, $ref);
   }
   elsif ($ref->{type} eq 'track')
   {
      return $this->OutputTrackRDF($cache, $ref);
   }
   return undef;
}

# Return the RDF representation of the Artist
sub OutputArtistRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $artist);

    $artist = $ref->{obj};

    $out  = $this->BeginDesc("mm:Artist", $this->GetBaseURI() .
                            "/artist/" . $artist->GetMBId());
    $out .=   $this->Element("dc:title", $artist->GetName());
    $out .=   $this->Element("mm:sortName", $artist->GetSortName());
    $out .= $this->EndDesc("mm:Artist");

    return $out;
}

# Return the RDF representation of the Album
sub OutputAlbumRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $album, $track, $artist, $ids);

    $album = $ref->{obj};
    $artist = GetFromCache($cache, 'artist', $album->GetArtist()); 
    $out  = $this->BeginDesc("mm:Album", $this->GetBaseURI() .
                            "/album/" . $album->GetMBId());
    $out .=   $this->Element("dc:title", $album->GetName());
    $out .=   $this->Element("dc:creator", "", "rdf:resource",
                             $this->GetBaseURI() . "/artist/" . 
                             $artist->GetMBId());
    $out .=   $this->BeginDesc("mm:trackList");
    $out .=   $this->BeginSeq();
    $ids = $ref->{_album};
    foreach $track (@$ids)
    {
       $out .=      $this->Li($this->{baseuri}. "/track/$track");
    }
    $out .=   $this->EndSeq();
    $out .=   $this->EndDesc("mm:trackList");
    $out .= $this->EndDesc("mm:Album");

    return $out;
}

# Return the RDF representation of the Track
sub OutputTrackRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $artist, $guid, $gu, $track);

    $track = $ref->{obj};
    $gu = GUID->new($this->{DBH});
    $guid = $gu->GetGUIDFromTrackId($track->GetId());

    $artist = GetFromCache($cache, 'artist', $track->GetArtist()); 

    $out  = $this->BeginDesc("mm:Track", $this->GetBaseURI() .
                            "/track/" . $track->GetMBId());
    $out .=   $this->Element("dc:title", $track->GetName());
    $out .=   $this->Element("mm:trackNum", $track->GetSequence());
    $out .=   $this->Element("dc:creator", "", "rdf:resource",
              $this->{baseuri}. "/artist/" . $artist->GetMBId());
    $out .=   $this->Element("mm:trmid", $guid) if defined $guid;
    $out .= $this->EndDesc("mm:Track");

    return $out;
}
