#!/usr/bin/perl -w
# vi: set ts=8 sw=4 :
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
use Style;

use vars qw(@ISA @EXPORT);
@ISA    = @ISA    = 'TableBase';
@EXPORT = @EXPORT = '';

use strict;
use Carp;
use Socket qw( $CRLF );
use IO::Socket::INET;
use Track;
use Album;
use Artist;
use Discid;
use ModDefs;
use Style;
use Alias;
use Encode qw( decode from_to );
use constant  CD_MSF_OFFSET => 150;
use constant  CD_FRAMES     =>  75;
use constant  CD_SECS       =>  60;

# private sub

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

# Public

sub Lookup
{
    my ($this, $Discid, $toc) = @_;
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
    $query = "cddb query $id $last $trackoffsets $total_seconds";

    $ret = $this->Retrieve("www.freedb.org", 888, $query);
    if (defined $ret)
    {
        $ret->{cdindexid} = $Discid;
        $ret->{toc} = $toc; 
    }
    return $ret;
}

# Public

sub LookupByFreeDBId
{
    my ($this, $id, $cat) = @_;
    my ($ret, $query);

    $query = "cddb read $cat $id";
    $ret = $this->Retrieve("www.freedb.org", 888, $query);
    if (defined $ret)
    {
        $ret->{freedbid} = $id;
    }
    return $ret;
}

# private sub

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

# private method

sub Retrieve
{
    my ($this, $remote, $port, $query) = @_;

    if ($remote eq '' || $port == 0)
    {
        croak "A port and server address/name must be given.";
        return undef;
    }

    my $sock = IO::Socket::INET->new(
	PeerAddr => $remote,
	PeerPort => $port,
	Proto => 'tcp',
    );

    if (not $sock)
    {
	print STDERR "FreeDB $remote:$port connect failed: $!\n";
	return undef;
    }

    $sock->autoflush(1);

    my ($line, @response);

    $line = <$sock>;
    #print $line;

    @response = split ' ', $line;
    if (!IsNumber($response[0]) || $response[0] < 200 || $response[0] > 299)
    {
        print STDERR "FreeDB $remote:$port does not want to talk to us: $line\n";
        close $sock;
        return undef;
    }

    # Send the hello string
    print $sock "cddb hello obs www.musicbrainz.org FreeDBGateway 1.0", $CRLF;
    $line = <$sock>;
    #print $line;

    @response = split ' ', $line;
    if ($response[0] < 200 || $response[0] > 299)
    {
        print STDERR "FreeDB $remote:$port does not like our hello: $line\n";
        return undef;
    }

    # Send the query 
    print $sock $query, $CRLF;
    $line = <$sock>;
    #print $line;

    @response = split ' ', $line;
    if ($response[0] == 202)
    {
        #print STDERR "FreeDB $remote:$port cannot find this CD ($query)\n";
        return undef;
    }
    if ($response[0] < 200 || $response[0] > 299)
    {
        print STDERR "FreeDB $remote:$port encountered an error: $line\n";
        return undef;
    }

    #
    # Parse the query 

    my ($category, $disc_id);
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

        for (my $i = 1; ; $i++)
        {
            $line = <$sock>;

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
   
    print $sock "cddb read $category $disc_id", $CRLF;

    my $artist = "";
    my $title = "";

    my $in_offsets = 0;
    my $last_track_offset = 0;
    my %info;
    $info{durations} = '';

    my @track_titles;

    while(defined($line = <$sock>))
    {
    	my @chars = split(//, $line, 2);
        if ($chars[0] eq '#')
        {
            if ($line =~ /Track frame offsets/)
            {
                $in_offsets = 1;
                next;
            }
            if (!$in_offsets)
            {
                next;
            }
            # parse the track offsets and the total time 
            if ($line =~ /Disc length:/)
            {
                $line =~ s/^# Disc length:\s*(\d*).*$/$1/i;
                $info{durations} .= ($line * 1000) - int(($last_track_offset*1000) / 75);
                $in_offsets = 0;
                next;
            }
            $line =~ tr/0-9//cd;
            if ($line eq '')
            {
                next;
            }
            if($last_track_offset > 0) 
            {
                $info{durations} .= int ((($line - $last_track_offset)*1000) / 75) . " ";
            }           
            $last_track_offset = $line;
            next;
        }

        @response = split ' ', $line;
        if ($response[0] eq '.')
        {
            last;
        }

        #print $line;
        my @parts = split '=', $line;
        if ($parts[0] eq "DTITLE")
        {
	    my $temp;
            if ($artist eq "")
            {
                ($artist, $temp) = split '\/', $parts[1];
            }
            else
            {
                $temp = $parts[1];
            }
            $temp = "" if not defined $temp;
            $temp =~ s/^[\n\r]*(.*?)[\r\n]*$/$1/;
            $title .= $temp;
            next;
        }

        my @subparts = split '([0-9]+)', $parts[0];
        if ($subparts[0] eq "TTITLE")
        {
            chomp $parts[1];
            chop $parts[1];
            $track_titles[$subparts[1]] .= $parts[1];
            $track_titles[$subparts[1]] =~ s/^\s*(.*?)\s*$/$1/;
            next;
        }
    } 

    if (!defined $title || $title eq "")
    {
        $title = $artist;
    }

    $artist =~ s/^\s*(.*?)\s*$/$1/;
    $title =~ s/^\s*(.*?)\s*$/$1/;

    if (!defined $title || $title eq "")
    {
        $title = $artist;
    }

    $artist =~ s/^\s*(.*?)\s*$/$1/;
    $title =~ s/^\s*(.*?)\s*$/$1/;

    $title = Style->new->NormalizeDiscNumbers($title);

    # Convert from iso-8859-1 to UTF-8

    from_to($artist, "iso-8859-1", "utf-8");
    $info{artist} = $info{sortname} = $artist;

    from_to($title, "iso-8859-1", "utf-8");
    $info{album} = $title;

    my @tracks;

    for (my $i = 0; $i < scalar(@track_titles); $i++)
    {
        #print("[$i]: $track_titles[$i]\n"); 

	my $t = $track_titles[$i];
	from_to($t, "iso-8859-1", "utf-8");

        push @tracks, { track=>$t, tracknum => ($i+1) };
    }

    $info{tracks} = \@tracks;

    close $sock;

    return \%info;
}

# private method

sub CheckTOC
{
    my ($this, $toc) = @_;

    my @parts = split / /, $toc;

    return 0 if $parts[0] != 1;
    return 0 if $parts[1] < 1;
    return 0 if $parts[1] > 99;
    return 0 if $parts[1] != scalar(@parts) - 3;
    return 0 if $parts[2] <= $parts[scalar(@parts) - 1]; 

    for (3 .. (scalar(@parts) - 2))
    {
        return 0 if ($parts[$_] >= $parts[$_ + 1]);
    }

    return 1;
}

# Public.  Called by Discid->GenerateAlbumFromDiscid

sub InsertForModeration
{
    my ($this, $info) = @_;
    my ($new, $track, $in, $u, $st, $ar, $alias, $aliasid);
    my $ref = $info->{tracks};

    # Don't insert CDs that have only one track.
    return if (scalar(@$ref) < 2);

    # Don't insert into the DB if the Toc is not correct.
    return unless $this->CheckTOC($info->{toc});

    # Don't insert albums by the name of 'various' or 'various artists'
    return if ($info->{artist} =~ /^various$/i ||
               $info->{artist} =~ /^various artists$/i); 

    $st = Style->new;
    return if (!$st->UpperLowercaseCheck($info->{artist}));
    return if (!$st->UpperLowercaseCheck($info->{album}));

    $info->{sortname} = $st->MakeDefaultSortname($info->{artist});

    $alias = Alias->new($this->{DBH});
    $ar = Artist->new($this->{DBH});

    # Check to see if the artist has an alias.
    $alias->{table} = "ArtistAlias";
    $aliasid = $alias->Resolve($info->{artist});

    if (defined $aliasid)
    {
        $ar->SetId($aliasid);
        if ($ar->LoadFromId())
        {
            $info->{artist} = $ar->GetName();
        }
    }

    if ($ar->LoadFromName($info->{artist}) || 
        $ar->LoadFromSortname($info->{artist}))
    {
        my (@albums, $al);

        # This is currently a byte-wise comparison, i.e. case-sensitive, etc.
	# Should it be done using lc() and maybe even unac_string() too?
        if ($ar->GetSortName() eq $info->{artist})
        {
            $info->{sortname} = $ar->GetSortName();
            $info->{artist} = $ar->GetName();
        }

	my $album = lc(decode "utf-8", $info->{album});
        @albums = $ar->GetAlbums();
        foreach $al (@albums)
        {
   	    my $thisname = lc(decode "utf-8", $al->GetName);

            if ($thisname eq $album)
            {
                if ($al->GetTrackCount() == scalar(@$ref))
                {
                    my ($di, $sql);

                    $di = Discid->new($this->{DBH});
                    $sql = Sql->new($this->{DBH});
                    eval
                    {
                        $sql->Begin();
                        $di->Insert($info->{cdindexid}, $al->GetId(), $info->{toc});
                        $sql->Commit();
                    };
                    if ($@)
                    {
                        # if it didn't insert properly... oh well.
                        $sql->Rollback();
                    }
                    return;
                }
            }
        }
    }

    $new = "Artist=$info->{artist}\n";
    $new .= "Sortname=$info->{sortname}\n";
    $new .= "AlbumName=$info->{album}\n";
    $new .= "NumTracks=" . scalar(@$ref) . "\n";
    $new .= "CDIndexId=$info->{cdindexid}\n";
    $new .= "TOC=$info->{toc}\n";

    my @durations = split ' ', $info->{durations};

    foreach $track (@$ref)
    {
        return if (!$st->UpperLowercaseCheck($track->{track}));
        $new .= "Track" . $track->{tracknum} . "=" . $track->{track} . "\n";
	my $dur = $durations[ $track->{tracknum}-1 ];
	$new .= "TrackDur" . $track->{tracknum} . "=$dur\n"
		if defined $dur;
    }


    $in = Insert->new($this->{DBH});
    $in->InsertAlbumModeration($new, &ModDefs::FREEDB_MODERATOR, 0);
}

1;
