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
                                                                               
package MusicBrainz;

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = '';
@EXPORT = @EXPORT = '';

use strict;
use CGI;
use DBI;
use DBDefs;

sub new
{
    my $this = {};
    $this->{CGI} = new CGI;
    bless $this;
    return $this;
}  

sub GetCGI
{
    my ($this) = @_;

    return $this->{CGI};
}

sub Header
{
   my ($this, $title) = @_;

   $this->{CGI} = new CGI;

   print $this->{CGI}->header();
   print $this->{CGI}->start_html(-"title"=>$title,
                                  -"background"=>'/images/background.gif',
                                  -"text"=>'#000000',
                                  -"bgcolor"=>'#FFFFFF',
                                  -"link"=>'#744bA9',
                                  -"vlink"=>'#542b89',
                                  -"alink"=>'#C0C000');

   print '<table width="100%" border="0"> <tr>  ';
   print SideBar($this);

   print "<TD width=\"100%\" VALIGN=\"TOP\"> <font size=+2> $title<p> </font> <P
>";
} 

sub Footer
{
   my ($this) = @_;

   print '</TD></TR></TABLE>';
   
   print $this->{CGI}->end_html;   
}

sub SideBar
{
    return <<END;
<td valign="top">
<table width="108">
<tr><td align="center">
<img src="/images/musicbrainz.gif"><br>
</td></tr>
</table>
<table>
<tr><td><img src="/images/spacer.gif"></td></tr>
</table>

<a href="/index.html">
<font color=white>MusicBrainz<br>Home</font></a><br>

<br><a href="/what.html">
<font color=white>What is<br>MusicBrainz?</font></a><br>

<br><a href="/search.html">
<font color=white>Search/Browse<br>MusicBrainz</font></a><br>

<br><a href="/faq.html">
<font color=white>Frequently<br>asked Questions</font></a><br>

<br><a href="/how.html">
<font color=white>How does<br>it work?</font></a><br>

<br><a href="/download.html">
<font color=white>Download</font></a><br>

<br><a href="http://www.freeamp.org/bugzilla">
<font color=white>Report a bug</font></a><br>

<br><a href="/cgi-bin/stats.pl">
<font color=white>Server Stats</font></a><br>

<br><a href="http://www.freeamp.org">
<font color=white>FreeAmp<br>Home Page</font></a><br>

<br><a href="http://www.emusic.com">
<font color=white>EMusic<br>Home Page</font></a><br>

<br><a href="http://www.relatable.com">
<font color=white>Relatable<br>Home Page</font></a>
</td>

END
} 

sub Login
{
   my ($this, $quiet) = @_;

   $this->{DBH} = DBI->connect(DBDefs->DSN,DBDefs->DB_USER,DBDefs->DB_PASSWD);
   if (!$this->{DBH})
   {
       return 0 if (defined $quiet);

       print "<font size=+1 color=red>Sorry, the database is currently ";
       print "not available. Please try again in a few minutes.</font>";
       print "(Error: ".$DBI::errstr.")";
       Footer($this);
       exit(0);
   } 
   return 1;
}

sub Logout
{
   my ($this) = @_;

   $this->{DBH}->disconnect() if ($this->{DBH});
}

sub PrintError
{
   my ($this, $error) = @_;

   print "<font size=+1 color=red>Error:</font> $error";
   Logout($this);
   Footer($this);
   exit(0);
}

sub CheckArgs
{
   my ($this);
   my ($i, $j, $err);

   $this = shift @_;
   for($i = 0; $i < scalar(@_); $i++)
   {
       if (!defined $this->{CGI}->param($_[$i]))
       {
           $err = "The page requires the following arguments: <b>";
           for($j = 0; $j < scalar(@_); $j++)
           {
               $err .= "$_[$j] ";
           }
           $err .= "</b>";
           PrintError($this, $err);
           Logout($this);
           Footer($this);
           exit(0);
       }
   }
}

sub GetArtistId
{
   my ($this, $artistname) = @_;
   my ($sth, $rv);

   $artistname = $this->{DBH}->quote($artistname);
   $sth = $this->{DBH}->prepare("select id from Artist where name=$artistname");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];

   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetAlbumId
{
   my ($this, $albumname, $artist, $tracks) = @_;
   my ($sth, $sth2, $rv);

   $rv = -1;

   $albumname = $this->{DBH}->quote($albumname);
   $sth = $this->{DBH}->prepare("select id from Album where name=$albumname and " .
                        "artist = $artist");
   $sth->execute;
   if ($sth->rows)
   {
       my (@row, @row2);

       while(@row = $sth->fetchrow_array)
       {
           if ($tracks < 0)
           {
               $rv = $row[0];
               last;
           }
           $sth2 = $this->{DBH}->prepare("select count(*) from Track where album=$row[0]");
           $sth2->execute;
           if ($sth2->rows > 0)
           {
               @row2 = $sth2->fetchrow_array;
               if ($row2[0] == $tracks)
               {
                  $rv = $row[0];
                  $sth2->finish;
                  last;
               }
           }
           $sth2->finish;
       }
   }
   $sth->finish;

   return $rv;
}

sub GetTrackId
{
   my ($this, $name, $artist, $album, $seq) = @_;
   my ($sth, $rv);

   $name = $this->{DBH}->quote($name);
   $sth = $this->{DBH}->prepare("select id from Track where name=$name ".
                        "and artist=$artist and album=$album and ".
                        "sequence=$seq");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];

   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetTrackIdFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, $rv);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare("select id from Track where guid=$guid");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetPendingIdsFromGUID
{
   my ($this, $guid) = @_;
   my ($sth, @ids);

   $guid = $this->{DBH}->quote($guid);
   $sth = $this->{DBH}->prepare("select id from Pending where guid=$guid");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @ids, $row[0];
        }
   }
   $sth->finish;

   return @ids;
}


sub GetGenreId
{
   my ($this, $genrename) = @_;
   my ($sth, $rv);

   $genrename = $this->{DBH}->quote($genrename);
   $sth = $this->{DBH}->prepare("select id from Genre where name=$genrename");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];

   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetAlbumFromDiskId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $id = $this->{DBH}->quote($id);
   $sth = $this->{DBH}->prepare("select album from Diskid where disk=$id");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];

   }
   else
   {
       $rv = -1;
   }
   $sth->finish;

   return $rv;
}

sub GetLastInsertId
{
   my $this = $_[0];
   my (@row, $sth);

   $sth = $this->{DBH}->prepare("select LAST_INSERT_ID()");
   $sth->execute;
   if ($sth->rows)
   {
       @row = $sth->fetchrow_array;
       $sth->finish;

       return $row[0];
   }
   $sth->finish;

   return -1;
}

sub GetArtistName
{
   my ($this, $artistid) = @_;
   my ($sth, @row);

   $sth = $this->{DBH}->prepare(qq/select name, modpending from Artist 
                                   where id=$artistid/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
   }
   $sth->finish;

   return @row;
}

sub ArtistSearch
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select id, name from Artist
               where /, "name") . " order by name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1]];
       }
   }
   $sth->finish;

   return @info;
};

sub GetArtistList
{
   my ($this, $ind, $offset, $max_items) = @_;
   my ($sth, $num_artists, @info); 

   $sth = $this->{DBH}->prepare(qq/select count(*) from Artist where 
                       left(name, 1) = '$ind'/);
   $sth->execute();
   $num_artists = ($sth->fetchrow_array)[0];
   $sth->finish;   

   $sth = $this->{DBH}->prepare(qq/select id, name, modpending from Artist 
      where left(name, 1) = '$ind' order by name limit $offset, $max_items/);
   $sth->execute();  
   if ($sth->rows > 0)
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {
           push @info, [$row[0], $row[1], $row[2]];
       }
   }
   $sth->finish;   

   return ($num_artists, @info);
}

sub GetAlbumName
{
   my ($this, $albumid) = @_;
   my ($sth, $rv);

   $sth = $this->{DBH}->prepare("select name from Album where id=$albumid");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   $sth->finish;

   return $rv;
}

sub GetArtistInfoFromAlbumId
{
   my ($this, $albumid) = @_;
   my ($sth, @row);

   $sth = $this->{DBH}->prepare(qq/select Artist.id, Artist.name, 
             Artist.modpending from Album, Artist where Album.id=$albumid 
             and Album.artist = Artist.id/);
   $sth->execute;
   if ($sth->rows)
   {
        @row = $sth->fetchrow_array;
   }
   else
   {
       $sth->finish;
       $sth = $this->{DBH}->prepare(qq/select artist from Album where id =
                 $albumid/);
       $sth->execute;
       if ($sth->rows)
       {
           $row[1] = 'Various Artists' if ($row[0] == 0);
       }
   }
   $sth->finish;

   return @row;
}

sub GetAlbumInfo
{
   my ($this, $albumid) = @_;
   my (@info, $sth);

   $sth = $this->{DBH}->prepare(qq/select id, sequence, name, modpending from 
                Track where Album = $albumid order by sequence/);
   if ($sth->execute())
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3]];
       }
   }
   $sth->finish;

   return @info;
}

sub GetMultipleArtistAlbumInfo
{
   my ($this, $albumid) = @_;
   my (@info, $sth);

   $sth = $this->{DBH}->prepare(qq/select Track.id, sequence, Track.name, 
                Artist.name, Track.modpending from Track, Artist where 
                Album = $albumid and Track.Artist = Artist.id order by 
                sequence/);
   if ($sth->execute())
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3], $row[4]];
       }
   }
   $sth->finish;

   return @info;
}

sub AlbumSearch
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select Album.id, Album.name,
               Artist.name, Artist.id from Album,Artist where Album.artist = 
               Artist.id and /, "Album.Name") . " order by Album.name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3]];
       }
   }
   $sth->finish;

   $sql = $this->AppendWhereClause($search, "select id, name " .
           "from Album where artist = 0 and ", "Name");
    $sql .= " order by name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], 'Various Artists', 0];
       }
   }
   $sth->finish;

   return @info;
};


sub GetAlbumList
{
   my ($this, $id) = @_;
   my ($sth, @idsalbums);

   $sth = $this->{DBH}->prepare("select id, name from Album where artist=$id");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @idsalbums, $row[0];
            push @idsalbums, $row[1];
        }
   }
   $sth->finish;

   return @idsalbums;
}

sub GetTrackName
{
   my ($this, $trackid) = @_;
   my ($sth, $rv);

   $sth = $this->{DBH}->prepare("select name from Track where id=$trackid");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   $sth->finish;

   return $rv;
}

sub GetTrackList
{
   my ($this, $albumid) = @_;
   my ($sth, @ids_tracks_seqs);

   $sth = $this->{DBH}->prepare("select id, name, sequence from Track " .
                                "where album=$albumid order by sequence");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        while(@row = $sth->fetchrow_array)
        {
            push @ids_tracks_seqs, $row[0];
            push @ids_tracks_seqs, $row[1];
            push @ids_tracks_seqs, $row[2];
        }
   }
   $sth->finish;

   return @ids_tracks_seqs;
}

sub TrackSearch
{
   my ($this, $search) = @_;
   my (@info, $sth, $sql);

   $sql = $this->AppendWhereClause($search, qq/select Track.id, Track.Name, 
             Album.id, Album.name, Artist.id, Artist.name from Track, Album, 
             Artist where Track.artist = Artist.id and Track.album = Album.id 
             and /, "Track.Name") .  " order by Track.name";

   $sth = $this->{DBH}->prepare($sql);
   $sth->execute();
   if ($sth->rows > 0) 
   {
       my @row;
       my $i;

       for(;@row = $sth->fetchrow_array;)
       {  
           push @info, [$row[0], $row[1], $row[2], $row[3], $row[4], $row[5]];
       }
   }
   $sth->finish;

   return @info;
};


sub GetPendingData
{
    my ($this, $id) = @_;
    my (@row, $sth);

    $sth = $this->{DBH}->prepare("select name, guid, artist, album, sequence, length, year, genre, filename, comment from Pending where id=$id");
    $sth->execute;
    if ($sth->rows)
    {
         @row = $sth->fetchrow_array;
    }
    $sth->finish;
 
    return @row;
}

sub DeletePendingData
{
    my ($this, $guid) = @_;

    $guid = $this->{DBH}->quote($guid);
    $this->{DBH}->do("delete from Pending where guid=$guid");
}

sub GetTrackData
{
    my ($this, $id) = @_;
    my (@row, $sth, $artist, $album);

    $artist = "Unknown";
    $album = "Unknown";

    $sth = $this->{DBH}->prepare("select name, guid, artist, album, sequence, length, year, genre, filename, comment from Track where id=$id");
    $sth->execute;
    if ($sth->rows)
    {
         @row = $sth->fetchrow_array;
    }
    $sth->finish;

    $sth = $this->{DBH}->prepare("select name from Artist where id=$row[2]");
    $sth->execute;
    if ($sth->rows)
    {
         $artist = ($sth->fetchrow_array)[0];
    }
    $sth->finish;

    $sth = $this->{DBH}->prepare("select name from Album where id=$row[3]");
    $sth->execute;
    if ($sth->rows)
    {
         $album = ($sth->fetchrow_array)[0];
    }
    $sth->finish;
 
    return ($row[0], $row[1], $artist, $album, $row[4], $row[5],
            $row[6], $row[7], $row[8]);
}

sub GetLyricId
{
   my ($this, $id) = @_;
   my ($sth, $rv);

   $rv = -1;

   $sth = $this->{DBH}->prepare("select Id from SyncLyrics where track=$id");
   $sth->execute;
   if ($sth->rows)
   {
        my @row;

        @row = $sth->fetchrow_array;
        $rv = $row[0];
   }
   $sth->finish;

   return $rv;
}

sub CreateNewGlobalId
{
    my ($this) = @_;
    my ($sth, $id, @row);

    $this->{DBH}->do("lock tables GlobalId write");

    $sth = $this->{DBH}->prepare("select MaxIndex, Host from GlobalId");
    $sth->execute();
    if ($sth->rows > 0)
    {
        @row = $sth->fetchrow_array;
        $id = sprintf('%08X@%s@%08X', $row[0], $row[1], time);
        $row[0]++;
        $this->{DBH}->do("update GlobalId set MaxIndex = $row[0]");
    }
    $sth->finish;
    $this->{DBH}->do("unlock tables");

    return $id;
}

sub InsertArtist
{
    my ($this, $name) = @_;
    my ($artist, $id);

    $artist = GetArtistId($this, $name);
    if ($artist < 0)
    {
         $id = $this->{DBH}->quote(CreateNewGlobalId($this));
         $name = $this->{DBH}->quote($name);
         $this->{DBH}->do("insert into Artist (name, gid) values ($name, $id)");

         $artist = GetLastInsertId($this);
    } 
    return $artist;
}

sub InsertAlbum
{
    my ($this, $name, $artist, $tracks) = @_;
    my ($album, $id);

    $album = GetAlbumId($this, $name, $artist, $tracks);
    if ($album < 0)
    {
         $id = $this->{DBH}->quote(CreateNewGlobalId($this));
         $name = $this->{DBH}->quote($name);
         $this->{DBH}->do("insert into Album (name,artist,gid) values " . 
                          "($name,$artist, $id)");

         $album = GetLastInsertId($this);
    } 
    return $album;
}

sub InsertTrack
{
    my ($this, $name, $artist, $album, $seq, $guid, $length, $year, $genre, 
        $filename, $comment) = @_;
    my ($track, $id, $query, $values);

    $track = GetTrackId($this, $name, $artist, $album, $seq);
    if ($track < 0)
    {
        $name = $this->{DBH}->quote($name);
        $id = $this->{DBH}->quote(CreateNewGlobalId($this));
        $query = "insert into Track (name,gid,artist,album,sequence";
        $values = "values ($name, $id, $artist, $album, $seq";

        if (defined $guid && $guid ne '')
        {
            $query .= ",guid";
            $values .= "," . $this->{DBH}->quote($guid);
        }
        if (defined $length && $length != 0)
        {
            $query .= ",length";
            $values .= ",$length";
        }
        if (defined $year && $year != 0)
        {
            $query .= ",year";
            $values .= ",$year";
        }
        if (defined $genre && $genre ne "")
        {
            $query .= ",genre";
            $values .= "," . $this->{DBH}->quote($genre);
        }
        if (defined $filename && $filename ne '')
        {
            $query .= ",filename";
            $values .= "," . $this->{DBH}->quote($filename);
        }
        if (defined $guid && $guid ne '')
        {
            $query .= ",comment";
            $values .= "," . $this->{DBH}->quote($comment);
        }

        $this->{DBH}->do("$query) $values)");
        $track = GetLastInsertId($this);
    }

    return $track;
}

sub InsertGenre
{
    my ($this, $name, $desc) = @_;
    my ($genre, $id);

    $genre = GetGenreId($this, $name);
    if ($genre < 0)
    {
         $name = $this->{DBH}->quote($name);
         $desc = $this->{DBH}->quote($desc);
         $this->{DBH}->do("insert into Genre (name, description) values ($name, $desc)");

         $genre = GetLastInsertId($this);
    } 
    return $genre;
}

sub InsertDiskId
{
    my ($this, $id, $album, $toc) = @_;
    my ($diskidalbum, $sql);

    $diskidalbum = GetAlbumFromDiskId($this, $id);
    if ($diskidalbum < 0)
    {
        $sql = $this->{DBH}->quote($id);
        $this->{DBH}->do("insert into Diskid (disk,album,toc,timecreated) " .
                         "values ($sql, $album, '$toc', now())"); 
    }

    InsertTOC($this, $id, $album, $toc);
}
 
sub InsertTOC
{
    my ($this, $diskid, $album, $toc) = @_;
    my (@offsets, $query, $i);

    @offsets = split / /, $toc;

    $query = "insert into TOC (DiskId, Album, Tracks, Leadout, ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
         $query .= "Track" . ($i - 2) . ", ";
    }
    chop($query);
    chop($query);

    $diskid = $this->{DBH}->quote($diskid);
    $query .= ") values ($diskid, $album, ". (scalar(@offsets) - 3) .
              ", $offsets[2], ";
    for($i = 3; $i < scalar(@offsets); $i++)
    {
        $query .= "$offsets[$i], ";
    }
    chop($query);
    chop($query);
    $query .= ")";

    $this->{DBH}->do($query);
}

sub InsertPendingData
{
    my ($this, $name, $guid, $artist, $album, $seq, $length, $year,
        $genre, $filename, $comment) = @_;
    my (@ids, $id);

    @ids = GetPendingIdsFromGUID($this, $guid);
    if (scalar(@ids) == 0)
    {
         $name = $this->{DBH}->quote($name);
         $guid = $this->{DBH}->quote($guid);
         $artist = $this->{DBH}->quote($artist);
         $album = $this->{DBH}->quote($album);
         $genre = $this->{DBH}->quote($genre);
         $filename = $this->{DBH}->quote($filename);
         $comment = $this->{DBH}->quote($comment);
         $this->{DBH}->do("insert into Pending (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");
         $this->{DBH}->do("insert into PendingArchive (name, GUID, Artist, Album, Sequence, Length, Year, Genre, Filename, Comment) values ($name, $guid, $artist, $album, $seq, $length, $year, $genre, $filename, $comment)");

         $id = GetLastInsertId($this);
    } 
    return $id;
}

sub InsertLyrics
{
    my ($this, $trackid, $type, $url, $contrib) = @_;
    my ($id);

    $id = GetLyricId($this, $trackid);
    if ($id < 0)
    {
         $url = $this->{DBH}->quote($url);
         $contrib = $this->{DBH}->quote($contrib);
         $this->{DBH}->do("insert into SyncLyrics (track, type, url, submittor, submitted) values ($trackid, $type, $url, $contrib, now())");

         $id = GetLastInsertId($this);
    } 
    return $id;
}

sub InsertSyncEvent
{
    my ($this, $lyricid, $ts, $text) = @_;
    my ($id);

    $text = $this->{DBH}->quote($text);
    $this->{DBH}->do("insert into SyncEvent (synctext, ts, text) values ($lyricid, $ts, $text)");

    $id = GetLastInsertId($this);
    return $id;
}

sub FindTextInColumn
{
    my ($this, $table, $column, $search) = @_;
    my ($sql, $sth, @idslabels, @row, $i);

    $sql = AppendWhereClause($this, $search, "select id, $column from $table ".
                             "where ", $column) . " order by $column";

    $sth = $this->{DBH}->prepare($sql);
    $sth->execute();
    if ($sth->rows > 0)
    {
        for($i = 0; @row = $sth->fetchrow_array; $i++)
        {
            push @idslabels, $row[0];
            push @idslabels, $row[1];
        }
    }

    return @idslabels;
}

sub AppendWhereClause
{
    my ($this, $search, $sql, $col) = @_;
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

sub FindFuzzy
{
   my ($this, $tracks, $toc) = @_;
   my $sth;
   my @row;
   my ($i, $query, @list, @albums);

   return @albums if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "abs(Track" . ($i - 2) . " - $list[$i]) < 1000 and ";
   }
   chop($query); chop($query); chop($query); chop($query);

   $sth = $this->{DBH}->prepare($query);
   $sth->execute;
   if ($sth->rows)
   {
      while(@row = $sth->fetchrow_array)
      {
          push @albums, $row[0];
      }
   }
   $sth->finish;

   return @albums;
}

sub FindFreeDBEntry
{
   my ($this, $tracks, $toc, $id) = @_;
   my $sth;
   my @row;
   my ($i, $query, @list, $album);

   return $album if ($tracks == 1);

   @list = split / /, $toc;

   $query = "select id, album from TOC where tracks = $tracks and ";
   for($i = 3; $i < scalar(@list); $i++)
   {
       $query .= "Track" . ($i-2) . " = $list[$i] and ";
   }
   chop($query); chop($query); chop($query); chop($query); chop($query);

   $sth = $this->{DBH}->prepare($query);
   $sth->execute;
   if ($sth->rows == 1)
   {
      @row = $sth->fetchrow_array;
      $album = $row[1];

      # Once we've found a record that matches exactly, update
      # the missing data (leadout) and the diskid for future use.
      $query = "update TOC set Leadout = $list[2], Diskid = '$id' " . 
               "where id = $row[0]";
      $this->{DBH}->do($query);
      $query = "update Diskid set Disk = '$id', Toc = '$toc', " .
               "LastChanged = now() where id = $row[0]";
      $this->{DBH}->do($query);
   }
   $sth->finish;

   return $album;
}

sub InsertModification
{
    my ($this, $table, $column, $id, $prev, $new, $uid) = @_;

    $this->{DBH}->do(qq/update $table set modpending = 1 where id = $id/);

    $table = $this->{DBH}->quote($table);
    $column = $this->{DBH}->quote($column);
    $prev = $this->{DBH}->quote($prev);
    $new = $this->{DBH}->quote($new);
    $this->{DBH}->do(qq/insert into Changes (tab, col, rowid, prevvalue, 
           newvalue, timesubmitted, moderator, yesvotes, novotes) values 
           ($table, $column, $id, $prev, $new, now(), $uid, 0, 0)/);
}

1;
