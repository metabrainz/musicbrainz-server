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

use strict;

package FreeDB;

use Carp;
use Socket qw( $CRLF );
use ModDefs qw( FREEDB_MODERATOR );
use Encode qw( decode from_to );

use constant AUTO_INSERT_MIN_TRACKS => 5;
use constant FREEDB_SERVER => "www.freedb.org";
use constant FREEDB_PORT => 888;

sub new
{
    my ($class, $dbh) = @_;

    bless {
	DBH => $dbh,
    }, ref($class) || $class;
}

# Public

sub Lookup
{
    my ($this, $Discid, $toc) = @_;

    require Discid;
    my %info = Discid->ParseTOC($toc)
    	or die;
    $info{discid} eq $Discid
    	or die;

    my $ret = $this->_Retrieve(
	FREEDB_SERVER, FREEDB_PORT,
	sprintf(
	    "cddb query %s %d %s %d",
	    $info{freedbid},
	    $info{lasttrack},
	    join(" ", @{ $info{trackoffsets} }),
	    int($info{leadoutoffset}/75),
	),
    ) or return undef;

    $ret->{cdindexid} = $info{discid};
    $ret->{toc} = $info{toc}; 

    return $ret;
}

# Public

sub LookupByFreeDBId
{
    my ($this, $id, $cat) = @_;

    my $ret = $this->_Retrieve(
	FREEDB_SERVER, FREEDB_PORT,
	"cddb read $cat $id",
    ) or return undef;

    $ret->{freedbid} = $id;

    return $ret;
}

# private method

sub _Retrieve
{
    my ($this, $remote, $port, $query) = @_;

    my $key = "FreeDB-$remote-$port-$query";

    require MusicBrainz::Server::Cache;
    if (my $r = MusicBrainz::Server::Cache->get($key))
    {
	return $$r;
    }

    print STDERR "Querying FreeDB: $remote:$port '$query'\n";
    my $r = $this->_Retrieve_no_cache($remote, $port, $query);
    MusicBrainz::Server::Cache->set($key, \$r);
    return $r;
}

sub _Retrieve_no_cache
{
    my ($this, $remote, $port, $query) = @_;

    if ($remote eq '' || $port == 0)
    {
        croak "A port and server address/name must be given.";
        return undef;
    }

    require IO::Socket::INET;
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
    if (!MusicBrainz::IsNonNegInteger($response[0]) || $response[0] < 200 || $response[0] > 299)
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

    goto READQUERY if $query =~ /^cddb read /;

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

    $query = "cddb read $category $disc_id";
   
READQUERY:
    print STDERR ">> $query\n";
    print $sock $query, $CRLF;

    my $artist = "";
    my $title = "";

    my $in_offsets = 0;
    my $last_track_offset = 0;
    my %info;
    $info{durations} = '';

    # Used for debugging
    my $response = $info{_response} = [];
    my $offsets = $info{_offsets} = [];
    my $disc_length = \$info{_disc_length};

    my @track_titles;

    while(defined($line = <$sock>))
    {
	push @$response, $line;

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
		$$disc_length = $1;
                $info{durations} .= ($line * 1000) - int(($last_track_offset*1000) / 75);
                $in_offsets = 0;
                next;
            }
            $line =~ tr/0-9//cd;
            if ($line eq '')
            {
                next;
            }
	    push @$offsets, $line;
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

    require Style;
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

# Public.  Called by Discid->GenerateAlbumFromDiscid

sub InsertForModeration
{
    my ($this, $info) = @_;
    my ($new, $track, $in, $u, $st, $ar, $alias, $aliasid);
    my $ref = $info->{tracks};

    # Don't insert CDs that have only a few tracks
    return if (scalar(@$ref) < AUTO_INSERT_MIN_TRACKS);

    # Don't insert into the DB if the Toc is not correct.
    require Discid;
    return unless Discid->ParseTOC($info->{toc});

    # Don't insert albums by the name of 'various' or 'various artists'
    return if ($info->{artist} =~ /^various$/i ||
               $info->{artist} =~ /^various artists$/i); 

    require Style;
    $st = Style->new;
    return if (!$st->UpperLowercaseCheck($info->{artist}));
    return if (!$st->UpperLowercaseCheck($info->{album}));

    $info->{sortname} = $st->MakeDefaultSortname($info->{artist});

    require Alias;
    require Artist;
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

		    require Discid;
		    require Sql;
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

    require Insert;
    $in = Insert->new($this->{DBH});
    $in->InsertAlbumModeration($new, FREEDB_MODERATOR, 0);
}

# Given the TOC offsets (track 1 start, track 2 start, ... track n start,
# leadout start), return the 8-character FreeDB ID.
# Marked as internal, but called from Discid->ParseTOC.

sub _compute_discid
{
    my @frames = @_;
    my $tracks = @frames-1;

    my $n = 0;
    for my $i (0..$tracks-1)
    {
	$n = $n + $_
	    for split //, int($frames[$i]/75);
    }

    my $t = int($frames[-1]/75) - int($frames[0]/75);

    sprintf "%08x", ((($n % 0xFF) << 24) | ($t << 8) | $tracks);
}

1;
# eof FreeDB.pm
