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

package MM_2_1;

use TableBase;
use strict;
use RDF2;
use TRM;
use DBDefs;
use Discid;
use Artist;
use MM;
use TaggerSupport;
use Data::Dumper;
use Carp qw(cluck);

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
           $out .= $this->Element("mm:releaseType", "", "rdf:resource", $this->GetMMNamespace() . 
                                  "Type" . $album->GetAttributeName($attr));
        }
        elsif ($attr >= Album::ALBUM_ATTR_SECTION_STATUS_START && 
               $attr <= Album::ALBUM_ATTR_SECTION_STATUS_END)
        {
           $out .= $this->Element("mm:releaseStatus", "", "rdf:resource", $this->GetMMNamespace() . 
                                  "Status" . $album->GetAttributeName($attr));
        }
    }

    if (exists $ref->{_album})
    {
        my $complete;

        $out .=   $this->BeginDesc("mm:trackList");
        $out .=   $this->BeginSeq();
        $ids = $ref->{_album};

        $complete = $$ids[scalar(@$ids) - 1]->{tracknum} != (scalar(@$ids) + 1);
        foreach $track (@$ids)
        {
            my $li = $complete ? "rdf:li" : ("rdf:_" . $track->{tracknum});
            $out .= $this->Element($li, "", "rdf:resource", 
                                   $this->{baseuri} . "/track/" . $track->{id});
        }

        $out .=   $this->EndSeq();
        $out .=   $this->EndDesc("mm:trackList");
    }

    if (exists $ref->{_track})
    {
        my ($trackid, $tracknum) = @{$ref->{_track}};

        $out .=   $this->BeginDesc("mm:trackList");
        $out .=   $this->BeginSeq();

        $out .= $this->Element("rdf:_" . $tracknum, "", "rdf:resource", 
                               $this->{baseuri} . "/track/" . $trackid);

        $out .=   $this->EndSeq();
        $out .=   $this->EndDesc("mm:trackList");
    }
    $out .= $this->EndDesc("mm:Album");

    return $out;
}

# Return the RDF representation of the Track
sub OutputTrackRDF
{
    my ($this, $ref, $album) = @_;
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

    if ($track->GetLength() != 0) 
    {
        $out .=   $this->Element("mm:duration", $track->GetLength());
    }
    if (defined $album)
    {
        $out .= $this->Element("mq:album", "", "rdf:resource",
                  $this->{baseuri}. "/album/" . $album->GetMBId());
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

# Internal
sub GetObject
{
   my ($this, $tagger, $type, $id, $mbid) = @_;
   my ($obj);

   if (exists $tagger->{$type} && defined $tagger->{$type})
   {
       $obj = $tagger->{$type};
       $this->AddToCache(0, $type, $obj);
   }
   else
   {
       $obj = $this->GetFromCache($type, $id, $mbid);
       if (!defined $obj)
       {
           $obj = $this->LoadObject($id, $mbid, $type);
           $this->AddToCache(0, $type, $obj);
       }
   }

   return $obj;
}

sub CreateFileLookup
{
   my ($this, $tagger, $error, $data, $flags, $list) = @_;
   my ($ar, $out, $id, $al, $tr);

   $this->{cache} = [];
   if (defined $error && $error ne '')
   {
       return $this->ErrorRDF($error);
   }

   $out  = $this->BeginRDFObject(exists $this->{file});

   if ($flags & TaggerSupport::ARTISTLIST)
   {
       $out .= $this->BeginDesc("mq:Result");
       $out .= $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       $out .= $this->BeginDesc("mq:lookupResultList");
       $out .= $this->BeginSeq();
       foreach $id (@$list)
       {
           $out .= $this->BeginDesc("rdf:li");
           $out .= $this->BeginDesc("mq:ArtistResult");

           $ar = $this->GetObject($tagger, 'artist', $id->{id});
           $out .=   $this->Element("mq:relevance", int(100 * $id->{sim}));
           $out .=   $this->Element("mq:artist", "", "rdf:resource",
                     $this->{baseuri}. "/artist/" . $ar->GetMBId());

           $out .= $this->EndDesc("mq:ArtistResult");
           $out .= $this->EndDesc("rdf:li");
       }
       $out .= $this->EndSeq();
       $out .= $this->EndDesc("mq:lookupResultList");
      
       $out .= $this->EndDesc("mq:Result");

       foreach $id (@$list)
       {
           $ar = $this->GetFromCache('artist', $id->{id});
           if (defined $ar)
           {
               $out .= $this->OutputArtistRDF({ obj=>$ar });
           }
       }
   }
   elsif ($flags & TaggerSupport::ALBUMLIST)
   {
       $out .= $this->BeginDesc("mq:Result");
       $out .= $this->Element("mq:status", 
                  ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       
       $out .= $this->BeginDesc("mq:lookupResultList");
       $out .= $this->BeginSeq();
       foreach $id (@$list)
       {
           $out .= $this->BeginDesc("rdf:li");
           $out .= $this->BeginDesc("mq:AlbumResult");

           $al = $this->GetObject($tagger, 'album', $id->{id});
           $out .=   $this->Element("mq:relevance", int(100 * $id->{sim}));
           $out .=   $this->Element("mq:album", "", "rdf:resource",
                     $this->{baseuri}. "/album/" . $al->GetMBId());

           $out .= $this->EndDesc("mq:AlbumResult");
           $out .= $this->EndDesc("rdf:li");
       }
       $out .= $this->EndSeq();
       $out .= $this->EndDesc("mq:lookupResultList");
      
       $out .= $this->EndDesc("mq:Result");

       $ar = $this->GetObject($tagger, 'artist', $id->{artistid});
       $out .= $this->OutputArtistRDF({ obj=>$ar });

       foreach $id (@$list)
       {
           $al = $this->GetFromCache('album', $id->{id});
           if (defined $al)
           {
               $out .= $this->OutputAlbumRDF({ obj=>$al });
           }
       }
   }
   # TODO: Output album metadata
   elsif ($flags & TaggerSupport::ALBUMTRACKLIST)
   {
       $out .= $this->BeginDesc("mq:Result");
       $out .= $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       

       $out .= $this->BeginDesc("mq:lookupResultList");
       $out .= $this->BeginSeq();
       foreach $id (@$list)
       {
           $out .= $this->BeginDesc("rdf:li");
           $out .= $this->BeginDesc("mq:AlbumTrackResult");

           $al = $this->GetObject($tagger, 'album', $id->{albumid});
           $tr = $this->GetObject($tagger, 'track', $id->{id});

           $out .=   $this->Element("mq:relevance", int(100 * $id->{sim}));
           $out .=   $this->Element("mq:album", "", "rdf:resource",
                     $this->{baseuri}. "/album/" . $al->GetMBId());
           $out .=   $this->Element("mq:track", "", "rdf:resource",
                     $this->{baseuri}. "/track/" . $tr->GetMBId());

           $out .= $this->EndDesc("mq:AlbumTrackResult");
           $out .= $this->EndDesc("rdf:li");
       }
       $out .= $this->EndSeq();
       $out .= $this->EndDesc("mq:lookupResultList");
      
       $out .= $this->EndDesc("mq:Result");

       $ar = $this->GetObject($tagger, 'artist', $id->{artistid});
       $out .= $this->OutputArtistRDF({ obj=>$ar });

       foreach $id (@$list)
       {
           $ar = $this->GetFromCache('album', $id->{albumid});
           $tr = $this->GetFromCache('track', $id->{id});
           if (defined $tr && defined $ar)
           {
               my $tracknum = $ar->GetTrackSequence($tr->GetId());
               $out .= $this->OutputAlbumRDF({ obj=>$al, _track=> [ $tr->GetMBId(), $tracknum ] });
               $out .= $this->OutputTrackRDF({ obj=>$tr });
           }
       }
   }
   elsif (($flags & TaggerSupport::ARTISTID) &&
          ($flags & TaggerSupport::ALBUMID) &&
          ($flags & TaggerSupport::TRACKID))
   {
       $ar = $this->GetObject($tagger, 'artist', undef, $data->{artistid});
       $al = $this->GetObject($tagger, 'album', undef, $data->{albumid});
       $tr = $this->GetObject($tagger, 'track', undef, $data->{trackid});

       $out .= $this->BeginDesc("mq:Result");
       $out .=    $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       $out .=    $this->Element("mq:artist", "", "rdf:resource", $this->{baseuri}. "/artist/" . $ar->GetMBId());
       $out .=    $this->Element("mq:album", "", "rdf:resource", $this->{baseuri}. "/album/" . $al->GetMBId());
       $out .=    $this->Element("mq:track", "", "rdf:resource", $this->{baseuri}. "/track/" . $tr->GetMBId());
       $out .= $this->EndDesc("mq:Result");

       my $tracknum = $al->GetTrackSequence($tr->GetId());
       $out .= $this->OutputArtistRDF({ obj=>$ar });
       $out .= $this->OutputAlbumRDF({ obj=>$al, _track=> [ $tr->GetMBId(), $tracknum ] });
       $out .= $this->OutputTrackRDF({ obj=>$tr });
   }
   elsif (($flags & TaggerSupport::ARTISTID) &&
          ($flags & TaggerSupport::TRACKID))
   {
       $ar = $this->GetObject($tagger, 'artist', undef, $data->{artistid});
       $tr = $this->GetObject($tagger, 'track', undef, $data->{trackid});

       $out .= $this->BeginDesc("mq:Result");
       $out .=    $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       $out .=    $this->Element("mq:artist", "", "rdf:resource", $this->{baseuri}. "/artist/" . $ar->GetMBId());
       $out .=    $this->Element("mq:track", "", "rdf:resource", $this->{baseuri}. "/track/" . $tr->GetMBId());
       $out .= $this->EndDesc("mq:Result");

       $out .= $this->OutputArtistRDF({ obj=>$ar });
       $out .= $this->OutputTrackRDF({ obj=>$tr });
   }
   elsif (($flags & TaggerSupport::ARTISTID) &&
          ($flags & TaggerSupport::ALBUMID))
   {
       $ar = $this->GetObject($tagger, 'artist', undef, $data->{artistid});
       $al = $this->GetObject($tagger, 'album', undef, $data->{albumid});

       $out .= $this->BeginDesc("mq:Result");
       $out .=    $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       $out .=    $this->Element("mq:artist", "", "rdf:resource", $this->{baseuri}. "/artist/" . $ar->GetMBId());
       $out .=    $this->Element("mq:album", "", "rdf:resource", $this->{baseuri}. "/album/" . $al->GetMBId());
       $out .= $this->EndDesc("mq:Result");

       $out .= $this->OutputArtistRDF({ obj=>$ar });
       $out .= $this->OutputAlbumRDF({ obj=>$al });
   }
   elsif ($flags & TaggerSupport::ARTISTID)
   {
       $ar = $this->GetObject($tagger, 'artist', undef, $data->{artistid});

       $out .= $this->BeginDesc("mq:Result");
       $out .=    $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       $out .=    $this->Element("mq:artist", "", "rdf:resource", $this->{baseuri}. "/artist/" . $ar->GetMBId());
       $out .= $this->EndDesc("mq:Result");

       $out .= $this->OutputArtistRDF({ obj=>$ar });
   }
   else
   {
       return $this->ErrorRDF("No artists matched.");
   }
   $out .= $this->EndRDFObject;

   return $out;
}
1;
