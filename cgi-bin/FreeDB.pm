#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
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
                                                                               
package FreeDB;
use TableBase;

BEGIN { require 5.6.1 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Socket;
use Track;
use Album;
use Artist;
use Diskid;
use ModDefs;
use Unicode::String;
use constant  CD_MSF_OFFSET => 150;
use constant  CD_FRAMES     =>  75;
use constant  CD_SECS       =>  60;

sub new
{
   my ($type, $dbh) = @_;

   my $this = TableBase->new($dbh);
   return bless $this, $type;
}

sub _lba_to_msf
{
    my ($lba) = @_;
    my ($m, $s, $f);

    $lba &= 0xffffff;   # negative lbas use only 24 bits 
    $m = int($lba / (CD_SECS * CD_FRAMES));
    $lba %= (CD_SECS * CD_FRAMES);
    $s = int($lba / CD_FRAMES);
    $f = int($lba % CD_FRAMES);

    return ($m, $s, $f);
}

sub EnterRecord
{
    my $this = shift @_;
    my $tracks = shift @_;
    my $title = shift @_;
    my $artistname = shift @_;
    my $diskid = shift @_;
    my $toc = shift @_;
    my ($artistid, $albumid);
    my ($sql, $sql2);
    my ($i, $ar, $al, $d, @ids, $num, $t);

    if (!defined $artistname || $artistname eq '')
    {
        $artistname = "Unknown";
    }

    $ar = Artist->new($this->{DBH});
    $ar->SetName($artistname);
    $ar->SetSortName($artistname);
    $artistid = $ar->Insert();
    if (not defined $artistid)
    {
        return 0;
    }

    @ids = $ar->GetAlbumsByName($title);
    for(;defined($al = shift @ids);)
    {
        $num = $al->GetTrackCount();
        if (!defined $num || $num < 0)
        {
            undef $al;
            last;
        }
        last if ($num == $tracks);
    }

    if (!defined $al)
    {
        $al = Album->new($this->{DBH});
        $al->SetArtist($artistid);
        $al->SetName($title);
        $albumid = $al->Insert();
        if (!defined $albumid)
        {
            return 0;
        }
    }
    else
    {
        $albumid = $al->GetId();
    }
    for($i = 0; $i < $tracks; $i++)
    {
        $title = shift @_;
        $title = "Unknown" if $title eq '';

        $t = Track->new($this->{DBH});
        $t->SetName($title);
        $t->SetSequence($i + 1);
        if (!defined $t->Insert($al, $ar))
        {
            print STDERR "Inserting track $title ($artistid, $albumid) failed.\n";
        }
    }
    $d = Diskid->new($this->{DBH});
    $d->Insert($diskid, $al->GetId(), $toc);

    return $albumid;
}


sub Lookup
{
    my ($this, $diskid, $toc) = @_;
    my ($i, $first, $last, $leadout, @cddb_toc);
    my ($m, $s, $f, @cd_data, $ret);
    my ($id, $query, $trackoffsets, $offset, $sum, $total_seconds);

    my @toc = split / /, $toc;
    $first = shift @toc;
    $last = shift @toc;
    $leadout = shift @toc;

    $trackoffsets = join(" ", @toc);
    $toc[$last] = $leadout - $toc[0];
    for($i = $last - 1; $i >= 0; $i--)
    {
        $toc[$i] -= $toc[0];
    }

    for($i = 0; $i < $last; $i++)
    {
        $offset = int($toc[$i] / 75 + 2);
        map { $sum += $_; } split(//, $offset);
        $total_seconds += int($toc[$i + 1] / 75) - int($toc[$i] / 75);
    }
    $id = sprintf("%08x", (($sum % 255) << 24) | ($total_seconds << 8) | $last);
    ($m, $s, $f) = _lba_to_msf($leadout);
    $total_seconds = $m * 60 + $s;
    $query = "cddb query $id $last $trackoffsets $total_seconds\n";

    $ret = $this->Retrieve("www.freedb.org", 888, $query, $last);
    if (defined $ret)
    {
        $ret->{cdindexid} = $diskid;
        $ret->{toc} = $toc; 
    }
    return $ret;
}

sub Strip
{
    $_ = $_[0];

    tr/\'//d;
    s/\A[ \n\t\r]\b//;
    while(s/[ \n\t\r]$//) { } ;

    return $_;
}

sub IsNumber
{
    if ($_[0] =~ m/^-?[\d]*\.?[\d]*$/)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

sub Retrieve
{
    my ($this, $remote, $port, $query, $last_track) = @_;
    my ($iaddr, $paddr, $proto, $line);
    my (@response, $category, $i);
    my (@selection, @chars, @parts, @subparts);
    my ($aritst, $title, %info, @track_titles, @tracks, @query);
    my ($disc_id, $first_track, @track_offsets, $seconds_in_cd); 

    if ($remote eq '' || $port == 0)
    {
        print STDERR "A part and server address/name must be given.\n";
        return undef;
    }

    if ($port =~ /\D/)
    {
        $port = getsrvbyname($port, 'tcp');
    }

    $iaddr = inet_aton($remote) or 
       return undef;
    $paddr = sockaddr_in($port, $iaddr);
    $proto = getprotobyname('tcp');

    socket(SOCK, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
    connect(SOCK, $paddr)                      or die "connect: $!";

    $line = <SOCK>;
    #print $line;

    @response = split ' ', $line;
    if (!IsNumber($response[0]) || $response[0] < 200 || $response[0] > 299)
    {
        print STDERR "Server $remote does not want to talk to us.\n($line)\n";
        close SOCK;
        return undef;
    }

    #
    # Send the hello string
    #
    $line = "cddb hello obs www.musicbrainz.org FreeDBGateway 1.0\r\n";
    send SOCK, $line, 0;

    $line = <SOCK>;
    #print $line;

    @response = split ' ', $line;
    if ($response[0] < 200 || $response[0] > 299)
    {
        print STDERR "Server $remote does not like our hello.\n($line)\n";
        return undef;
    }

    #
    # Send the query 
    #
    send SOCK, $query, 0;

    $line = <SOCK>;
    #print $line;

    @response = split ' ', $line;
    if ($response[0] == 202)
    {
        #print STDERR "Server $remote cannot find this cd.\n  ($query)\n";
        return undef;
    }
    if ($response[0] < 200 || $response[0] > 299)
    {
        print STDERR "Server $remote encountered an error.\n($line)\n";
        return undef;
    }

    #
    # Parse the query 
    #
    if ($response[0] == 200)
    {
        $category = $response[1];
        $disc_id = $response[2];
    }
    #
    # Do we have more than one match? 
    #
    elsif ($response[0] == 211)
    {
        my (@categories, @disc_ids);

        for($i = 1; ; $i++)
        {
            $line = <SOCK>;

            @response = split ' ', $line;
            if ($response[0] eq '.')
            {
               last;
            }

            #print "[$i]: $line";

            $categories[$i] = $response[0];
            $disc_ids[$i] = $response[1];
        }

        $category = $categories[1];
        $disc_id = $disc_ids[1];
    }
   
    $query = "cddb read $category $disc_id\n";    
    send SOCK, $query, 0;

    $aritst = "";
    $title = "";
    while(defined($line = <SOCK>))
    {
        @chars = split(//, $line, 2);
        if ($chars[0] eq '#')
        {
            next;
        }

        @response = split ' ', $line;
        if ($response[0] eq '.')
        {
            last;
        }

        #print $line;
        @parts = split '=', $line;
        if ($parts[0] eq "DTITLE")
        {
            if ($aritst eq "")
            {
                ($aritst, $title) = split '\/', $parts[1];
            }
            else
            {
                $title = $parts[1];
            }
            next;
        }
        @subparts = split '([0-9]+)', $parts[0];
        if ($subparts[0] eq "TTITLE")
        {
            chomp $parts[1];
            chop $parts[1];
            $track_titles[$subparts[1]] .= $parts[1];
            next;
        }
     }

     if (!defined $title || $title eq "")
     {
         $title = $aritst;
     }
     $info{artist} = Strip($aritst);
     $info{sortname} = Strip($aritst);
     $info{album} = Strip($title);
 
     for($i = 0; $i < $last_track; $i++)
     {
         #print("[$i]: $track_titles[$i]\n"); 
         push @tracks, { track=>$track_titles[$i], tracknum => ($i+1) };
     }
     $info{tracks} = \@tracks;
 
     close SOCK;

     return \%info;
}

use bytes;
sub InsertForModeration
{
    my ($this, $info) = @_;
    my ($new, $track, $in, $u);
    my $ref = $info->{tracks};

    # Don't insert CDs that have only one track.
    return if (scalar(@$ref) < 2);

    # Don't insert albums by the name of 'various' or 'various artists'
    return if ($info->{artist} =~ /^various$/i ||
               $info->{artist} =~ /^various artists$/i); 

    $new = "Artist=$info->{artist}\n";
    $new .= "Sortname=$info->{artist}\n";
    $new .= "AlbumName=$info->{album}\n";
    $new .= "NumTracks=" . scalar(@$ref) . "\n";
    $new .= "CDIndexId=$info->{cdindexid}\n";
    $new .= "TOC=$info->{toc}\n";

    foreach $track (@$ref)
    {
        $new .= "Track" . $track->{tracknum} . "=" . $track->{track} . "\n";
    }

    $in = Insert->new($this->{DBH});
    $in->InsertAlbumModeration($new, ModDefs::FREEDB_MODERATOR);
}
