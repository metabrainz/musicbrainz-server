#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   CD Index - The Internet CD Index
#
#   Copyright (C) 1998 Robert Kaye
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

use lib "../cgi-bin";
use strict;
use DBDefs;
use Sql;
use MusicBrainz;
use RDFOutput2;
use Artist;
use Album;
use Track;

my ($outfile, $sql, @tinfo, $timestring, $mb, @row, $rdfout, @ids);

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

print RDF "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n";
print RDF (GetLicense());

$mb = MusicBrainz->new;
$mb->Login;

$rdfout = RDFOutput2->new($mb->{DBH});
$rdfout->SetBaseURI("http://mm.musicbrainz.org");
$rdfout->SetDepth(1);

$sql = Sql->new($mb->{DBH});
if ($sql->Select("select gid from Artist order by sortname"))
{
    for(;@row = $sql->NextRow;)
    {
       push @ids, $row[0];
    }
}
$sql->Finish;

$rdfout->SetOutputFile(\*RDF);

print "Dumping Artist list.\n";
$rdfout->DumpBegin('artist', @ids);
@ids = ();

$| = 1;
print "Dumping artists.\n";
Dump($sql, $rdfout, 'Artist');
print "Dumping albums.\n";
Dump($sql, $rdfout, 'Album');
print "Dumping tracks.\n";
Dump($sql, $rdfout, 'Track');

print "Dump finished.\n";

$rdfout->DumpEnd();

close RDF;

$mb->Logout;

sub Dump
{
    my ($sql, $rdfout, $type) = @_;

    my @row;
    my $lctype = $type;
    $lctype =~ tr/A-Z/a-z/;

    my ($start, $nw, $count, $mx, $spr, $left, $mins, $hours, $secs);
    if ($sql->Select("select id from Artist order by sortname"))
    {
        $start = time;
        $mx = $sql->Rows();
        for($count = 1;@row = $sql->NextRow; $count++)
        {
            $rdfout->DumpArtist($lctype, $row[0]);
    
            $nw = time;
            $spr = ($nw - $start) / $count;
            $left = ($mx - $count) * $spr;
            $hours = int($left / 3600);
            $left %= 3600;
            $mins = int($left / 60);
            $left %= 60;

            print "  $count of $mx -- Time left: " . 
                  sprintf("%02d:%02d:%02d   \r", $hours, $mins, $left, $spr);
        }
    }
    $sql->Finish;
}

sub GetLicense
{
    my $text = <<END;
<!--
OpenContent License (OPL)
Version 1.0, July 14, 1998. 

This document outlines the principles underlying the OpenContent (OC) movement and may be redistributed provided it remains unaltered. For legal purposes, this document is the license under which OpenContent is made available for use. 

The original version of this document may be found at http://opencontent.org/opl.shtml 

LICENSE 

Terms and Conditions for Copying, Distributing, and Modifying 

Items other than copying, distributing, and modifying the Content with which this license was distributed (such as using, etc.) are outside the scope of this license. 

  1. You may copy and distribute exact replicas of the OpenContent (OC) as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice and disclaimer of warranty; keep intact all the notices that refer to this License and to the absence of any warranty; and give any other recipients of the OC a copy of this License along with the OC. You may at your option charge a fee for the media and/or handling involved in creating a unique copy of the OC for use offline, you may at your option offer instructional support for the OC in exchange for a fee, or you may at your option offer warranty in exchange for a fee. You may not charge a fee for the OC itself. You may not charge a fee for the sole service of providing access to and/or use of the OC via a network (e.g. the Internet), whether it be via the world wide web, FTP, or any other method. 

  2. You may modify your copy or copies of the OpenContent or any portion of it, thus forming works based on the Content, and distribute such modifications or work under the terms of Section 1 above, provided that you also meet all of these conditions: 

  a) You must cause the modified content to carry prominent notices stating that you changed it, the exact nature and content of the changes, and the date of any change. 

  b) You must cause any work that you distribute or publish, that in whole or in part contains or is derived from the OC or any part thereof, to be licensed as a whole at no charge to all third parties under the terms of this License,
  unless otherwise permitted under applicable Fair Use law. 

  These requirements apply to the modified work as a whole. If identifiable sections of that work are not derived from the OC, and can be reasonably considered independent and separate works in themselves, then this License, and its terms, do not apply to those sections when you distribute them as separate works. But when you distribute the same sections as part of a whole which is a work based on the OC, the distribution of the whole must be on the terms of this License, whose permissions for other licensees extend to the entire whole, and thus to each and every part regardless of who wrote it. Exceptions are made to this requirement to release modified works free of charge under this license only in compliance with Fair Use law where applicable. 

  3. You are not required to accept this License, since you have not signed it. However, nothing else grants you permission to copy, distribute or modify the OC. These actions are prohibited by law if you do not accept this License. Therefore, by distributing or translating the OC, or by deriving works herefrom, you indicate your acceptance of this License to do so, and all its terms and conditions for copying, distributing or translating the OC. 

  NO WARRANTY 

  4. BECAUSE THE OPENCONTENT (OC) IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY FOR THE OC, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE OC "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE OF THE OC IS WITH YOU. SHOULD THE OC PROVE FAULTY, INACCURATE, OR OTHERWISE UNACCEPTABLE YOU ASSUME THE COST OF ALL NECESSARY REPAIR OR CORRECTION. 

  5. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MIRROR AND/OR REDISTRIBUTE THE OC AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE OC, EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. 
-->
END

   return $text;
}
