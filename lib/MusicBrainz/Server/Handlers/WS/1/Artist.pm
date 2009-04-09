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
#   $Id: Artist.pm 10557 2008-10-26 18:00:52Z murdos $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Artist;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use MusicBrainz::Server::Handlers::WS::1::Common qw( :DEFAULT apply_rate_limit );

sub handler
{
    my ($c, $info) = @_;
    my $r = $c->req;

    # URLs are of the form:
    # http://server/ws/1/artist or
    # http://server/ws/1/artist/MBID 

    return bad_req($c, "Only GET is acceptable")
        unless $r->method eq "GET";

    my $mbid = $1 if ($r->path =~ /ws\/1\/artist\/([a-z0-9-]*)/);
    my $inc = $info->{inc};

    return bad_req($c, "Cannot include artist in inc options for an artist query.") if ($inc & INC_ARTIST);

    my $type = $r->params->{type};
    if (!defined($type) || $type ne 'xml')
    {
        return bad_req($c, "Invalid content type. Must be set to xml.");
    }
    if ((!MusicBrainz::Server::Validation::IsGUID($mbid) && $mbid ne ''))
    {
        return bad_req($c, "Incorrect URI.");
    }
    if ($inc & INC_TRACKS)
    {
        return bad_req($c, "Cannot use track parameter for artist resources.");
    }
    if (!$mbid)
    {
        return bad_req($c, "Invalid collection URL -- collection URLs must end with /.")
            if (!($r->path =~ /\/$/));

        my $query = $r->params->{query} || "";
        my $name = $r->params->{name} || "";
        my $limit = $r->params->{limit};
        my $offset = $r->params->{offset} or 0;

        if (my $st = apply_rate_limit($c)) { return $st }
        return xml_search($c, { type => 'artist', artist => $name, limit => $limit, query=>$query, offset=>$offset });
    }

    if (my $st = apply_rate_limit($c)) { return $st }

    my $status = eval {
        # Try to serve the request from the database
        {
            my $status = serve_from_db($c, $mbid, $inc, $info);
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
    my ($c, $mbid, $inc, $info) = @_;

    my $ar;
    my $al;

    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login;
    require MusicBrainz::Server::Artist;

    $ar = MusicBrainz::Server::Artist->new($mb->{dbh});
    $ar->mbid($mbid);
    return undef unless $ar->LoadFromId(1);

    if ($inc & INC_ALIASES)
    {
        require MusicBrainz::Server::Alias;
        my $alias = MusicBrainz::Server::Alias->new($mb->{dbh}, "ArtistAlias");
        my @list = $alias->load_all($ar->id);
        $info->{aliases} = \@list;  
    }

    my $printer = sub {
        print_xml($mbid, $inc, $ar, $info, $c->user);
    };

    send_response($c, $printer);
    return RC_OK;
}

sub print_xml
{
    my ($mbid, $inc, $ar, $info, $user) = @_;

    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    xml_artist($ar, $inc, $info, $user);
    print '</metadata>';
}

1;
# eof Artist.pm
