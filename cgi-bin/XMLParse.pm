#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
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
                                                                               
package XMLParse;

use strict;
use XML::Parser;
use CGI;
use MusicBrainz;
use QuerySupport;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

my $CDInfo;
my $IdInfo;
my $NumIds;
my $DiskId;
my $SingleArtist;
my $MultipleArtist;
my $TrackInfo;
my $CurrentElement;
my $CurrentOffset;
my $CurrentTrack;
my $IsSingleArtist;
my $RetVal;

sub SubmitCDInfo
{
    my ($cd, $queryname, $xml) = @_;
    my ($ret, $n1);

    $n1 = new XML::Parser(Handlers => {
                                        Init     => \&ParseInit,
                                        Final    => \&ParseFinal,
                                        Start    => \&ParseStart,
                                        End      => \&ParseEnd,
                                        Char     => \&ParseChar
                                      });

    eval
    {
        $ret = $n1->parsestring($xml);
    };
    if ($@)
    {
         $@ =~ tr/\n\r/  /;
         $xml = QuerySupport::EmitErrorXML("XML Parse error: $@");
    }
    else
    {
         if ($ret eq '')
         {
            $xml = "<XD3>\n  <Result>\n    <Name>$queryname</Name>\n";
            $xml .= "  </Result>\n</XD3>\n";
         }
         else
         {
            $xml = QuerySupport::EmitErrorXML("$ret");
         }
    }

    return $xml;
}

sub ParseInit
{
   my ($Expat) = $_;
   my %Temp;

   $CDInfo = \%Temp;

   $RetVal = '';
}

sub ParseFinal
{
   my ($Expat) = $_;

   return $RetVal;
}

sub ParseStart
{
   my ($Expat, $Element, %Attr) = @_;
   my $key;
   
   $CurrentElement = $Element;

   if ($Element eq 'Id' || $Element eq 'Title' || $Element eq 'NumTracks' ||
       $Element eq 'Name' || $Element eq 'Artist' || $Element eq 'CDInfoDump')
   {
      return;
   }
   if ($Element eq 'CDInfo')
   {
      return;
   }
   if ($Element eq 'IdInfo')
   {
      my %Temp;

      $IdInfo = \%Temp;
      $NumIds = 0;
      return;
   }
   if ($Element eq 'DiskId')
   {
      my %Temp;

      $DiskId = \%Temp;
      return;
   }
   if ($Element eq 'TOC')
   {
      $DiskId->{First} = $Attr{First};
      $DiskId->{Last} = $Attr{Last};
      return;
   }
   if ($Element eq 'Offset')
   {
      $CurrentOffset = $Attr{Num};
      return;
   }
   if ($Element eq 'SingleArtistCD')
   {
      my %Temp;

      $SingleArtist = \%Temp;
      $IsSingleArtist = 1;
      return;
   }
   if ($Element eq 'MultipleArtistCD')
   {
      my %Temp;

      $MultipleArtist = \%Temp;
      $IsSingleArtist = 0;
      return;
   }
   if ($Element eq 'Track')
   {
      my %Temp;

      $TrackInfo = \%Temp;
      $CurrentTrack = $Attr{Num};
      return;
   }
   if ($Element eq '')
   {
      return;
   }
   if ($Element eq '')
   {
      return;
   }

   $RetVal .=  "Parse error: Unrecognized element $Element\n";
}

sub ParseEnd
{
   my ($Expat, $Element) = @_;
   my $cd;

   $cd = new MusicBrainz;

   $CurrentElement = '';
   if ($Element eq 'Id' || $Element eq 'Offset' || $Element eq 'Artist' || 
       $Element eq 'TOC' || $Element eq 'Name' ||  $Element eq 'Title' || 
       $Element eq 'NumTracks' || $Element eq 'CDInfoDump')
   {
      return;
   }
   if ($Element eq 'DiskId')
   {
      $IdInfo->{$NumIds} = $DiskId;
      $NumIds++;
      return;
   }
   if ($Element eq 'IdInfo')
   {
      $CDInfo->{IdInfo} = $IdInfo;
      return;
   }
   if ($Element eq 'SingleArtistCD')
   {
      $CDInfo->{SingleArtist} = $SingleArtist;
      return;
   }
   if ($Element eq 'MultipleArtistCD')
   {
      $CDInfo->{MultipleArtist} = $MultipleArtist;
      return;
   }
   if ($Element eq 'Track')
   {
      if (!$IsSingleArtist)
      {
          $MultipleArtist->{$CurrentTrack} = $TrackInfo;
      }
      return;
   }
   if ($Element eq 'CDInfo')
   {
      if ($RetVal eq '')
      {
          my $ret;

          $cd->Login;
          if ($IsSingleArtist)
          {
              $ret = AcceptSingleArtistXML($CDInfo, $cd);
          }
          else
          {
              $ret = AcceptMultipleArtistXML($CDInfo, $cd);
          }
          if ($ret ne '')
          {
             $RetVal .= "DB Error: $ret\n";
          }
          $cd->Logout;
      }
      return;
   }

   $RetVal .= "Parse error: Unrecognized close element $Element\n";
}

sub ParseChar
{
   my ($Expat, $Char) = @_;
   my $Dummy;

   if ($CurrentElement eq 'Title')
   {
      $CDInfo->{Title} .= $Char;
      return;
   }
   if ($CurrentElement eq 'NumTracks')
   {
      $CDInfo->{NumTracks} = $Char;
      return;
   }
   if ($CurrentElement eq 'Id')
   {
      $DiskId->{Id} .= $Char;
      return;
   }
   if ($CurrentElement eq 'Offset')
   {
      $DiskId->{$CurrentOffset} = $Char;
      return;
   }
   if ($CurrentElement eq 'Artist')
   {
      if ($IsSingleArtist)
      {
          $SingleArtist->{Artist} .= $Char;
      }
      else
      {
          $TrackInfo->{Artist} .= $Char;
      }
      return;
   }
   if ($CurrentElement eq 'Name')
   {
      if ($IsSingleArtist)
      {
          $SingleArtist->{$CurrentTrack} .= $Char;
      }
      else
      {
          $TrackInfo->{Name} .= $Char;
      }
      return;
   }

   $Dummy = $Char;
   $Dummy =~ tr/ \n\r\t//ds;
   if ($Dummy ne '')
   {
       $RetVal = "Parse Error: Extra character data '$Char'\n";
   }
}

sub GenerateTOC
{
    my $DiskId = shift;
    my $tracks = shift;
    my $i;
    my $toc;

    if (!defined $DiskId->{Last} || !defined $DiskId->{First})
    {
       return ('', '');
    }

    if ($tracks ne $DiskId->{Last})
    {
       return ("Table of contents data does not contain the same number of tracks as the album.",
               '');
    }

    $toc = "$DiskId->{First} $DiskId->{Last}";
    for($i = 0; $i <= $tracks; $i++)
    {
        if (!defined $DiskId->{$i} || $DiskId->{$i} eq '')
        {
             return ("The offset information for this CD is not complete.", "");
        }
        $toc .= " $DiskId->{$i}";
    }

    return ('', $toc);
}

sub WriteDiskIds
{
    my $cd = shift;
    my $album = shift;
    my $CDInfo = shift;
    my $tracks = shift;
    my ($err, $key, $toc);
    my $IdRef = $CDInfo->{IdInfo};

    foreach $key (sort keys %$IdRef) 
    {
        ($err, $toc) = GenerateTOC($IdRef->{$key}, $tracks);
        if ($err ne '')
        {
            return $err;
        }
        if (!defined $IdRef->{$key}->{Id})
        {
            $IdRef->{$key}->{Id} = '';
        }

        if ($IdRef->{$key}->{Id} ne '' || $toc ne '')
        {
            $cd->InsertDiskId($IdRef->{$key}->{Id}, $album, $toc);
            $cd->InsertTOC($IdRef->{$key}->{Id}, $album, $toc);
        }
    }
}

sub AcceptSingleArtistXML
{
    my $CDInfo = shift;
    my $cd = shift;
    my $tracks;
    my $artistname;
    my $title;
    my $toc;
    my $artist;
    my ($sql, $sql2);
    my $album;
    my $i;
    my $err;

    # Extract the key information from the hash and carry out basic sanity checking
    $artistname = $CDInfo->{SingleArtist}->{Artist};
    if (!defined $artistname || $artistname eq '')
    {
        return "Missing artist name.";
    }
    $title = $CDInfo->{Title};
    if (!defined $title || $title eq '')
    {
        return "Missing title.";
    }
    $tracks = $CDInfo->{NumTracks};
    if (!defined $tracks || $tracks eq '')
    {
        return "Missing title.";
    }

    for($i = 1; $i <= $tracks; $i++)
    {
       if (!defined $CDInfo->{SingleArtist}->{$i} || 
           $CDInfo->{SingleArtist}->{$i} eq '')
       {
           return "Track $i title is missing";
       }
    }

    # Start the insertion process, handling all the key elements
    $artist = $cd->InsertArtist($artistname);
    if ($artist < 0)
    {
        return "Cannot insert artist into the database.";
    }

    $album = $cd->GetAlbumId($title, $artist, $tracks);
    if ($album >= 0)
    {
        return "This album is already in the index.";
    }

    $album = $cd->InsertAlbum($title, $artist, $tracks);
    if ($album < 0)
    {
        return "Cannot insert album into the database.";
    }

    for($i = 0; $i < $tracks; $i++)
    {
       my $t;

       $t = $i + 1;
       $title = $cd->{DBH}->quote($CDInfo->{SingleArtist}->{($t)});
       $cd->InsertTrack($title, $artist, $album, $i);
    }

    return WriteDiskIds($cd, $album, $CDInfo, $tracks);
}

sub AcceptMultipleArtistXML
{
    my $CDInfo = shift;
    my $cd = shift;
    my $tracks;
    my $artistname;
    my $title;
    my $toc;
    my $artist;
    my ($sql, $sql2);
    my $album;
    my $i;
    my $err;

    # Extract the key information from the hash and carry out basic sanity checking
    $title = $CDInfo->{Title};
    if (!defined $title || $title eq '')
    {
        return "Missing title.";
    }
    $tracks = $CDInfo->{NumTracks};
    if (!defined $tracks || $tracks eq '')
    {
        return "Missing title.";
    }

    for($i = 1; $i <= $tracks; $i++)
    {
       if (!defined $CDInfo->{MultipleArtist}->{$i}->{Artist} || 
                    $CDInfo->{MultipleArtist}->{$i}->{Artist} eq '')
       {
           return "Artist $i name is missing";
       }
       if (!defined $CDInfo->{MultipleArtist}->{$i}->{Name} || 
                    $CDInfo->{MultipleArtist}->{$i}->{Name} eq '')
       {
           return "Track $i title is missing";
       }
    }

    $album = $cd->GetAlbumId($title, 0, $tracks);
    if ($album > 0)
    {
        return "This album is already in the index.";
    }
    $album = $cd->InsertAlbum($title, 0, $tracks);
    if ($album < 0)
    {
        return "Cannot insert a new album into the database.";
    }

    for($i = 0; $i < $tracks; $i++)
    {
       my $t;

       $t = $i + 1;
       $artistname = $CDInfo->{MultipleArtist}->{($t)}->{Artist};
       $artist = $cd->InsertArtist($artistname);
       if ($artist < 0)
       {
           return "Cannot insert a new artist into the database.";
       }

       $title = $CDInfo->{MultipleArtist}->{($t)}->{Name};
       $cd->InsertTrack($title, $artist, $album, $i);
    }

    return WriteDiskIds($cd, $album, $CDInfo, $tracks);
}

1;
