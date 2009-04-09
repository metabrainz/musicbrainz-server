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
#   $Id: Release.pm 10934 2008-12-05 19:30:16Z murdos $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Release;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );
use MusicBrainz::Server::CDTOC;
use MusicBrainz::Server::ReleaseCDTOC;

use constant SERVE_CRAP_FOR_THESE_MANY_DAYS => 14;

sub handler
{
    my ($c, $info) = @_;
    my $r = $c->req;

    # URLs are of the form:
    # GET  http://server/ws/1/release or
    # GET  http://server/ws/1/release/MBID 

    return handler_post($c) if ($r->method eq "POST");

    return bad_req($c, "Only GET/POST methods are acceptable")
        unless $r->method eq "GET";

    my $mbid = $1 if ($r->path =~ /ws\/1\/release\/([a-z0-9-]*)/);

    # Check general arguments
    my $inc = $info->{inc};
    return bad_req($c, "Cannot include release in inc options for a release query.") if ($inc & INC_RELEASES);
    
    my $type = $r->params->{type};
    if (!defined($type) || $type ne 'xml')
    {
        return bad_req($c, "Invalid content type. Must be set to xml.");
    }
    if ($inc & INC_RELEASES)
    {
        return bad_req($c, "Invalid inc options: 'releases'.");
    }

    # Check for collection arguments
    my $cdid = $r->params->{discid};
    if ($cdid && length($cdid) != MusicBrainz::Server::CDTOC::CDINDEX_ID_LENGTH)
    {
        return bad_req($c, "Invalid cdindex id.");
    }
    my $toc = $r->params->{toc};
    if ($toc)
    {
        my @info = MusicBrainz::Server::CDTOC::ParseTOC(undef, $toc);
        return bad_req($c, "Invalid cd toc.") if (scalar(@info) == 0);
    }

    my $artistid = $r->params->{artistid};
    if ($artistid && !MusicBrainz::Server::Validation::IsGUID($artistid))
    {
        return bad_req($c, "Invalid artist id.");
    }
    if (!$mbid && !$cdid)
    {
        return bad_req($c, "Invalid collection URL -- collection URLs must end with /.")
            if (!($r->path =~ /\/$/));

        my $title = $r->params->{title} || "";
        my $artist = $r->params->{artist} || "";
        my $release = $r->params->{release} || "";
        my $query = $r->params->{query} || "";
        my $offset = $r->params->{offset} || 0;
        my ($info, $bad) = parse_inc($r->params->{releasetypes} or "");

        my $limit = $r->params->{limit};
        $limit = 25 if ($limit < 1 || $limit > 100);
        my $count = $r->params->{count} || 0;
        my $discids = $r->params->{discids} || 0;
        my $date = $r->params->{date} || "";
        my $asin = $r->params->{asin} || "";
        my $lang = $r->params->{lang} || 0;
        my $script = $r->params->{script} || 0;

        $artist = "" if ($artistid);

        if (my $st = apply_rate_limit($c)) { return $st }

        return xml_search($c, {type=>'release', artist=>$artist, release=>$title, offset=>$offset,
                               artistid => $artistid, limit => $limit, releasetype => $info->{type}, 
                               releasestatus=> $info->{status}, count=> $count, discids=>$discids,
                               date => $date, asin=>$asin, lang=>$lang, script=>$script, query=>$query });
    }

    if (my $st = apply_rate_limit($c)) { return $st }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db($c, $mbid, $artistid, $cdid, $toc, $inc);
            return $status if defined $status;
        }
        undef;
    };

    if ($@)
    {
        my $error = "$@";
        $c->log->warn("WS Error: $error\n");
        $c->response->status(RC_INTERNAL_SERVER_ERROR);
        return RC_INTERNAL_SERVER_ERROR;
    }
    if (!defined $status)
    {
        $c->response->status(RC_NOT_FOUND);
        return RC_NOT_FOUND;
    }

    return RC_OK;
}

sub handler_post
{
    my $c = shift;

    # URLs are of the form:
    # POST http://server/ws/1/release/?client=<client>&title=<title>&artist=<sa-artist>&toc=<toc>&discid=<discid>&barcode=<barcode>&comment=<comment>&track0=<track1>&track1=<track1>...
    # POST http://server/ws/1/release/?client=<client>&title=<title>&toc=<toc>&discid=<discid>&barcode=<barcode>&comment=<comment>&track0=<track0>&artist0=<artist1>&track1=<track1>...

    my $title = $c->req->params->{title};
    my $discid = $c->req->params->{discid};
    my $toc = $c->req->params->{toc};
    my $barcode = $c->req->params->{barcode};
    my $comment = $c->req->params->{comment};
    my $client = $c->req->params->{client};

    if (!defined($client) || $client eq '')
    {
        return bad_req($c, "You must provide a client id in order to submit CD Stubs.");
    }

    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
    {
        return bad_req($c, "You cannot submit cd stubs to a slave server.");
    }

    my (@artists, @tracks);
    my ($tmp, $num);;
    my $artist = $c->req->params->{artist};

    $num = 0;
    for(0..98)
    {
        $tmp = $c->req->params->{"track$_"};
        $tmp =~ s/^\s*?(.*?)\s*$/$1/;
        last if (!$tmp);

        my $data = { title => $tmp };
        $num++;

        $tmp = $c->req->params->{"artist$_"};
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
        $c->log->warn("WS Error: $check{discid} does not match provided discid\n");
        return bad_req($c, "Incorrect discid provided for toc.");
    }

    if ($check{lasttrack} != $num)
    {
        return bad_req($c, "Number of tracks provided and tracks in TOC do not match.");
    }

    if (my $st = apply_rate_limit($c)) { return $st }

    my $mb = MusicBrainz->new;
    $mb->Login;

    my $rcdtoc = MusicBrainz::Server::ReleaseCDTOC->new($mb->{dbh});
    my $releaseids = $rcdtoc->release_ids_from_discid($discid);
    if (scalar(@$releaseids))
    {
        return bad_req($c, "A MusicBrainz release already exists with this discid.");

    }

    $mb->Logout;
    $mb->Login(db => "RAWDATA");

    require MusicBrainz::Server::CDStub;
    my $rc = MusicBrainz::Server::CDStub->new($mb->{dbh});
    my $cd = $rc->Lookup($discid);
    if ($cd)
    {
        return bad_req($c, "This CD Stub already exists.");
    }
    $cd = {};
    $cd->{title} = $title;
    $cd->{tracks} = \@tracks;
    $cd->{discid} = $discid;
    $cd->{toc} = $toc;
    $cd->{barcode} = $barcode;
    $cd->{comment} = $comment;
    $cd->{artist} = $artist;

    my $error = $rc->Insert($cd);
    if ($error)
    {
        return bad_req($c, $error);
    }

    my $printer = sub {
        print '<?xml version="1.0" encoding="UTF-8"?>';
        print '<metadata/>';
    };

    send_response($c, $printer);
    return RC_OK;
}

sub serve_from_db
{
    my ($c, $mbid, $artistid, $cdid, $toc, $inc) = @_;

    my $ar;
    my $al;
    my $is_coll = 0;

    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login;
    require MusicBrainz::Server::Release;

    my @releases;
    my $cdstub;
    $al = MusicBrainz::Server::Release->new($mb->{dbh});
    if ($mbid)
    {
        $al->mbid($mbid);
        return undef unless $al->LoadFromId(1);
        push @releases, $al;
    }
    elsif ($cdid)
    {
        require MusicBrainz::Server::ReleaseCDTOC;

        $is_coll = 1;
        $inc = INC_ARTIST | INC_COUNTS | INC_RELEASEINFO | INC_TRACKS;

        my $cd = MusicBrainz::Server::ReleaseCDTOC->new($mb->{dbh});
        my $releaseids = $cd->GetReleaseIDsFromDiscID($cdid);
        if (scalar(@$releaseids))
        {
            foreach my $id (@$releaseids)
            {
                $al = MusicBrainz::Server::Release->new($mb->{dbh});
                $al->id($id);
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
            my $rc = MusicBrainz::Server::CDStub->new($raw->{dbh});
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
        $ar = MusicBrainz::Server::Artist->new($mb->{dbh});
        my $rr = $al->artist;
        $ar->id($al->artist);
        $ar->LoadFromId();
    }

    my $printer = sub {
        print_xml($mbid, $ar, \@releases, $inc, $is_coll, $cdstub, $c->user);
    };

    send_response($c, $printer);
    return RC_OK;
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
        xml_release($ar, $_, $inc, undef, $is_coll, $user) foreach(@$releases);
    }
    print '</release-list>' if (scalar(@$releases) > 1 || $is_coll);
    print '</metadata>';
}

1;
# eof Release.pm
