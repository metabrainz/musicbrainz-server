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
use String::Similarity;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use constant FUZZY_THRESHOLD_ALBUM  => .5;
use constant FUZZY_THRESHOLD_TRACK  => .5;
use constant ALL_WORDS              => 1;
use constant ALBUM_TRACK_THRESHOLD  => .25;

# These are the status flags that Lookup returns for the results
use constant ARTISTID               => 1; 
use constant ARTISTLIST             => 2;
use constant ALBUMID                => 4;
use constant ALBUMLIST              => 8;
use constant TRACKID                => 16;
use constant TRACKLIST              => 32;
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

sub FileInfoLookup
{
   my $tagger = TaggerSupport->new(shift);
   return $tagger->Lookup(@_);
}

# TODO: Fix this for the new Lookup function
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
   $data->{tracknum} = 0 if (!defined $data->{tracknum} || 
                             !($data->{tracknum} =~ /^\d+$/));

   foreach (keys %$data)
   {
       $data->{$_} =~ tr/A-Z/a-z/;
   }

   $this->{fuzzy} = 0;
   $maxItems = 15 if not defined $maxItems;
   $this->{maxitems} = $maxItems;

   if ($data->{artist} eq "Various Artists")
   {
       $data->{artistid} = "e06d2236-5806-409f-ac9f-9245844ce5d9";
   }

   # TODO: Re-add this. Its not useful for testing
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
       print STDERR "FIL artistId: $data->{artistid}\n";
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
       print STDERR "FIL albumId: $data->{albumid}\n";
   }   

   my $flags = 0;
   
   $flags |= ARTISTID if ($data->{artistid} ne '');
   $flags |= ALBUMID if ($data->{albumid} ne '');
   $flags |= TRACKID if ($data->{trackid} ne '');

   print STDERR "No-op in TaggerSupport!\n";
   return ("", $data, $flags, undef);
}

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
        $data->{album} ||= $parts[0];
        $data->{track} ||= $parts[1];
   }
   elsif (scalar(@parts) == 1)
   {
        $data->{track} ||= $parts[0];
   }
}

sub ArtistSearch
{
   my ($this, $name) = @_;
   my ($ar, @ids);

   $ar = Artist->new($this->{DBH});
   if (defined $ar->LoadFromName($name))
   {
       print STDERR "Artist: loaded '$name'\n";

       $this->{artist} = $ar;     
       return (ARTISTID, [ 
                           {
                             id=>$ar->GetId(),
                             mbid=>$ar->GetMBId(), 
                             name=>$ar->GetName(),
                             sortname=>$ar->GetSortName(),
                             sim=>1
                           }
                         ]);
   }

   my $engine = SearchEngine->new($this->{DBH});
   $engine->Table('Artist');
   $engine->AllWords(ALL_WORDS);
   $engine->Limit($this->{maxitems});
   $engine->Search($name);
   if ($engine->Rows == 1)
   {
       my $row = $engine->NextRow;

       $ar->SetId($row->[0]);
       if (defined $ar->LoadFromId())
       {
           print STDERR "Artist: found 1/loaded '$ar->{name}'\n";
           $this->{artist} = $ar;     
           $this->{fuzzy} = 1;
           return (ARTISTID | FUZZY, 
                             [ 
                               { 
                                 id=>$ar->GetId(),
                                 mbid=>$ar->GetMBId(), 
                                 name=>$ar->GetName(),
                                 sortname=>$ar->GetSortName(),
                                 sim=>similarity(lc($ar->GetName()), $name)
                               }
                             ]);
       }
   }
   else
   {
       my $row;
       
       print STDERR "Artist: search on '$name'\n";
       while($row = $engine->NextRow)
       {
           print STDERR "  $row->[1]\n";
           push @ids, { id=>$row->[0],
                        name=>$row->[1],
                        sortname=>$row->[2],
                        mbid=>$row->[3], 
                        sim=>similarity(lc($row->[1]), $name) };
       }

       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;

       return (ARTISTLIST, \@ids);
   }

   return (0, []);
}

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
           print STDERR "Album: failed to load artist\n";
           return (undef, []);
       }
       $this->{artist} = $ar;     
   }

   $al = Album->new($this->{DBH});
   $al->SetArtist($ar->GetId());
   my (@aids) = $al->GetAlbumListFromName($name);
   if (scalar(@aids) > 1)
   {
       print STDERR "Album: more then one album by same name\n";
       return (ALBUMLIST, \@aids);
   }

   my @albums = $ar->GetAlbums();
   if (scalar(@albums) == 0)
   {
       return (undef, []);
   }

   print STDERR "Albums: exact match\n"; 
   # do an exact match
   foreach $al (@albums)
   {
       if (lc($al->GetName()) eq lc($name))
       {
           print STDERR "Album: exact match '$al->{name}'\n";
           push @ids, { id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        sim=>1 };
       }
   }

   # do fuzzy matches if need be
   if (scalar(@ids) == 0)
   {
       my $sim;

       print STDERR "Albums: fuzzy match\n"; 
       foreach $al (@albums)
       {
           $sim = similarity(lc($al->GetName()), $name);
           print STDERR "Album: fuzzy match '$al->{name}'\n";
           push @ids, { id=>$al->GetId(),
                        name=>$al->GetName(),
                        mbid=>$al->GetMBId(),
                        sim=>$sim};
           $this->{fuzzy} = 1;
       }
   }

   if (scalar(@ids) > 0)
   {
       print STDERR "Album: return " . scalar(@ids) . "\n";
       @ids = sort { $b->{sim} <=> $a->{sim} } @ids;
       return (ALBUMLIST, \@ids);
   }
  
   return (0, []);
}

# TODO: Finish ranking & fuzzy attrs
sub TrackSearch
{
   my ($this, $artistId, $trackName, $albumName, $trackNum, $duration) = @_;
   my ($ar, $al, $tr, @ids, $last, $id, %result);
   my ($sql, $tracks, $count, $query, $flags);

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
           print STDERR "Track: failed to load artist\n";
           return (undef, []);
       }
       $this->{artist} = $ar;     
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
           $lensim = 0.0;
           $namesim = similarity(lc($row[2]), $trackName);
           if ($row[2] =~ /^(.*)\s*\(.*\)\s*$/)
           {
               my $chopsim = similarity(lc($1), $trackName);
               $namesim = ($chopsim > $namesim) ? $chopsim : $namesim;
           }
           if ($duration > 0 && $row[3] > 0)
           {
               $lensim = 1 - (int(abs($duration - $row[3]) / 2000) * .25);
               $lensim = ($lensim < 0) ? 0 : $lensim;
           }

           $sim = ($namesim * .5) + ($lensim * .5);
           push @ids, { id=>$row[0],
                        name=>$row[2], 
                        mbid=>$row[1],
                        id=>$row[0],
                        namesim=>$namesim,
                        lensim=>$lensim,
                        sim=>$sim
                      };
       }
       $sql->Finish;
   }

   return (0, []) if (scalar(@ids) == 0);

   @ids = (sort { $b->{sim} <=> $a->{sim} } @ids)[0..9];
   $query = qq|select album.id, album.name, album.gid, albumjoin.sequence, track 
                 from Album, AlbumJoin
                where albumjoin.album = album.id and albumjoin.track in (|;
   foreach $id (@ids)
   {
      $result{$id->{id}} = $id;
      $query .= $id->{id} . ",";
   }
   chop($query);
   $query .= ")";

   $sql = Sql->new($this->{DBH});
   if ($sql->Select($query))
   {
       my (@row, $namesim, $numsim);

       while(@row = $sql->NextRow)
       {
           $numsim = 0.0;
           $namesim = 0.0;

           if ($albumName ne '')
           {
               $namesim = similarity(lc($row[1]), $albumName);
           }
           if ($trackNum > 0 && $row[3] > 0 && $trackNum == $row[3])
           {
               $numsim = 1.0;
           }

           $id = $result{$row[4]};
           next if not defined $id;

           # Update the entry with the info for the album
           $id->{sim} = ($namesim * .3) + ($numsim * .1) + 
                        ($id->{namesim} * .3) + ($id->{lensim} * .3);
           $id->{albumsim} = $namesim;
           $id->{numsim} = $numsim;
           $id->{album} = $row[1];
           $id->{albummbid} = $row[2];
           $id->{albumid} = $row[0];
       }
       $sql->Finish;
   }

   @ids = sort { $b->{sim} <=> $a->{sim} } @ids;

   return (ALBUMTRACKLIST | $flags, \@ids);
}
