#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
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
use MusicBrainz::Server::LogFile qw( lprint lprintf );
use Encode qw( decode from_to );

use constant AUTO_INSERT_MIN_TRACKS => 5;
use constant AUTO_ADD_DISCID => 1;
use constant AUTO_ADD_ALBUM => 0;
use constant FREEDB_SERVER => "www.freedb.org";
use constant FREEDB_PORT => 888;
use constant FREEDB_PROTOCOL => 6; # speaks UTF-8

sub new
{
    my ($class, $dbh) = @_;

    bless {
	DBH => $dbh,
    }, ref($class) || $class;
}

# Public.  Called from MusicBrainz::Server::AlbumCDTOC->GenerateAlbumFromDiscid; cdi/enter.html;
# cdi/menter.html

sub Lookup
{
    my ($this, $Discid, $toc) = @_;

    require MusicBrainz::Server::CDTOC;
    my %info = MusicBrainz::Server::CDTOC->ParseTOC($toc)
    	or warn("Failed to parse toc '$toc'"), return undef;
    $info{discid} eq $Discid
    	or warn("Parsed toc '$toc' and got '$info{discid}', not '$Discid'"), return undef;

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

# Public.  Called by freedb/import.html

sub LookupByFreeDBId
{
    my ($this, $id, $cat) = @_;

    my $ret = $this->_Retrieve(
	FREEDB_SERVER, FREEDB_PORT,
	"cddb read $cat $id",
    ) or return undef;

    $ret->{freedbid} = $id;
    $ret->{freedbcat} = $cat;

    return $ret;
}

# private method

sub _Retrieve
{
    my ($this, $remote, $port, $query) = @_;

    my $key = "FreeDB-$remote-$port-$query";

    if (my $r = MusicBrainz::Server::Cache->get($key))
    {
	return $$r;
    }

    lprint "freedb", "Querying FreeDB: $remote:$port '$query'";
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
	lprint "freedb", "FreeDB $remote:$port connect failed: $!";
	return undef;
    }

    $sock->autoflush(1);

    my ($line, @response);

    $line = <$sock>;
    lprint "freedb", "<< $line";

    @response = split ' ', $line;
    if (!MusicBrainz::Server::Validation::IsNonNegInteger($response[0]) || $response[0] < 200 || $response[0] > 299)
    {
        lprint "freedb", "FreeDB $remote:$port does not want to talk to us: $line";
        close $sock;
        return undef;
    }

    # Send the hello string
    $line = "cddb hello obs www.musicbrainz.org FreeDBGateway 1.0";
    lprint "freedb", ">> $line";
    print $sock $line, $CRLF;

    $line = <$sock>;
    lprint "freedb", "<< $line";

    @response = split ' ', $line;
    if ($response[0] < 200 || $response[0] > 299)
    {
        lprint "freedb", "FreeDB $remote:$port does not like our hello: $line";
        return undef;
    }

    # Select the required protocol
    $line = "proto " . FREEDB_PROTOCOL;
    lprint "freedb", ">> $line";
    print $sock $line, $CRLF;

    $line = <$sock>;
    lprint "freedb", "<< $line";

    # Expect 201 (OK, changed) or 502 (already using that protocol)
    unless ($line =~ /^(201|502) /)
    {
        lprint "freedb", "FreeDB $remote:$port failed to switch to protocol ".FREEDB_PROTOCOL.": $line";
        return undef;
    }

    goto READQUERY if $query =~ /^cddb read /;

    # Send the query 
    lprint "freedb", ">> $query";
    print $sock $query, $CRLF;

    $line = <$sock>;
    lprint "freedb", "<< $line";

    @response = split ' ', $line;
    if ($response[0] == 202)
    {
        #print STDERR "FreeDB $remote:$port cannot find this CD ($query)\n";
        return undef;
    }
    if ($response[0] < 200 || $response[0] > 299)
    {
        lprint "freedb", "FreeDB $remote:$port encountered an error: $line";
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
    # Do we have more than one match?  Just use the first match.
    #
    elsif ($response[0] == 210 or $response[0] == 211)
    {
        my (@categories, @disc_ids);

        for (my $i = 1; ; $i++)
        {
            $line = <$sock>;
	    lprint "freedb", "<< $line";

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

    # FIXME lots of undef warnings coming from here
    $query = "cddb read $category $disc_id";
   
READQUERY:
    lprint "freedb", ">> $query";
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
	lprint "freedb", "<< $line";
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
                ($artist, $temp) = split ' \/ ', $parts[1], 2
		    or
                ($artist, $temp) = split '\/', $parts[1], 2;
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
    lprint "freedb", "<< (EOF)";

    $artist =~ s/^\s*(.*?)\s*$/$1/ if defined $artist;
    $title =~ s/^\s*(.*?)\s*$/$1/ if defined $title;

    if (!defined $title || $title eq "")
    {
        $title = $artist;
    }

    $info{artist} = $info{sortname} = $artist;
    $info{album} = $title;

    require Style;
    $title = Style->new->NormalizeDiscNumbers($title);

    my @tracks;

    for (my $i = 0; $i < scalar(@track_titles); $i++)
    {
        #print("[$i]: $track_titles[$i]\n"); 

	my $t = $track_titles[$i];
        push @tracks, { track=>$t, tracknum => ($i+1) };
    }

    $info{tracks} = \@tracks;

    close $sock;

    $info{freedbid} = $disc_id;
    $info{freedbcat} = $category;

    return \%info;
}

# Public.  Called by MusicBrainz::Server::AlbumCDTOC->GenerateAlbumFromDiscid

sub InsertForModeration
{
    my ($this, $info) = @_;
    my ($new, $track, $in, $u, $st, $ar, $alias, $aliasid);
    my $ref = $info->{tracks};

    # Don't insert CDs that have only a few tracks
    return if (scalar(@$ref) < AUTO_INSERT_MIN_TRACKS);

    # Don't insert into the DB if the Toc is not correct.
    require MusicBrainz::Server::CDTOC;
    return unless MusicBrainz::Server::CDTOC->ParseTOC($info->{toc});

    # Don't insert albums by the name of 'various' or 'various artists'
    return if ($info->{artist} =~ /^various$/i ||
               $info->{artist} =~ /^various artists$/i); 

    # or anything which looks like it might be a VA album
    {
	my @names = map { $_->{track} } @{ $info->{tracks} };
	return if (grep m/ - /, @names) >= @names * 0.7;
	return if (grep m/ \/ /, @names) >= @names * 0.7;
	return if (grep m/-/, @names) >= @names * 0.85;
	return if (grep m/\//, @names) >= @names * 0.85;
    }

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

    my $artists = $ar->GetArtistsFromName($info->{artist});
    $artists = $ar->GetArtistsFromSortname($info->{artist}) if (!scalar(@$artists));
    if (scalar(@$artists))
    {
        my (@albums, $al);

        # Just pick the first artist -- this is probably not the smartest thing to do, but
        # this feature has been disabled, so it shouldn't be too big of a problem.
	$ar = $$artists[0];

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
		    return unless AUTO_ADD_DISCID;
		    return if $al->IsNonAlbumTracks;

		    require Sql;
                    my $sql = Sql->new($this->{DBH});

		    my $ret = eval {
                        $sql->Begin();
			require Moderation;
			my @mods = Moderation->InsertModeration(
			    DBH	=> $this->{DBH},
			    uid	=> FREEDB_MODERATOR,
			    privs => 0,
			    type => &ModDefs::MOD_ADD_DISCID,
			    # --
			    album => $al,
			    toc => $info->{toc},
			);
			$sql->Commit;
			\@mods;
		    };

                    if ($@)
                    {
                        # if it didn't insert properly... oh well.
			my $err = $@;
                        $sql->Rollback();
			warn "FreeDB MOD_ADD_DISCID failed: $err\n";
                    }
                    return;
                }
            }
        }
    }

    return unless AUTO_ADD_ALBUM;

    $new = "Artist=$info->{artist}\n";
    $new .= "Sortname=$info->{sortname}\n";
    $new .= "AlbumName=$info->{album}\n";
    $new .= "NumTracks=" . scalar(@$ref) . "\n";
    $new .= "CDIndexId=$info->{cdindexid}\n";
    $new .= "TOC=$info->{toc}\n";
    $new .= "FreedbId=$info->{freedbid}\n" if $info->{freedbid};
    $new .= "FreedbCat=$info->{freedbcat}\n" if $info->{freedbcat};

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

    # returns ($artistid, $albumid, $mods);
    $in->InsertAlbumModeration($new, FREEDB_MODERATOR, 0);
}

# Given the TOC offsets (track 1 start, track 2 start, ... track n start,
# leadout start), return the 8-character FreeDB ID.
# Marked as internal, but called from MusicBrainz::Server::CDTOC->ParseTOC.

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
