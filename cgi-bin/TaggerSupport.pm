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

use constant FUZZY_THRESHOLD => .8;
use constant ALL_WORDS       => 1;

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

sub Lookup
{
   my ($this, $doc, $rdf, $artistName, $albumName, $trackName, $trmId,
       $trackNum, $duration, $fileName, $artistId, $albumId, $trackId, $maxItems) = @_;

   my ($fileInfo, %info);

   # Initialize the data to reasonable defaults
   $artistName ||= '';
   $albumName ||= '';
   $trackName ||= '';
   $trackNum = 0 if (!defined $trackNum || !($trackNum =~ /^\d+$/));
   $artistId ||= '';
   $albumId ||= '';
   $trackId ||= '';

   $this->{fuzzy} = 0;
   $maxItems = 15 if not defined $maxItems;
   $this->{maxitems} = $maxItems;

   if ($artistName eq "Various Artists")
   {
       $artistId = "e06d2236-5806-409f-ac9f-9245844ce5d9";
   }

   if ($artistName eq '' || $albumName eq '' || $trackName eq '' || 
       $trackNum < 0 || $trackNum > 99)
   {
       ($artistName, $albumName, $trackName, $trackNum) = 
           $this->ParseFileName($fileName, $artistName, $albumName, $trackName, $trackNum);
   }

   if ($artistId eq '')
   {
       my $artistList;

       return $rdf->ErrorRDF("No artist name or artist id given.") if ($artistName eq '');

       ($artistId, $artistList) = $this->ArtistSearch($artistName);
       if (not defined $artistId)
       {
           if (scalar(@$artistList) > 0)
           {
               $this->{artistlist} = $artistList;
           }

           return $rdf->CreateFileLookup($this, "unknown");
       }
       $this->{artistid} = $artistId;
       print STDERR "FIL artistId: $artistId\n";
   }   

   if ($albumId eq '')
   {
       if ($albumName ne '')
       {
           my $albumList;

           ($albumId, $albumList) = $this->AlbumSearch($albumName, $artistId);
           if (not defined $albumId)
           {
               if (scalar(@$albumList) > 0)
               {
                   $this->{albumlist} = $albumList;
               }

               return $rdf->CreateFileLookup($this, "artist");
           }
           $this->{albumid} = $albumId;
           print STDERR "FIL albumId: $albumId\n";
       }   
   }   

   if ($trackId eq '')
   {
       my $trackList;

       ($trackId, $trackList) = $this->TrackSearch($trackName, $artistId, $albumId, 
                                                   $trackNum, $duration);
       if (not defined $trackId)
       {
           if (scalar(@$trackList) > 0)
           {
               $this->{tracklist} = $trackList;
           }

           if ($albumId ne '')
           {
               return $rdf->CreateFileLookup($this, "artist_album");
           }
           else
           {
               return $rdf->CreateFileLookup($this, "artist");
           }
       }
       $this->{trackid} = $trackId;
       print STDERR "FIL trackId: $trackId\n";
   }   

   print STDERR "\n";
   return $rdf->CreateFileLookup($this, 
                      ($albumId ne '') ? "artist_album_track" : "artist_track");
}

sub ParseFileName
{
   my ($this, $fileName, $artistName, $albumName, $trackName, $trackNum) = @_;
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
        $artistName ||= $parts[0];
        $albumName ||= $parts[1];
        if ($parts[2] =~ /^\d+$/)
        {
            $trackNum ||= $parts[2];
        }
        $trackName ||= $parts[3];
   }
   elsif (scalar(@parts) == 3)
   {
        $artistName ||= $parts[0];
        if ($parts[1] =~ /^\d+$/)
        {
            $trackNum ||= $parts[1];
        }
        else
        {
            $albumName ||= $parts[1];
        }
        $trackName ||= $parts[2];
   }
   elsif (scalar(@parts) == 2)
   {
        $artistName ||= $parts[0];
        $trackName ||= $parts[1];
   }
   elsif (scalar(@parts) == 1)
   {
        $trackName ||= $parts[0];
   }
   return ($artistName, $albumName, $trackName, $trackNum);
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
       return ($ar->GetMBId(), []);
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
           return ($ar->GetMBId(), []);
       }
   }
   else
   {
       my $row;
       
       while($row = $engine->NextRow)
       {
           push @ids, $row->[3];
       }

       return (undef, \@ids);
   }

   return (undef, []);
}

sub AlbumSearch
{
   my ($this, $name, $artistId) = @_;
   my ($ar, $al, @ids, $last);

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
       return (undef, \@aids);
   }

   if (scalar(@aids) == 1)
   {
       print STDERR "Album: single album name match: $aids[0]\n";
       return ($aids[0], []);
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
           push @ids, $al->GetMBId(); 
           $last = $al;
       }
   }

   # do fuzzy matches if need be
   if (scalar(@ids) == 0)
   {
       print STDERR "Albums: fuzzy match\n"; 
       foreach $al (@albums)
       {
           if (similarity($al->GetName(), $name) >= FUZZY_THRESHOLD)
           {
               print STDERR "Album: fuzzy match '$al->{name}'\n";
               push @ids, $al->GetMBId(); 
               $last = $al;
               $this->{fuzzy} = 1;
           }
       }
   }

   if (scalar(@ids) == 1)
   {
       print STDERR "Album: one item found\n";
       $this->{album} = $last;
       return ($last->GetMBId(), []);
   }

   if (scalar(@ids) > 0)
   {
       print STDERR "Album: return " . scalar(@ids) . "\n";
       return (undef, \@ids);
   }
  
   # Still nothing. Do an album search
   my $engine = SearchEngine->new($this->{DBH});
   $engine->Table('Album');
   $engine->AllWords(ALL_WORDS);
   $engine->Limit($this->{maxitems});
   $engine->Search($name);

   my $row;
   while($row = $engine->NextRow)
   {
       push @ids, $row->[4];
   }
   print STDERR "Album: search return " . scalar(@ids) . "\n";

   return (undef, \@ids);
}

sub TrackSearch
{
   my ($this, $name, $artistId, $albumId, $trackNum, $duration) = @_;
   my ($ar, $al, $tr, @ids, $last);

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

   # If no album is given, try to find the track given the track name, num or duration
   if ($albumId eq '')
   {
       my $sql;

       # Try the track name search
       $sql = Sql->new($this->{DBH});
       if ($sql->Select(qq|select track.id, track.gid from Track 
                            where track.artist = | . $ar->GetId() . qq| and
                                  track.name = | . $sql->Quote($name)))
       {
           my (@row, @ids);

           if ($sql->Rows == 1)
           {
               @row = $sql->NextRow;    
               $sql->Finish;
               $this->{fuzzy} = 1;
               print STDERR "Track: return no album 1 name match\n";
               return ($row[1], []);
           }
           if ($sql->Rows > 1)
           {
               while(@row = $sql->NextRow)
               {
                   push @ids, $row[1];
               }
               $sql->Finish;

               print STDERR "Track: return no album name matches\n";
               return (undef, \@ids);
           }

           $sql->Finish;
       }

       # try to match a track based on duration
       if ($duration > 0)
       {
           if ($sql->Select(qq|select track.id, track.gid from Track 
                                where track.artist = | . $ar->GetId() . qq| and
                                      track.length >= | . ($duration - 1000) . 
                                      " and track.length <= " . ($duration + 1000)))
           {
               my (@row, @ids);

               if ($sql->Rows == 1)
               {
                   @row = $sql->NextRow;    
                   $sql->Finish;
                   $this->{fuzzy} = 1;
                   print STDERR "Track: return no album 1 duration match\n";
                   return ($row[1], []);
               }
               if ($sql->Rows > 1)
               {
                   while(@row = $sql->NextRow)
                   {
                       push @ids, $row[1];
                   }
                   $sql->Finish;

                   print STDERR "Track: return no album duration matches\n";
                   return (undef, \@ids);
               }

               $sql->Finish;
           }
       }

       print STDERR "Track: no album, no shorts, no service!\n";
       return (undef, \@ids);
   }

   if (exists $this->{album})
   {
       $al = $this->{album};
   }
   else
   {
       $al = Album->new($this->{DBH});
       $al->SetMBId($albumId);
       if (!defined $al->LoadFromId())
       {
           print STDERR "Track: failed to load album\n";
           return (undef, []);
       }
       $this->{album} = $al;     
   }

   my @tracks = $al->LoadTracks();
   if (scalar(@tracks) == 0)
   {
       return (undef, []);
   }

   # TODO: Document this shortcut
   if ($name ne '')
   {
       print STDERR "Track: exact match\n"; 
       # do an exact match
       foreach $tr (@tracks)
       {
           if (lc($tr->GetName()) eq lc($name))
           {
               print STDERR "Track: exact match '$tr->{name}'\n";
               push @ids, $tr->GetMBId(); 
               $last = $tr;
           }
       }

       # do fuzzy matches if need be
       if (scalar(@ids) == 0)
       {
           print STDERR "Track: fuzzy match\n"; 
           foreach $tr (@tracks)
           {
               if (similarity($tr->GetName(), $name) >= FUZZY_THRESHOLD)
               {
                   print STDERR "Track: fuzzy match '$al->{name}'\n";
                   push @ids, $tr->GetMBId(); 
                   $last = $tr;
                   $this->{fuzzy} = 1;
               }
           }
       }

       if (scalar(@ids) == 1)
       {
           print STDERR "Track: one item found\n";
           return ($last->GetMBId(), []);
       }

       if (scalar(@ids) > 0)
       {
           print STDERR "Track: return " . scalar(@ids) . "\n";
           return (undef, \@ids);
       }
   }

   print STDERR "Track: no matches. return all tracks\n";

   my $trackNumMatch = "";
   foreach $tr (@tracks)
   {
       if ($trackNum != 0 && $tr->GetSequence() == $trackNum)
       {
           $trackNumMatch = $tr->GetMBId(); 
       }
       push @ids, $tr->GetMBId(); 
   }

   if ($trackNumMatch ne '')
   {
       print STDERR "Track: return trackNum match\n";
       return (undef, [$trackNumMatch]); 
   }

   print STDERR "Track: return " . scalar(@ids) . "\n";
   return (undef, \@ids);
}
