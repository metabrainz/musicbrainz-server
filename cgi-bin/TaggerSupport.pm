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
use MusicBrainz;
use TableBase;
use Album;
use Discid;
use Artist;
use Track;
use String::Unicode::Similarity;
use Encode qw( encode decode );

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use constant ALL_WORDS              => 1;

# These are the status flags that Lookup returns for the results
use constant ARTISTID               => 1; 
use constant ARTISTLIST             => 2;
use constant ALBUMID                => 4;
use constant ALBUMLIST              => 8;
use constant TRACKID                => 16;
use constant ALBUMTRACKID           => 64;
use constant ALBUMTRACKLIST         => 128;
use constant FUZZY                  => 256;

# TODO: Make sure the RDF interface still works (change to hash refs lists)
sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

# Used by mq.pl

sub FileInfoLookup
{
   my $tagger = TaggerSupport->new(shift);
   return $tagger->Lookup(@_);
}

# TODO: Fix this for the new Lookup function
# ? not used yet in the codebase I'm looking at.  dave 2003-01-09

sub RDFLookup
{
   my ($this, $doc, $rdf, $artistName, $albumName, $trackName, $trmId,
          $trackNum, $duration, $fileName, $artistId, $albumId, $trackId, $maxItems) = @_;
   my ($status, $error, %data);

   $data{artist} = $artistName;
   $data{artistid} = $artistId;
   $data{album} = $albumName;
   $data{albumid} = $albumId;
   $data{track} = $trackName;
   $data{trackid} = $trackId;
   $data{tracknum} = $trackNum;
   $data{tmid} = $trmId;
   $data{duration} = $duration;
   $data{filename} = $fileName;

   ($status, $error) = $this->Lookup(\%data);
   if (defined $error)
   {
       return $rdf->ErrorRDF($error);
   }

   return $rdf->CreateFileLookup($this, $status);
}

# Internal.

       use Data::Dumper;
# fix users of lensim and namesim for track matches
sub SetSim
{
   my ($this, $ref) = @_;

   if (exists $ref->{sim_album} &&
       exists $ref->{sim_track} &&
       exists $ref->{sim_tracklen} &&
       exists $ref->{sim_tracknum})
   {
       $ref->{sim} = ($ref->{sim_album} * .3) + 
                     ($ref->{sim_track} * .3) + 
                     ($ref->{sim_tracklen} * .3) +
                     ($ref->{sim_tracknum} * .1);
       return $ref;
   }

   if (exists $ref->{sim_track} &&
       exists $ref->{sim_tracklen})
   {
       $ref->{sim} = ($ref->{sim_track} * .5) + 
                     ($ref->{sim_tracklen} * .5);
      return $ref;
   }

   if (exists $ref->{sim_artist})
   {
      $ref->{sim} = $ref->{sim_artist};
      return $ref;
   }

   if (exists $ref->{sim_album})
   {
      $ref->{sim} = $ref->{sim_album};
      return $ref;
   }

   # Ooops, something wen't wrong
   $ref->{sim} = -1;

   return $ref;
}

# Public object method.  Used by QuerySupport and taglookup.

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
   $data->{duration} ||= 0;
   $data->{tracknum} = 0 if (!defined $data->{tracknum} || 
                             !($data->{tracknum} =~ /^\d+$/));

   # Make sure to clean out any old similarity ratings
   delete $data->{sim};
   delete $data->{sim_artist};
   delete $data->{sim_album};
   delete $data->{sim_track};
   delete $data->{sim_tracknum};
   delete $data->{sim_duration};

   foreach (values %$data)
   {
       $_ = encode "utf-8", lc(decode "utf-8", $_);
   }

   $this->{fuzzy} = 0;
   $maxItems = 15 if not defined $maxItems;
   $this->{maxitems} = $maxItems;

   if ($data->{artist} eq "Various Artists")
   {
       $data->{artistid} = "e06d2236-5806-409f-ac9f-9245844ce5d9";
   }

   if ($data->{artist} eq '' || $data->{album} eq '' || $data->{track} eq '' || 
       $data->{tracknum} < 0 || $data->{tracknum} > 99)
   {
       $this->ParseFileName($data->{filename}, $data);
   }

   if ($data->{artistid} eq '')
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
           return ("", $data, $flags, $list);
       }
   }   

   if ($data->{albumid} eq '' && $data->{trackid} eq '' && $data->{track} ne '')
   {
       my ($list, $flags);
       ($flags, $list) = $this->TrackSearch($data->{artistid}, $data->{track}, 
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

   $ar = Artist->new($this->{DBH});
   if (defined $ar->LoadFromName($name))
   {
       $this->{artist} = $ar;     
       return (ARTISTID, [ 
                           $this->SetSim({
                             id=>$ar->GetId(),
                             mbid=>$ar->GetMBId(), 
                             name=>$ar->GetName(),
                             sortname=>$ar->GetSortName(),
                             sim_artist=>1
                           })
                         ]);
   }

   my $engine = SearchEngine->new($this->{DBH});
   $engine->Table('Artist');
   $engine->AllWords(ALL_WORDS);
   $engine->Limit($this->{maxitems});
   $engine->Search($name);

   $name = lc(decode "utf-8", $name);

   if ($engine->Rows == 1)
   {
       my $row = $engine->NextRow;

       $ar->SetId($row->[0]);
       if (defined $ar->LoadFromId())
       {
           $this->{artist} = $ar;     
           $this->{fuzzy} = 1;
	   my $thisname = lc(decode "utf-8", $ar->GetName);
           return (ARTISTID | FUZZY, 
                             [ 
                              $this->SetSim({ 
                                 id=>$ar->GetId(),
                                 mbid=>$ar->GetMBId(), 
                                 name=>$ar->GetName(),
                                 sortname=>$ar->GetSortName(),
                                 sim_artist=>similarity($thisname, $name)
                               })
                             ]);
       }
   }
   else
   {
       my $row;
       
       while($row = $engine->NextRow)
       {
	   my $thisname = lc(decode "utf-8", $row->[1]);

           push @ids, $this->SetSim({ id=>$row->[0],
                        name=>$row->[1],
                        sortname=>$row->[2],
                        mbid=>$row->[3], 
                        sim_artist=>similarity($thisname, $name) });
       }

       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;

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
       $ar = Artist->new($this->{DBH});
       $ar->SetMBId($artistId);
       if (!defined $ar->LoadFromId())
       {
           return (undef, []);
       }
       $this->{artist} = $ar;     
   }

   $al = Album->new($this->{DBH});
   $al->SetArtist($ar->GetId());
   my (@aids) = $al->GetAlbumListFromName($name);
   if (scalar(@aids) > 1)
   {
       return (ALBUMLIST, \@aids);
   }

   my @albums = $ar->GetAlbums(0, 1);
   if (scalar(@albums) == 0)
   {
       return (undef, []);
   }

   $name = lc(decode "utf-8", $name);

   # do an exact match
   foreach $al (@albums)
   {
       my $thisname = lc(decode "utf-8", $al->GetName);

       if ($thisname eq $name)
       {
           push @ids, $this->SetSim({ id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        album_tracks=>$al->GetTrackCount(),
                        album_discids=>$al->GetDiscidCount(),
                        album_trmids=>$al->GetTrmidCount(),
                        sim_album=>1 });
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

           push @ids, $this->SetSim({ id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        album_tracks=>$al->GetTrackCount(),
                        album_discids=>$al->GetDiscidCount(),
                        album_trmids=>$al->GetTrmidCount(),
                        sim_album=>$sim});
           $this->{fuzzy} = 1;
       }
   }

   if (scalar(@ids) > 0)
   {
       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;
       return (ALBUMLIST, \@ids);
   }
  
   return (0, []);
}

# Internal.

sub TrackSearch
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
       $ar = Artist->new($this->{DBH});
       $ar->SetMBId($artistId);
       if (!defined $ar->LoadFromId())
       {
           return (undef, []);
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

           if ($duration > 0 && $row[3] > 0)
           {
               $lensim = 1 - (int(abs($duration - $row[3]) / 2000) * .25);
               $lensim = ($lensim < 0) ? 0 : $lensim;
           }

           push @ids, $this->SetSim({ id=>$row[0],
                        name=>$row[2], 
                        mbid=>$row[1],
                        tracklen=>$row[3],
                        sim_track=>$namesim,
                        sim_tracklen=>$lensim,
                      });
       }
       $sql->Finish;
   }

   return (0, []) if (scalar(@ids) == 0);

   @ids = (sort { $b->{sim} <=> $a->{sim} } @ids);
   @ids = splice @ids, 0, 10;
   $query = qq|select album.id, album.name, album.gid, albumjoin.sequence, track,
                      albummeta.tracks, albummeta.discids, albummeta.trmids 
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

           # Update the entry with the info for the album
           $id->{sim_album} = $namesim;
           $id->{sim_tracknum} = $numsim;
           $id->{tracknum} = $row[3];
           $id->{album} = $row[1];
           $id->{albummbid} = $row[2];
           $id->{albumid} = $row[0];
           $id->{album_tracks} = $row[5];
           $id->{album_discids} = $row[6];
           $id->{album_trmids} = $row[7];
           $id->{albumid} = $row[0];
           $id->{albumid} = $row[0];
           $id->{artist} = $ar->GetName();
           $id->{artistmbid} = $ar->GetMBId();
           $this->SetSim($id);
       }
       $sql->Finish;
   }

   @ids = sort { $b->{sim} <=> $a->{sim} } @ids;

   return (ALBUMTRACKLIST | $flags, \@ids);
}
