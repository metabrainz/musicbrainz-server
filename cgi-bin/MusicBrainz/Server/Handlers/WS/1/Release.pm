#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

package MusicBrainz::Server::Handlers::WS::1::Release;

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common;

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# http://server/ws/1/release or
	# http://server/ws/1/release/MBID 

	return bad_req($r, "Only GET is acceptable")
		unless $r->method eq "GET";

    my $mbid = $1 if ($r->uri =~ /ws\/1\/release\/([a-z0-9-]*)/);

    # Check general arguments
	my %args; { no warnings; %args = $r->args };
    my ($inc, $bad) = convert_inc($args{inc});
    if ($bad)
    {
		return bad_req($r, "Invalid inc options: '$bad'. For usage, please see: http://musicbrainz.org/development/mmd");
	}
    my $type = $args{type};
    if (!defined($type) || $type ne 'xml')
    {
		return bad_req($r, "Invalid content type. Must be set to xml.");
	}
    if ($inc & INC_RELEASES)
    {
		return bad_req($r, "Invalid inc options: 'releases'. For usage, please see: http://musicbrainz.org/development/mmd");
	}

    # Check for collection arguments
    my $cdid = $args{discid};
    if ($cdid && length($cdid) != MusicBrainz::Server::CDTOC::CDINDEX_ID_LENGTH)
    {
		return bad_req($r, "Invalid cdindex id. For usage, please see: http://musicbrainz.org/development/mmd");
	}

    my $status;
    my $types = $args{releasetypes};
    if (!$mbid)
    {
        $types = "Album Official" if (!$types);
        ($types, $status, $bad) = convert_types($types);
        if ($bad || $types < 0 || $status < 0)
        {
            return bad_req($r, "Invalid releasetype options: '$bad'. For usage, please see: http://musicbrainz.org/development/mmd");
        }
    }

    my $artistid = $args{artistid};
    if ($artistid && !MusicBrainz::IsGUID($artistid))
    {
        return bad_req($r, "Invalid artist id. For usage, please see: http://musicbrainz.org/development/mmd");
    }
    if (!$mbid && !$cdid)
    {
        my $title = $args{title} or "";
		return bad_req($r, "Must specify a title argument for release collections.") if (!$title);

        my $artist = $args{artist} or "";
        my $release = $args{release} or "";
        my $limit = $args{limit};
        $limit = 25 if ($limit < 1 || $limit > 25);

        $artist = "" if ($artistid);

        return xml_search($r, {type=>'release', artist=>$artist, release=>$title, 
                               artistid => $artistid, limit => $limit});
    }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid, $artistid, $cdid, $inc, $types, $status);
			return $status if defined $status;
		}
        undef;
	};

	if ($@)
	{
		my $error = "$@";
        print STDERR "WS Error: $error\n";
        # TODO: We should print a custom 500 server error screen with details about our error and where to report it
		$r->status(Apache::Constants::SERVER_ERROR());
		return Apache::Constants::SERVER_ERROR();
	}
    if (!defined $status)
    {
        $r->status(Apache::Constants::NOT_FOUND());
        return Apache::Constants::NOT_FOUND();
    }

    $r->status(Apache::Constants::OK());
	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid, $artistid, $cdid, $inc, $types, $status) = @_;

	my $ar;
	my $al;
    my $is_coll = 0;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require Album;

    my @albums;
	$al = Album->new($mb->{DBH});
    if ($mbid)
    {
        $al->SetMBId($mbid);
        return undef unless $al->LoadFromId(1);
        push @albums, $al;
    }
    elsif ($cdid)
    {
        require MusicBrainz::Server::AlbumCDTOC;

        my $cd = MusicBrainz::Server::AlbumCDTOC->new($mb->{DBH});
        my $albumids = $cd->GetAlbumIDsFromDiscID($cdid);
        if (scalar(@$albumids))
        {
            foreach my $id (@$albumids)
            {
                $al = Album->new($mb->{DBH});
                $al->SetId($id);
                return undef unless $al->LoadFromId(1);
                my ($t, $s) = $al->GetReleaseTypeAndStatus();
                push @albums, $al if ($types == $t && $s == $status);
            }
        }
    }
    elsif ($artistid)
    {
        $ar = Artist->new($mb->{DBH});
        $ar->SetMBId($artistid);
        return undef unless $ar->LoadFromId();

        my @albumlist = $ar->GetAlbums(0, 1, 0);
        if (scalar(@albumlist))
        {
            foreach $al (@albumlist)
            {
                my ($t, $s) = $al->GetReleaseTypeAndStatus();
                push @albums, $al if ($types == $t && $s == $status);
            }
        }
    }

    if (!$ar && $inc & INC_ARTIST || $inc & INC_TRACKS)
    {
        $ar = Artist->new($mb->{DBH});
        $ar->SetId($al->GetArtist);
        $ar->LoadFromId();
    }

	my $printer = sub {
		print_xml($mbid, $ar, \@albums, $inc);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub print_xml
{
	my ($mbid, $ar, $albums, $inc, $is_coll) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print '<release-list>' if (scalar(@$albums));
    xml_release($ar, $_, $inc) foreach(@$albums);
    print '</release-list>' if (scalar(@$albums));
	print '</metadata>';
}

1;
# eof Release.pm
