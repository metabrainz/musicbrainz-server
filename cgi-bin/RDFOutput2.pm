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

sub SetOutputFile
{
    $_[0]->{file} = $_[1];
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

   $this->{status} = "OK";
   return $this->CreateOutputRDF('artist', @ids);
}

sub CreateAlbum
{
   my ($this, $fuzzy, $id) = @_;

   $this->{status} = $fuzzy ? "Fuzzy" : "OK";
   return $this->CreateOutputRDF('album', $id);
}

sub CreateAlbumList
{
   my ($this, @ids) = @_;

   $this->{status} = "OK";
   return $this->CreateOutputRDF('album', @ids);
}

sub CreateTrackList
{
   my ($this, @ids) = @_;

   $this->{status} = "OK";
   return $this->CreateOutputRDF('track', @ids);
}

sub CreateGUIDList
{
   my ($this, @ids) = @_;

   $this->{status} = "OK";
   return $this->CreateOutputRDF('trmid', @ids);
}

# Check for duplicates, then add if not already in cache
sub AddToCache
{
   my ($this, $curdepth, $type, $id, $obj) = @_;
   my (%item, $i, $cache, $ret);

   return undef if (!defined $curdepth || !defined $type || 
                    !defined $id || !defined $obj);

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

   return undef if (!defined $type || !defined $id);

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

   #print STDERR "Find: dep: $curdepth > ", $this->{depth} + 1, "\n";
   return if ($curdepth > $this->{depth} + 1);
     
   #print STDERR "Find: adding\n";
   foreach $ref (@ids)
   {
      $obj = $this->LoadObject($ref->{id}, $ref->{type});
      next if (!defined $obj);

      #print STDERR "Add to cache: $ref->{type}, $ref->{id} dep: $curdepth\n";
      $cacheref = AddToCache($this, $curdepth, $ref->{type}, $ref->{id}, $obj);

      push @newrefs, $this->GetReferences($cacheref)
         if (defined $cacheref);
   }
   #print STDERR "New refs: " . join(", ", @newrefs) . "\n";
   $this->FindReferences($curdepth + 1, @newrefs);
}

sub CreateOutputRDF
{
   my ($this, $type, @ids) = @_;
   my (@cache, %obj, $id, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   return $this->CreateStatus() if (!defined $ids[0]);

   $depth = $this->GetDepth();
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 0);

   $this->{cache} = \@cache;
   #print STDERR "Depth: $depth\n";

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
          if (defined $cache[$i]->{id})
          {
              push @gids, $cache[$i]->{id};
          }
      }
      else
      {
          push @gids, $cache[$i]->{obj}->GetMBId();
      }
   }
   $out  = $this->BeginRDFObject(exists $this->{file});
   $out .= $this->OutputList($type, \@gids);

   if (exists $this->{file})
   {
       print {$this->{file}} $out;
       $out = "";
   }
  
   # Output all of the referenced objects. Make sure to only output
   # the objects in the cache that have been loaded. The objects that
   # have not been loaded will not be output, even though they are
   # in the cache. (They would've been output if depth was one greater)
   $total = scalar(@cache);
   for($i = 0; $i < $total; $i++)
   {
      #print STDERR "Cache: $cache[$i]->{type} $cache[$i]->{id} dep: $cache[$i]->{depth}\n";
      next if (!defined $cache[$i]->{depth} || $cache[$i]->{depth} > $depth);

      $out .= $this->OutputRDF(\@cache, $cache[$i]);
      $out .= "\n";
      if (exists $this->{file})
      {
          print {$this->{file}} $out;
          $out = "";
      }
   }

   $out .= $this->EndRDFObject;
   if (exists $this->{file})
   {
       print {$this->{file}} $out;
       $out = "";
   }

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
   if (!defined $obj->LoadFromId())
   {
       return undef;
   }

   return $obj;
}

sub OutputList
{
   my ($this, $type, $list) = @_;
   my ($item, $rdf);

   $rdf  =   $this->BeginDesc("mq:Result");
   $rdf .=   $this->Element("mq:status", $this->{status});
   $rdf .=     $this->BeginDesc("mm:" . $type . "List");
   $rdf .=       $this->BeginSeq();
   foreach $item (@$list)
   {
      next if (!defined $item);
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
   return $this->GetArtistReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'artist');
   return $this->GetAlbumReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'album');
   return $this->GetTrackReferences($ref, $ref->{obj}) 
       if ($ref->{type} eq 'track');

   # If this type is not supported return an empty list
   return ();
}

# For an Artist, add a ref for each album
sub GetArtistReferences
{
   my ($this, $ref, $artist) = @_;
   my (@albums, @albumids, $album, %info, @ret);

   @albums = $artist->GetAlbums();
   foreach $album (@albums)
   {
      next if not defined $album;
      $info{type} = 'album';
      $info{id} = $album->GetId();
      $info{obj} = undef;
      push @ret, {%info};
      push @albumids, $album->GetMBId();
      #print STDERR "artist " .$artist->GetId() . " needs album: $info{id}\n";
      #print STDERR $albumids[0], "\n";
   }
   $ref->{_artist} = \@albumids;

   return @ret;
}

# And for an album, add the artist ref and a ref for each track
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
      next if not defined $track;
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
    my ($out, $artist, $ids, $album);

    return "" if (!defined $this->GetBaseURI());
    $artist = $ref->{obj};

    $out  = $this->BeginDesc("mm:Artist", $this->GetBaseURI() .
                            "/artist/" . $artist->GetMBId());
    $out .=   $this->Element("dc:title", $artist->GetName());
    $out .=   $this->Element("mm:sortName", $artist->GetSortName());
    $out .=   $this->BeginDesc("mm:albumList");
    $out .=   $this->BeginSeq();
    $ids = $ref->{_artist};
    foreach $album (@$ids)
    {
       next if not defined $album;
       $out .=      $this->Li($this->{baseuri}. "/album/$album");
    }
    $out .=   $this->EndSeq();
    $out .=   $this->EndDesc("mm:albumList");
    $out .= $this->EndDesc("mm:Artist");

    return $out;
}

# Return the RDF representation of the Album
sub OutputAlbumRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $album, $track, $artist, $ids);

    return "" if (!defined $this->GetBaseURI());

    $album = $ref->{obj};
    
    $artist = GetFromCache($this, 'artist', $album->GetArtist()); 
    return "" if (!defined $artist);

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
    my ($out, $artist, @guid, $gu, $track);

    return "" if (!defined $this->GetBaseURI());
    $track = $ref->{obj};
    $gu = GUID->new($this->{DBH});
    @guid = $gu->GetGUIDFromTrackId($track->GetId());

    $artist = GetFromCache($this, 'artist', $track->GetArtist()); 
    return "" if (!defined $artist);

    $out  = $this->BeginDesc("mm:Track", $this->GetBaseURI() .
                            "/track/" . $track->GetMBId());
    $out .=   $this->Element("dc:title", $track->GetName());
    $out .=   $this->Element("mm:trackNum", $track->GetSequence());
    $out .=   $this->Element("dc:creator", "", "rdf:resource",
              $this->{baseuri}. "/artist/" . $artist->GetMBId());
    $out .=   $this->Element("mm:trmid", $guid[0]) if scalar(@guid);
    $out .= $this->EndDesc("mm:Track");

    return $out;
}

sub CreateMetadataExchange
{
   my ($this, @data) = @_;
   my ($rdf);

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc("mq:Result");
   $rdf .=   $this->Element("mq:status", "OK");
   $rdf .= $this->Element("mq:trackName", $data[0])
       unless !defined $data[0] || $data[0] eq '';
   $rdf .= $this->Element("mq:artistName", $data[1])
       unless !defined $data[1] || $data[1] eq '';
   $rdf .= $this->Element("mq:albumName", $data[2])
       unless !defined $data[2] || $data[2] eq '';
   $rdf .= $this->Element("mm:trackNum", $data[3])
       unless !defined $data[3] || $data[3] == 0;
   $rdf .= $this->Element("mm:trmid", "", guid=>$data[4])
       unless !defined $data[4] || $data[4] eq '';
   $rdf .= $this->Element("mm:issued", $data[6])
       unless !defined $data[6] || $data[6] == 0;
   $rdf .= $this->Element("mm:genre", $data[7])
       unless !defined $data[7] || $data[7] eq '';
   $rdf .= $this->Element("dc:description", $data[8])
       unless !defined $data[8] || $data[8] eq '';
   $rdf .= $this->Element("mm:duration", $data[13])
       unless !defined $data[13] || $data[13] == 0;
   $rdf .= $this->EndDesc("mq:Result");
   $rdf .= $this->EndRDFObject();

   return $rdf;
}

sub CreateFreeDBLookup
{
   my ($this, $info) = @_;
   my ($item, $rdf, $tracks, $track, $i);

   $rdf  = $this->BeginRDFObject;
   $rdf .=   $this->BeginDesc("mq:Result");
   $rdf .=   $this->Element("mq:status", "OK");
   $rdf .=     $this->BeginDesc("mm:albumList");
   $rdf .=       $this->BeginSeq();
   $rdf .=         $this->Li("freedb:genid1");
   $rdf .=       $this->EndSeq();
   $rdf .=     $this->EndDesc("mm:albumList");
   $rdf .=   $this->EndDesc("mq:Result");

   $rdf .=   $this->BeginDesc("mm:Artist", "freedb:genid2");
   $rdf .=   $this->Element("dc:title", $info->{artist});
   $rdf .=   $this->Element("mm:sortName", $info->{sortname});
   $rdf .=   $this->EndDesc("mm:Artist");

   $rdf .=   $this->BeginDesc("mm:Album", "freedb:genid1");
   $rdf .=     $this->Element("dc:title", $info->{album});
   $rdf .=     $this->Element("dc:creator", "", 
                              "rdf:resource", "freedb:genid2");  
   $rdf .=     $this->BeginDesc("mm:trackList");
   $rdf .=       $this->BeginSeq();

   $tracks = $info->{tracks};
   $i = 3;
   foreach $track (@$tracks)
   {
       $rdf .=      $this->Li("freedb:genid$i");
       $i++;
   }
   $rdf .=       $this->EndSeq();
   $rdf .=   $this->EndDesc("mm:trackList");
   $rdf .=   $this->EndDesc("mm:Album");

   $i = 3;
   foreach $track (@$tracks)
   {
       $rdf .=   $this->BeginDesc("mm:Track", "freedb:genid$i");
       $rdf .=      $this->Element("dc:title", $track->{track});
       $rdf .=      $this->Element("mm:trackNum", $track->{tracknum});
       $rdf .=      $this->Element("dc:creator", "", 
                                   "rdf:resource", "freedb:genid2");  
       $rdf .=   $this->EndDesc("mm:Track");
       $i++;
   }

   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub DumpBegin
{
   my ($this, $type, @gids) = @_;

   return undef if (!exists $this->{file});

   print {$this->{file}} $this->BeginRDFObject(1);
   print {$this->{file}} $this->OutputList($type, \@gids);

   return 1;
}

sub DumpArtist
{
   my ($this, $type, $id) = @_;
   my (@cache, %obj, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   $depth = $this->{depth};
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 0);

   $this->{cache} = \@cache;

   # Create a cache of objects and add the passed object ids without
   # loading the actual objects
   $obj{id} = $id;
   $obj{type} = $type;
   push @newrefs, {%obj};

   # Call find references to recursively load and find referenced objects
   $this->FindReferences(1, @newrefs);

   # Output all of the referenced objects. Make sure to only output
   # the objects in the cache that have been loaded. The objects that
   # have not been loaded will not be output, even though they are
   # in the cache. (They would've been output if depth was one greater)
   $total = scalar(@cache);
   for($i = 0; $i < $total; $i++)
   {
      #print STDERR "Cache: $cache[$i]->{type} $cache[$i]->{id} dep: $cache[$i]->{depth}\n";
      next if (!defined $cache[$i]->{depth} || $cache[$i]->{depth} > $depth);

      print {$this->{file}} $this->OutputRDF(\@cache, $cache[$i]) . "\n";
   }

   return 1;
}

sub DumpEnd
{
   my ($this) = @_;

   print {$this->{file}} $this->EndRDFObject;
}
