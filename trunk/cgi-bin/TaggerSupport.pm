#!/usr/bin/perl -w
# vi: set ts=4 sw=4 et :
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

package TaggerSupport;

use strict;
use MusicBrainz::Server::Release; # for constants
use String::Similarity;
use Encode qw( encode decode );

# These are the status flags that Lookup returns for the results
use constant ARTISTID               => 1; 
use constant ARTISTLIST             => 2;
use constant ALBUMID                => 4;
use constant ALBUMLIST              => 8;
use constant TRACKID                => 16;
use constant ALBUMTRACKID           => 64;
use constant ALBUMTRACKLIST         => 128;
use constant FUZZY                  => 256;
use constant TRACKLIST              => 512;

sub new
{
    my ($class, $dbh) = @_;

    bless {
	DBH => $dbh,
    }, ref($class) || $class;
}

sub GetDBH { return $_[0]->{DBH} }
sub SetDBH { $_[0]->{DBH} = $_[1] }

# Used by MQ_2_1.pm
sub FileInfoLookup
{
   my ($dbh, $doc, $rdf, $artistName, $albumName, $trackName, $trmId,
       $trackNum, $duration, $fileName, $artistId, $albumId, $trackId, $maxItems) = @_;
   my (%data);

   $data{artist} = $artistName;
   $data{artistid} = $artistId;
   $data{album} = $albumName;
   $data{albumid} = $albumId;
   $data{track} = $trackName;
   $data{trackid} = $trackId;
   $data{tracknum} = $trackNum;
   $data{duration} = $duration;
   $data{filename} = $fileName;

   require TaggerSupport;
   my $ts = TaggerSupport->new($dbh);
   return $rdf->CreateFileLookup($ts, $ts->Lookup(\%data, $maxItems));
}

# Public object method.  Used by QuerySupport and taglookup and above

# returns ($error, $dataref, $flags, $listref);
sub Lookup
{
   my ($this, $data, $maxItems) = @_;
   my ($fileInfo, %info);

   # Initialize the data to reasonable defaults
   $data->{artist} ||= '';
   $data->{album} ||= '';
   $data->{track} ||= '';
   $data->{artistid} ||= '';
   $data->{albumid} ||= '';
   $data->{trackid} ||= '';
   $data->{filename} ||= '';
   $data->{albumtype} ||= '';
   $data->{duration} = 0 if (!defined $data->{duration} || 
                             !($data->{duration} =~ /^\d+$/));
   $data->{tracknum} = 0 if (!defined $data->{tracknum} || 
                             !($data->{tracknum} =~ /^\d+$/));

   # Make sure to clean out any old similarity ratings
   delete $data->{sim};

   foreach (values %$data)
   {
       $_ = encode "utf-8", lc(decode "utf-8", $_);
   }

   $this->{fuzzy} = 0;
   $maxItems = 15 if not defined $maxItems;
   $this->{maxitems} = $maxItems;
   $this->{data} = $data;  # Add a ref so that SetSim can access it

   if ($data->{artist} eq "Various Artists")
   {
       $data->{artistid} = &ModDefs::VARTIST_MBID;
   }

   if ($data->{artist} eq '' || $data->{album} eq '' || $data->{track} eq '' || 
       $data->{tracknum} < 0 || $data->{tracknum} > 99)
   {
       $this->ParseFileName($data->{filename}, $data);
   }

   if ($data->{artistid} eq '' && $data->{trackid} eq '')
   {
       my ($list, $flags);

       return ("No artist name or artist id given.", $data, 0, undef) 
           if ($data->{artist} eq '');

       ($flags, $list) = $this->ArtistSearch($data->{artist});
       if (scalar(@$list) == 1 && ($flags & ARTISTID))
       {
           $data->{artistid} = $list->[0]->{mbid};
       }
       else
       {
           return ("", $data, $flags, $list) if ($data->{album} eq '' || scalar(@$list) > 1);

           ($flags, $list) = $this->VariousArtistSearch($data->{album});
           if (scalar(@$list) == 1 && ($flags & ALBUMID))
           {
               $data->{artistid} = &ModDefs::VARTIST_MBID;
               $data->{albumid} = $list->[0]->{mbid};
           }
           else
           {
               return ("", $data, $flags, $list);
           }
       }
   }   

   if ($data->{albumid} ne '' && $data->{trackid} eq '' && $data->{track} ne '')
   {
       my ($list, $flags);

       ($flags, $list) = $this->TrackSearch($data->{artistid}, $data->{track}, 
                                            $data->{albumid}, $data->{tracknum}, 
                                            $data->{duration});
       return ("", $data, $flags, $list);
   }   

   if ($data->{albumid} eq '' && $data->{trackid} eq '' && $data->{track} ne '')
   {
       my ($list, $flags);
       ($flags, $list) = $this->AlbumTrackSearch($data->{artistid}, $data->{track}, 
                                                 $data->{album}, $data->{tracknum}, 
                                                 $data->{duration});
       return ("", $data, $flags, $list);
   }   

   if ($data->{albumid} eq '' && $data->{trackid} eq '' && $data->{album} ne '')
   {
       my ($list, $flags);

       ($flags, $list) = $this->AlbumSearch($data->{album}, $data->{artistid});
       if (scalar(@$list) == 1 && ($flags & ALBUMID))
       {
           $data->{albumid} = $list->[0]->{mbid};
       }
       else
       {
           return ("", $data, $flags, $list);
       }
   }   

   my $flags = 0;
   
   $flags |= ARTISTID if ($data->{artistid} ne '');
   $flags |= ALBUMID if ($data->{albumid} ne '');
   $flags |= TRACKID if ($data->{trackid} ne '');


   return ("", $data, $flags, undef);
}

sub LookupPUIDCollisions
{
   my ($this, $puid) = @_;
   my $sql = Sql->new($this->{DBH});

   my $data = $sql->SelectListOfHashes(
   	"SELECT DISTINCT
		albumjoin.album,
		puidjoin.track
	FROM	puid
		INNER JOIN puidjoin ON puidjoin.puid = puid.id
		INNER JOIN albumjoin ON albumjoin.track = puidjoin.track
	WHERE	puid.puid = ?
	ORDER BY 1, 2",
	$puid,
   );

   @$data;
}


sub SetSim
{
   my ($this, $type, $ref) = @_;
   my (%match);


   $match{artist} = '';
   $match{album} = '';
   $match{track} = '';
   $match{duration} = 0;
   $match{tracknum} = 0;
   $match{albumtype} = -1;

   if ($type == ARTISTID)
   {
       $match{artist} = $ref->{name};
   }
   elsif ($type == ALBUMID)
   {
       $match{artist} = $ref->{artist};
       $match{album} = $ref->{name};
       $match{albumtype} = $ref->{albumtype};
   }
   elsif ($type == ALBUMTRACKID)
   {
       $match{artist} = $ref->{artist};
       $match{album} = $ref->{album};
       $match{track} = $ref->{name};
       $match{duration} = $ref->{tracklen};
       $match{tracknum} = $ref->{tracknum};
       $match{albumtype} = $ref->{albumtype};
   }
   elsif ($type == TRACKID)
   {
       $match{artist} = $ref->{artist};
       $match{album} = $ref->{album};
       $match{track} = $ref->{name};
       $match{duration} = $ref->{tracklen};
       $match{tracknum} = $ref->{tracknum};
   }
   else
   {
       $ref->{sim} = 0;
       return 0;
   }

   $ref->{sim} = $this->MetadataCompare(\%match, $this->{data});

   return $ref;
}

# Internal method: given a filename, try to extract artist/album/track etc
# from it.  Stash the results in $data.
# NOTE: I *think* this is unicode-safe.  Not sure about the use of \s and \d.
sub ParseFileName
{
   my ($this, $fileName, $data) = @_;
   my (@parts);

   for(;;)
   {
        if ($fileName =~ s/^([^-]*)-//)
        {
            $_ = $1;
            s/^\s*(.*?)\s*$/$1/;

            push @parts, $_ if (defined $_ and $_ ne '');
        }
        else
        {
            $_ = $fileName;
            s/^(.*?)\..*$/$1/;
            s/^\s*(.*?)\s*$/$1/;
            push @parts, $_;
            last;
        }
   }
   if (scalar(@parts) == 4)
   {
        $data->{artist} ||= $parts[0];
        $data->{album} ||= $parts[1];
        if ($parts[2] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[2];
        }
        $data->{track} ||= $parts[3];
   }
   elsif (scalar(@parts) == 3)
   {
        $data->{artist} ||= $parts[0];
        if ($parts[1] =~ /^\d+$/)
        {
            $data->{tracknum} ||= $parts[1];
        }
        else
        {
            $data->{album} ||= $parts[1];
        }
        $data->{track} ||= $parts[2];
   }
   elsif (scalar(@parts) == 2)
   {
        $data->{artist} ||= $parts[0];
        $data->{track} ||= $parts[1];
   }
   elsif (scalar(@parts) == 1)
   {
        $data->{track} ||= $parts[0];
   }
}

# Internal.

sub ArtistSearch
{
   my ($this, $name) = @_;
   my ($ar, @ids);

   return (0, []) if (!$name);

   require MusicBrainz::Server::Artist;
   $ar = MusicBrainz::Server::Artist->new($this->{DBH});

   my $artists = $ar->GetArtistsFromName($name);
   if (scalar(@$artists) == 1)
   {
       $this->{artist} = $$artists[0];
       return (ARTISTID, [ 
                           $this->SetSim(ARTISTID, {
                             id=>$this->{artist}->GetId(),
                             mbid=>$this->{artist}->GetMBId(), 
                             name=>$this->{artist}->GetName(),
                             resolution=>$this->{artist}->GetResolution(),
                             sortname=>$this->{artist}->GetSortName() })
                         ]);
   }
   if (scalar(@$artists) > 1)
   {
       foreach my $item (@$artists)
       {
           push @ids, { id=>$item->GetId(),
                      name=>$item->GetName(),
                  sortname=>$item->GetSortName(),
                      mbid=>$item->GetMBId(),
                resolution=>$item->GetResolution(),
                       sim=>1.0
                      };
       }
       return (ARTISTLIST, \@ids);
   }

   require SearchEngine;
   my $engine = SearchEngine->new($this->{DBH}, 'artist');

   $engine->Search(
	query => $name,
	limit => $this->{maxitems},
   );

   $name = lc(decode "utf-8", $name);

   if ($engine->Rows == 1)
   {
       my $row = $engine->NextRow;

       $ar->SetId($row->{'artistid'});
       if (defined $ar->LoadFromId())
       {
           $this->{artist} = $ar;     
           $this->{fuzzy} = 1;
           my $thisname = lc(decode "utf-8", $ar->GetName);
           return (ARTISTID | FUZZY, 
                             [ 
                              $this->SetSim(ARTISTID, { 
                                 id=>$ar->GetId(),
                                 mbid=>$ar->GetMBId(), 
                                 name=>$ar->GetName(),
                                 resolution=>$ar->GetResolution(),
                                 sortname=>$ar->GetSortName()})
                             ]);
       }
   }
   else
   {
       my $row;
       
       while($row = $engine->NextRow)
       {
           my $thisname = lc(decode "utf-8", $row->{'artistname'});

           push @ids, $this->SetSim(ARTISTID, { id=>$row->{'artistid'},
                        name=>$row->{'artistname'},
                        sortname=>$row->{'artistsortname'},
                        resolution=>$row->{'artistresolution'},
                        mbid=>$row->{'artistgid'}});
       }

       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;
       @ids = splice @ids, 0, $this->{maxitems};

       return (ARTISTLIST, \@ids);
   }

   return (0, []);
}

# Internal.
sub AlbumSearch
{
   my ($this, $name, $artistId) = @_;
   my ($ar, $al, @ids);

   if (exists $this->{artist})
   {
       $ar = $this->{artist};
   }
   else
   {
       require MusicBrainz::Server::Artist;
       $ar = MusicBrainz::Server::Artist->new($this->{DBH});
       $ar->SetMBId($artistId);
       if (!defined $ar->LoadFromId())
       {
           return (0, []);
       }
       $this->{artist} = $ar;     
   }

   # first check, if there are any exact matches for artist & album
   require MusicBrainz::Server::Release;
   $al = MusicBrainz::Server::Release->new($this->{DBH});
   $al->SetArtist($ar->GetId());
   my (@aids) = $al->GetAlbumListFromName($name);

   my @albums;
   if (scalar(@aids) > 0)
   {
       # found exact matches, no need to fetch the complete album list
       # (just a speed-up)
       foreach my $aid (@aids)
       {
           $al = MusicBrainz::Server::Release->new($this->{DBH});
           $al->SetMBId($aid->{mbid});
           if ($al->LoadFromId)
           {
               push @albums, $al;
           }
       }
   } else {
       # get the complete album list from artist
       @albums = $ar->GetReleases(0, 1);
   }
   
   if (scalar(@albums) == 0)
   {
       # artist has no albums, return empty list
       return (0, []);
   }

   $name = lc(decode "utf-8", $name);

   # do an exact match
   foreach $al (@albums)
   {
       my $thisname = lc(decode "utf-8", $al->GetName);

       if ($thisname eq $name)
       {
           my $albumtype = -1;
           my $attr;
           my @attrs = $al->GetAttributes();
           foreach $attr (@attrs)
           {
               if ($attr >= &MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
                   $attr <= &MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
               {
                   $albumtype = $attr;
                   last;
               }
           }
           push @ids, $this->SetSim(ALBUMID, { 
                        artist=>$ar->GetName(),
                        id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        album_tracks=>$al->GetTrackCount(),
                        album_discids=>$al->GetDiscidCount(),
                        albumtype=>$albumtype});
           $this->{album} = $al if (scalar(@ids) == 1);
           $this->{album} = undef if (scalar(@ids) > 1);
       }
   }

   # do fuzzy matches if need be
   if (scalar(@ids) == 0)
   {
       my $sim;

       foreach $al (@albums)
       {
           my $thisname = lc(decode "utf-8", $al->GetName);

           $sim = similarity($thisname, $name);

           if ($thisname =~ /^(.*?)\s*\(.*\)\s*$/)
           {
               my $temp = lc $1;
               my $chopsim = similarity($temp, $name);
               $sim = ($chopsim > $sim) ? $chopsim : $sim;
           }

           next if ($sim < .5);

           my $albumtype = -1;
           my $attr;
           my @attrs = $al->GetAttributes();
           foreach $attr (@attrs)
           {
               if ($attr >= &MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
                   $attr <= &MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
               {
                   $albumtype = $attr;
                   last;
               }
           }
           push @ids, $this->SetSim(ALBUMID, { 
                        artist=>$ar->GetName(),
                        id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        album_tracks=>$al->GetTrackCount(),
                        album_discids=>$al->GetDiscidCount(),
                        albumtype=>$albumtype});
           $this->{fuzzy} = 1;
       }
   }

   if (scalar(@ids) > 0)
   {
       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;
       @ids = splice @ids, 0, $this->{maxitems};
       return (ALBUMLIST, \@ids);
   }
  
   return (0, []);
}

# Internal.

sub AlbumTrackSearch
{
   my ($this, $artistId, $trackName, $albumName, $trackNum, $duration) = @_;
   my ($ar, $al, $tr, @ids, $last, $id, %result);
   my ($sql, $tracks, $count, $query, $flags, $altname);

   $flags = 0;
   if (exists $this->{artist})
   {
       $ar = $this->{artist};
   }
   else
   {
	require MusicBrainz::Server::Artist;
       $ar = MusicBrainz::Server::Artist->new($this->{DBH});
       $ar->SetMBId($artistId);
       if (!defined $ar->LoadFromId())
       {
           return (0, []);
       }
       $this->{artist} = $ar;     
   }

   $trackName = lc(decode "utf-8", $trackName);

   if ($trackName =~ /^(.*?)\s*\(.*\)\s*$/)
   {
       $altname = $1;
   }

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select track.id, track.gid, track.name, track.length
               from Track 
               where track.artist = | . $ar->GetId()))
   {
       my (@row, $namesim, $lensim, $sim);

       $flags |= FUZZY;
       while(@row = $sql->NextRow)
       {
           my $thisname = lc(decode "utf-8", $row[2]);

           $lensim = 0.0;
           $namesim = similarity($thisname, $trackName);
           if ($thisname =~ /^(.*?)\s*\(.*\)\s*$/)
           {
               my $temp = lc $1;
               my $chopsim = similarity($temp, $trackName);
               $namesim = ($chopsim > $namesim) ? $chopsim : $namesim;
           }
           if (defined $altname)
           {
               my $altsim = similarity($thisname, $altname);
               $namesim = ($altsim > $namesim) ? $altsim : $namesim;
           }

           next if ($namesim < .5);

           push @ids, $this->SetSim(ALBUMTRACKID, { id=>$row[0],
                        name=>$row[2], 
                        mbid=>$row[1],
                        tracklen=>$row[3]
                      });
       }
   }
    $sql->Finish;

   return (0, []) if (scalar(@ids) == 0);

   @ids = (sort { $b->{sim} <=> $a->{sim} } @ids);
   @ids = splice @ids, 0, $this->{maxitems};
   $query = qq|select album.id, album.name, album.gid, albumjoin.sequence, track,
                      albummeta.tracks, albummeta.discids, album.artist, album.attributes
                 from Album, AlbumJoin, albummeta
                where albumjoin.album = album.id and 
                      album.id = albummeta.id and
                      albumjoin.track in (|;
   foreach $id (@ids)
   {
      next if (!defined $id);
      $result{$id->{id}} = $id;
      $query .= $id->{id} . ",";
   }
   chop($query);
   $query .= ")";


   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
       my (@row, $namesim, $numsim);

       $albumName = lc(decode "utf-8", $albumName);

       while(@row = $sql->NextRow)
       {
           $numsim = 0.0;
           $namesim = 0.0;

           if ($albumName ne '')
           {
	            my $thisalbum = lc(decode "utf-8", $row[1]);
               $namesim = similarity($thisalbum, $albumName);
           }
           if ($trackNum > 0 && $row[3] > 0 && $trackNum == $row[3])
           {
               $numsim = 1.0;
           }

           $id = $result{$row[4]};
           next if not defined $id;

           # TODO: Use album type to order the albums
           # Update the entry with the info for the album
           $id->{tracknum} = $row[3];
           $id->{album} = $row[1];
           $id->{albummbid} = $row[2];
           $id->{albumid} = $row[0];
           $id->{album_tracks} = $row[5];
           $id->{album_discids} = $row[6];
           $id->{album_artist} = $row[7];
           $id->{album_attrs} = $row[8];
           $id->{albumid} = $row[0];
           $id->{artist} = $ar->GetName();
           $id->{artistmbid} = $ar->GetMBId();
           $this->SetSim(ALBUMTRACKID, $id);
       }
   }
    $sql->Finish;

   @ids = sort { $b->{sim} <=> $a->{sim} } @ids;

   return (ALBUMTRACKLIST | $flags, \@ids);
}

sub TrackSearch
{
   my ($this, $artistId, $trackName, $albumId, $trackNum, $duration) = @_;
   my ($ar, $al, $tr, @ids, $last, $id, %result);
   my ($sql, $tracks, $count, $query, $flags, $altname);

   $flags = 0;
   if (exists $this->{artist})
   {
       $ar = $this->{artist};
   }
   else
   {
	require MusicBrainz::Server::Artist;
       $ar = MusicBrainz::Server::Artist->new($this->{DBH});
       $ar->SetMBId($artistId);
       if (!defined $ar->LoadFromId())
       {
           return (0, []);
       }
       $this->{artist} = $ar;     
   }

   if (exists $this->{album})
   {
       $al = $this->{album};
   }
   else
   {
	require MusicBrainz::Server::Release;
       $al = MusicBrainz::Server::Release->new($this->{DBH});
       $al->SetMBId($albumId);
       if (!defined $al->LoadFromId())
       {
           return (0, []);
       }
       $this->{album} = $al;     
   }

   $trackName = lc(decode "utf-8", $trackName);

   if ($trackName =~ /^(.*?)\s*\(.*\)\s*$/)
   {
       $altname = $1;
   }

   $sql = Sql->new($this->{DBH});
   if ($sql->Select(qq|select track.id, track.gid, track.name, track.length, albumjoin.sequence
                         from Track, AlbumJoin 
                        where albumjoin.album = | . $al->GetId() . qq| and
                              albumjoin.track = track.id|))
   {
       my (@row, $namesim, $lensim, $sim);

       $flags |= FUZZY;
       while(@row = $sql->NextRow)
       {
           my $thisname = lc(decode "utf-8", $row[2]);

           $lensim = 0.0;
           $namesim = similarity($thisname, $trackName);
           if ($thisname =~ /^(.*?)\s*\(.*\)\s*$/)
           {
               my $temp = lc $1;
               my $chopsim = similarity($temp, $trackName);
               $namesim = ($chopsim > $namesim) ? $chopsim : $namesim;
           }
           if (defined $altname)
           {
               my $altsim = similarity($thisname, $altname);
               $namesim = ($altsim > $namesim) ? $altsim : $namesim;
           }

           next if ($namesim < .35);

           push @ids, $this->SetSim(TRACKID, { id=>$row[0],
                        artist=>$ar->GetName(),
                        albumid=>$al->GetId(),
                        album=>$al->GetName(),
                        name=>$row[2], 
                        mbid=>$row[1],
                        tracklen=>$row[3],
                        tracknum=>$row[4]
                      });
       }
   }
    $sql->Finish;

   return (0, []) if (scalar(@ids) == 0);

   @ids = (sort { $b->{sim} <=> $a->{sim} } @ids);
   @ids = splice @ids, 0, $this->{maxitems};

   return (TRACKLIST | $flags, \@ids);
}

sub VariousArtistSearch
{
   my ($this, $name) = @_;
   my ($al, @ids, $ar);

   require MusicBrainz::Server::Artist;
   $ar = MusicBrainz::Server::Artist->new($this->{DBH});
   $ar->SetId(&ModDefs::VARTIST_ID);
   $ar->LoadFromId();
   $this->{artist} = $ar;     

   require MusicBrainz::Server::Release;
   $al = MusicBrainz::Server::Release->new($this->{DBH});

   require SearchEngine;
   my $engine = SearchEngine->new($this->{DBH}, 'album');

   $engine->Search(
	query => $name,
	limit => $this->{maxitems},
   vartist => 1,
   );

   $name = lc(decode "utf-8", $name);

   if ($engine->Rows == 1)
   {
       my $row = $engine->NextRow;

       $al->SetId($row->{'albumid'});
       if (defined $al->LoadFromId())
       {
           $this->{artistid} = &ModDefs::VARTIST_MBID;
           $this->{album} = $al;     
           $this->{fuzzy} = 1;
           my $thisname = lc(decode "utf-8", $al->GetName);
           return (ALBUMID, 
                             [ 
                              $this->SetSim(ALBUMID, { 
                                 id=>$al->GetId(),
                                 artist=>$ar->GetName(),
                                 mbid=>$al->GetMBId(), 
                                 name=>$al->GetName(),
                                 albumtype=>MusicBrainz::Server::Release::RELEASE_ATTR_COMPILATION
                               })
                             ]);
       }
   }
   else
   {
       my $row;
       
       while($row = $engine->NextRow)
       {
           my $thisname = lc(decode "utf-8", $row->{'albumname'});

           push @ids, $this->SetSim(ALBUMID, { id=>$row->{'albumid'},
                        name=>$row->{'albumname'},
                        mbid=>$row->{'albumgid'},
                        albumtype=>MusicBrainz::Server::Release::RELEASE_ATTR_COMPILATION });
       }

       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;
       @ids = splice @ids, 0, $this->{maxitems};

       return (ALBUMLIST, \@ids);
   }

   return (0, []);
}

my @weights = (
#     ar    al    tr    tn     du         ar  al  tr  tn  du
    [ 0.00, 0.00, 0.00, 0.00,  0.00 ], #  0   0   0   0   0
    [ 0.00, 0.00, 0.00, 0.00,  0.95 ], #  0   0   0   0   1
    [ 0.00, 0.00, 0.00, 0.95,  0.00 ], #  0   0   0   1   0
    [ 0.00, 0.00, 0.00, 0.25,  0.70 ], #  0   0   0   1   1
    [ 0.00, 0.00, 0.95, 0.00,  0.00 ], #  0   0   1   0   0
    [ 0.00, 0.00, 0.75, 0.00,  0.20 ], #  0   0   1   0   1
    [ 0.00, 0.00, 0.75, 0.20,  0.00 ], #  0   0   1   1   0
    [ 0.00, 0.00, 0.65, 0.10,  0.20 ], #  0   0   1   1   1
    [ 0.00, 1.00, 0.00, 0.00,  0.00 ], #  0   1   0   0   0
    [ 0.00, 0.80, 0.00, 0.00,  0.20 ], #  0   1   0   0   1
    [ 0.00, 0.80, 0.00, 0.20,  0.00 ], #  0   1   0   1   0
    [ 0.00, 0.70, 0.00, 0.10,  0.20 ], #  0   1   0   1   1
    [ 0.00, 0.50, 0.50, 0.00,  0.00 ], #  0   1   1   0   0
    [ 0.00, 0.40, 0.40, 0.00,  0.20 ], #  0   1   1   0   1
    [ 0.00, 0.45, 0.45, 0.10,  0.00 ], #  0   1   1   1   0
    [ 0.00, 0.35, 0.35, 0.15,  0.15 ], #  0   1   1   1   1

    [ 0.95, 0.00, 0.00, 0.00,  0.00 ], #  1   0   0   0   0
    [ 0.75, 0.00, 0.00, 0.00,  0.20 ], #  1   0   0   0   1
    [ 0.85, 0.00, 0.00, 0.10,  0.00 ], #  1   0   0   1   0
    [ 0.60, 0.00, 0.00, 0.10,  0.25 ], #  1   0   0   1   1
    [ 0.48, 0.00, 0.47, 0.00,  0.00 ], #  1   0   1   0   0
    [ 0.43, 0.00, 0.42, 0.00,  0.10 ], #  1   0   1   0   1
    [ 0.43, 0.00, 0.42, 0.10,  0.00 ], #  1   0   1   1   0
    [ 0.38, 0.00, 0.37, 0.10,  0.10 ], #  1   0   1   1   1
    [ 0.50, 0.50, 0.00, 0.00,  0.00 ], #  1   1   0   0   0
    [ 0.45, 0.45, 0.00, 0.00,  0.10 ], #  1   1   0   0   1
    [ 0.45, 0.45, 0.00, 0.10,  0.00 ], #  1   1   0   1   0
    [ 0.40, 0.40, 0.00, 0.10,  0.10 ], #  1   1   0   1   1
    [ 0.33, 0.33, 0.34, 0.00,  0.00 ], #  1   1   1   0   0
    [ 0.30, 0.30, 0.30, 0.00,  0.10 ], #  1   1   1   0   1
    [ 0.30, 0.30, 0.30, 0.10,  0.00 ], #  1   1   1   1   0
    [ 0.25, 0.25, 0.25, 0.125, 0.125]  #  1   1   1   1   1
);

sub IsNumber
{
    return 0 unless defined $_[0];
    return 0 unless $_[0] =~ /\d/;
    $_[0] =~ /^-?[\d]*\.?[\d]*$/;
}

sub DurationSim
{
    my ($trackA, $trackB) = @_;
    my $diff;

    return 0 if ($trackA == 0 || $trackB == 0);

    $diff = abs($trackA - $trackB);
    if ($diff > 30000)
    {
       return 0;
    }

    return 1.0 - ($diff / 30000);
}

sub MetadataCompare
{
    my ($this, $trackA, $trackB) = @_;
    my $index = 0;
    my %A = %{ $trackA };
    my %B = %{ $trackB };

    $A{duration} = 0 if (!IsNumber($A{duration}));
    $B{duration} = 0 if (!IsNumber($B{duration}));
    $A{tracknum} = -1 if (!IsNumber($A{tracknum}));
    $B{tracknum} = -2 if (!IsNumber($B{tracknum}));
    $A{albumtype} = -1 if (!IsNumber($A{albumtype}));
    $B{albumtype} = -1 if (!IsNumber($B{albumtype}));

    foreach (values %A)
    {
        $_ = lc(decode "utf-8", $_);
    }
    foreach (values %B)
    {
        $_ = lc(decode "utf-8", $_);
    }
 
    # If one of the two is completely empty of meaningful info, just return 0
    return 0 if (($A{artist} eq '' && $A{album} eq '' && $A{track} eq '') ||
                ($B{artist} eq '' && $B{album} eq '' && $B{track} eq ''));

    $index |= 16 if ($A{artist} ne '' && $B{artist} ne '');

#use Data::Dumper;
#print STDERR Data::Dumper->Dump([ \%A, \%B ],[ '*A', '*B' ]);

    # If one album is blank, and the other is an album, copy it over to favor it.
    $A{album} = $B{album} if ($A{album} eq '' && $B{album} ne '' && 
                              $B{albumtype} == &MusicBrainz::Server::Release::RELEASE_ATTR_ALBUM);

    # Now check the reverse case as well.
    $B{album} = $A{album} if ($B{album} eq '' && $A{album} ne '' && 
                              $A{albumtype} == &MusicBrainz::Server::Release::RELEASE_ATTR_ALBUM);

    $index |= 8 if ($A{album} ne '' && $B{album} ne '');

    $index |= 4 if ($A{track} ne '' && $B{track} ne '');

    $index |= 2 if ($A{tracknum} > 0 && $B{tracknum} > 0);

    $index |= 1 if ($A{duration} != 0 && $B{duration} != 0);

    return 0 if ($index == 0);

    my $w = $weights[$index];    

    return (($$w[0] && $$w[0] * similarity($A{artist}, $B{artist}))      
            + ($$w[1] && $$w[1] * similarity($A{album}, $B{album}))      
            + ($$w[2] && $$w[2] * similarity($A{track}, $B{track}))      
            + (($A{tracknum} == $B{tracknum}) ? $$w[3] : 0)      
            + ($$w[4] && $$w[4] * DurationSim($A{duration}, $B{duration})));
}

1;
# eof TaggerSupport.pm
