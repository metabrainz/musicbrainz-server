#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
#   Portions  (C) 1998 Rocco Caputo <troc@netrus.net>
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

BEGIN { require 5.003 }
use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Socket;
use Track;
use Album;
use Artist;
use Diskid;
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
    my ($m, $s, $f, $cddb, @cd_data);
    my ($id, $query, $trackoffsets, $offset, @id_data);

    my @toc = split / /, $toc;
    $first = shift @toc;
    $last = shift @toc;
    $leadout = shift @toc;

    for($i = $first; $i <= $last; $i++)
    {
        $offset = shift @toc;
        $trackoffsets .= "$offset ";
        ($m, $s, $f) = _lba_to_msf($offset);
        push @cddb_toc, "$i $m $s $f"; 
    }
    ($m, $s, $f) = _lba_to_msf($leadout);
    push @cddb_toc, "999 $m $s $f"; 

    @id_data = $cddb->calculate_id(@cddb_toc);
    $query = "cddb query $id_data[0] $last $trackoffsets $id_data[4]\n";
 
    return $this->Retrieve("www.freedb.org", 888, $query, $last);
}

sub CalculateId 
{
  my $this = shift;
  my @toc = @_;
 
  my ($seconds_previous, $seconds_first, $seconds_last, $cddb_sum,
      @track_numbers, @track_lengths, @track_offsets,
     );
 
  foreach my $line (@toc) {
    my ($track, $mm_begin, $ss_begin, $ff_begin) = split(/\s+/, $line, 4);
    my $seconds_begin = ($mm_begin * 60) + $ss_begin;
 
    if (defined $seconds_previous) {
      my $elapsed = $seconds_begin - $seconds_previous;
      push( @track_lengths,
            sprintf("%02d:%02d", int($elapsed / 60), $elapsed % 60)
          );
    }
    else {
      $seconds_first = $seconds_begin;
    }
                                        # virtual track: lead-out information
    if ($track == 999) {
      $seconds_last = $seconds_begin;
      last;
    }
                                        # virtual track: get-toc error code
    if ($track == 1000) {
      print STDERR "error in TOC: $ff_begin";
      return undef;
    }
 
    map { $cddb_sum += $_; } split(//, $seconds_begin);
    push @track_offsets, ($mm_begin * 60 + $ss_begin) * 75 + $ff_begin;
    push @track_numbers, sprintf("%03d", $track);
    $seconds_previous = $seconds_begin;
  }
 
  my $total_seconds = $seconds_last - $seconds_first;
  my $id = sprintf
    ( "%08x",
      (($cddb_sum % 255) << 24)
      | ($total_seconds << 8)
      | scalar(@track_offsets)
    );
                                        # return things cddb needs
  if (wantarray()) {
    ($id, \@track_numbers, \@track_lengths, \@track_offsets, $total_seconds);
  }
  else {
    $id;
  }
}

sub Strip
{
    $_ = $_[0];

    tr/\'//d;
    s/\A[ \n\t\r]\b//;
    while(s/[ \n\t\r]$//) { } ;

    return $_;
}

sub Retrieve
{
    my ($remote, $port, $query, $last_track) = @_;
    my ($iaddr, $paddr, $proto, $line);
    my (@response, $category, $query, $i);
    my (@selection, @chars, @parts, @subparts);
    my ($aritst, $title, %info, @track_titles, @tracks, @query);
    my ($disc_id, $first_track, $last_track, @track_offsets, $seconds_in_cd); 

    if ($remote eq '' || $port == 0)
    {
        print STDERR "A part and server address/name must be given.\n";
        return undef;
    }

    if ($port =~ /\D/)
    {
        $port = getsrvbyname($port, 'tcp');
    }

    $iaddr = inet_aton($remote) or die "no host: $remote";
    $paddr = sockaddr_in($port, $iaddr);
    $proto = getprotobyname('tcp');

    socket(SOCK, PF_INET, SOCK_STREAM, $proto) or die "socket: $!";
    connect(SOCK, $paddr)                      or die "connect: $!";

    $line = <SOCK>;
    #print $line;

    @response = split ' ', $line;
    if ($response[0] < 200 || $response[0] > 299)
    {
        print STDERR "Server $remote does not want to talk to us.\n($line)\n";
        close SOCK;
        return undef;
    }

    #
    # Send the hello string
    #
    $line = "cddb hello obs obs.freeamp.org RipCd.pl 1.0\r\n";
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
        print STDERR "Server $remote cannot find this cd.\n";
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

     if ($title eq "")
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

