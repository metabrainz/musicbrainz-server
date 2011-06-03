#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#    MusicBrainz -- the open internet music database
#
#    Copyright (C) 1998 Robert Kaye
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#    $Id$
#____________________________________________________________________________

use FindBin;
use lib "$FindBin::Bin/../lib";

use strict;
use DBDefs;
use Sql;
use MusicBrainz;
use MM_2_1;
use MusicBrainz::Server::Artist;
use MusicBrainz::Server::Release;
use MusicBrainz::Server::Track;

my $verbose = -t;

my ($outfile, $sql, @tinfo, $timestring, $mb, @row, $rdf, @ids);

@tinfo = localtime;
$timestring = "rdfdump-" . (1900 + $tinfo[5]) . "-".($tinfo[4]+1)."-$tinfo[3]";

$outfile = shift;
if (defined $outfile && ($outfile eq "-h" || $outfile eq "--help"))
{
    print "Usage: RDFDump.pl <dumpfile>\n\n";
    exit(0);
}
$outfile = "$timestring.rdf.bz2" if (!defined $outfile);

@tinfo = localtime;

open RDF, "| bzip2 -c > $outfile"
    or die "Cannot open a pipe to bzip2 for output.\n";

print "Writing dump to $outfile.\n";

print RDF "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print RDF (GetLicense());

$mb = MusicBrainz->new;
$mb->Login;

$sql = Sql->new($mb->{dbh});
$rdf = MM_2_1->new();
print RDF $rdf->BeginRDFObject(1);
print RDF "\n";

$| = 1;
print "\nDumping artists.\n";
DumpArtists($sql, $rdf, \*RDF, "http://musicbrainz.org");
print "\nDumping tracks.\n";
DumpTracks($sql, $rdf, \*RDF, "http://musicbrainz.org");
print "\nDumping albums.\n";
DumpAlbums($sql, $rdf, \*RDF, "http://musicbrainz.org");

print RDF $rdf->EndRDFObject();

print "\nDump finished.\n";

close RDF;

$mb->Logout;

sub DumpArtists
{
    my ($sql, $rdf, $file, $baseuri) = @_;

    my (@row, $out, $last_id);
    my ($start, $nw, $count, $mx, $spr, $left, $mins, $hours, $secs);

    $sql->Select(
        "select Artist.gid, Artist.name, Artist.sortname, 
                        Album.gid
        from    Artist left join Album on Artist.id = Album.artist
        order by Artist.id",
    );

    $start = time;
    $mx = $sql->Rows();

    $last_id = "";
    for($count = 1;@row = $sql->NextRow; $count++)
    {
        $out = "";

        if ($row[0] ne $last_id)
        {
                if ($count != 1)
                {
                        $out .=   $rdf->EndSeq();
                        $out .=   $rdf->EndDesc("mm:albumList");
                        $out .= $rdf->EndDesc("mm:Artist"); 
                        $out .= "\n";
                }
                $out .= $rdf->BeginDesc("mm:Artist", "$baseuri/artist/$row[0]");
                $out .= $rdf->Element("dc:title", $row[1]);
                $out .= $rdf->Element("mm:sortName", $row[2]);
                $out .= $rdf->BeginDesc("mm:albumList");
                $out .= $rdf->BeginSeq();
        }

        $out .= $rdf->Li("$baseuri/album/$row[3]") if defined $row[3];
        print {$file} $out;

        $last_id = $row[0];

        $nw = time;
        $spr = ($nw - $start) / $count;
        $left = ($mx - $count) * $spr;
        $hours = int($left / 3600);
        $left %= 3600;
        $mins = int($left / 60);
        $left %= 60;

        print "  $count of $mx artist albums -- Time left: " . 
                sprintf("%02d:%02d:%02d \r", $hours, $mins, $left, $spr)
                if $verbose;
    }

    $out = $rdf->EndSeq();
    $out .= $rdf->EndDesc("mm:albumList");
    $out .= $rdf->EndDesc("mm:Artist"); 
    $out .= "\n";
    print {$file} $out;

    $sql->Finish;
}

sub DumpAlbums
{
    my ($sql, $rdf, $file, $baseuri) = @_;

    my (@row, $out, $last_id);
    my ($sql2, @row2, $album, $out_disc);
    my ($start, $nw, $count, $mx, $spr, $left, $mins, $hours, $secs, @attrs, $attr);

    $sql->Select(
        "select Album.gid, Artist.gid, Album.name, Track.gid,
                        Album.id, AlbumJoin.sequence, Album.attributes
        from    Artist, Album, AlbumJoin, Track 
        where   Artist.id = Album.artist
        and             Album.id = AlbumJoin.album
        and             AlbumJoin.track = Track.id
        order by Album.id",
    );

    my $cur_diskid_album = -1;

    $start = time;
    $mx = $sql->Rows();

    $album = MusicBrainz::Server::Release->new($sql->{dbh});
    $sql2 = Sql->new($sql->{dbh});
    $sql2->Select(
        "SELECT j.album, t.discid
        FROM    album_cdtoc j, cdtoc t
        WHERE   j.cdtoc = t.id
        ORDER BY album",
    );

    $last_id = "";
    for($count = 1;@row = $sql->NextRow; $count++)
    {
        $out = "";
        if ($row[0] ne $last_id)
        {
                if ($count != 1)
                {
                        $out .=   $rdf->EndSeq();
                        $out .=   $rdf->EndDesc("mm:trackList");
                        $out .= $rdf->EndDesc("mm:Album"); 
                        $out .= "\n";
                }
                $out .= $rdf->BeginDesc("mm:Album", "$baseuri/album/$row[0]");
                $out .=   $rdf->Element("dc:title", $row[2]);
                $out .=   $rdf->Element("dc:creator", "", "rdf:resource",
                                                                "$baseuri/artist/$row[1]");

                $out_disc = "";
                while($cur_diskid_album <= $row[4])
                {
                        if ($cur_diskid_album == $row[4])
                        {
                                $out_disc .= $rdf->Element("rdf:li", "", "rdf:resource",
                                                                                   $baseuri . "/cdindex/" . $row2[1]);
                        }

                        if (!(@row2 = $sql2->NextRow))
                        {
                                $cur_diskid_album = 9999999999;
                                last;
                        }
                        $cur_diskid_album = $row2[0];
                }

                if (length($out_disc))
                {
                        $out .= $rdf->BeginDesc("mm:cdindexidList");
                        $out .= $rdf->BeginBag();
                        $out .= $out_disc;
                        $out .= $rdf->EndBag();
                        $out .= $rdf->EndDesc("mm:cdindexidList");
                }

                $row[6] =~ s/^\{(.*)\}$/$1/;
                my @attrs = split /,/, $row[6];
                shift @attrs; 
                foreach $attr (@attrs)
                {
                        if ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_START &&
                                $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_TYPE_END)
                        {
                                $out .= $rdf->Element("rdf:type", "", "rdf:resource", 
                                                $rdf->GetMMNamespace() . "Type" . 
                                                $album->GetAttributeName($attr));
                        }
                        elsif ($attr >= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_START &&
                                        $attr <= MusicBrainz::Server::Release::RELEASE_ATTR_SECTION_STATUS_END)
                        {
                                $out .= $rdf->Element("mm:release", "", "rdf:resource", 
                                                $rdf->GetMMNamespace() . "Status" .
                                                $album->GetAttributeName($attr));
                        }
                }

                $out .=   $rdf->BeginDesc("mm:trackList");
                $out .=   $rdf->BeginSeq();
        }
        $out .= $rdf->Element("rdf:li", "", "rdf:resource","$baseuri/track/$row[3]",
                                                  "mm:trackNum", $row[5]);

        print {$file} $out;

        $last_id = $row[0];

        $nw = time;
        $spr = ($nw - $start) / $count;
        $left = ($mx - $count) * $spr;
        $hours = int($left / 3600);
        $left %= 3600;
        $mins = int($left / 60);
        $left %= 60;

        print "  $count of $mx album tracks -- Time left: " . 
                  sprintf("%02d:%02d:%02d       \r", $hours, $mins, $left, $spr)
    if $verbose;
    }
    $sql2->Finish;

    $out =       $rdf->EndSeq();
    $out .=   $rdf->EndDesc("mm:trackList");
    $out .= $rdf->EndDesc("mm:Album"); 
    $out .= "\n";
    print {$file} $out;

    $sql->Finish;
}

sub DumpTracks
{
    my ($sql, $rdf, $file, $baseuri) = @_;

    my (@row, $out, $last_id);
    my ($sql2, @row2, $out_trm);
    my ($start, $nw, $count, $mx, $spr, $left, $mins, $hours, $secs);

    $sql->Select(
        "select Track.gid, Artist.gid, Track.name, Track.id, Track.length
        from Artist, Track 
        where Artist.id = Track.artist 
        order by Track.id",
    );

    my $cur_trm_track = -1;

    $start = time;
    $mx = $sql->Rows();

    $sql2 = Sql->new($sql->{dbh});
    if (!$sql2->Select(qq|select TRMJoin.track, TRM.trm
                                                from TRMJoin, TRM
                                           where TRMJoin.trm = TRM.id
                                        order by TRMJoin.track|))
    {
        die "Cannot start trm id query.\n";
    }

    $last_id = "";
    for($count = 1;@row = $sql->NextRow; $count++)
    {
        $out = "";
        if ($row[0] ne $last_id)
        {
                if ($count != 1)
                {
                        $out .= $rdf->EndDesc("mm:Track"); 
                        $out .= "\n";
                }
                $out .= $rdf->BeginDesc("mm:Track", "$baseuri/track/$row[0]");
                $out .= $rdf->Element("dc:title", $row[2]);
                $out .= $rdf->Element("dc:creator", "", "rdf:resource",
                                                          "$baseuri/artist/$row[1]");
                if ($row[4] != 0) 
                {
                        $out .= $rdf->Element("mm:duration", $row[4]);
                }

                $out_trm = "";
                while($cur_trm_track <= $row[3])
                {
                        if ($cur_trm_track == $row[3])
                        {
                                $out_trm .= "    " .$rdf->Element("rdf:li", "", "rdf:resource",
                                                                                  $baseuri . "/trmid/" . $row2[1]);
                        }

                        if (!(@row2 = $sql2->NextRow))
                        {
                                $cur_trm_track = 999999999;
                                last;
                        }
                        $cur_trm_track = $row2[0];
                }
        }
        if (length($out_trm))
        {
                $out .= $rdf->BeginDesc("mm:trmidList");
                $out .= $rdf->BeginBag();
                $out .= $out_trm;
                $out .= $rdf->EndBag();
                $out .= $rdf->EndDesc("mm:trmidList");
        }
        print {$file} $out;

        $last_id = $row[0];

        $nw = time;
        $spr = ($nw - $start) / $count;
        $left = ($mx - $count) * $spr;
        $hours = int($left / 3600);
        $left %= 3600;
        $mins = int($left / 60);
        $left %= 60;

        print "  $count of $mx tracks -- Time left: " . 
                  sprintf("%02d:%02d:%02d       \r", $hours, $mins, $left, $spr)
    if $verbose;
    }
    $sql2->Finish;

    $out .= $rdf->EndDesc("mm:Track"); 
    $out .= "\n";
    print {$file} $out;

    $sql->Finish;
}

sub GetLicense
{
    my $text = <<END;
<!--
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This work is hereby released into the Public Domain. To view a copy of 
the public domain dedication, visit 

                http://creativecommons.org/licenses/publicdomain 
    
or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, 
California 94305, USA. 

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                   P U B L I C   D O M A I N   D E D I C A T I O N

                Copyright-Only Dedication (based on United States law)


This is a record of a Public Domain Dedication.

On February 10, 2003, MusicBrainz Community dedicated to the public domain 
the work "MusicBrainz Core Data." Before making the dedication, MusicBrainz 
Community represented that MusicBrainz Community owned all copyrights in the
work. By making the dedication, MusicBrainz Community made an overt act
of relinquishment in perpetuity of all present and future rigths under
copyright law, whether vested or contingent, in "MusicBrainz Core Data."

MusicBrainz Community understands that such relinquishment of all rights
includes the relinquishment of all rights to enforce (by lawsuit or
otherwise) those copyrights in the Work.

MusicBrainz Community recognizes that, once placed in the public domain,
"MusicBrainz Core Data" may be freely reproduced, distributed, transmitted, 
used, modified, built upon, or otherwise exploited by anyone for any
purpose, commercial or non-commercial, and in any way, including by
methods that have not yet been invented or conceived.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-->
END

   return $text;
}
