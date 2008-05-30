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

package MM_2_1;

use MM;
use RDF2;
{ our @ISA = qw( MM RDF2 ) }

use strict;
use DBDefs;
use TaggerSupport; # for constants
use Carp qw( carp cluck croak confess );

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

sub GetAZNamespace
{
    my ($this) = @_;

    return "http://www.amazon.com/gp/aws/landing.html#";
}

sub GetARNamespace
{
    my ($this) = @_;

    return "http://musicbrainz.org/ar/ar-1.0#";
}

# Return the RDF representation of the Artist
sub OutputArtistRDF
{
    my ($this, $ref) = @_;
    my ($out, $artist, $ids, $album);

    return "" if (!defined $this->GetBaseURI());
    $artist = $ref->{obj};

    $out  = $this->BeginDesc("mm:Artist", $this->GetBaseURI() . "/artist/" . $artist->GetMBId())
	if ($artist);

    $out .=   $this->Element("dc:title", $artist->GetName());
    $out .=   $this->Element("mm:sortName", $artist->GetSortName());

    my $begindate = MusicBrainz::Server::Validation::MakeDisplayDateStr($artist->GetBeginDate);
    $out .= $this->Element("mm:beginDate", $begindate) if ($begindate);

    my $enddate = MusicBrainz::Server::Validation::MakeDisplayDateStr($artist->GetEndDate);
    $out .= $this->Element("mm:endDate", $enddate) if ($enddate);
    $out .= $this->Element("dc:comment", $artist->GetResolution) if ($artist->GetResolution);

    $out .= $this->Element("mm:artistType", "", "rdf:resource", $this->GetMMNamespace() . 
                                  "Type" . &MusicBrainz::Server::Artist::GetTypeName($artist->GetType)) if ($artist->GetType);
    $out .= $this->OutputRelationships($ref->{_relationships})
        if (exists $ref->{_relationships});

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
	 my (@releases, $releasedate);

    return "" if (!defined $this->GetBaseURI());

    $album = $ref->{obj};
    $artist = $this->GetFromCache('artist', $album->GetArtist()); 

    @releases = $album->ReleaseEvents;
    require MusicBrainz::Server::Country;
    my $country_obj = MusicBrainz::Server::Country->new($album->{DBH})
       if @releases;

    $out  = $this->BeginDesc("mm:Album", $this->GetBaseURI() . "/album/" . $album->GetMBId())
	if ($album);
    $out .=   $this->Element("dc:title", $album->GetName());
    if (defined $artist)
    {
        $out .=   $this->Element("dc:creator", "", "rdf:resource",
                                 $this->GetBaseURI() . "/artist/" . 
                                 $artist->GetMBId());
    }
    else
    {
	my $temp = $album->GetArtist();
	if ($temp && $temp == &ModDefs::VARTIST_ID)
	{
	    $out .=   $this->Element("dc:creator", "", "rdf:resource",
				     $this->GetBaseURI() . "/artist/" . 
				     &ModDefs::VARTIST_MBID);
	}
    }

    if (exists $album->{"_cdindexid0"} && $album->{"_cdindexid0"} ne '')
    {
        $out .=   $this->BeginDesc("mm:cdindexidList");
        $out .=   $this->BeginBag();

        for($i = 0;; $i++)
        {
            if (exists $album->{"_cdindexid$i"} && $album->{"_cdindexid$i"} ne '')
            {
                $out .= $this->Element("rdf:li", "", "rdf:resource", 
                              $this->{baseuri} . "/cdindex/" . $album->{"_cdindexid$i"});
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
        if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START && 
            $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
        {
           $out .= $this->Element("mm:releaseType", "", "rdf:resource", $this->GetMMNamespace() . 
                                  "Type" . $album->GetAttributeName($attr));
        }
        elsif ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START && 
               $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END)
        {
           $out .= $this->Element("mm:releaseStatus", "", "rdf:resource", $this->GetMMNamespace() . 
                                  "Status" . $album->GetAttributeName($attr));
        }
    }

    if (@releases)
    {
        $out .= $this->BeginDesc("mm:releaseDateList");
        $out .= $this->BeginSeq();
        for my $rel (@releases)
        {
             my $cid = $rel->GetCountry;
             my $c = $country_obj->newFromId($cid);
             my ($year, $month, $day) = $rel->GetYMD();
        
             $releasedate = $year;
             $releasedate .= sprintf "-%02d", $month if ($month != 0);
             $releasedate .= sprintf "-%02d", $day if ($day != 0);
             $out .= $this->BeginElement("rdf:li");
             $out .= $this->BeginElement("mm:ReleaseDate");
             $out .= $this->Element("dc:date", $releasedate);
             $out .= $this->Element("mm:country", $c ? $c->GetISOCode : "?");
             $out .= $this->EndElement("mm:ReleaseDate");
             $out .= $this->EndElement("rdf:li");
         }
         $out .= $this->EndSeq();
         $out .= $this->EndDesc("mm:releaseDateList");
    }

    my $asin = $album->GetAsin();
    if ($asin)
    {
        $out .= $this->Element("az:Asin", $asin);
    }

    $out .= $this->OutputRelationships($ref->{_relationships})
        if (exists $ref->{_relationships});

    if (exists $ref->{_album})
    {
        my $complete;

        $out .=   $this->BeginDesc("mm:trackList");
        $out .=   $this->BeginSeq();
        $ids = $ref->{_album};

	if (scalar(@$ids))
	{
	    $complete = $$ids[scalar(@$ids) - 1]->{tracknum} != (scalar(@$ids) + 1);
            $complete = 1 if (!$complete && $album->GetName() eq &MusicBrainz::Server::Release::NONALBUMTRACKS_NAME);
	    foreach $track (@$ids)
	    {
		my $li = $complete ? "rdf:li" : ("rdf:_" . $track->{tracknum});
		$out .= $this->Element($li, "", "rdf:resource", 
				       $this->{baseuri} . "/track/" . $track->{id});
	    }
        }

        $out .=   $this->EndSeq();
        $out .=   $this->EndDesc("mm:trackList");
    }

    if (exists $ref->{_track})
    {
        my ($trackid, $tracknum) = @{$ref->{_track}};
	if ($trackid && $tracknum)
	{
	    $out .=   $this->BeginDesc("mm:trackList");
	    $out .=   $this->BeginSeq();

	    $out .= $this->Element("rdf:_" . $tracknum, "", "rdf:resource", 
				   $this->{baseuri} . "/track/" . $trackid);

	    $out .=   $this->EndSeq();
	    $out .=   $this->EndDesc("mm:trackList");
	}
    }
    $out .= $this->EndDesc("mm:Album");

    return $out;
}

# Return the RDF representation of the Track
sub OutputTrackRDF
{
    my ($this, $ref, $album) = @_;
    my ($out, $artist, $gu, $track);

    if (!defined $this->GetBaseURI())
    {
        return "";
    }

    $track = $ref->{obj};
    $artist = $this->GetFromCache('artist', $track->GetArtist()); 

    $out  = $this->BeginDesc("mm:Track", $this->GetBaseURI() .
                            "/track/" . $track->GetMBId());
    $out .=   $this->Element("dc:title", $track->GetName());

    if (defined $artist)
    {
    	$out .= $this->Element("dc:creator", "", "rdf:resource",
		        $this->{baseuri}. "/artist/" . $artist->GetMBId())
	}
    if ($track->GetLength() != 0) 
    {
        $out .=   $this->Element("mm:duration", $track->GetLength());
    }
    if (defined $album)
    {
        $out .= $this->Element("mq:album", "", "rdf:resource",
                  $this->{baseuri}. "/album/" . $album->GetMBId());
    }

    $out .= $this->OutputRelationships($ref->{_relationships})
        if (exists $ref->{_relationships});

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

sub CreateTrackListing
{
   my ($this, $album) = @_;
   $album or confess '$album not defined';
   my (@trackids, @tracks, $track);

   @tracks = $album->LoadTracks();
   foreach $track (@tracks)
   {
       next if not defined $track;

       push @trackids, { id=>$track->GetMBId(),
           tracknum=>$track->GetSequence() };
   }

   return \@trackids;
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
           my $trackids;
           $al = $this->GetFromCache('album', $id->{id});
           if (defined $al)
           {
               $trackids = $this->CreateTrackListing($al);
               $out .= $this->OutputAlbumRDF({ obj=>$al, _album=> $trackids });
           }
       }
   }
   elsif ($flags & TaggerSupport::ALBUMTRACKLIST || 
          $flags & TaggerSupport::TRACKLIST)
   {
       my %albums;

       $out .= $this->BeginDesc("mq:Result");
       $out .= $this->Element("mq:status", ($flags & TaggerSupport::FUZZY) != 0  ? "Fuzzy" : "OK");
       

       $out .= $this->BeginDesc("mq:lookupResultList");
       $out .= $this->BeginSeq();
       foreach $id (@$list)
       {
           $out .= $this->BeginDesc("rdf:li");
           $out .= $this->BeginDesc("mq:AlbumTrackResult");
           $out .=   $this->Element("mq:relevance", int(100 * $id->{sim}));

	   if ($id->{albumid})
	   {
	       $albums{$id->{albumid}}++;
	       $al = $this->GetObject($tagger, 'album', $id->{albumid});
               $out .=   $this->Element("mq:album", "", "rdf:resource", $this->{baseuri}. "/album/" . $al->GetMBId());
	   }

           $tr = $this->GetObject($tagger, 'track', $id->{id});
           $out .=   $this->Element("mq:track", "", "rdf:resource", $this->{baseuri}. "/track/" . $tr->GetMBId())
	       if ($tr);

           $out .= $this->EndDesc("mq:AlbumTrackResult");
           $out .= $this->EndDesc("rdf:li");
       }
       $out .= $this->EndSeq();
       $out .= $this->EndDesc("mq:lookupResultList");
      
       $out .= $this->EndDesc("mq:Result");

       $ar = $this->GetObject($tagger, 'artist', $id->{artistid});
       $out .= $this->OutputArtistRDF({ obj=>$ar });

       foreach $id (keys %albums)
       {
           my $trackids;
           $al = $this->GetFromCache('album', $id);
           $trackids = $this->CreateTrackListing($al);
           $out .= $this->OutputAlbumRDF({ obj=>$al, _album=> $trackids });
       }
       foreach $id (@$list)
       {
           $tr = $this->GetFromCache('track', $id->{id});
           if (defined $tr)
           {
               if ($ar->GetId() == ModDefs::VARTIST_ID)
               {
                   my $artist;

		   require MusicBrainz::Server::Artist;
                   $artist = MusicBrainz::Server::Artist->new($this->{DBH});
                   $artist->SetId($tr->GetArtist());
                   $artist->LoadFromId();
                   $this->AddToCache(0, 'artist', $artist);
                   $out .= $this->OutputArtistRDF({ obj=>$artist });
               }
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
       $out .=    $this->Element("mq:album", "", "rdf:resource", $this->{baseuri}. "/album/" . $al->GetMBId())
           if ($al);
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
       return $this->ErrorRDF("No items matched.");
   }
   $out .= $this->EndRDFObject;

   return $out;
}

sub OutputRelationships
{
    my ($this, $rels) = @_;

    return "" if (scalar @$rels == 0);
    my $out;

    $out = $this->BeginDesc("ar:relationshipList");
    $out .= $this->BeginBag();
    foreach my $item (@$rels)
    {
	my $name = ucfirst($item->{name});
	$name =~ s/[^A-Za-z0-9]+([A-Za-z0-9]?)/uc $1/eg;
        $out .= $this->BeginDesc("rdf:li");
	$out .= $this->BeginElement("ar:$name");
	$item->{begindate} = MusicBrainz::Server::Validation::MakeDisplayDateStr($item->{begindate});
	$item->{enddate} = MusicBrainz::Server::Validation::MakeDisplayDateStr($item->{enddate});
	$out .= $this->Element("ar:beginDate", $item->{begindate}) if ($item->{begindate});
	$out .= $this->Element("ar:endDate", $item->{enddate}) if ($item->{enddate});
	if ($item->{type} eq 'url')
	{
	    $out .= $this->Element("ar:to".ucfirst($item->{type}), "", "rdf:resource", $item->{url});
	}
	else
	{
	    $out .= $this->Element("ar:to".ucfirst($item->{type}), "", "rdf:resource", $this->{baseuri} . '/' . $item->{type} .'/' . $item->{id});
	    $out .= $this->Element("ar:direction", "", "rdf:resource", $this->GetARNamespace . "Direction" . $item->{direction})
	    	if $item->{direction};
	    if (exists $item->{"_attrs"})
	    {
                my $attrs = $item->{"_attrs"}->GetAttributes();
		if ($attrs)
		{
	            $out .= $this->BeginElement("ar:attributeList");
                    $out .= $this->BeginBag();
		    foreach my $ref (@$attrs)
		    {
			my $text = ucfirst($ref->{value_text});
	                $text =~ s/[^A-Za-z0-9]+([A-Za-z0-9]?)/uc $1/eg;
			if ($ref->{name} eq $ref->{value_text})
			{
     			    $out .= $this->Element("rdf:li", "", "rdf:resource", $this->GetARNamespace . ucfirst($ref->{name}));
			}
			else
			{
     			    $out .= $this->Element("rdf:li", "", "rdf:resource", $this->GetARNamespace . $text);
			}
		    }
                    $out .= $this->EndBag();
	            $out .= $this->EndElement("ar:attributeList");
	        }
	    }
	}
	$out .= $this->EndElement("ar:$name");
        $out .= $this->EndDesc("rdf:li");
    }
    $out .= $this->EndBag();
    $out .= $this->EndDesc("ar:relationshipList");
    return $out;
}

sub CreateRelationshipList
{
    my ($this, $parser, $obj, $type, $links) = @_;

    $this->{status} = "OK";

    my $out;
    $out  = $this->BeginRDFObject();
    $out .= $this->BeginDesc("mq:Result");
    $out .= $this->OutputList($type, [$obj->GetMBId]);
    $out .= $this->EndDesc("mq:Result");

    # Create a list of rel names and other ent mbids
    # Create list of unique artists

    my (@rels, @entities);
    foreach my $item (@$links)
    {
        my $temp;

	my $otype = $item->{"link" . (($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type) ? 1 : 0) . "_type"};
	my $oid = $item->{"link" . (($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type) ? 1 : 0) . "_id"};

	if ($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type)
	{
	     my $ref = { 
	    	         type =>$item->{"link1_type"},
		         id =>$item->{"link1_mbid"}, 
		         name => $item->{"link_name"}, 
		         url => $item->{"link1_name"},
		         begindate => $item->{"begindate"},
		         enddate => $item->{"enddate"},
                       };
	     $ref->{direction} = "Forward" if $item->{link0_type} eq $item->{link1_type};
	     $ref->{_attrs} = $item->{"_attrs"} if (exists $item->{"_attrs"});
	     push @rels, $ref;
	     push @entities, $item->{"link1_type"} ."-". $item->{"link1_id"};
	}
	else
	{
	     my $ref = { 
		         type =>$item->{"link0_type"},
		         id =>$item->{"link0_mbid"}, 
			 name => $item->{"link_name"}, 
			 url => $item->{"link0_name"},
			 begindate => $item->{"begindate"},
			 enddate => $item->{"enddate"},
	               };
	     $ref->{direction} = "Backward" if $item->{link0_type} eq $item->{link1_type};
	     $ref->{_attrs} = $item->{"_attrs"} if (exists $item->{"_attrs"});
	     push @rels, $ref;
	     push @entities, $item->{"link0_type"} ."-". $item->{"link0_id"};
	}
    }

    $out .= $this->OutputArtistRDF({ obj => $obj, _relationships => \@rels }) if ($type eq 'artist');
    $out .= $this->OutputAlbumRDF({ obj => $obj, _relationships => \@rels }) if ($type eq 'album');
    $out .= $this->OutputTrackRDF({ obj => $obj, _relationships => \@rels }) if ($type eq 'track');

    @entities = do { my %t; @t{@entities}=(); keys %t };
    foreach my $item (@entities)
    {
        my $temp;
	my ($type, $id) = split '-', $item;
	if ($type eq 'artist')
	{
	    $temp = MusicBrainz::Server::Artist->new($this->{DBH});
	    $temp->SetId($id);
	    die if (!$temp->LoadFromId());
            $out .= $this->OutputArtistRDF({ obj=> $temp });
	} elsif ($type eq 'album')
	{
	    $temp = MusicBrainz::Server::Release->new($this->{DBH});
	    $temp->SetId($id);
	    die if (!$temp->LoadFromId());
            $out .= $this->OutputAlbumRDF({ obj=> $temp });
	} elsif ($type eq 'track')
	{
	    $temp = MusicBrainz::Server::Track->new($this->{DBH});
	    $temp->SetId($id);
	    die if (!$temp->LoadFromId());
            $out .= $this->OutputTrackRDF({ obj=> $temp });
	}
    }

    $out .= $this->EndRDFObject;

    return $out;
}

1;
# eof MM_2_1.pm
