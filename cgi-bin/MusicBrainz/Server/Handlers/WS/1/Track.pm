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

package MusicBrainz::Server::Handlers::WS::1::Track;

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );
use Apache::Constants qw( OK BAD_REQUEST DECLINED SERVER_ERROR NOT_FOUND FORBIDDEN);

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# GET http://server/ws/1/track or
	# GET http://server/ws/1/track/MBID or
	# POST http://server/ws/1/puid/?name=<user_name>&client=<client id>&puids=<trackid:puid+trackid:puid>

    return handler_post($r) if ($r->method eq "POST");

    my $mbid = $1 if ($r->uri =~ /ws\/1\/track\/([a-z0-9-]*)/);

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
	if ((!MusicBrainz::Server::Validation::IsGUID($mbid) && $mbid ne '') || $inc eq 'error')
	{
		return bad_req($r, "Incorrect URI.");
	}

    my $puid = $args{puid};
	if ($puid && !MusicBrainz::Server::Validation::IsGUID($puid))
	{
		return bad_req($r, "Invalid puid.");
	}

    if (!$mbid && !$puid)
    {
        return bad_req($r, "Invalid collection URL -- collection URLs must end with /.")
            if (!($r->uri =~ /\/$/));

        my $title = $args{title} or "";
        my $query = $args{query} or "";
        my $offset = $args{offset} or 0;
        my $artist = $args{artist} or "";
        my $release = $args{release} or "";
        my $count = $args{count} or 0;
        my $releasetype = $args{releasetype} or -1;

        my $duration = $args{duration} or 0;
        my $tnum = -1;
        $tnum = $args{tracknumber} + 1 if ($args{tracknumber} =~ /^\d+$/);
        my $limit = $args{limit};
        $limit = 25 if ($limit < 1 || $limit > 100);

        my $artistid = $args{artistid};
        if ($artistid && !MusicBrainz::Server::Validation::IsGUID($artistid))
        {
            return bad_req($r, "Invalid artist id.");
        }
        $artist = "" if ($artistid);

        my $releaseid = $args{releaseid};
        if ($releaseid && !MusicBrainz::Server::Validation::IsGUID($releaseid))
        {
            return bad_req($r, "Invalid release id.");
        }
        $release = "" if ($releaseid);

		if (my $st = apply_rate_limit($r)) { return $st }

        return xml_search($r, {type=>'track', track=>$title, artist=>$artist, release=>$release, 
                               artistid => $artistid, releaseid=>$releaseid, duration=>$duration,
                               tracknumber => $tnum, limit => $limit, count => $count, releasetype=>$releasetype, 
                               query=>$query, offset=>$offset});
    }

	if (my $st = apply_rate_limit($r)) { return $st }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid, $puid, $inc);
			return $status if defined $status;
		}
        undef;
	};

	if ($@)
	{
		my $error = "$@";
        print STDERR "WS Error: $error\n";
		$r->status(Apache::Constants::SERVER_ERROR());
		$r->send_http_header("text/plain; charset=utf-8");
		$r->print($error."\015\012") unless $r->header_only;
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
	my ($r, $mbid, $puid, $inc) = @_;

    # if this is a puid request, send it
    if ($puid)
    {
        my $printer = sub {
            xml_puid($puid);
        };

        send_response($r, $printer);
        return Apache::Constants::OK();
    }

	my $ar;
	my $tr;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require MusicBrainz::Server::Track;

	$tr = MusicBrainz::Server::Track->new($mb->{DBH});
    $tr->SetMBId($mbid);
	return undef unless $tr->LoadFromId(1);

    if ($inc & INC_ARTIST || $inc & INC_RELEASES)
    {
        $ar = MusicBrainz::Server::Artist->new($mb->{DBH});
        $ar->SetId($tr->GetArtist);
        $ar = undef unless $ar->LoadFromId(1);
    }

	my $user = get_user($r->user, $inc); 
	my $printer = sub {
		print_xml($mbid, $inc, $ar, $tr, $user);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
}

sub print_xml
{
	my ($mbid, $inc, $ar, $tr, $user) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print xml_track($ar, $tr, $inc, $user);
	print '</metadata>';
}

sub handler_post
{
    my $r = shift;

	# URLs are of the form:
	# http://server/ws/1/puid/?name=<user_name>&client=<client id>&puids=<trackid:puid+trackid:puid>

    my $apr = Apache::Request->new($r);
    my $user = $r->user;
    my @pairs = $apr->param('puid');
    my $client = $apr->param('client');
    my @puids;

    foreach my $pair (@pairs)
    {
        my ($trackid, $puid) = split(' ', $pair);
        if (!MusicBrainz::Server::Validation::IsGUID($puid) || !MusicBrainz::Server::Validation::IsGUID($trackid))
        {
            $r->status(BAD_REQUEST);
            return BAD_REQUEST;
        }
        push @puids, { puid => $puid, trackmbid => $trackid };
    }

    # We have to have a limit, I think.  It's only sensible.
    # So far I've not seen anyone submit more that about 4,500 PUIDs at once,
    # so this limit won't affect anyone in a hurry.
    if (scalar(@puids) > 5000)
    {
		$r->status(DECLINED);
        return DECLINED;
    }

    # Ensure that the login name is the same as the resource requested 
    if ($r->user ne $user)
    {
		$r->status(FORBIDDEN);
        return FORBIDDEN;
    }
    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE || $client eq '')
    {
		$r->status(BAD_REQUEST);
        return BAD_REQUEST;
    }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db_post($r, $user, $client, \@puids);
			return $status if defined $status;
		}
        undef;
	};

	if ($@)
	{
		my $error = "$@";
        print STDERR "WS Error: $error\n";
		$r->status(SERVER_ERROR);
		$r->content_type("text/plain; charset=utf-8");
		$r->print($error."\015\012") unless $r->header_only;
		return SERVER_ERROR;
	}
    if (!defined $status)
    {
        $r->status(NOT_FOUND);
        return NOT_FOUND;
    }

	return OK;
}

sub serve_from_db_post
{
	my ($r, $user, $client, $puids) = @_;

	my $printer = sub {
		print_xml_post($user, $client, $puids);
	};

	send_response($r, $printer);
	return OK();
}

sub print_xml_post
{
	my ($user, $client, $links) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login(db => 'READWRITE');

    require UserStuff;
    my $us = UserStuff->new($mb->{DBH});
    $us = $us->newFromName($user) or die "Cannot load user.\n";

    require Sql;
    my $sql = Sql->new($mb->{DBH});

    # Check each track and then then adjust the list to have the row id of the track
    require MusicBrainz::Server::Track;
    foreach my $pair (@$links)
    {
        my $tr = MusicBrainz::Server::Track->new($sql->{DBH});
        $tr->SetMBId($pair->{trackmbid});
        unless ($tr->LoadFromId)
        {
            print STDERR "Unknown MB Track Id: " . $pair->{trackmbid} . "\n";
        } 
        else 
        {
            $pair->{trackid} = $tr->GetId;
        }
    }

    if (@$links)
    {
        eval
        {
            require Moderation;
            my @mods;

            # Break the list of PUIDs up into 100 PUIDs at a time.
            # This is so that each moderation is manageably small.
            while (@$links)
            {
                my @thistime;
                if (@$links > 100) { @thistime = splice(@$links, 0, 100) }
                else { @thistime = @$links; @$links = () }

                my @mods = Moderation->InsertModeration(
                    DBH => $mb->{DBH},
                    uid => $us->GetId,
                    privs => 0, # TODO
                    type => &ModDefs::MOD_ADD_PUIDS,
                    # --
                    client => $client,
                    links => \@thistime,
                );
            }
        };
        if ($@)
        {
            print STDERR "Cannot insert PUID: $@\n";
            die("Cannot write PUIDs to database.\n")
        }
    }

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>';
}

# This code is duplicated since it is THE MOST CALLED CODE IN ALL OF MUSICBRAINZ.
# Thus this is optimized to move as fast as possible. Thus everything has been flattened out.
sub xml_puid
{
	require MusicBrainz::Server::Track;
	my ($puid) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;

    require Sql;
    my $sql = Sql->new($mb->{DBH});

    my $rows = $sql->SelectListOfLists("SELECT t.gid, t.name, t.length, t.artist, j.sequence,
                                               a.gid, a.name, a.attributes, a.artist, ar.name, ar.gid, ar.sortname
                                        FROM   puid, puidjoin tj, track t, albumjoin j, album a, artist ar
                                        WHERE  puid.puid = ?
                                        AND    tj.puid = puid.id
                                        AND    t.id = tj.track
                                        AND    j.track = t.id
                                        AND    a.id = j.album
                                        AND    t.artist = ar.id
                                        LIMIT  100", $puid);
    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    if (!@$rows)
    {
        print "</metadata>";
        return;
    }
    print "<track-list>";
    for my $row (@$rows)
    {
        printf '<track id="%s"', $row->[0];
        print '><title>';
        print xml_escape($row->[1]);
        print '</title>';
        if ($row->[2])
        {
            print '<duration>';
            print $row->[2];
            print '</duration>';
        }
        printf '<artist id="%s"', $row->[10];
        print '><name>';
        print xml_escape($row->[9]);
        print '</name><sort-name>';
        print xml_escape($row->[11]);
        print '</sort-name></artist>';
        printf '<release-list><release id="%s"><title>', $row->[5];
        print xml_escape($row->[6]);
        printf '</title><track-list offset="%d"/>', ($row->[4]-1);
        print '</release></release-list>';
        print '</track>';
    }
    print "</track-list></metadata>";
}

1;
# eof Track.pm
