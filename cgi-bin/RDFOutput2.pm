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

sub CreateAlbum
{
   my ($this, $fuzzy, $id) = @_;

   $this->{fuzzy} = 1;
   return $this->CreateOutputRDF('album', $id);
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
   my ($this, $curdepth, $type, $id, $obj) = @_;
   my (%item, $i, $cache, $ret);

   # check to make sure this object does not already exist in the list
   $cache = $this->{cache};
   foreach $i (@$cache)
   {
      return $i->{obj} if ($i->{id} == $id && $i->{type} eq $type);
   }

   $item{type} = $type;
   $item{id} = $id;
   $item{obj} = $obj;
   $item{depth} = $curdepth;
   $ret = \%item;
   push @$cache, $ret;

   return $ret;
}

# Get an object from the cache, given its id
sub GetFromCache
{
   my ($this, $type, $id) = @_;
   my ($i, $cache);

   # check to make sure this object does not already exist in the list
   $cache = $this->{cache};
   foreach $i (@$cache)
   {
      if ($i->{id} == $id && $i->{type} eq $type)
      {
          return $i->{obj} 
      }
   }
   return undef;
}

sub FindReferences
{
   my ($this, $curdepth, @ids) = @_;
   my ($id, $obj, @newrefs, $ref, $cacheref);

   print STDERR "Find: dep: $curdepth > ", $this->{depth} + 1, "\n";
   return if ($curdepth > $this->{depth} + 1);
     
   print STDERR "Find: adding\n";
   foreach $ref (@ids)
   {
      $obj = $this->LoadObject($ref->{id}, $ref->{type});
      print STDERR "Add to cache: $ref->{type}, $ref->{id} dep: $curdepth\n";
      $cacheref = AddToCache($this, $curdepth, $ref->{type}, $ref->{id}, $obj);
      push @newrefs, $this->GetReferences($cacheref);
   }
   $this->FindReferences($curdepth + 1, @newrefs);
}

sub CreateOutputRDF
{
   my ($this, $type, @ids) = @_;
   my (@cache, %obj, $id, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   return $this->CreateStatus() if (scalar(@ids) == 0);

   $depth = $this->GetDepth();
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 0);

   $this->{cache} = \@cache;
   print STDERR "Depth: $depth\n";

   # Create a cache of objects and add the passed object ids without
   # loading the actual objects
   foreach $id (@ids)
   {
      $obj{id} = $id;
      $obj{type} = $type;
      push @newrefs, {%obj};
   }

   # Call find references to recursively load and find referenced objects
   $this->FindReferences(1, @newrefs);

   # Now that we've compiled a list of objects, output the list and 
   # the actual objects themselves

   # Output the actual list of objects, making sure to only
   # include the first few objects in the cachce, not all of them.
   $total = scalar(@ids);
   for($i = 0; $i < $total; $i++)
   {
      if (!defined $cache[$i]->{obj})
      {
          push @gids, $cache[$i]->{id};
      }
      else
      {
          push @gids, $cache[$i]->{obj}->GetMBId();
      }
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
      print STDERR "Cache: $cache[$i]->{type} $cache[$i]->{id} dep: $cache[$i]->{depth}\n";
      next if $cache[$i]->{depth} > $depth;

      $out .= $this->OutputRDF(\@cache, $cache[$i]);
      $out .= "\n";
   }
   $out .= $this->EndRDFObject;

   return $out;
}

sub LoadObject
{
   my ($this, $id, $type) = @_;
   my $obj;

   if ($type eq 'artist')
   {
      $obj = Artist->new($this->{DBH});
   }
   elsif ($type eq 'album')
   {
      $obj = Album->new($this->{DBH});
   }
   elsif ($type eq 'track')
   {
      $obj = Track->new($this->{DBH});
   }
   elsif ($type eq 'trmid')
   {
      # In this case, we already have the TRMID, so there is no need to
      # load an object.
      $obj = undef;
   }

   return undef if (not defined $obj);

   $obj->SetId($id);
   $obj->LoadFromId();

   return $obj;
}

sub OutputList
{
   my ($this, $type, $list) = @_;
   my ($item, $rdf);

   $rdf  =   $this->BeginDesc("mq:Result");
   if (exists $this->{fuzzy})
   {
      $rdf .=  $this->Element("mq:status", "Fuzzy");
   }
   else
   {
      $rdf .=  $this->Element("mq:status", "OK");
   }
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

   return () if not defined $ref;

   # Artists and TRMIDs do not have any references, so they are not listed here
   return $this->GetAlbumReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'album');
   return $this->GetTrackReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'track');

   # If this type is not supported return an empty list
   return ();
}

# An for an album, add the artist ref and a ref for each track
sub GetAlbumReferences
{
   my ($this, $ref, $album) = @_;
   my (@tracks, $track, @ret, %info, @trackids, $albumartist);

   $albumartist = $album->GetArtist();
   $info{type} = 'artist';
   $info{id} = $album->GetArtist();
   $info{obj} = undef;
   push @ret, {%info};
   #print STDERR "album " .$album->GetId() . " needs artist: $info{id}\n";

   @tracks = $album->LoadTracks();
   foreach $track (@tracks)
   {
      if ($albumartist == 1)
      {
          $info{type} = 'artist';
          $info{id} = $track->GetArtist();
          $info{obj} = undef;
          push @ret, {%info};
          #print STDERR "malbum track " .$track->GetId() . " needs artist: $info{id}\n";
      }

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
   #print STDERR "track " .$track->GetId() . " needs artist: $info{id}\n";

   #$info{type} = 'album';
   #$info{id} = $track->GetAlbum();
   #$info{obj} = undef;
   #push @ret, {%info};
   #print STDERR "track " .$track->GetId() . " needs album: $info{id}\n";

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
   elsif ($ref->{type} eq 'trmid')
   {
      return "";
   }

   return "";
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
    
    $artist = GetFromCache($this, 'artist', $album->GetArtist()); 
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

    $artist = GetFromCache($this, 'artist', $track->GetArtist()); 

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
