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
                                                                               
package QuerySupport;

use strict;
use XML::Parser;
use XML::DOM;
use XML::XQL;
use XMLParse;
use RDF;
use DBDefs;
use Unicode::String;
use TableBase;
use MusicBrainz;
use UserStuff;
use Album;
use Diskid;
use TableBase;
use Artist;
use Genre;
use Pending;
use Track;
use Lyrics;
use UserStuff;
use Moderation;
use GUID;  
use ParseFilename;  
use FreeDB;  

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

    if (defined $data)
    {
       my $u;
       $u = Unicode::String::utf8($data);
       $data = $u->latin1;
    }

    return $data;
}

sub EmitErrorRDF
{
    my ($emit_headers) = @_;
    my ($rdf, $r, $len);

    $r = RDF::new;

    $rdf .= $r->BeginRDFObject;
    $rdf .= $r->BeginDesc;
    $rdf .= $r->Element("MQ:Error", $_[0]);
    $rdf .= $r->EndDesc;
    $rdf .= $r->EndRDFObject;

    if (defined $emit_headers && $emit_headers)
    {
        $len = length($rdf);
        $rdf = "Content-type: text/plain\n" .
               "Content-Length: $len\n\r\n" . $rdf;
    }

    return $rdf;
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

sub GenerateCDInfoObjectFromDiskId
{
   my ($mb, $doc, $id, $numtracks, $toc) = @_;
   my ($sth, @row, $rdf, $album, $di);

   return EmitErrorRDF("No DiskId given.") if (!defined $id);

   # Check to see if the album is in the main database
   $di = Diskid->new($mb);
   $sth = $mb->{DBH}->prepare("select Album from Diskid where disk='$id'");
   if ($sth->execute && $sth->rows)
   {
        @row =  $sth->fetchrow_array;
        $rdf = CreateAlbum($mb, 0, $row[0]);
   }
   else
   {
        # Ok, its not in the main db. Do we have a freedb entry that
        # matches, but has no DiskId?
        $album = $di->FindFreeDBEntry($numtracks, $toc, $id);
        if (defined $album)
        {
            $rdf = $mb->CreateAlbum($mb, 0, $album);
        }
        else
        {
            my (@albums, $album, $disk);
   
            # Ok, no freedb entries were found. Can we find a fuzzy match?
            @albums = $di->FindFuzzy($numtracks, $toc);
            if (scalar(@albums) > 0)
            {
                $rdf = CreateAlbum($mb, 1, @albums);
            }
            else
            {
                my $fd;

                # No fuzzy matches either. Let's pull the records
                # from freedb.org and insert it into the db if we find it.
                $fd = FreeDB->new($mb);
                $album = $fd->Lookup($id, $toc);
                if ($album > 0)
                {
                    $rdf = CreateAlbum($mb, 0, $album);
                }
                else
                {
                    my $r = RDF::new;
                   
                    # No Dice. This CD cannot be found!
                    $rdf = $r->BeginRDFObject;
                    $rdf .= $r->BeginDesc;
                    $rdf .= $r->Element("MQ:Status", "OK", items=>0);
                    $rdf .= $r->EndDesc;
                    $rdf .= $r->EndRDFObject;
                }
            }
        }
   }
   $sth->finish;  

   return $rdf;
}

sub AssociateCDFromAlbumId
{
   my ($mb, $query, $diskid, $toc, $albumid) = @_;

   my $di = Diskid->new($mb);
   $di->InsertDiskId($diskid, $albumid, $toc);
}

sub GenerateCDInfoObjectFromAlbumId
{
   my ($mb, $albumid, $fuzzy) = @_;
   my ($sth, $xml, $i, $query);
   my ($artistid, $albumname, $artistname, $numtracks);

   return EmitErrorRDF("No album id given.") if (!defined $albumid);
   return undef if (!defined $mb);

   $sth = $mb->{DBH}->prepare("select name,artist from Album where id='$albumid'");
   if ($sth->execute)
   {
       my @row;

       @row = $sth->fetchrow_array;
       $albumname = $row[0];
       $artistid = $row[1];

       $sth->finish;

       if ($artistid)
       {
           $sth = $mb->{DBH}->prepare("select name from Artist where id='$artistid'");
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
       $xml .= "   <Title>".escape($albumname)."</Title>\n";

       # --------------------------------------------------------------
       # Collect track info 
       # --------------------------------------------------------------
       $sth = $mb->{DBH}->prepare("select count(*) from Track where " . 
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

       $sth = $mb->{DBH}->prepare($query);
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
           $sth = $mb->{DBH}->prepare("select Track.Name, Artist.Name from Track," .
                                " Artist where Track.album = $albumid and " .
                                "Track.Artist = Artist.id order by sequence");
           if ($sth->execute)
           {
               for($i = 0; @row = $sth->fetchrow_array; $i++)
               {
                   $xml .= "      <Track Num=\"" . ($i + 1) . "\">\n";
                   $xml .= "         <Artist>".escape($row[1])."</Artist>\n";
                   $xml .= "         <Name>".escape($row[0])."</Name>\n";
                   $xml .= "      </Track>\n";
               }
           }
           $sth->finish;
           $xml .= "   </MultipleArtistCD>\n\n";
       }
       else
       {
           $xml .= "   <SingleArtistCD>\n";
           $xml .= "      <Artist>".escape($artistname)."</Artist>\n";
           $sth = $mb->{DBH}->prepare("select Name from Track where " .
                                "Track.album = $albumid order by sequence");
           if ($sth->execute)
           {
               for($i = 0; @row = $sth->fetchrow_array; $i++)
               {
                   $xml .= "      <Track Num=\"" . ($i + 1) . "\">\n";
                   $xml .= "         <Name>".escape($row[0])."</Name>\n";
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

# returns artistList
sub FindArtistByName
{
   my ($mb, $doc, $search) = @_;
   my ($sth, $sql, @row, @ids, $tb);

   return EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $mb);

   $tb = TableBase->new($mb);
   $sql = $tb->AppendWhereClause($search, "select id from Artist where ", 
                                 "Name");
   $sql .= " order by name";

   $sth = $mb->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateArtistList($mb, $doc, @ids);
}

# returns an albumList
sub FindAlbumsByArtistName
{
   my ($mb, $doc, $search) = @_;
   my ($sth, $sql, @row, @ids);

   return EmitErrorRDF("No artist search criteria given.") 
      if (!defined $search);
   return undef if (!defined $mb);

   # This query finds single artist albums
   my $tb = TableBase->new($mb);
   $sql = $tb->AppendWhereClause($search, qq/select Album.id from Album, 
                  Artist where Album.artist = Artist.id and /, "Artist.Name");
   $sql .= " order by Album.name";

   $sth = $mb->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   # This query finds multiple artist albums
   $sql = $tb->AppendWhereClause($search, qq/select Album.id from Album, 
          Artist,Track,AlbumJoin where Album.artist = 0 and Track.Artist = 
          Artist.id and AlbumJoin.track = Track.id and AlbumJoin.album = 
          Album.id and Artist.name and /, "Artist.name");
   $sql .= " order by Album.name";

   $sth = $mb->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($mb, @ids);
}

# returns albumList
sub FindAlbumByName
{
   my ($mb, $doc, $search, $artist) = @_;
   my ($sth, $rdf, $sql, @row, @ids);

   my $r = RDF::new;

   return EmitErrorRDF("No album search criteria given.") 
      if (!defined $search && !defined $artist);
   return undef if (!defined $mb);

   my $tb = TableBase->new($mb);
   if (defined $artist && $artist ne '')
   {
       $artist = $mb->{DBH}->quote($artist);
       if (defined $search)
       {
           $sql = $tb->AppendWhereClause($search, "select Album.id from Album, Artist where Artist.name = $artist and Artist.id = Album.artist and " , "Album.Name");
       }
       else
       {
           $sql = "select Album.id from Album, Artist where ".
                  "Album.artist=Artist.id and Artist.name = $artist";
       }
   }
   else
   {
       $sql = $tb->AppendWhereClause($search, "select Album.id from Album, Artist where Album.artist = Artist.id and ", "Album.Name");
   }

   $sql .= " order by Album.name";   

   $sth = $mb->{DBH}->prepare($sql);
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($mb, @ids);
}

# returns trackList
sub FindTrackByName
{
   my ($mb, $doc, $search, $album, $artist) = @_;
   my ($sth, $rdf, $sql, @row, $count);

   my $r = RDF::new;

   return EmitErrorRDF("No track search criteria given.") 
      if (!defined $search && !defined $artist && !defined $album);
   return undef if (!defined $mb);

   my $tb = TableBase->new($mb);
   if (defined $search)
   {
       if (!defined $album && !defined $artist)
       {
           $sql = $tb->AppendWhereClause($search,
             qq/select Track.id from Track, Album, Artist, AlbumJoin where 
                Track.artist = Artist.id and AlbumJoin.track = Track.id 
                and AlbumJoin.album = Album.id and /,
                "Track.Name") .  " order by Track.name";
       }
       else
       {
           if (defined $artist  && !defined $album)
           {
               $artist = $mb->{DBH}->quote($artist);
               $sql = $tb->AppendWhereClause($search,
                 qq/select Track.id from Track, Album, Artist, AlbumJoin 
                    where Track.artist = Artist.id and AlbumJoin.track = 
                    Track.id and AlbumJoin.album = Album.id and Artist.name = 
                    $artist and /, "Track.Name") . " order by Track.name";

           }
           else
           {
               $album = $mb->{DBH}->quote($album);
               $sql = $tb->AppendWhereClause($search,
                 qq/select Track.id from Track, Album, Artist, AlbumJoin
                 where Track.artist = Artist.id and AlbumJoin.track = 
                 Track.id and AlbumJoin.album = Album.id and Album.name = 
                 $album and /, "Track.Name") .  " order by Track.name";
           }
       }
   }
   else
   {
       if (defined $album && defined $artist)
       {
           $artist = $mb->{DBH}->quote($artist);
           $album = $mb->{DBH}->quote($album);
           $sql = qq/select Track.id from Track, Album, Artist where 
                     Track.Artist = Artist.id and AlbumJoin.track = Track.id 
                     and AlbumJoin.album = Album.id and Album.name = $album 
                     and Artist.name = $artist/;
       }
       else
       {
           return EmitErrorRDF("Invalid track search criteria given.") 
       }
   }

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;
   $rdf .= $r->BeginElement("MC:Collection", 'type'=>'trackList');
   $rdf .= $r->BeginBag();

   $sth = $mb->{DBH}->prepare($sql);
   if ($sth->execute())
   {
        for($count = 0; @row = $sth->fetchrow_array; $count++)
        {
            $rdf .= $r->BeginLi;
            $rdf .=   CreateTrackRDFSnippet($mb, $r, $row[0]);
            $rdf .= $r->EndLi;
        }
   }
   $sth->finish;

   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MC:Collection");
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf
}

# returns GUIDList
sub FindDistinctGUID
{
   my ($mb, $doc, $name, $artist) = @_;
   my ($sql, $sth, $r, @row, $rdf, $count);

   $r = RDF::new;
   $count = 0;

   return EmitErrorRDF("No name or artist search criteria given.")
      if (!defined $name && !define $artist);
   return undef if (!defined $mb);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;
   $rdf .= $r->BeginElement("MC:Collection", 'type'=>'guidList');
   $rdf .= $r->BeginBag();

   if ((defined $name && $name ne '') && 
       (defined $artist && $artist ne '') )
   {
      # This query finds single track id by name and artist
      $name = $mb->{DBH}->quote($name);
      $artist = $mb->{DBH}->quote($artist);
      $sql = qq/select distinct GUID.guid from Track, Artist, GUIDJoin, GUID 
                where Track.artist = Artist.id and 
                GUIDJoin.track = Track.id and
                GUID.id = GUIDJoin.guid and
                lower(Artist.name) = lower($artist) and 
                lower(Track.Name) = lower($name)/;

      $sth = $mb->{DBH}->prepare($sql);
      if ($sth->execute() && $sth->rows)
      {
         for($count = 0; @row = $sth->fetchrow_array; $count++)
         {
             if (!defined $row[0] || $row[0] eq '')
             {
                 $count--;
                 next;
             }

             $rdf .= $r->BeginLi();
             $rdf .= $r->Element("DC:Identifier", "", guid=>($row[0]));
             $rdf .= $r->EndLi();
         }
      }
      $sth->finish;
   }

   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MC:Collection");
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc;
   $rdf .= $r->EndRDFObject;

   return $rdf;
}

# returns artistList
sub GetArtistByGlobalId
{
   my ($mb, $doc, $id) = @_;
   my ($sth, $sql, @row, $artist);

   return EmitErrorRDF("No artist id given.") 
      if (!defined $id);
   return undef if (!defined $mb);

   $id = $mb->{DBH}->quote($id);
   $sth = $mb->{DBH}->prepare("select id from Artist where gid = $id");
   if ($sth->execute && $sth->rows)
   {
        @row = $sth->fetchrow_array;
        $artist = $row[0];
   }
   $sth->finish;

   return CreateArtistList($mb, $doc, $artist);
}

# returns album
sub GetAlbumByGlobalId
{
   my ($mb, $doc, $id) = @_;
   my ($sth, $sql, @row, $album);

   return EmitErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $mb);


   $id = $mb->{DBH}->quote($id);
   $sth = $mb->{DBH}->prepare("select id from Album where gid = $id");
   if ($sth->execute() && $sth->rows)
   {
        @row = $sth->fetchrow_array;
        $album = $row[0];
   }
   $sth->finish;

   return CreateAlbum($mb, 0, $album);
}

# returns trackList
sub GetTrackByGlobalId
{
   my ($mb, $doc, $id) = @_;
   my ($sth, $rdf, $sql, @row, $count);

   my $r = RDF::new; 
   $count = 0;

   return EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $mb);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;

   $id = $mb->{DBH}->quote($id);
   $sth = $mb->{DBH}->prepare(qq/select Track.id from Track, Album, AlbumJoin
              where Track.gid = $id and AlbumJoin.track = Track.id and 
              AlbumJoin.album = Album.id/);
   if ($sth->execute())
   {
        @row = $sth->fetchrow_array;

        $rdf .=   $r->BeginLi;
        $rdf .=      CreateTrackRDFSnippet($mb, $r, $row[0]);
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
   my ($mb, $doc, $id) = @_;
   my ($sth, $sql, @row, @ids);

   return EmitErrorRDF("No album id given.") 
      if (!defined $id);
   return undef if (!defined $mb);

   $id = $mb->{DBH}->quote($id);
   $sth = $mb->{DBH}->prepare("select Album.id from Album, Artist where Artist.gid = $id and Album.artist = Artist.id");
   if ($sth->execute() && $sth->rows)
   {
        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return CreateAlbumList($mb, @ids);
}

# returns an artistList
sub CreateArtistList
{
   my ($mb, $doc);
   my ($sth, $rdf, $sql, @row, $id, $r, $count);

   $mb = shift @_; 
   $doc = shift @_;
   $r = RDF::new;
   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MC:Collection", 'type'=>'artistList'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $mb->{DBH}->prepare("select name, gid from Artist where id = $id");
       if ($sth->execute())
       {
            for(; @row = $sth->fetchrow_array; $count++)
            {
                $rdf .= $r->BeginLi();
                $rdf .=   $r->Element("DC:Identifier", "", 'artistId'=>$row[1]);
                $rdf .=   $r->Element("DC:Creator", escape($row[0]));
                $rdf .= $r->EndLi();
            }
       }
       $sth->finish;
   }
   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MC:Collection"); 
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

# returns an albumList
sub CreateAlbumList
{
   my ($mb);
   my ($sth, $rdf, $sql, @row, $id, $r, $count);

   $mb = shift @_; 
   $r = RDF::new;

   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MC:Collection", 'type'=>'albumList'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $mb->{DBH}->prepare("select Album.name, Album.gid, Artist.name, Artist.gid from Album, Artist where Album.artist = Artist.id and Album.id = $id");
       if ($sth->execute() && $sth->rows > 0)
       {
            for(;@row = $sth->fetchrow_array; $count++)
            {
                $rdf .= $r->BeginLi();
                $rdf .=   $r->Element("DC:Identifier", "", 
                              'artistId'=>$row[3],
                              'albumId'=>$row[1]);
                $rdf .=   $r->Element("DC:Creator", escape($row[2]));
                $rdf .=   $r->Element("MM:Album", escape($row[0]));
                $rdf .= $r->EndLi();
            }
       }
       else
       {
            $sth->finish;

            $sth = $mb->{DBH}->prepare("select Album.name, Album.gid from Album where Album.id = $id");
            if ($sth->execute())
            {
                 for(;@row = $sth->fetchrow_array; $count++)
                 {
                     $rdf .= $r->BeginLi();
                     $rdf .=   $r->Element("DC:Identifier", "", 
                                   'albumId'=>$row[1]);
                     $rdf .=   $r->Element("DC:Creator", "[Multiple Artists]");
                     $rdf .=   $r->Element("MM:Album", escape($row[0]));
                     $rdf .= $r->EndLi();
                 }
            }
       }
       $sth->finish;
   }
   $rdf .= $r->EndBag();
   $rdf .= $r->EndElement("MC:Collection"); 
   $rdf .= $r->Element("MQ:Status", "OK", items=>$count);
   $rdf .= $r->EndDesc();
   $rdf .= $r->EndRDFObject();  

   return $rdf;
}

# returns album
sub CreateAlbum
{
   my ($mb, $fuzzy);
   my ($sth, $rdf, $sth2, @row, @row2);
   my ($artist, $id, $count, $trdf, $numtracks);

   $mb = shift @_; 
   $fuzzy = shift @_; 
   my $r = RDF::new;
   $count = 0;

   $rdf = $r->BeginRDFObject();
   $rdf .= $r->BeginDesc; 
   $rdf .= $r->BeginElement("MC:Collection", 'type'=>'album'); 
   $rdf .= $r->BeginBag();
   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $artist = "";
       $sth = $mb->{DBH}->prepare("select Album.name, Album.gid, Album.id " .
                                  "from Album where Album.id = $id");
       if ($sth->execute() && $sth->rows)
       {
            while(@row = $sth->fetchrow_array)
            {
                $trdf = "";
                $sth2 = $mb->{DBH}->prepare("select Track.id, Artist.id, Artist.name from Track, Artist, AlbumJoin where AlbumJoin.track = Track.id and AlbumJoin.album = $row[2] and Track.artist = Artist.id order by AlbumJoin.sequence");
                if ($sth2->execute() && $sth2->rows)
                {
                    $numtracks = $sth2->rows;
                    $r->BeginSeq();
                    $r->BeginLi();
                    while(@row2 = $sth2->fetchrow_array)
                    {
                         $trdf .= $r->BeginLi();
                         $trdf .=   CreateTrackRDFSnippet($mb, $r, $row2[0]);
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
                                    'albumId'=>escape($row[1]));
                $rdf .= $r->Element("MM:Album", 
                                    escape($row[0]),
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
   $rdf .= $r->EndElement("MC:Collection"); 
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
   my ($mb);
   my ($sth, $rdf, @row, $id, $r, $guid, $gu);

   $mb = shift @_; 
   $r = shift @_; 
   $gu = GUID->new($mb);

   for(;;)
   {
       $id = shift @_;
       last if !defined $id;

       $sth = $mb->{DBH}->prepare(qq/select Track.name, Track.gid, 
                AlbumJoin.sequence, Artist.name, Artist.gid, Album.name, 
                Album.gid from Track, Artist,Album, AlbumJoin where 
                Track.id = $id and Track.artist = Artist.id and 
                AlbumJoin.album = Album.id and AlbumJoin.track = 
                Track.id order by AlbumJoin.sequence/);
       if ($sth->execute() && $sth->rows)
       {
            while(@row = $sth->fetchrow_array)
            {
                $guid = $gu->GetGUIDFromTrackId($id);
                if (defined $guid)
                {
                    $rdf .= $r->Element("DC:Identifier", "",
                                'artistId'=>escape($row[4]),
                                'albumId'=>escape($row[6]),
                                'trackId'=>escape($row[1]),
                                'trackGUID'=>escape($guid));
                }
                else
                {
                    $rdf .= $r->Element("DC:Identifier", "",
                                'artistId'=>escape($row[4]),
                                'albumId'=>escape($row[6]),
                                'trackId'=>escape($row[1]));
                }
                $rdf .= $r->Element("DC:Relation", "",
                            'track'=>($row[2]+1));
                $rdf .= $r->Element("DC:Creator", 
                            escape($row[3]));
                $rdf .= $r->Element("DC:Title", 
                            escape($row[0]));
                $rdf .= $r->Element("MM:Album", 
                            escape($row[5]));
            }     
       }
       $sth->finish;
   }

   return $rdf;
}

# Check to see if the guid needs to be converted from 38 to 36 chars
sub ConvertGUID
{
    my ($guid) = @_;

    return $guid if (length($guid) != 38);

    $guid =~ /(.{20})..(.*)$/;
    return $1 . $2;
}

sub ExchangeMetadata
{
   my ($mb, $doc, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment) = @_;
   my (@ids, $id, $rdf, $r, $gu, $pe, $tr, $rv, $ar);

   $guid = ConvertGUID($guid);

   $r = RDF::new;

   #print STDERR "\nArtist: '$artist' Album: '$album' Track: '$name'\n";
   #print STDERR "GUID: '$guid' Seq: '$seq'\n";

   $ar = Artist->new($mb);
   $gu = GUID->new($mb);
   $pe = Pending->new($mb);
   $tr = Track->new($mb);
   # has this data been accepted into the database?
   $id = $gu->GetTrackIdFromGUID($guid);
   if ($id < 0)
   {
       # No it has not.
       @ids = $pe->GetIdsFromGUID($guid);
       if (scalar(@ids) == 0)
       {
            # Call ParseFilename() in an attempt to parse out the filename and
            # try to find an artist and title within the filename.
            $rv = ParseFilename::Parse($mb, $ar, $pe, $guid, $filename, 'N');
            if ($rv == -1)
            {
               # ParseFilename could not find title and artist in filename, 
               # so insert into Pending table.
               $pe->Insert($name, $guid, $artist, $album, $seq,
                           $len, $year, $genre, $filename, $comment);
            }
       }
       else
       {
            # Do the metadata glom
            CheckMetadata($mb, $pe, $name, $guid, $artist, $album, $seq,
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
        $db_genre, $db_filename, $db_comment) = $tr->GetFromIdAndAlbum($id, 
                                                                      $album);
       #print STDERR "DBArtist: '$db_artist' DBAlbum: '$db_album' DBTrack: '$db_name'\n";
       #print STDERR "DBGUID: '$db_guid' DBSeq: '$db_seq'\n";

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
   my ($id, $mb, $pe, $artistid, $albumid);
   my ($name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $filename, $comment);
   my ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
       $db_len, $db_year, $db_genre, $db_filename, $db_comment);
   my ($ar, $al, $tr, $gu, $trackid);

   $mb = shift; $pe = shift; $name = shift; $guid = shift; $artist = shift;
   $album = shift; $seq = shift; $len = shift; $year = shift;
   $genre = shift; $filename = shift; $comment = shift;

   $ar = Artist->new($mb);
   $al = Album->new($mb);
   $tr = Track->new($mb);
   $gu = GUID->new($mb);
   for(;;)
   {
       $id = shift;
       return if !defined $id;

       
       ($db_name, $db_guid, $db_artist, $db_album, $db_seq,
        $db_len, $db_year, $db_genre, $db_filename, $db_comment) =
         $pe->GetData($id);

       if (defined $db_name && defined $name && $name eq $db_name && 
           defined $db_artist && defined $artist && $artist eq $db_artist &&
           defined $db_album && defined $album && $album eq $db_album)
       { 
           my @albumids;

           $artistid = $ar->Insert($artist, $artist);

           @albumids = $al->FindFromNameAndArtistId($album, $artistid);
           if (defined @albumids)
           {
               $albumid = $albumids[0];
           }
           else
           {
               $albumid = $al->Insert($album, $artistid);
           }

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

           $trackid = $tr->Insert($name, $artistid, $albumid, $seq,  
                                  $len, $year, $genre, $comment);
           if (defined $trackid)
           {
               $gu->Insert($guid, $trackid);
           }
           $pe->DeleteByGUID($guid);
           return;
       }
       else
       {
           # Call ParseFilename in an attempt to match title and artist.
           ParseFileName::Parse($mb, $ar, $pe, $guid, $filename, 'Y');
       }
   }
}

sub SubmitTrack
{
   my ($mb, $doc, $name, $guid, $artist, $album, $seq,
       $len, $year, $genre, $comment, $sync_url, $sync_contrib,
       $sync_type, $sync_date) = @_;
   my ($rdf, $r, $i, $ts, $text, $artistid, $albumid, $trackid, $type, $id);
   my ($al, $ar, $tr, $ly, $gu, @albumids);

   if (!defined $name || $name eq '' ||
       !defined $album || $album eq '' ||
       !defined $seq || $seq eq '' ||
       !defined $artist || $artist eq '')
   {
       return EmitErrorRDF("Incomplete track information submitted.") 
   }

   #print STDERR "T: '$name' a: '$artist' l: '$album'\n";

   $ar = Artist->new($mb);
   $al = Album->new($mb);
   $tr = Track->new($mb);
   $ly = Lyrics->new($mb);
   $gu = GUID->new($mb);

   $artistid = $ar->Insert($artist, $artist);
   return EmitErrorRDF("Cannot insert artist into database.") 
      if (!defined $artistid || $artistid < 0);

   @albumids = $al->FindFromNameAndArtistId($album, $artistid);
   if (defined @albumids && scalar(@albumids) > 0)
   {
      $albumid = $albumids[0];
   }
   else
   {
      $albumid = $al->Insert($album, $artistid, -1);
   }
   print STDERR "Insert album failed!!!!!!!!!!!\n"
      if (!defined $albumid || $albumid < 0);
   
   return EmitErrorRDF("Cannot insert album into database.") 
      if (!defined $albumid || $albumid < 0);

   $trackid = $tr->Insert($name, $artistid, $albumid, $seq, 
                          $len, $year, $genre, $comment);
   return EmitErrorRDF("Cannot insert track into database.") 
      if (!defined $trackid || $trackid < 0);

   if (defined $trackid && (defined $guid && $guid ne ''))
   {
       $gu->Insert($guid, $trackid);
   }

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
       #only accept entry if it is not already present with same type for same person
       $id = $ly->GetSyncTextId($trackid, $type, $sync_contrib);
       if ($id < 0)
       {
           $id = $ly->InsertSyncText($trackid, $type, $sync_url, $sync_contrib);
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
        
               $id = $ly->InsertSyncEvent($trackid, $ts, $text);
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
#TODO: use the methods defined by Lyrics.pm to access the data.
sub GetLyricsByGlobalId
{
   my ($mb, $doc, $id) = @_;
   my ($sth, $rdf, $sql, @row, $count, $trackid);

   my $r = RDF::new; 
   $count = 0;

   if (! DBDefs->USE_LYRICS)
   {  
       return EmitRDFError("This server does not store lyrics.");
   }

   return EmitErrorRDF("No track id given.") 
      if (!defined $id);
   return undef if (!defined $mb);

   $rdf = $r->BeginRDFObject;
   $rdf .= $r->BeginDesc;

   $id = $mb->{DBH}->quote($id);
   $sth = $mb->{DBH}->prepare("select Track.id from Track where Track.gid = $id");
   if ($sth->execute())
   {
        @row = $sth->fetchrow_array;
        $trackid = $row[0];
        $sth->finish;

        #JOHAN: bugfix, do not use id but Track in the where clause.
        $sth = $mb->{DBH}->prepare("select type, url, submittor, submitted, id from SyncText where Track = $trackid");
        if ($sth->execute())
        {
            @row = $sth->fetchrow_array;
            $sth->finish;
    
            $rdf .= CreateTrackRDFSnippet($mb, $r, $trackid);
            $rdf .= $r->BeginElement("MM:SyncEvents");
            $rdf .= $r->BeginDesc($row[1]);
            $rdf .= $r->Element("DC:Contributor", $row[2]); 
            $rdf .= $r->Element("DC:Type", "", type=>($TypesLyric{$row[0]}));
            $rdf .= $r->Element("DC:Date", $row[3]);
            $rdf .= $r->BeginSeq;
    
            $sth = $mb->{DBH}->prepare("select ts, text from SyncEvent where SyncText = $row[4]");
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
