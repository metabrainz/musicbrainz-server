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
                                                                               
package QuerySupport;

use strict;
use XML::Parser;
use XML::DOM;
use XML::XQL;
use CGI;
use XMLParse;
use RDF;
use DBDefs;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

my %LyricTypes =
(
   unknown        => 0,
   lyrics         => 1,
   artitstinfo    => 2,
   albuminfo      => 3,
   trackinfo      => 4,
   funny          => 5
);

# This reverse table is a hack -- I'm running out of time!
my %TypesLyric =
(
   0 => "unknown",
   1 => "lyrics",
   2 => "artitstinfo",
   3 => "albuminfo",
   4 => "trackinfo",
   5 => "funny"
);

sub SolveXQL
{
    my ($doc, $xql) = @_;
    my ($data, $node, @result);

    @result = XML::XQL::solve ($xql, $doc);
    $node = $result[0];

    if (defined $node)
    {
        if ($node->getNodeType == XML::DOM::ELEMENT_NODE)
        {
            $data = $node->getFirstChild->getData
                if (defined $node->getFirstChild);
        }
        elsif ($node->getNodeType == XML::DOM::ATTRIBUTE_NODE)
        {
            $data = $node->getValue
                if (defined $node->getNodeType);
        }
    }

    return $data;
}


sub EmitErrorRDF
{
    my ($rdf, $r, $len);

    $r = RDF::new;

    $rdf .= $r->BeginRDFObject;
    $rdf .= $r->BeginDesc;
    $rdf .= $r->Element("MQ:Error", $_[0]);
    $rdf .= $r->EndDesc;
    $rdf .= $r->EndRDFObject;

    $len = length($rdf);
    $rdf = "Content-type: text/plain\n" .
           "Content-Length: $len\n\r\n" . $rdf;

    return $rdf;
}

sub GenerateCDInfoObjectFromDiskId
{
   my ($cd, $doc, $id, $numtracks, $toc) = @_;
   my ($sth, @row, $rdf, $album);

   return EmitErrorRDF("No DiskId given.") if (!defined $id);

   $sth = $cd->{DBH}->prepare("select Album from Diskid where disk='$id'");
   if ($sth->execute && $sth->rows)
   {
        @row =  $sth->fetchrow_array;
        $rdf = CreateAlbum($cd, 0, $row[0]);
   }
   else
   {
        $album = $cd->FindFreeDBEntry($numtracks, $toc, $id);
        if (defined $album)
        {
            $rdf = CreateAlbum($cd, 0, $album);
        }
        else
        {
            my (@albums, $album, $disk);

            @albums = $cd->FindFuzzy($numtracks, $toc);
            if (scalar(@albums) > 0)
            {
                $rdf = CreateAlbum($cd, 1, @albums);
            }
            else
            {
                my $r = RDF::new;

                $rdf = $r->BeginRDFObject;
                $rdf .= $r->BeginDesc;
                $rdf .= $r->Element("MQ:Status", "OK", items=>0);
                $rdf .= $r->EndDesc;
                $rdf .= $r->EndRDFObject;
            }
        }
   }
   $sth->finish;  

   return $rdf;
}

sub AssociateCDFromAlbumId
{
   my ($cd, $query, $diskid, $toc, $albumid) = @_;

   $cd->InsertDiskId($diskid, $albumid, $toc);
}

sub GenerateCDInfoObjectFromAlbumId
{
   my ($cd, $albumid, $fuzzy, $o) = @_;
   my ($sth, $xml, $i, $query);
   my ($artistid, $albumname, $artistname, $numtracks);

   $o = CGI::new if (!defined $o);

   return EmitErrorRDF("No album id given.") if (!defined $albumid);
   return undef if (!defined $cd);

   $sth = $cd->{DBH}->prepare("select name,artist from Album where id='$albumid'");
   if ($sth->execute)
   {
       my @row;

       @row = $sth->fetchrow_array;
       $albumname = $row[0];
       $artistid = $row[1];

       $sth->finish;

       if ($artistid)
       {
           $sth = $cd->{DBH}->prepare("select name from Artist where id='$artistid'");
           $sth->execute;
           if ($sth->rows)
           {
               @row = $sth->fetchrow_array;
               $artistname = $row[0];
           }
           else
           {
               print STDERR "Empty artist name for artist $artistid\n";
               $artistname = "(unknown)" 
           }
           $sth->finish;
       }
       else
       {
           $artistname = "(various)";
       } 

       $xml .= "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
       $xml .= "<!DOCTYPE CDInfo SYSTEM \"http://www.cdindex.org";
       $xml .= "/dtd/CDInfo.dtd\">\n\n";
       $xml .= "<CDInfo>\n\n";  
       $xml .= "   <Title>".$o->escapeHTML($albumname)."</Title>\n";

       # --------------------------------------------------------------
       # Collect track info 
       # --------------------------------------------------------------
       $sth = $cd->{DBH}->prepare("select count(*) from Track where " . 
                            "album='$albumid'");
       if ($sth->execute)
       {
           @row = $sth->fetchrow_array;
           $xml .= "   <NumTracks>$row[0]</NumTracks>\n\n";
           $numtracks = $row[0];
       } 
       $sth->finish;

       # --------------------------------------------------------------
       # Print out Disk ids & TOC
       # --------------------------------------------------------------
       $query = "select Disk, toc from Diskid where ";
       if ($fuzzy)
       {
           $query .= "id=$fuzzy";
       }
       else
       {
           $query .= "album=$albumid";
       }

       $sth = $cd->{DBH}->prepare($query);
       if ($sth->execute)
       {
           my @Offsets;

           $xml .= "   <IdInfo>\n";

           for($i = 0; @row = $sth->fetchrow_array; $i++)
           {
               $xml .= "      <DiskId>\n"; 
               $xml .= "         <Id";
               if ($fuzzy)
               {
                   $xml .= " Fuzzy=\"$albumid\"";
               }
               $xml .= ">$row[0]</Id>\n"; 

               if (defined $row[1] && $row[1] ne '')
               {
                   @Offsets = split / /, $row[1];
                   $xml .= "         <TOC First=\"$Offsets[0]\"";
                   $xml .= " Last=\"$Offsets[1]\">\n";
                   $xml .= "            <Offset Num=\"0";
                   $xml .= "\">$Offsets[2]</Offset>\n"; 
                   for($i = 1; $i < $numtracks + 1; $i++)
                   {
                       if (defined $Offsets[$i + 2])
                       {
                           $xml .= "            <Offset Num=\"$i";
                           $xml .= "\">$Offsets[$i + 2]</Offset>\n"; 
                       }
                       else
                       {
                           print STDERR "Missing offset in data. Album ",
                                        "$albumid, offset $i\n";
                       }
                   }
                   $xml .= "         </TOC>\n";
               }
              $xml .= "      </DiskId>\n"; 
           }
           $xml .= "   </IdInfo>\n\n";
       } 
       $sth->finish;

       # --------------------------------------------------------------
       # Print track info 
       # --------------------------------------------------------------
       if ($artistid == 0)
       {
           $xml .= "   <MultipleArtistCD>\n";
           $sth = $cd->{DBH}->prepare("select Track.Name, Artist.Name from Track," .
                                " Artist where Track.album = $albumid and " .
                                "Track.Artist = Artist.id order by sequence");
           if ($sth->execute)
           {
               for($i = 0; @row = $sth->fetchrow_array; $i++)
               {
                   $xml .= "      <Track Num=\"" . ($i + 1) . "\">\n";
                   $xml .= "         <Artist>".$o->escapeHTML($row[1])."</Artist>\n";
                   $xml .= "         <Name>".$o->escapeHTML($row[0])."</Name>\n";
                   $xml .= "      </Track>\n";
               }
           }
           $sth->finish;
           $xml .= "   </MultipleArtistCD>\n\n";
       }
       else
       {
           $xml .= "   <SingleArtistCD>\n";
           $xml .= "      <Artist>".$o->escapeHTML($artistname)."</Artist>\n";
           $sth = $cd->{DBH}->prepare("select Name from Track where " .
                                "Track.album = $albumid order by sequence");
           if ($sth->execute)
           {
               for($i = 0; @row = $sth->fetchrow_array; $i++)
               {
                   $xml .= "      <Track Num=\"" . ($i + 1) . "\">\n";
                   $xml .= "         <Name>".$o->escapeHTML($row[0])."</Name>\n";
                   $xml .= "      </Track>\n";
               }
           }
           $sth->finish;
           $xml .= "   </SingleArtistCD>\n\n";
       }
       $xml .= "</CDInfo>\n\n";
   }
   else
   {
       $sth->finish;
   }

   return $xml;
}

sub AppendWhereClause
{
    my ($search, $sql, $col) = @_;
    my (@words, $i);

    $search =~ tr/A-Za-z0-9/ /cs;
    $search =~ tr/A-Z/a-z/;
    @words = split / /, $search;

    $i = 0;
    foreach (@words)
    {
       if (length($_) > 1)
       {
          if ($i++ > 0)
          {
             $sql .= " and ";
          }
          $sql .= "instr(lower($col), '" . $_ . "') <> 0";
       }
       else
       {
          if ($i++ > 0)
          {
             $sql .= " and ";
          }
          $sql .= "lower($col) regexp  '([[:<:]]+|[[:punct:]]+)" .
                  $_ . "([[:punct:]]+|[[:>:]]+)'";
       }
    }

    return $sql;
} 

# returns artistList
sub FindArtistByName
{
   my ($cd, $doc, $search) = @_;
   my ($sth, $sql, @row, @ids);

   my $o = $cd->GetCGI; 

   return EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $cd);

   $sql = AppendWhereClause($search, "select id from Artist where ", "Name");
   $sql .= " order by name";

   $sth = $cd->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateArtistList($cd, $doc, @ids);
}

# returns an albumList
sub FindAlbumsByArtistName
{
   my ($cd, $doc, $search) = @_;
   my ($sth, $sql, @row, @ids);
   my $o = $cd->GetCGI; 

   return EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $cd);

   # This query finds single artist albums
   $sql = AppendWhereClause($search, "select Album.id from Album, Artist where Album.artist = Artist.id and ", "Artist.Name");
   $sql .= " order by Album.name";

   $sth = $cd->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   # This query finds multiple artist albums
   $sql = AppendWhereClause($search, "select Album.id from Artist, Album, Track where Album.artist = 0 and Track.artist = Artist.id and Track.album = Album.id and ", "Artist.name");
   $sql .= " order by Album.name";

   $sth = $cd->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($cd, @ids);
}

# returns albumList
sub FindAlbumByName
{
   my ($cd, $doc, $search, $artist) = @_;
   my ($sth, $rdf, $sql, @row, @ids);

   my $o = $cd->GetCGI;
   my $r = RDF::new;

   return EmitErrorRDF("No album search criteria given.") 
      if (!defined $search && !defined $artist);
   return undef if (!defined $cd);

   if (defined $artist && $artist ne '')
   {
       $artist = $cd->{DBH}->quote($artist);
       if (defined $search)
       {
           $sql = AppendWhereClause($search, "select Album.id from Album, Artist where Artist.name = $artist and Artist.id = Album.artist and " , "Album.Name");
       }
       else
       {
           $sql = "select Album.id from Album, Artist where ".
                  "Album.artist=Artist.id and Artist.name = $artist";
       }
   }
   else
   {
       $sql = AppendWhereClause($search, "select Album.id from Album, Artist where Album.artist = Artist.id and ", "Album.Name");
   }

   $sql .= " order by Album.name";   

   $sth = $cd->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($cd, @ids);
}

# returns trackList
sub FindTrackByName
{
   my ($cd, $doc, $search, $album, $artist) = @_;
   my ($sth, $rdf, $sql, @row, $count);

   my $o = $cd->GetCGI;
   my $r = RDF::new;

   return EmitErrorRDF("No track search criteria given.") 
      if (!defined $search && !defined $artist && !defined $album);
   return undef if (!defined $cd);

   if (defined $search)
   {
       if (!defined $album && !defined $artist)
       {
           $sql = AppendWhereClause($search,
             "select Track.id from Track, Album, " .
             "Artist where Track.artist = Artist.id and Track.album = Album.id".
             " and ", "Track.Name") .  " order by Track.name";
       }
       else
       {
           if (defined $artist  && !defined $album)
           {
               $artist = $cd->{DBH}->quote($artist);
               $sql = AppendWhereClause($search,
                 "select Track.id from Track, Album, Artist where Track.artist = Artist.id and Track.album = Album.id and Artist.name = $artist and ", "Track.Name") .  " order by Track.name";

           }
           else
           {
               $album = $cd->{DBH}->quote($album);
               $sql = AppendWhereClause($search,
                 "select Track.id from Track, Album, Artist where Track.artist = Artist.id and Track.album = Album.id and Album.name = $album and ", "Track.Name") .  " order by Track.name";
           }
       }
   }
   else
   {
       if (defined $album && defined $artist)
       {
           $artist = $cd->{DBH}->quote($artist);
           $album = $cd->{DBH}->quote($album);
           $sql = "select Track.id from Track, Album, Artist where Track.Artist = Artist.id and Track.album = Album.id and Album.name = $album and Artist.name = $artist";
       }
       else
       {
           return EmitErrorRDF("Invalid track search criteria given.") 
       }
   }

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;
   $rdf .= $r->BeginElement("MQ:Collection", 'type'=>'trackList');
   $rdf .= $r->BeginBag();

   $sth = $cd->{DBH}->prepare($sql);
   if ($sth->execute())
   {
        for($count = 0; @row = $sth->fetchrow_array; $count++)
        {
            $rdf .= $r->BeginLi;
            $rdf .=   CreateTrackRDFSnippet($cd, $r, $row[0]);
            $rdf .= $r->EndLi;
        }
   }
   $sth->finish;

   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MQ:Collection");
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf
}

# returns trackList
sub FindDistinctGUID
{
   my ($cd, $doc, $name, $artist) = @_;
   my ($sql, $sth, $r, @row, $rdf, $count);

   my $o = $cd->GetCGI;
   $r = RDF::new;
   $count = 0;

   return EmitErrorRDF("No name or artist search criteria given.")
      if (!defined $name && !define $artist);
   return undef if (!defined $cd);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;
   $rdf .= $r->BeginElement("MQ:Collection", 'type'=>'trackList');
   $rdf .= $r->BeginBag();

   if ((defined $name && $name ne '') && 
       (defined $artist && $artist ne '') )
   {
      # This query finds single track id by name and artist
      $name = $cd->{DBH}->quote($name);
      $artist = $cd->{DBH}->quote($artist);
      $sql = "select Track.id from Track, Artist where Track.artist = Artist.id and Artist.name = $artist and Track.Name = $name";

      print STDERR "$sql\n";
      $sth = $cd->{DBH}->prepare($sql);
      if ($sth->execute() && $sth->rows)
      {
         for($count = 0; @row = $sth->fetchrow_array; $count++)
         {
             $rdf .= $r->BeginLi();
             $rdf .= CreateTrackRDFSnippet($cd, $r, $row[0]);
             $rdf .= $r->EndLi();
         }
      }
      $sth->finish;
   }

   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MQ:Collection");
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}

# returns artistList
sub GetArtistByGlobalId
{
   my ($cd, $doc, $id) = @_;
   my ($sth, $sql, @row, $artist);

   return EmitErrorRDF("No artist id given.") 
      if (!defined $id);
   return undef if (!defined $cd);

   $id = $cd->{DBH}->quote($id);
   $sth = $cd->{DBH}->prepare("select id from Artist where gid = $id");
   if ($sth->execute && $sth->rows)
   {
        @row = $sth->fetchrow_array;
        $artist = $row[0];
   }
   $sth->finish;

   return CreateArtistList($cd, $doc, $artist);
}

# returns album
sub GetAlbumByGlobalId
{
   my ($cd, $doc, $id) = @_;
   my ($sth, $sql, @row, $album);

   return EmitErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $cd);


   $id = $cd->{DBH}->quote($id);
   $sth = $cd->{DBH}->prepare("select id from Album where gid = $id");
   if ($sth->execute() && $sth->rows)
   {
        @row = $sth->fetchrow_array;
        $album = $row[0];
   }
   $sth->finish;

   return CreateAlbum($cd, 0, $album);
}

# returns trackList
sub GetTrackByGlobalId
{
   my ($cd, $doc, $id) = @_;
   my ($sth, $rdf, $sql, @row, $count);

   my $o = $cd->GetCGI; 
   my $r = RDF::new; 
   $count = 0;

   return EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $cd);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;

   $id = $cd->{DBH}->quote($id);
   $sth = $cd->{DBH}->prepare("select Track.id from " .
              "Track, Album where Track.gid = $id and Track.album = Album.id");
   if ($sth->execute())
   {
        @row = $sth->fetchrow_array;

        $rdf .=   $r->BeginLi;
        $rdf .=      CreateTrackRDFSnippet($cd, $r, $row[0]);
        $rdf .=   $r->EndLi;
        $count++;
   }
   $sth->finish;

   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}

# returns albumList
sub GetAlbumsByArtistGlobalId
{
   my ($cd, $doc, $id) = @_;
   my ($sth, $sql, @row, @ids);

   return EmitErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $cd);

   $id = $cd->{DBH}->quote($id);
   $sth = $cd->{DBH}->prepare("select Album.id from Album, Artist where Artist.gid = $id and Album.artist = Artist.id");
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($cd, @ids);
}

# returns an artistList
sub CreateArtistList
{
   my ($cd, $doc);
   my ($sth, $rdf, $sql, @row, $id, $o, $r, $count);

   $cd = shift @_; 
   $doc = shift @_;
   $o = $cd->GetCGI; 
   $r = RDF::new;
   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MQ:Collection", 'type'=>'artistList'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $cd->{DBH}->prepare("select name, gid from Artist where id = $id");
       if ($sth->execute())
       {
            for(; @row = $sth->fetchrow_array; $count++)
            {
                $rdf .= $r->BeginLi();
                $rdf .=   $r->Element("DC:Identifier", "", 'artistId'=>$row[1]);
                $rdf .=   $r->Element("DC:Creator", $o->escapeHTML($row[0]));
                $rdf .= $r->EndLi();
            }
       }
       $sth->finish;
   }
   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MQ:Collection"); 
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

# returns an albumList
sub CreateAlbumList
{
   my ($cd);
   my ($sth, $rdf, $sql, @row, $id, $o, $r, $count);

   $cd = shift @_; 
   $o = $cd->GetCGI; 
   $r = RDF::new;

   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MQ:Collection", 'type'=>'albumList'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $cd->{DBH}->prepare("select Album.name, Album.gid, Artist.name, Artist.gid from Album, Artist where Album.artist = Artist.id and Album.id = $id");
       if ($sth->execute() && $sth->rows > 0)
       {
            for(;@row = $sth->fetchrow_array; $count++)
            {
                $rdf .= $r->BeginLi();
                $rdf .=   $r->Element("DC:Identifier", "", 
                              'artistId'=>$row[3],
                              'albumId'=>$row[1]);
                $rdf .=   $r->Element("DC:Creator", $o->escapeHTML($row[2]));
                $rdf .=   $r->Element("MM:Album", $o->escapeHTML($row[0]));
                $rdf .= $r->EndLi();
            }
       }
       else
       {
            $sth->finish;

            $sth = $cd->{DBH}->prepare("select Album.name, Album.gid from Album where Album.id = $id");
            if ($sth->execute())
            {
                 for(;@row = $sth->fetchrow_array; $count++)
                 {
                     $rdf .= $r->BeginLi();
                     $rdf .=   $r->Element("DC:Identifier", "", 
                                   'albumId'=>$row[1]);
                     $rdf .=   $r->Element("DC:Creator", "[Multiple Artists]");
                     $rdf .=   $r->Element("MM:Album", $o->escapeHTML($row[0]));
                     $rdf .= $r->EndLi();
                 }
            }
       }
       $sth->finish;
   }
   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MQ:Collection"); 
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

# returns album
sub CreateAlbum
{
   my ($cd, $fuzzy);
   my ($sth, $rdf, $sth2, @row, @row2);
   my ($artist, $id, $count, $trdf, $numtracks);

   $cd = shift @_; 
   $fuzzy = shift @_; 
   my $o = $cd->GetCGI; 
   my $r = RDF::new;
   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MQ:Collection", 'type'=>'album'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $artist = "";
       $sth = $cd->{DBH}->prepare("select Album.name, Album.gid, Album.id " .
                                  "from Album where Album.id = $id");
       if ($sth->execute() && $sth->rows)
       {
            while(@row = $sth->fetchrow_array)
            {
                $trdf = "";
                $sth2 = $cd->{DBH}->prepare("select Track.id, Artist.id, Artist.name from Track, Artist where album = $row[2] and Track.artist = Artist.id order by sequence");
                if ($sth2->execute() && $sth2->rows)
                {
                    $numtracks = $sth2->rows;
                    $r->BeginSeq();
                    $r->BeginLi();
                    while(@row2 = $sth2->fetchrow_array)
                    {
                         $trdf .= $r->BeginLi();
                         $trdf .=   CreateTrackRDFSnippet($cd, $r, $row2[0]);
                         $trdf .= $r->EndLi();
                    
                         $artist = $row2[2] if ($row2[1] != 0);
                    }
                    $r->EndLi();
                    $r->EndSeq();
                }
                $sth2->finish;

                $count++;
                $rdf .= $r->BeginLi();
                $rdf .= $r->Element("DC:Identifier", "",
                                    'albumId'=>$o->escapeHTML($row[1]));
                $rdf .= $r->Element("MM:Album", 
                                    $o->escapeHTML($row[0]),
                                    'numTracks'=>$numtracks);
                if ($artist ne "")
                {
                    $rdf .= $r->Element("DC:Creator", $artist);
                }
                $rdf .= $r->BeginSeq();
                $rdf .= $trdf;
                $rdf .= $r->EndSeq();
                $rdf .= $r->EndLi();
            }
       }
       $sth->finish;
   }

   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MQ:Collection"); 
   if ($fuzzy)
   {
      $rdf .= $r->Element("MQ:Status", "Fuzzy", items=>$count);
   }
   else
   {
      $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   }
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

# returns single track description
sub CreateTrackRDFSnippet
{
   my ($cd);
   my ($sth, $rdf, @row, $id, $r);

   $cd = shift @_; 
   $r = shift @_; 
   my $o = $cd->GetCGI; 

   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $cd->{DBH}->prepare("select Track.name, Track.gid, Track.sequence, Artist.name, Artist.gid, Album.name, Album.gid, Track.guid from Track, Artist,Album where Track.id = $id and Track.artist = Artist.id and Track.album = Album.id order by sequence");
       if ($sth->execute() && $sth->rows)
       {
            while(@row = $sth->fetchrow_array)
            {
                $rdf .= $r->Element("DC:Identifier", "",
                            'artistId'=>$o->escapeHTML($row[4]),
                            'albumId'=>$o->escapeHTML($row[6]),
                            'trackId'=>$o->escapeHTML($row[1]),
                            'trackGUID'=>$o->escapeHTML($row[7]));
                $rdf .= $r->Element("DC:Relation", "",
                            'track'=>($row[2]+1));
                $rdf .= $r->Element("DC:Creator", 
                            $o->escapeHTML($row[3]));
                $rdf .= $r->Element("DC:Title", 
                            $o->escapeHTML($row[0]));
                $rdf .= $r->Element("MM:Album", 
                            $o->escapeHTML($row[5]));
            }     
       }
       $sth->finish;
   }

   return $rdf;
}

sub ExchangeMetadata
{
   my ($cd, $doc, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment) = @_;
   my (@ids, $id, $rdf, $r);

   $r = RDF::new;

   # has this data been accepted into the database?
   $id = $cd->GetTrackIdFromGUID($guid);
   if ($id < 0)
   {
       # No it has not.
       @ids = $cd->GetPendingIdsFromGUID($guid);
       if (scalar(@ids) == 0)
       {
            $cd->InsertPendingData($name, $guid, $artist, $album, $seq,
                              $len, $year, $genre, $filename, $comment);
       }
       else
       {
            # Do the metadata glom
            CheckMetadata($cd, $name, $guid, $artist, $album, $seq,
                          $len, $year, $genre, $filename, $comment, @ids);
       }
   }
   else
   {
       my ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
           $db_len, $db_year, $db_genre, $db_filename, $db_comment);

       # Yes, it has. Retrieve the data and return it
       # Fill in, don't override...
       ($db_name, $db_guid, $db_artist, $db_album, $db_seq, $db_len, $db_year, 
        $db_genre, $db_filename, $db_comment) = $cd->GetTrackData($id);

       $name = $db_name 
           if (!defined $name || $name eq "") && defined $db_name;
       $artist = $db_artist 
           if (!defined $artist || $artist eq "") && defined $db_artist;
       $album = $db_album 
           if (!defined $album || $album eq "") && defined $db_album;
       $seq = $db_seq 
           if (!defined $seq || $seq == 0) && defined $db_seq;
       $len = $db_len 
           if (!defined $len || $len == 0) && defined $db_len;
       $year = $db_year 
           if (!defined $year || $year == 0) && defined $db_year;
       $genre = $db_genre 
           if (!defined $genre || $genre eq "") && defined $db_genre;
   }

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->Element("DC:Title", $name) 
       unless !defined $name || $name eq '';
   $rdf .= $r->Element("DC:Identifier", "", guid=>$guid)
       unless !defined $guid || $guid eq '';
   $rdf .= $r->Element("DC:Creator", $artist)
       unless !defined $artist || $artist eq '';
   $rdf .= $r->Element("MM:Album", $album)
       unless !defined $album || $album eq '';
   $rdf .= $r->Element("DC:Relation", "", track=>$seq)
       unless !defined $seq || $seq == 0;
   $rdf .= $r->Element("DC:Format", "", duration=>$len)
       unless !defined $len || $len == 0;
   $rdf .= $r->Element("DC:Date", "", issued=>$year)
       unless !defined $year || $year == 0;
   $rdf .= $r->Element("MM:Genre", $genre)
       unless !defined $genre || $genre eq '';
   $rdf .= $r->Element("DC:Description", $comment)
       unless !defined $comment || $comment eq '';
   $rdf .= $r->Element("MQ:Status", "OK", items=>1);
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

sub CheckMetadata
{
   my ($id, $cd, $artistid, $albumid);
   my ($name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment);
   my ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
       $db_len, $db_year, $db_genre, $db_filename, $db_comment);

   $cd = shift; $name = shift; $guid = shift; $artist = shift;
   $album = shift; $seq = shift; $len = shift; $year = shift;
   $genre = shift; $filename = shift; $comment = shift;

   for(;;)
   {
       $id = shift;
       return if !defined $id;
       
       ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
        $db_len, $db_year, $db_genre, $db_filename, $db_comment) =
         $cd->GetPendingData($id);

       if (defined $db_name && defined $name && $name eq $db_name && 
           defined $db_artist && defined $artist && $artist eq $db_artist &&
           defined $db_album && defined $album && $album eq $db_album)
       {
           $artistid = $cd->InsertArtist($artist);
           $albumid = $cd->InsertAlbum($album, $artistid, -1);

           $seq = 0 unless 
               defined $seq && defined $db_seq && $seq == $db_seq;
           $len = 0 unless 
               defined $len && defined $db_len && $len == $db_len;
           $year = 0 unless 
               defined $year && defined $db_year && $year == $db_year;
           $genre = undef unless 
               defined $genre && defined $db_genre && $genre eq $db_genre;
           $comment = undef unless 
               defined $comment && defined $db_comment && 
               $comment eq $db_comment;

           $cd->InsertTrack($name, $artistid, $albumid, $seq, $guid, 
                            $len, $year, $genre, $comment);

           $cd->DeletePendingData($guid);
           return;
       }
   }
}

sub SubmitTrack
{
   my ($cd, $doc, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $comment, $sync_url, $sync_contrib,
       $sync_type, $sync_date) = @_;
   my ($rdf, $r, $i, $ts, $text, $artistid, $albumid, $trackid, $type, $id);

   $artistid = $cd->InsertArtist($artist);
   return EmitErrorRDF("Cannot insert artist into database.") 
      if ($artistid < 0);
   $albumid = $cd->InsertAlbum($album, $artistid, -1);
   return EmitErrorRDF("Cannot insert album into database.") 
      if ($albumid < 0);

   $trackid = $cd->InsertTrack($name, $artistid, $albumid, $seq, $guid, 
                               $len, $year, $genre, $comment);
   return EmitErrorRDF("Cannot insert track into database.") 
      if ($trackid < 0);

   if (defined $sync_url || defined $sync_contrib || 
       defined $sync_type || defined $sync_date)
   {
       if (! DBDefs->USE_LYRICS)
       {  
           return EmitRDFError("This server does not accept lyrics.");
       }
       if (!defined $sync_type || !exists $LyricTypes{$sync_type})
       { 
           $type = 0;
       }
       else
       {
           $type = $LyricTypes{$sync_type};
       }

       $id = $cd->GetLyricId($trackid);
       if ($id < 0)
       {
           $id = $cd->InsertLyrics($trackid, $type, $sync_url, $sync_contrib);
           for($i = 0;; $i++)
           {
               $ts = SolveXQL($doc, "/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/rdf:Seq/rdf:li[$i]" . '/rdf:Description/MM:SyncText/@ts');
               $text = SolveXQL($doc, "/rdf:RDF/rdf:Description/MM:SyncEvents/rdf:Description/rdf:Seq/rdf:li[$i]/rdf:Description/MM:SyncText");
               last if (!defined $ts || !defined $text);

               if ($ts =~ /:/)
               {
                   $ts = ($1 * 3600 + $2 * 60 + $3) * 1000 + $4
                       if ($ts =~ /(\d*):(\d*):(\d*)\.(\d*)/);
                   $ts = ($1 * 60 + $2) * 1000 + $3
                       if ($ts =~ /(\d*):(\d*)\.(\d*)/);
               }
        
               $id = $cd->InsertSyncEvent($trackid, $ts, $text);
           }
       }
   }

   $r = RDF::new;
   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->Element("MQ:Status", "OK", items=>0);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}

# returns lyrics
sub GetLyricsByGlobalId
{
   my ($cd, $doc, $id) = @_;
   my ($sth, $rdf, $sql, @row, $count, $trackid);

   my $o = $cd->GetCGI; 
   my $r = RDF::new; 
   $count = 0;

   if (! DBDefs->USE_LYRICS)
   {  
       return EmitRDFError("This server does not store lyrics.");
   }

   return EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $cd);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;

   $id = $cd->{DBH}->quote($id);
   $sth = $cd->{DBH}->prepare("select Track.id from Track where Track.gid = $id");
   if ($sth->execute())
   {
        @row = $sth->fetchrow_array;
        $trackid = $row[0];
        $sth->finish;

        $sth = $cd->{DBH}->prepare("select type, url, submittor, submitted, id from SyncLyrics where id = $trackid");
        if ($sth->execute())
        {
            @row = $sth->fetchrow_array;
            $trackid = $row[0];
            $sth->finish;
    
            $rdf .= CreateTrackRDFSnippet($cd, $r, $trackid);
            $rdf .= $r->BeginElement("MM:SyncEvents");
            $rdf .= $r->BeginDesc($row[1]);
            $rdf .= $r->Element("DC:Contributor", $row[2]); 
            $rdf .= $r->Element("DC:Type", "", type=>($TypesLyric{$row[0]}));
            $rdf .= $r->Element("DC:Date", $row[3]);
            $rdf .= $r->BeginSeq;
    
            $sth = $cd->{DBH}->prepare("select ts, text from SyncEvent where SyncText = $row[4]");
            if ($sth->execute())
            {
                while(@row = $sth->fetchrow_array)
                {
                   $rdf .= $r->BeginLi;
                   $rdf .= $r->Element("MM:SyncText", $row[1], ts=>$row[0]);
                   $rdf .= $r->EndLi;
                }
            }
            $rdf .= $r->EndSeq;
            $rdf .= $r->EndDesc;
            $rdf .= $r->EndElement("MM:SyncEvents");
            $count++;
        }
   }
   $sth->finish;

   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}
