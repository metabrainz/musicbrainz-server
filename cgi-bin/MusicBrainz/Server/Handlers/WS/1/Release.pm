#!/usr/bin/perl -w
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
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );
use MusicBrainz::Server::CDTOC;

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
		return bad_req($r, "Invalid inc options: '$bad'.");
	}
    my $type = $args{type};
    if (!defined($type) || $type ne 'xml')
    {
		return bad_req($r, "Invalid content type. Must be set to xml.");
	}
    if ($inc & INC_RELEASES)
    {
		return bad_req($r, "Invalid inc options: 'releases'.");
	}

    # Check for collection arguments
    my $cdid = $args{discid};
    if ($cdid && length($cdid) != MusicBrainz::Server::CDTOC::CDINDEX_ID_LENGTH)
    {
		return bad_req($r, "Invalid cdindex id.");
	}

    my $artistid = $args{artistid};
    if ($artistid && !MusicBrainz::Server::Validation::IsGUID($artistid))
    {
        return bad_req($r, "Invalid artist id.");
    }
    if (!$mbid && !$cdid)
    {
        return bad_req($r, "Invalid collection URL -- collection URLs must end with /.")
            if (!($r->uri =~ /\/$/));

        my $title = $args{title} or "";
        my $artist = $args{artist} or "";
        my $release = $args{release} or "";
        my $query = $args{query} or "";
        my $offset = $args{offset} or 0;
        my ($info, $bad) = get_type_and_status_from_inc($args{releasetypes} or "");

        my $limit = $args{limit};
        $limit = 25 if ($limit < 1 || $limit > 100);
        my $count = $args{count} or 0;
        my $discids = $args{discids} or 0;
        my $date = $args{date} or "";
        my $asin = $args{asin} or "";
        my $lang = $args{lang} or 0;
        my $script = $args{script} or 0;

        $artist = "" if ($artistid);

		return bad_req($r, "Must specify a title OR query argument for release collections. Not both.") if ($title && $query);

		if (my $st = apply_rate_limit($r)) { return $st }

        return xml_search($r, {type=>'release', artist=>$artist, release=>$title, offset=>$offset,
                               artistid => $artistid, limit => $limit, releasetype => $info->{type}, 
                               releasestatus=> $info->{status}, count=> $count, discids=>$discids,
                               date => $date, asin=>$asin, lang=>$lang, script=>$script, query=>$query });
    }

	if (my $st = apply_rate_limit($r)) { return $st }

	my $user = get_user($r->user, $inc); 
	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid, $artistid, $cdid, $inc, $user);
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

	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid, $artistid, $cdid, $inc, $user) = @_;

	my $ar;
	my $al;
    my $is_coll = 0;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require MusicBrainz::Server::Release;

    my @albums;
	$al = MusicBrainz::Server::Release->new($mb->{DBH});
    if ($mbid)
    {
        $al->SetMBId($mbid);
        return undef unless $al->LoadFromId(1);
        push @albums, $al;
    }
    elsif ($cdid)
    {
        require MusicBrainz::Server::ReleaseCDTOC;

        $is_coll = 1;
        $inc = INC_ARTIST | INC_COUNTS | INC_RELEASEINFO;

        my $cd = MusicBrainz::Server::ReleaseCDTOC->new($mb->{DBH});
        my $albumids = $cd->GetReleaseIDsFromDiscID($cdid);
        if (scalar(@$albumids))
        {
            foreach my $id (@$albumids)
            {
                $al = MusicBrainz::Server::Release->new($mb->{DBH});
                $al->SetId($id);
                return undef unless $al->LoadFromId(1);
                push @albums, $al;
            }
        }
    }

    if (@albums && !$ar && $inc & INC_ARTIST || $inc & INC_TRACKS)
    {
        $ar = MusicBrainz::Server::Artist->new($mb->{DBH});
        $ar->SetId($al->GetArtist);
        $ar->LoadFromId();
    }

	my $printer = sub {
		print_xml($mbid, $ar, \@albums, $inc, $is_coll, $user);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub print_xml
{
	my ($mbid, $ar, $albums, $inc, $is_coll, $user) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#">';
    print '<release-list>' if (scalar(@$albums) > 1 || $is_coll);
    xml_release($ar, $_, $inc, undef, $is_coll, $user) foreach(@$albums);
    print '</release-list>' if (scalar(@$albums) > 1 || $is_coll);
	print '</metadata>';
}

1;
# eof Release.pm
