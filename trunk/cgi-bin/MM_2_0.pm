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

package MM_2_0;

use MM;
use RDF2;
{ our @ISA = qw( MM RDF2 ) }

use strict;
use DBDefs;

sub GetMQNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/mm/mq-1.0#";
}

sub GetMMNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/mm/mm-2.0#";
}

sub GetARNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/ar/ar-1.0#";
}

sub GetAZNamespace
{
    my ($this) = @_;

    return "http://www.amazon.com/gp/aws/landing.html#";
}

# Return the RDF representation of the Artist
sub OutputArtistRDF
{
    my ($this, $ref) = @_;
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
    my ($this, $ref) = @_;
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
    for($i = 0;; $i++)
    {
        if (exists $album->{"_cdindexid$i"} && $album->{"_cdindexid$i"} ne '')
        {
            $out .=   $this->Element("mm:cdindexId", $album->{"_cdindexid$i"});
        }
        else
        {
            last;
        }
    }

    my @attrs = $album->GetAttributes();
    foreach $attr (@attrs)
    {
        if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START && 
            $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
        {
           $out .= $this->Element("rdf:type", "", "rdf:resource", $this->GetMMNamespace() . $album->GetAttributeName($attr));
        }
        elsif ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START && 
               $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END)
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
    my ($this, $ref) = @_;
    my ($out, $artist, $track);

    if (!defined $this->GetBaseURI())
    {
        return "";
    }

    $track = $ref->{obj};

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

1;
# eof MM_2_0.pm
