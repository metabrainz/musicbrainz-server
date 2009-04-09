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
#   $Id: Track.pm 10646 2008-11-06 23:36:26Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Track;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );

sub handler
{
    my ($c, $info) = @_;
    my $r = $c->req;

    # URLs are of the form:
    # GET http://server/ws/1/track or
    # GET http://server/ws/1/track/MBID or
    # POST http://server/ws/1/puid/?name=<user_name>&client=<client id>&puids=<trackid:puid+trackid:puid>

    return handler_post($r) if ($r->method eq "POST");

    my $mbid = $1 if ($r->path =~ /ws\/1\/track\/([a-z0-9-]*)/);
    my $inc = $info->{inc};

    return bad_req($c, "Cannot include track in inc options for a track query.") if ($inc & INC_TRACKS);

    my $type = $r->params->{type};
    if (!defined($type) || $type ne 'xml')
    {
        return bad_req($c, "Invalid content type. Must be set to xml.");
    }
    if ((!MusicBrainz::Server::Validation::IsGUID($mbid) && $mbid ne '') || $inc eq 'error')
    {
        return bad_req($c, "Incorrect URI.");
    }

    my $puid = $r->params->{puid};
    if ($puid && !MusicBrainz::Server::Validation::IsGUID($puid))
    {
        return bad_req($c, "Invalid puid.");
    }

    if (!$mbid && !$puid)
    {
        return bad_req($c, "Invalid collection URL -- collection URLs must end with /.")
            if (!($r->path =~ /\/$/));

        my $title = $r->params->{title} || "";
        my $query = $r->params->{query} || "";
        my $offset = $r->params->{offset} || 0;
        my $artist = $r->params->{artist} || "";
        my $release = $r->params->{release} || "";
        my $count = $r->params->{count} || 0;
        my $releasetype = $r->params->{releasetype} || -1;

        my $duration = $r->params->{duration} || 0;
        my $tnum = -1;
        $tnum = $r->params->{tracknumber} + 1 if (defined $r->params->{tracknumber} && $r->params->{tracknumber} =~ /^\d+$/);
        my $limit = $r->params->{limit};

        my $artistid = $r->params->{artistid};
        if ($artistid && !MusicBrainz::Server::Validation::IsGUID($artistid))
        {
            return bad_req($c, "Invalid artist id.");
        }
        $artist = "" if ($artistid);

        my $releaseid = $r->params->{releaseid};
        if ($releaseid && !MusicBrainz::Server::Validation::IsGUID($releaseid))
        {
            return bad_req($c, "Invalid release id.");
        }
        $release = "" if ($releaseid);

        if (my $st = apply_rate_limit($c)) { return $st }

        return xml_search($c, {type=>'track', track=>$title, artist=>$artist, release=>$release, 
                               artistid => $artistid, releaseid=>$releaseid, duration=>$duration,
                               tracknumber => $tnum, limit => $limit, count => $count, releasetype=>$releasetype, 
                               query=>$query, offset=>$offset});
    }

    if (my $st = apply_rate_limit($c)) { return $st }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db($c, $mbid, $puid, $inc);
            return $status if defined $status;
        }
        undef;
    };

    if ($@)
    {
        my $error = "$@";
        $c->log->warn("WS Error: $error\n");
        $c->response->status(RC_INTERNAL_SERVER_ERROR);
        $c->response->content_type("text/plain; charset=utf-8");
        $c->response->body($error."\015\012");
        return RC_INTERNAL_SERVER_ERROR;
    }
    if (!defined $status)
    {
        $c->response->status(RC_NOT_FOUND);
        return RC_NOT_FOUND;
    }

    return RC_OK;
}

sub serve_from_db
{
    my ($c, $mbid, $puid, $inc) = @_;

    # if this is a puid request, send it
    if ($puid)
    {
        my $printer = sub {
            xml_puid($puid);
        };

        send_response($c, $printer);
        return RC_OK;
    }

    my $ar;
    my $tr;

    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login;
    require MusicBrainz::Server::Track;

    $tr = MusicBrainz::Server::Track->new($mb->{dbh});
    $tr->mbid($mbid);
    return undef unless $tr->LoadFromId(1);

    if ($inc & INC_ARTIST || $inc & INC_RELEASES)
    {
        $ar = $tr->artist;
        $ar = undef unless $ar->LoadFromId(1);
    }

    my $printer = sub {
        print_xml($mbid, $inc, $ar, $tr, $c->user);
    };

    send_response($c, $printer);
    return RC_OK;
}

sub print_xml
{
    my ($mbid, $inc, $ar, $tr, $user) = @_;

    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    xml_track($ar, $tr, $inc, $user);
    print '</metadata>';
}

sub handler_post
{
    my $c = shift;

    # URLs are of the form:
    # http://server/ws/1/puid/?name=<user_name>&client=<client id>&puids=<trackid:puid+trackid:puid>

    my $name = $c->req->params->{name};
    my @pairs = $c->req->params->{puid};
    my $client = $c->req->params->{client};
    my @puids;

    foreach my $pair (@pairs)
    {
        my ($trackid, $puid) = split(' ', $pair);
        if (!MusicBrainz::Server::Validation::IsGUID($puid) || !MusicBrainz::Server::Validation::IsGUID($trackid))
        {
            $c->response->status(RC_BAD_REQUEST);
            return RC_BAD_REQUEST
        }
        push @puids, { puid => $puid, trackmbid => $trackid };
    }

    # We have to have a limit, I think.  It's only sensible.
    # So far I've not seen anyone submit more that about 4,500 PUIDs at once,
    # so this limit won't affect anyone in a hurry.
    if (scalar(@puids) > 5000)
    {
        $c->response->status(RC_BAD_REQUEST);
        return RC_BAD_REQUEST;
    }

    # Ensure that the login name is the same as the resource requested 
    if ($name ne $c->user->name)
    {
        $c->response->status(RC_FORBIDDEN);
        return RC_FORBIDDEN;
    }
    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE || $client eq '')
    {
        $c->response->status(RC_BAD_REQUEST);
        return RC_BAD_REQUEST
    }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db_post($c, $client, \@puids);
            return $status if defined $status;
        }
        undef;
    };

    if ($@)
    {
        my $error = "$@";
        print STDERR "WS Error: $error\n";
        $c->response->status(RC_INTERNAL_SERVER_ERROR);
        $c->response->content_type("text/plain; charset=utf-8");
        $c->response->body($error."\015\012");
        return RC_INTERNAL_SERVER_ERROR
    }
    if (!defined $status)
    {
        $c->response->status(RC_NOT_FOUND);
        return RC_NOT_FOUND;
    }

    return RC_OK;
}

sub serve_from_db_post
{
    my ($c, $client, $puids) = @_;

    my $printer = sub {
        print_xml_post($c->user, $client, $puids);
    };

    send_response($c, $printer);
    return RC_OK;
}

sub print_xml_post
{
    my ($user, $client, $links) = @_;

    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login(db => 'READWRITE');

    require Sql;
    my $sql = Sql->new($mb->{dbh});

    # Check each track and then then adjust the list to have the row id of the track
    require MusicBrainz::Server::Track;
    foreach my $pair (@$links)
    {
        my $tr = MusicBrainz::Server::Track->new($sql->{dbh});
        $tr->mbid($pair->{trackmbid});
        unless ($tr->LoadFromId)
        {
            print STDERR "Unknown MB Track Id: " . $pair->{trackmbid} . "\n";
        } 
        else 
        {
            $pair->{trackid} = $tr->id;
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
                    dbh => $mb->{dbh},
                    uid => $user->id,
                    privs => $user->privs,
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
            die("Cannot write PUIDs to database. Make sure you are submitting a valid list of TRACK ids.\n")
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
    my $sql = Sql->new($mb->{dbh});

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
    printf '<track-list count="%s">', scalar(@$rows);
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
