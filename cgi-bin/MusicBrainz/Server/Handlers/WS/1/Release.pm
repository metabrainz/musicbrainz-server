#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#	MusicBrainz -- the open internet music database
#
#	Copyright (C) 2004 Robert Kaye
#
#	This program is free software; you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation; either version 2 of the License, or
#	(at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#	$Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Release;

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );
use MusicBrainz::Server::CDTOC;
use MusicBrainz::Server::ReleaseCDTOC;

use Data::Dumper;

use constant SERVE_CRAP_FOR_THESE_MANY_DAYS => 14;

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# GET  http://server/ws/1/release or
	# GET  http://server/ws/1/release/MBID 

	return handler_post($r) if ($r->method eq "POST");

	return bad_req($r, "Only GET/POST methods are acceptable")
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
	my $toc = $args{toc};
	if ($toc)
	{
		my @info = MusicBrainz::Server::CDTOC::ParseTOC(undef, $toc);
		return bad_req($r, "Invalid cd toc.") if (scalar(@info) == 0);
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
			my $status = serve_from_db($r, $mbid, $artistid, $cdid, $toc, $inc, $user);
			return $status if defined $status;
		}
		undef;
	};

	if ($@)
	{
		my $error = "$@";
		print STDERR "WS Error: $error\n";
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

sub handler_post
{
	my $r = shift;

	# URLs are of the form:
	# POST http://server/ws/1/release/?type=xml&client=<client>&title=<title>&artist=<sa-artist>&toc=<toc>&track0=<track1>&track1=<track1>...
	# POST http://server/ws/1/release/?type=xml&client=<client>&title=<title>&toc=<toc>&track0=<track0>&artist0=<artist1>&track1=<track1>...

	my $apr = Apache::Request->new($r);
	my $title = $apr->param('title');
	my $discid = $apr->param('discid');
	my $toc = $apr->param('toc');
    my $client = $apr->param('client');

	if (!defined($client) || $client eq '')
	{
		return bad_req($r, "You must provide a client id in order to submit Raw CDs.");
	}

	# Ensure that we're not a replicated server and that we were given a client version
	if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
	{
		return bad_req($r, "You cannot submit raw cds to a slave server.");
	}

	my (@artists, @tracks);
	my ($tmp, $num);;
	my $artist = $apr->param('artist');

	$num = 0;
	for(0..98)
	{
		$tmp = $apr->param("track$_");
		$tmp =~ s/^\s*?(.*?)\s*$/$1/;
		last if (!$tmp);

		my $data = { title => $tmp };
		$num++;

		$tmp = $apr->param("artist$_");
		if ($tmp)
		{
			$tmp =~ s/^\s*?(.*?)\s*$/$1/;
			$data->{artist} = $tmp;
		}

		push @tracks, $data;
	}

	require MusicBrainz::Server::CDTOC;
	my %check = MusicBrainz::Server::CDTOC::ParseTOC(undef, $toc);
	if ($check{discid} ne $discid)
	{
		print STDERR "$check{discid} does not match provided discid\n";
		return bad_req($r, "Incorrect discid provided for toc.");
	}

	if ($check{lasttrack} != $num)
	{
		return bad_req($r, "Number of tracks provided and tracks in TOC do not match.");
	}

	if (my $st = apply_rate_limit($r)) { return $st }

	require MusicBrainz::Server::CDStub;
	my $mb = MusicBrainz->new;
	$mb->Login(db => "RAWDATA");

	my $rc = MusicBrainz::Server::CDStub->new($mb->{DBH});
	my $cd = $rc->Lookup($discid);
	if ($cd)
	{
		return bad_req($r, "This Raw CD already exists.");
	}
	$cd = {};
	$cd->{title} = $title;
	$cd->{tracks} = \@tracks;
	$cd->{discid} = $discid;
	$cd->{toc} = $toc;
	$cd->{artist} = $artist;

	my $error = $rc->Insert($cd);
	if ($error)
	{
		return bad_req($r, $error);
	}

	my $printer = sub {
		print '<?xml version="1.0" encoding="UTF-8"?>';
		print '<metadata/>';
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid, $artistid, $cdid, $toc, $inc, $user) = @_;

	my $ar;
	my $al;
	my $is_coll = 0;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require MusicBrainz::Server::Release;

	my @releases;
	my $cdstub;
	$al = MusicBrainz::Server::Release->new($mb->{DBH});
    if ($mbid)
    {
        $al->SetMBId($mbid);
        return undef unless $al->LoadFromId(1);
        push @releases, $al;
    }
    elsif ($cdid)
    {
        require MusicBrainz::Server::ReleaseCDTOC;

		$is_coll = 1;
		$inc = INC_ARTIST | INC_COUNTS | INC_RELEASEINFO | INC_TRACKS;

        my $cd = MusicBrainz::Server::ReleaseCDTOC->new($mb->{DBH});
		my $releaseids = $cd->GetReleaseIDsFromDiscID($cdid, $toc);
		if (scalar(@$releaseids))
		{
			foreach my $id (@$releaseids)
			{
				$al = MusicBrainz::Server::Release->new($mb->{DBH});
				$al->SetId($id);
				return undef unless $al->LoadFromId(1);
				push @releases, $al;
			}
		}
		else
		{
			# See if the have the CD in the CDStub store
			my $raw = MusicBrainz->new;
			$raw->Login(db => 'RAWDATA');
			require MusicBrainz::Server::CDStub;
			my $rc = MusicBrainz::Server::CDStub->new($raw->{DBH});
			$cdstub = $rc->Lookup($cdid);
			$rc->IncrementLookupCount($cdstub->{id}) if $cdstub;
			if (!$cdstub || $cdstub->{age} > SERVE_CRAP_FOR_THESE_MANY_DAYS)
			{
				$cdstub = undef;
			}
		}
	}
    if (@releases && !$ar && !$cdstub && ($inc & INC_ARTIST || $inc & INC_TRACKS))
    {
        $ar = MusicBrainz::Server::Artist->new($mb->{DBH});
        $ar->SetId($al->GetArtist);
        $ar->LoadFromId();
    }

	my $printer = sub {
		print_xml($mbid, $ar, \@releases, $inc, $is_coll, $cdstub, $user);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub print_xml
{
	my ($mbid, $ar, $releases, $inc, $is_coll, $cd, $user) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#" xmlns:ext="http://musicbrainz.org/ns/ext-1.0#">';
	print '<release-list>' if (scalar(@$releases) > 1 || $is_coll);
	if ($cd)
	{
		xml_cdstub($cd);
	}
	else
	{
		xml_release($ar, $_, $inc, undef, $is_coll) foreach(@$releases);
	}
	print '</release-list>' if (scalar(@$releases) > 1 || $is_coll);
	print '</metadata>';
}

1;
# eof Release.pm
