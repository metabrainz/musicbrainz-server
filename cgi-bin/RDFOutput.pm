#____________________________________________________________________________
#
#   MusicBrainz -- the internet music database
#
#   Copyright (C) 2000 Robert Kaye
#   Portions  (C) 2000 Benjamin Holzman
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
                                                                               
package RDFOutput;
use TableBase;

use strict;
use RDF;
use DBDefs;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = qw(TableBase RDF);
@EXPORT = @EXPORT = '';

sub new
{
    my ($type, $dbh) = @_;

    my $this = TableBase->new($dbh);
    return bless $this, $type;
}

# This function was taken from XML::Generator and is 
# Copyright (C) 2000 Benjamin Holzman
sub escape 
{
    $_[0] =~ s/&/&amp;/g;  # & first of course
    $_[0] =~ s/</&lt;/g;
    $_[0] =~ s/>/&gt;/g;
    return $_[0];
}

sub ErrorRDF
{
    my ($this, $text, $emit_headers) = @_;
    my ($rdf, $r, $len);

    $rdf = $this->BeginRDFObject;
    $rdf .= $this->BeginDesc;
    $rdf .= $this->Element("MQ:Error", $text);
    $rdf .= $this->EndDesc;
    $rdf .= $this->EndRDFObject;

    if (defined $emit_headers && $emit_headers)
    {
        $len = length($rdf);
        $rdf = "Content-type: text/plain\n" .
               "Content-Length: $len\n\r\n" . $rdf;
    }

    return $rdf;
}

sub CreateStatus
{
   my ($this, $count) = @_;
   my $rdf;

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc;
   $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $this->EndDesc;
   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub CreateFreeDBLookup
{
   my ($this, $info) = @_;

   return $this->CreateStatus(0);
}

sub CreateTrackList
{
   my ($this, @ids) = @_;
   my ($rdf, $id, $count);

   $rdf = $this->BeginRDFObject;
   $rdf .= $this->BeginDesc;
   $rdf .= $this->BeginElement("MM:Collection", 'type'=>'trackList');
   $rdf .= $this->BeginBag();

   for($count = 0;; $count++)
   {
      $id = shift @ids;
      last if not defined $id;

      $rdf .= $this->BeginLi;
      $rdf .= $this->CreateTrackRDFSnippet(1, $id);
      $rdf .= $this->EndLi;
   }

   $rdf .= $this->EndBag();
   $rdf .= $this->EndElement("MM:Collection");
   $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $this->EndDesc;
   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub CreateTRMList
{
   my ($this, @ids) = @_;
   my ($rdf, $id, $count);

   $rdf = $this->BeginRDFObject;
   $rdf .= $this->BeginDesc;
   $rdf .= $this->BeginElement("MM:Collection", 'type'=>'TRMList');
   $rdf .= $this->BeginBag();

   for($count = 0;; $count++)
   {
      $id = shift @ids;
      last if not defined $id;

      $rdf .= $this->BeginLi;
      $rdf .= $this->Element("DC:Identifier", "", TRM=>($id));
      $rdf .= $this->EndLi;
   }

   $rdf .= $this->EndBag();
   $rdf .= $this->EndElement("MM:Collection");
   $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $this->EndDesc;
   $rdf .= $this->EndRDFObject;

   return $rdf;
}

sub CreateMetadataExchange
{
   my ($this, @data) = @_;
   my ($rdf);

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc;
   $rdf .= $this->Element("DC:Title", $data[0])
       unless !defined $data[0] || $data[0] eq '';
   $rdf .= $this->Element("DC:Identifier", "", TRM=>$data[4])
       unless !defined $data[4] || $data[4] eq '';
   $rdf .= $this->Element("DC:Creator", $data[1])
       unless !defined $data[1] || $data[1] eq '';

   if (defined $data[2] && $data[2] ne '')
   {
       $rdf .= $this->BeginElement("DC:Relation", 'type'=>'album');
       $rdf .=    $this->BeginDesc;
       $rdf .=       $this->Element("DC:Title", escape($data[2]));
       $rdf .=    $this->EndDesc();
       $rdf .= $this->EndElement("DC:Relation");
   }

   $rdf .= $this->Element("MM:TrackNum", $data[3])
       unless !defined $data[3] || $data[3] == 0;
   $rdf .= $this->Element("DC:Format", "", duration=>$data[13])
       unless !defined $data[13] || $data[13] == 0;
   $rdf .= $this->Element("DC:Date", "", issued=>$data[6])
       unless !defined $data[6] || $data[6] == 0;
   $rdf .= $this->Element("MM:Genre", $data[7])
       unless !defined $data[7] || $data[7] eq '';
   $rdf .= $this->Element("DC:Description", $data[8])
       unless !defined $data[8] || $data[8] eq '';
   $rdf .= $this->Element("MQ:Status", "OK", items=>1);
   $rdf .= $this->EndDesc();
   $rdf .= $this->EndRDFObject();

   return $rdf;
}

# returns an artistList
sub CreateArtistList
{
   my ($this, $doc);
   my ($rdf, $sql, @row, $id, $r, $count);

   $this = shift @_; 
   $doc = shift @_;
   $count = 0;

   $sql = Sql->new($this->{DBH});

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc; 
   $rdf .= $this->BeginElement("MM:Collection", 'type'=>'artistList'); 
   $rdf .= $this->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       if ($sql->Select("select name, gid from Artist where id = $id"))
       {
            for(; @row = $sql->NextRow(); $count++)
            {
                $rdf .= $this->BeginLi();
                $rdf .=   $this->Element("DC:Identifier", "", 
                                         'artistId'=>$row[1]);
                $rdf .=   $this->Element("DC:Creator", escape($row[0]));
                $rdf .= $this->EndLi();
            }
            $sql->Finish;
       }
   }
   $rdf .= $this->EndBag();
   $rdf .= $this->EndElement("MM:Collection"); 
   $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $this->EndDesc();
   $rdf .= $this->EndRDFObject();  

   return $rdf;
}

# returns an albumList
sub CreateAlbumList
{
   my ($this);
   my ($rdf, $sql, @row, $id, $r, $count);

   $this = shift @_; 

   $count = 0;

   $sql = Sql->new($this->{DBH});

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc; 
   $rdf .= $this->BeginElement("MM:Collection", 'type'=>'albumList'); 
   $rdf .= $this->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       if ($sql->Select(qq\select Album.name, Album.gid, Artist.name, 
                           Artist.gid from Album, Artist where Album.artist = 
                           Artist.id and Album.id = $id\))
       {
            for(;@row = $sql->NextRow(); $count++)
            {
                $rdf .= $this->BeginLi();
                $rdf .=   $this->Element("DC:Identifier", "", 
                              'artistId'=>$row[3]);
                $rdf .=   $this->Element("DC:Creator", escape($row[2]));
                $rdf .=   $this->BeginElement("DC:Relation", 'type'=>'album');
                $rdf .=      $this->BeginDesc();
                $rdf .=         $this->Element("DC:Title", escape($row[0]));
                $rdf .=         $this->Element("DC:Identifier", "", 
                                            'albumId'=>$row[1]);
                $rdf .=      $this->EndDesc();
                $rdf .=   $this->EndElement("DC:Relation");
                $rdf .= $this->EndLi();
            }
            $sql->Finish;
       }
       else
       {
            if ($sql->Select(qq\select Album.name, Album.gid from Album  
                                where Album.id = $id\))
            {
                 for(;@row = $sql->NextRow(); $count++)
                 {
                     $rdf .= $this->BeginLi();
                     $rdf .=   $this->Element("DC:Identifier", "", 
                                   'albumId'=>$row[1]);
                     $rdf .=   $this->Element("DC:Creator", "[Multiple Artists]");
                     $rdf .=   $this->BeginElement("DC:Relation", "", 
                                                'type'=>'album');
                     $rdf .=      $this->BeginDesc();
                     $rdf .=         $this->Element("DC:Title", escape($row[0]));
                     $rdf .=         $this->Element("DC:Identifier", "", 
                                                 'albumId'=>$row[1]);
                     $rdf .=      $this->EndDesc();
                     $rdf .=   $this->EndElement("DC:Relation");
                     $rdf .= $this->EndLi();
                 }
                 $sql->Finish;
            }
       }
   }
   $rdf .= $this->EndBag();
   $rdf .= $this->EndElement("MM:Collection"); 
   $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $this->EndDesc();
   $rdf .= $this->EndRDFObject();  

   return $rdf;
}

# returns album
sub CreateAlbum
{
   my ($this, $fuzzy);
   my ($sql, $sql2, $rdf, @row, @row2);
   my ($artist, $artist_gid, $id, $count, $trdf, $numtracks, $first);

   $this = shift @_; 
   $fuzzy = shift @_; 
   $id = shift @_;
   $count = 0;

   $sql = Sql->new($this->{DBH});
   $sql2 = Sql->new($this->{DBH});

   $rdf = $this->BeginRDFObject();
   $rdf .= $this->BeginDesc; 

   $artist = "";
   $artist_gid = "";
   $first = 1;
   if ($sql->Select(qq\select Album.name, Album.gid, Album.id, 
                     Album.artist from Album where Album.id = $id\))
   {
        while(@row = $sql->NextRow())
        {
            $trdf = "";
            if ($sql2->Select(qq\select Track.id, Artist.id, Artist.name, 
                Artist.gid from Track, Artist, AlbumJoin where AlbumJoin.track 
                = Track.id and AlbumJoin.album = $row[2] and Track.artist = 
                Artist.id order by AlbumJoin.sequence\))
            {
                $numtracks = $sql2->Rows;
                $this->BeginSeq();
                $this->BeginLi();
                while(@row2 = $sql2->NextRow())
                {
                     $trdf .= $this->BeginLi();
                     $trdf .= $this->CreateTrackRDFSnippet(!($row[3]), 
                                                           $row2[0]);
                     $trdf .= $this->EndLi();
                
                     $artist = $row2[2] if ($row2[1] != 0);
                     $artist_gid = $row2[3] if ($row2[1] != 0);
                }
                $this->EndLi();
                $this->EndSeq();
                $sql2->Finish;
            }

            $rdf .= $this->BeginElement("MM:Collection", 
                                     'type'=>'album',
                                     'numParts'=>$numtracks); 

            $rdf .= $this->BeginDesc();
            $rdf .= $this->Element("DC:Identifier", "",
                                'albumId'=>escape($row[1]));
            $rdf .= $this->Element("DC:Title", escape($row[0]));

            if ($row[3] != 0)
            {
                $rdf .= $this->Element("DC:Creator", $artist);
                $rdf .= $this->Element("DC:Identifier", "",
                                    'artistId'=>escape($artist_gid));
            }

            $rdf .= $this->BeginSeq();
            $rdf .= $trdf;
            $rdf .= $this->EndSeq();
        
            $rdf .= $this->EndDesc();
            $rdf .= $this->EndElement("MM:Collection"); 

            $count++;
        }
        $sql->Finish;
   }

   if ($fuzzy)
   {
      $rdf .= $this->Element("MQ:Status", "Fuzzy", items=>$count);
   }
   else
   {
      $rdf .= $this->Element("MQ:Status", "OK", items=>$count);
   }
   $rdf .= $this->EndDesc();
   $rdf .= $this->EndRDFObject();  

   return $rdf;
}

# returns single track description
sub CreateTrackRDFSnippet
{
   my ($this);
   my ($sql, $rdf, @row, $id, $r, @TRM, $gu, $emit_details);

   $this = shift @_; 
   $emit_details = shift @_; 
   $gu = TRM->new($this->{DBH});
   $sql = Sql->new($this->{DBH});

   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       if ($sql->Select(qq/select Track.name, Track.gid, 
                AlbumJoin.sequence, Artist.name, Artist.gid, Album.name, 
                Album.gid, Track.Length from Track, Artist,Album, AlbumJoin where 
                Track.id = $id and Track.artist = Artist.id and 
                AlbumJoin.album = Album.id and AlbumJoin.track = 
                Track.id order by AlbumJoin.sequence/))
       {
            while(@row = $sql->NextRow())
            {
                my %ids;

                $ids{'trackId'} = escape($row[1]),

                @TRM = $gu->GetTRMFromTrackId($id);
                $ids{'trackTRM'} = escape($TRM[0]->{TRM}) 
                    if (scalar(@TRM) > 0);

                if ($emit_details)
                {
                    $ids{'artistId'} = escape($row[4]),
                    $ids{'trackId'} = escape($row[1]);
                }

                $rdf .= $this->Element("DC:Identifier", "", %ids);
                $rdf .= $this->Element("MM:TrackNum", $row[2]);
                $rdf .= $this->Element("MM:Duration", $row[7]);
                $rdf .= $this->Element("DC:Title", escape($row[0]));

                if ($emit_details)
                {
                    $rdf .= $this->Element("DC:Creator", escape($row[3]));
                    $rdf .= $this->BeginElement("DC:Relation", "type"=>"album");
                    $rdf .=   $this->BeginDesc();
                    $rdf .=     $this->Element("DC:Title", 
                                            escape($row[5]));
                    $rdf .=     $this->Element("DC:Identifier", "",
                                  'albumId'=>escape($row[6]));
                    $rdf .=   $this->EndDesc();
                    $rdf .= $this->EndElement("DC:Relation");
                }
            }     
            $sql->Finish;
       }
   }

   return $rdf;
}


