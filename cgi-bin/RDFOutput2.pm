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
use TRM;
use DBDefs;
use Discid;
use Artist;
use Data::Dumper;

BEGIN { require 5.6.1 }
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

sub CreateTRMList
{
   my ($this, @ids) = @_;

   $this->{status} = "OK";
   return $this->CreateOutputRDF('trmid', @ids);
}

sub CreateFileLookup
{
   my ($this, $tagger, $matchType) = @_;
   my (@cache, %obj, $id, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   return $this->CreateStatus() if (!defined $tagger);

   $depth = $this->GetDepth();
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 1);
   #print STDERR "Depth: $depth\n";

   $this->{cache} = \@cache;

   $out  = $this->BeginRDFObject(exists $this->{file});
   $out .= $this->BeginDesc("mq:Result");
   $out .= $this->Element("mq:status", $tagger->{fuzzy} ? "Fuzzy" : "OK");
   $out .= $this->Element("mq:matchType", $matchType);

   # Load the artists or artistlist of Ids
   if (exists $tagger->{artistid})
   {
       $obj{mbid} = $tagger->{artistid};
       $obj{type} = 'artist';
       push @newrefs, {%obj};

       $out .= $this->OutputList('artist', [$tagger->{artistid}]);

       if (exists $tagger->{artist})
       {
           $this->AddToCache($depth, 'artist', 
                             $tagger->{artist}->GetId(), 
                             $tagger->{artist}->GetMBId(), 
                             $tagger->{artist});
       }
   }
   elsif (exists $tagger->{artistlist})
   {
       my $aref = $tagger->{artistlist};

       $out .= $this->OutputList('artist', $tagger->{artistlist});
       foreach $ref (@$aref)
       {
           $obj{mbid} = $ref;
           $obj{type} = 'artist';
           push @newrefs, {%obj};
       }
   }

   # Load the albums or albumlist of Ids
   if (exists $tagger->{albumid})
   {
       $obj{mbid} = $tagger->{albumid};
       $obj{type} = 'album';
       push @newrefs, {%obj};

       $out .= $this->OutputList('album', [$tagger->{albumid}]);

       if (exists $tagger->{album})
       {
           $this->AddToCache($depth, 'album', 
                             $tagger->{album}->GetId(), 
                             $tagger->{album}->GetMBId(), 
                             $tagger->{album});
       }
   }
   elsif (exists $tagger->{albumlist})
   {
       my $aref = $tagger->{albumlist};
       $out .= $this->OutputList('album', $tagger->{albumlist});
       foreach $ref (@$aref)
       {
           $obj{mbid} = $ref;
           $obj{type} = 'album';
           push @newrefs, {%obj};
       }
   }

   # Load the tracks or tracklist of Ids
   if (exists $tagger->{trackid})
   {
       $obj{mbid} = $tagger->{trackid};
       $obj{type} = 'track';
       push @newrefs, {%obj};

       $out .= $this->OutputList('track', [$tagger->{trackid}]);

       if (exists $tagger->{track})
       {
           $this->AddToCache($depth, 'track', 
                             $tagger->{track}->GetId(), 
                             $tagger->{track}->GetMBId(), 
                             $tagger->{track});
       }
   }
   elsif (exists $tagger->{tracklist})
   {
       my $aref = $tagger->{tracklist};
       $out .= $this->OutputList('track', $tagger->{tracklist});
       foreach $ref (@$aref)
       {
           $obj{mbid} = $ref;
           $obj{type} = 'track';
           push @newrefs, {%obj};
       }
   }

   $out .= $this->EndDesc("mq:Result");
   $out .= "\n";

   # Call find references to recursively load and find referenced objects
   $this->FindReferences(0, @newrefs);

   # Output all of the referenced objects. Make sure to only output
   # the objects in the cache that have been loaded. The objects that
   # have not been loaded will not be output, even though they are
   # in the cache. (They would've been output if depth was one greater)
   $total = scalar(@cache);
   for($i = 0; $i < $total; $i++)
   {
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

# Check for duplicates, then add if not already in cache
sub AddToCache
{
   my ($this, $curdepth, $type, $id, $mbid, $obj) = @_;
   my (%item, $i, $cache, $ret);

   return undef if (!defined $curdepth || !defined $type || !defined $obj);
   return undef if (!defined $id && !defined $mbid);

   # TODO: Probably best to use a hash for this, rather than scanning the
   # list each time.
   $cache = $this->{cache};
   foreach $i (@$cache)
   {
      next if ($i->{type} ne $type);
      if ((defined $id && exists $i->{id} && $i->{id} == $id) ||
          (defined $mbid && exists $i->{mbid} && $i->{mbid} eq $mbid))
      {
          return $i->{obj} 
      }
   }

   $item{type} = $type;
   $item{id} = $id;
   $item{mbid} = $mbid;
   $item{obj} = $obj;
   $item{depth} = $curdepth;
   $ret = \%item;
   push @$cache, $ret;

   return $ret;
}

# Get an object from the cache, given its id
sub GetFromCache
{
   my ($this, $type, $id, $mbid) = @_;
   my ($i, $cache);

   return undef if (!defined $type || !defined $id);

   # check to make sure this object does not already exist in the list
   $cache = $this->{cache};
   foreach $i (@$cache)
   {
      next if ($i->{type} ne $type);
      if ((defined $id && exists $i->{id} && $i->{id} == $id) ||
          (defined $mbid && exists $i->{mbid} && $i->{mbid} eq $mbid))
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


   #print STDERR "\n" if ($curdepth > $this->{depth});
   return if ($curdepth > $this->{depth});

   #print STDERR "Find references: $curdepth max: $this->{depth}\n";
    
   $curdepth+=2;

   # Load all of the referenced objects
   foreach $ref (@ids)
   {
      #print STDERR "  Object: $ref->{type} ";
      #print STDERR "$ref->{id} " if defined $ref->{id};
      #print STDERR "($ref->{mbid}) " if defined $ref->{mbid};
      #print STDERR "--> ";
      $obj = $this->GetFromCache($ref->{type}, $ref->{id}, $ref->{mbid});
      if (!defined $obj)
      {
          #print STDERR "load\n";
          $obj = $this->LoadObject($ref->{id}, $ref->{mbid}, $ref->{type});
      }
      else
      {
          #print STDERR "cached\n";
      }
      next if (!defined $obj);

      $cacheref = AddToCache($this, $curdepth, $ref->{type}, $ref->{id}, $ref->{mbid}, $obj);
      if (defined $cacheref)
      {
           push @newrefs, $this->GetReferences($cacheref, $curdepth);
      }
   }

   $this->FindReferences($curdepth, @newrefs);
}

sub CreateOutputRDF
{
   my ($this, $type, @ids) = @_;
   my (@cache, %obj, $id, $ref, @newrefs, $i, $total, @gids, $out, $depth); 

   return $this->CreateStatus() if (!defined $ids[0]);

   $depth = $this->GetDepth();
   return $this->ErrorRDF("Invalid search depth specified.") if ($depth < 1);

   $this->{cache} = \@cache;

   # Create a cache of objects and add the passed object ids without
   # loading the actual objects
   foreach $id (@ids)
   {
      $obj{id} = $id;
      $obj{type} = $type;
      push @newrefs, {%obj};
   }

   # Call find references to recursively load and find referenced objects
   $this->FindReferences(0, @newrefs);

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
   $out .= $this->BeginDesc("mq:Result");
   $out .= $this->OutputList($type, \@gids);
   $out .= $this->EndDesc("mq:Result");

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
   my ($this, $id, $mbid, $type) = @_;
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

   if (defined $mbid)
   {
       $obj->SetMBId($mbid);
   }
   else
   {
       $obj->SetId($id);
   }
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

   $rdf =    $this->Element("mq:status", $this->{status});
   $rdf .=     $this->BeginDesc("mm:" . $type . "List");
   $rdf .=       $this->BeginBag();
   foreach $item (@$list)
   {
      next if (!defined $item);
      $rdf .=      $this->Li($this->{baseuri}. "/$type/$item");
   }
   $rdf .=       $this->EndBag();
   $rdf .=     $this->EndDesc("mm:" . $type . "List");
   $rdf .= "\n";

   return $rdf;
}

sub GetReferences
{
   my ($this, $ref, $depth) = @_;

   return () if not defined $ref;

   # Artists and TRMIDs do not have any references, so they are not listed here
   return $this->GetArtistReferences($ref, $ref->{obj}, $depth) 
       if ($ref->{type} eq 'artist');
   return $this->GetAlbumReferences($ref, $ref->{obj}, $depth) 
       if ($ref->{type} eq 'album');
   return $this->GetTrackReferences($ref, $ref->{obj}, $depth) 
       if ($ref->{type} eq 'track');

   # If this type is not supported return an empty list
   return ();
}

# For an Artist, add a ref for each album
sub GetArtistReferences
{
   my ($this, $ref, $artist, $depth) = @_;
   my (@albums, @albumids, $album, %info, @ret);

   if ($artist->GetId() == ModDefs::VARTIST_ID ||
       $depth >= $this->{depth})
   {
       return ();
   }

   @albums = $artist->GetAlbums();
   foreach $album (@albums)
   {
      next if not defined $album;
      $info{type} = 'album';
      $info{id} = $album->GetId();
      $info{obj} = undef;
      push @ret, {%info};
      push @albumids, $album->GetMBId();
   }
   $ref->{_artist} = \@albumids;

   return @ret;
}

# And for an album, add the artist ref and a ref for each track
sub GetAlbumReferences
{
   my ($this, $ref, $album, $depth) = @_;
   my (@tracks, $track, @ret, %info, @trackids, $albumartist, $di);
   my (@albumrefs, $aref, $index);

   $albumartist = $album->GetArtist();
   $info{type} = 'artist';
   $info{id} = $album->GetArtist();
   $info{obj} = undef;
   push @ret, {%info};

   if ($depth < $this->{depth})
   {
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
         }
   
         $info{type} = 'track';
         $info{obj} = $track;
         $info{id} = $track->GetId();
         push @ret, {%info};
   
         push @trackids, { id=>$track->GetMBId(), 
                           tracknum=>$track->GetSequence() };
      }
      $ref->{_album} = \@trackids;
   }

   $di = Discid->new($this->{DBH});

   $index = 0;
   @albumrefs = $di->GetDiscidFromAlbum($album->GetId());
   foreach $aref (@albumrefs)
   {
      $ref->{"_cdindexid$index"} = $aref->{discid};
      $index++;
   }

   return @ret;
}

# An for a track, add the artist and album refs
sub GetTrackReferences
{
   my ($this, $ref, $track, $depth) = @_;
   my (@ret, %info);

   # TODO: Should the TRM output also be a seperate depth?
   $info{type} = 'artist';
   $info{id} = $track->GetArtist();
   $info{tracknum} = $track->GetSequence();
   $info{obj} = undef;
   push @ret, {%info};

   #$info{type} = 'album';
   #$info{id} = $track->GetAlbum();
   #$info{obj} = undef;
   #push @ret, {%info};

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

    if (exists $ref->{_artist})
    {
        $out .=   $this->BeginDesc("mm:albumList");
        $out .=   $this->BeginBag();
        $ids = $ref->{_artist};
        foreach $album (@$ids)
        {
           next if not defined $album;
           $out .=      $this->Li($this->{baseuri}. "/album/$album");
        }
        $out .=   $this->EndBag();
        $out .=   $this->EndDesc("mm:albumList");
    }
    $out .= $this->EndDesc("mm:Artist");


    return $out;
}

# Return the RDF representation of the Album
sub OutputAlbumRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $album, $track, $artist, $ids, $i);

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
    for($i = 0;; $i++)
    {
        if (exists $ref->{"_cdindexid$i"} && $ref->{"_cdindexid$i"} ne '')
        {
            $out .=   $this->Element("mm:cdindexId", $ref->{"_cdindexid$i"});
        }
        else
        {
            last;
        }
    }

    if (exists $ref->{_album})
    {
        $out .=   $this->BeginDesc("mm:trackList");
        $out .=   $this->BeginSeq();
        $ids = $ref->{_album};
        foreach $track (@$ids)
        {
           $out .= $this->Element("rdf:li", "", "rdf:resource", 
                                  $this->{baseuri} . "/track/" . $track->{id});
                                  #"mm:trackNum", $track->{tracknum});
        }
        $out .=   $this->EndSeq();
        $out .=   $this->EndDesc("mm:trackList");
    }
    $out .= $this->EndDesc("mm:Album");

    return $out;
}

# Return the RDF representation of the Track
sub OutputTrackRDF
{
    my ($this, $cache, $ref) = @_;
    my ($out, $artist, @TRM, $gu, $track);

    if (!defined $this->GetBaseURI())
    {
        return "";
    }

    $track = $ref->{obj};
    $gu = TRM->new($this->{DBH});
    @TRM = $gu->GetTRMFromTrackId($track->GetId());

    $artist = GetFromCache($this, 'artist', $track->GetArtist()); 
    return "" if (!defined $artist);

    $out  = $this->BeginDesc("mm:Track", $this->GetBaseURI() .
                            "/track/" . $track->GetMBId());
    $out .=   $this->Element("dc:title", $track->GetName());

    $out .=   $this->Element("dc:creator", "", "rdf:resource",
              $this->{baseuri}. "/artist/" . $artist->GetMBId());

    $out .=   $this->Element("mm:trackNum", $track->GetSequence());
    if ($track->GetLength() != 0) 
    {
        $out .=   $this->Element("mm:duration", $track->GetLength());
    }
    $out .=   $this->Element("mm:trmid", $TRM[0]->{TRM}) if scalar(@TRM);
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
   $rdf .= $this->Element("mm:trmid", "", TRM=>$data[4])
       unless !defined $data[4] || $data[4] eq '';
   $rdf .= $this->Element("mm:issued", $data[6])
       unless !defined $data[6] || $data[6] == 0;
   $rdf .= $this->Element("mm:genre", $data[7])
       unless !defined $data[7] || $data[7] eq '';
   $rdf .= $this->Element("dc:description", $data[8])
       unless !defined $data[8] || $data[8] eq '';
   $rdf .= $this->Element("mm:duration", $data[9])
       unless !defined $data[9] || $data[9] == 0;
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

sub CreateAuthenticateResponse
{
   my ($this, $sessionid, $challenge) = @_;
   my ($rdf);

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc("mq:Result");
   $rdf .= $this->Element("mq:status", "OK");
   $rdf .= $this->Element("mq:sessionId", $sessionid);
   $rdf .= $this->Element("mq:authChallenge", $challenge);
   $rdf .= $this->EndDesc("mq:Result");
   $rdf .= $this->EndRDFObject();

   return $rdf;
}
