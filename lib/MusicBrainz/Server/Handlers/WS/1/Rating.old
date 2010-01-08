#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2007 Sharon Myrtle Paradesi
#   Copyright (C) 2008 Aurelien Mino
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
#   $Id: Track.pm 8966 2007-03-27 19:13:13Z luks $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::1::Rating;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use MusicBrainz::Server::Handlers::WS::1::Common;
use MusicBrainz::Server::Rating;

use constant MAX_RATINGS_PER_REQUEST => 20;

sub handler
{
    my ($c) = @_;
    my $r = $c->req;

    # URLs are of the form:
    # GET  http://server/ws/1/rating/?entity=<entity>&id=<id>
    # POST http://server/ws/1/rating/?entity=<entity>&id=<id>&rating=<rating>
    # POST http://server/ws/1/rating/?entity.0=<entity>&id.0=<mbid>&rating.0=<rating>&entity.1=<entity>&id.1=<mbid>&rating.1=<rating>..

    if ($r->method eq "POST")
    {
        my $entity = $r->params->{'entity.0'};
        return handler_post_multiple($c) if ($entity);
        return handler_post($c);
    }

    return bad_req($c, "Only GET or POST is acceptable")
        unless $r->method eq "GET";

    my $name = $r->params->{name};
    my $entity = $r->params->{entity};
    my $id = $r->params->{id};
    my $type = $r->params->{type};
    if (!defined($type) || $type ne 'xml')
    {
        return bad_req($c, "Invalid content type. Must be set to xml.");
    }

    if (!MusicBrainz::Server::Validation::IsGUID($id) || 
        ($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
    {
        return bad_req($c, "Invalid MBID/entity.");
    }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db($c, $entity, $id);
            return $status if defined $status;
        }
        undef;
    };

    if ($@)
    {
        my $error = "$@";
        $c->log->warn("WS Error: $error\n");
        $c->response->body("An error occurred while trying to handle this request. ($error)\r\n");
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
    my $r = $c->req;

    # URLs are of the form:
    # POST http://server/ws/1/rating/?name=<user_name>&entity=<entity>&id=<id>&rating=<rating>

    my $entity = $r->param('entity');
    my $id = $r->param('id');
    my $rating = $r->param('rating');

    if (!MusicBrainz::Server::Validation::IsGUID($id) || 
        ($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
    {
        return bad_req($c, "Invalid MBID/entity.");
    }

    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
    {
        return bad_req($c, "You cannot submit ratings to a slave server.");
    }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db_post($c, [{entity => $entity, id => $id, rating => $rating}]);
            return $status if defined $status;
        }
        undef;
    };

    if ($@)
    {
        my $error = "$@";
        print STDERR "WS Error: $error\n";
        $c->response->status(RC_INTERNAL_SERVER_ERROR);
        $r->content_type("text/plain; charset=utf-8");
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

# handle multiple entities per post
sub handler_post_multiple
{
    my $c = shift;
    my $r = $c->req;

    # URLs are of the form:
    # POST http://server/ws/1/rating/?entity.0=<entity>&id.0=<mbid>&rating.0=<rating>&entity.1=<entity>&id.1=<mbid>&rating.1=<rating>..

    my @batch;

    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
    {
        return bad_req($c, "You cannot submit ratings to a slave server.");
    }

    my ($entity, $id, $rating, $count);
    for($count = 0;; $count++)
    {
        my $entity = $r->params->{"entity.$count"};
        my $id = $r->params->{"id.$count"};
        my $rating = $r->params->{"rating.$count"};

        last if (not defined $entity || not defined $id || not defined $rating);

        if (!MusicBrainz::Server::Validation::IsGUID($id) || 
            ($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
        {
            return bad_req($c, "Invalid MBID/entity for set $count.");
        }
        push @batch, { entity => $entity, id => $id, rating => $rating };
    }
    if (!$count)
    {
        return bad_req($c, "No valid ratings were specified in this request.");
    }
    if ($count > MAX_RATINGS_PER_REQUEST)
    {
        return bad_req($c, "Too many ratings for one request. Max " . MAX_RATINGS_PER_REQUEST . " ratings per request.");
    }

    my $status = eval 
    {
        # Try to serve the request from the database
        {
            my $status = serve_from_db_post($c, \@batch);
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
    my ($c, $ratings) = @_;

    my $printer = sub {
        process_user_input($c, $ratings);
    };

    send_response($c, $printer);
    return RC_OK;
}

sub process_user_input
{
    my ($c, $ratings) = @_;

    require MusicBrainz;
    my $mb = MusicBrainz->new;
    $mb->Login();

    require Sql;
    my $sql = Sql->new($mb->{dbh});

    require MusicBrainz::Server::Artist;
    require MusicBrainz::Server::Release;
    require MusicBrainz::Server::Label;
    require MusicBrainz::Server::Track;

    my ($obj, $count);
    foreach my $rating (@{$ratings})
    {
        if ($rating->{entity} eq 'artist')
        {
            $obj = MusicBrainz::Server::Artist->new($sql->{dbh});
        }
        elsif ($rating->{entity} eq 'release')
        {
            $obj = MusicBrainz::Server::Release->new($sql->{dbh});
        }
        elsif ($rating->{entity} eq 'track')
        {
            $obj = MusicBrainz::Server::Track->new($sql->{dbh});
        }
        elsif ($rating->{entity} eq 'label')
        {
            $obj = MusicBrainz::Server::Label->new($sql->{dbh});
        }
        $obj->mbid($rating->{id});
        unless ($obj->LoadFromId)
        {
            return bad_req($c, "Cannot load " . $rating->{entity} . ' ' . $rating->{id} . ". Bad entity id given?");
        } 

        my $ratings = MusicBrainz::Server::Rating->new($mb->{dbh});
        $ratings->Update($rating->{entity}, $obj->id, $c->user->id, $rating->{rating});
    }

    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>';
}

sub serve_from_db
{
    my ($c, $entity_type, $entity_id) = @_;

    # Login to the main DB
    my $main = MusicBrainz->new;
    $main->Login();
    my $maindb = Sql->new($main->{dbh});

    require MusicBrainz::Server::Artist;
    require MusicBrainz::Server::Release;
    require MusicBrainz::Server::Label;
    require MusicBrainz::Server::Track;

    my $obj;
    if ($entity_type eq 'artist')
    {
        $obj = MusicBrainz::Server::Artist->new($maindb->{dbh});
    }
    elsif ($entity_type eq 'release')
    {
        $obj = MusicBrainz::Server::Release->new($maindb->{dbh});
    }
    elsif ($entity_type eq 'track')
    {
        $obj = MusicBrainz::Server::Track->new($maindb->{dbh});
    }
    elsif ($entity_type eq 'label')
    {
        $obj = MusicBrainz::Server::Label->new($maindb->{dbh});
    }
    $obj->mbid($entity_id);
    unless ($obj->LoadFromId)
    {
        return bad_req($c, "Cannot load $entity_type $entity_id. Bad entity id given?");
    }

    my $rt = MusicBrainz::Server::Rating->new($maindb->{dbh});
    my $rating = $rt->GetUserRatingForEntity($entity_type, $obj->id, $c->user->id);

    my $printer = sub {
        print_xml($rating);
    };

    send_response($c, $printer);
    return RC_OK;
}

sub print_xml
{
    my ($rating) = @_;

    print '<?xml version="1.0" encoding="UTF-8"?>';
    print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print '<user-rating>'. $rating .'</user-rating>' if ($rating);
    print '</metadata>';
}

1;
# eof Rating.pm
