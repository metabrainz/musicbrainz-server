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

package MM;

use TableBase;
use strict;
use RDF2;
use TRM;
use DBDefs;
use Discid;
use Artist;
use Data::Dumper;

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

sub CreateDenseTrackList
{
   my ($this, $gids) = @_;
   my ($out, $ar, $al, $tr, $id, @ids);

   $this->{status} = "OK";

   $out  = $this->BeginRDFObject();
   $out .= $this->BeginDesc("mq:Result");
   $out .= $this->OutputList('track', $gids);
   $out .= $this->EndDesc("mq:Result") . "\n";

   $this->{cache} = [];
   foreach $id (@{$gids})
   {
       $tr = Track->new($this->{DBH});
       $tr->SetMBId($id);
       $tr->LoadFromId();

       $ar = Artist->new($this->{DBH});
       $ar->SetId($tr->GetArtist());
       $ar->LoadFromId();

       $al = Album->new($this->{DBH});
       @ids = $al->GetAlbumIdsFromTrackId($tr->GetId());
       $al->SetId($ids[0]);
       $al->LoadFromId();
       my $tracknum = $al->GetTrackSequence($tr->GetId());
   
       $this->AddToCache(0, 'artist', $ar);

       $out .= $this->OutputTrackRDF({ obj=>$tr }, $al) . "\n";
       $out .= $this->OutputArtistRDF({ obj=>$ar }) . "\n";
       $out .= $this->OutputAlbumRDF({ obj=>$al, _track=> [ $tr->GetMBId(), $tracknum ] });
   }

   $out .= $this->EndRDFObject;

   if (exists $this->{file})
   {
       print {$this->{file}} $out;
       $out = "";
   }

   return $out;
}

sub CreateTRMList
{
   my ($this, @ids) = @_;

   $this->{status} = "OK";
   return $this->CreateOutputRDF('trmid', @ids);
}


sub CreateDumpRDF
{
   my ($this, $artistid) = @_;
   my ($ar, $al, %ref, @albumids, $rdf, @albums, @tracks, $tr);

   $this->{cache} = [];

   $ar = Artist->new($this->{DBH});
   $ar->SetId($artistid);
   if (not defined $ar->LoadFromId())
   {
       return $this->ErrorRDF("Invalid artist specified.");
   }

   @albums = $ar->GetAlbums(1);
   @albums = sort { $a->GetMBId() cmp $b->GetMBId() } @albums;
   foreach $al (@albums)
   {
       push @albumids, $al->GetMBId();
   }

   $ref{obj} = $ar;
   $ref{_artist} = \@albumids;

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->OutputArtistRDF(\%ref) . "\n";

   $this->AddToCache(1, 'artist', $ar);

   foreach $al (@albums)
   {
       $ref{obj} = $al;
       #$ref{_artist} = \@albumids;

       $rdf .= $this->OutputAlbumRDF(\%ref) . "\n";;
       push @tracks, $al->LoadTracks();
   }

   @tracks = sort { $a->GetMBId() cmp $b->GetMBId() } @tracks;
   foreach $tr (@tracks)
   {
       $ref{obj} = $tr;
       #$ref{_artist} = \@albumids;

       $rdf .= $this->OutputTrackRDF(\%ref) . "\n";;
   }

   $rdf .= $this->EndRDFObject;

   return $rdf;
}

# Check for duplicates, then add if not already in cache
sub AddToCache
{
    my ($this, $curdepth, $type, $obj) = @_;
    my (%item, $i, $cache, $ret);

    return undef if (!defined $curdepth || !defined $type || !defined $obj);

    # TODO: Probably best to use a hash for this, rather than scanning the
    # list each time.
    $cache = $this->{cache};
    foreach $i (@$cache)
    {
        next if ($i->{type} ne $type);
        if ((exists $i->{id} && $i->{id} == $obj->GetId()) ||
            (exists $i->{mbid} && $i->{mbid} eq $obj->GetMBId))
        {
            return $i;
        }
    }

    $item{type} = $type;
    $item{id} = $obj->GetId();
    $item{mbid} = $obj->GetMBId();
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

    return undef if (!defined $type || (!defined $id && !defined $mbid));

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
          $obj = $this->LoadObject($ref->{id}, $ref->{mbid}, $ref->{type});
      }
      next if (!defined $obj);

      $cacheref = $this->AddToCache($curdepth, $ref->{type}, $obj);
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

   die if (not defined $this->GetBaseURI() || $this->GetBaseURI() eq '');
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
   #$info{obj} = undef;
   #push @ret, {%info};

   return @ret;
}

sub OutputRDF
{
   my ($this, $cache, $ref) = @_;

   if ($ref->{type} eq 'artist')
   {
      return $this->OutputArtistRDF($ref);
   }
   elsif ($ref->{type} eq 'album')
   {
      return $this->OutputAlbumRDF($ref);
   }
   elsif ($ref->{type} eq 'track')
   {
      return $this->OutputTrackRDF($ref);
   }
   elsif ($ref->{type} eq 'trmid')
   {
      return "";
   }

   return "";
}

1;
