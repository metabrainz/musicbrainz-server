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

use 5.6.1;

package MM_2_1;

use TableBase;
use strict;
use RDF2;
use TRM;
use DBDefs;
use Discid;
use Artist;
use MM;
use Data::Dumper;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = qw(MM RDF2);
@EXPORT = @EXPORT = '';

sub new
{
    my ($type, $dbh) = @_;

    my $this = MM->new($dbh);
    return bless $this, $type;
}

sub GetMQNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/mm/mq-1.1#";
}

sub GetMMNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/mm/mm-2.1#";
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
    my ($out, $album, $track, $artist, $ids, $i, $attr);

    return "" if (!defined $this->GetBaseURI());

    $album = $ref->{obj};
    
    $artist = $this->GetFromCache('artist', $album->GetArtist()); 
    return "" if (!defined $artist);

    $out  = $this->BeginDesc("mm:Album", $this->GetBaseURI() .
                            "/album/" . $album->GetMBId());
    $out .=   $this->Element("dc:title", $album->GetName());
    $out .=   $this->Element("dc:creator", "", "rdf:resource",
                             $this->GetBaseURI() . "/artist/" . 
                             $artist->GetMBId());

    if (exists $ref->{"_cdindexid0"} && $ref->{"_cdindexid0"} ne '')
    {
        $out .=   $this->BeginDesc("mm:cdindexidList");
        $out .=   $this->BeginBag();

        for($i = 0;; $i++)
        {
            if (exists $ref->{"_cdindexid$i"} && $ref->{"_cdindexid$i"} ne '')
            {
                $out .= $this->Element("rdf:li", "", "rdf:resource", 
                                  $this->{baseuri} . "/cdindex/" . $ref->{"_cdindexid$i"});
            }
            else
            {
                last;
            }
        }

        $out .=   $this->EndBag();
        $out .=   $this->EndDesc("mm:cdindexidList");
    }

    my @attrs = $album->GetAttributes();
    foreach $attr (@attrs)
    {
        if ($attr >= Album::ALBUM_ATTR_SECTION_TYPE_START && 
            $attr <= Album::ALBUM_ATTR_SECTION_TYPE_END)
        {
           $out .= $this->Element("rdf:type", "", "rdf:resource", $this->GetMMNamespace() . $album->GetAttributeName($attr));
        }
        elsif ($attr >= Album::ALBUM_ATTR_SECTION_STATUS_START && 
               $attr <= Album::ALBUM_ATTR_SECTION_STATUS_END)
        {
           $out .= $this->Element("mm:release", "", "rdf:resource", $this->GetMMNamespace() . $album->GetAttributeName($attr));
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
    my ($out, $artist, @TRM, $gu, $track, $trm);

    if (!defined $this->GetBaseURI())
    {
        return "";
    }

    $track = $ref->{obj};
    $gu = TRM->new($this->{DBH});
    @TRM = $gu->GetTRMFromTrackId($track->GetId());

    $artist = $this->GetFromCache('artist', $track->GetArtist()); 
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

    if (scalar(@TRM) > 0)
    {
        $out .=   $this->BeginDesc("mm:trmidList");
        $out .=   $this->BeginBag();

        foreach $trm (@TRM)
        {
            $out .= $this->Element("rdf:li", "", "rdf:resource", 
                    $this->{baseuri} . "/trmid/" . $trm->{TRM});
        }

        $out .=   $this->EndBag();
        $out .=   $this->EndDesc("mm:trmidList");
    }
    $out .= $this->EndDesc("mm:Track");


    return $out;
}

sub CreateFreeDBLookup
{
   my ($this, $info) = @_;
   my ($item, $rdf, $tracks, $track, $i);

   $rdf  = $this->BeginRDFObject;
   $rdf .=   $this->BeginDesc("mq:Result");
   $rdf .=   $this->Element("mq:status", "OK");
   $rdf .=     $this->BeginDesc("mm:albumList");
   $rdf .=       $this->BeginBag();
   $rdf .=         $this->Li("freedb:genid1");
   $rdf .=       $this->EndBag();
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
1;
