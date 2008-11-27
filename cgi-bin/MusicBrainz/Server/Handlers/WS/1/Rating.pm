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

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::Handlers::WS::1::Common;
use Apache::Constants qw( OK BAD_REQUEST DECLINED SERVER_ERROR NOT_FOUND FORBIDDEN);
use MusicBrainz::Server::Rating;
use Data::Dumper;

use constant MAX_RATINGS_PER_REQUEST => 20;

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# GET  http://server/ws/1/rating/?entity=<entity>&id=<id>
	# POST http://server/ws/1/rating/?entity=<entity>&id=<id>&rating=<rating>
	# POST http://server/ws/1/rating/?entity.0=<entity>&id.0=<mbid>&rating.0=<rating>&entity.1=<entity>&id.1=<mbid>&rating.1=<rating>..

	my $apr = Apache::Request->new($r);
    if ($r->method eq "POST")
	{
		my $entity = $apr->param('entity.0');
		return handler_post_multiple($r, $apr) if ($entity);
		return handler_post($r, $apr);
	}

	return bad_req($r, "Only GET or POST is acceptable")
		unless $r->method eq "GET";

	my $user = $r->user;
	my $entity = $apr->param('entity');
	my $id = $apr->param('id');
	my $type = $apr->param('type');
	if (!defined($type) || $type ne 'xml')
	{
		return bad_req($r, "Invalid content type. Must be set to xml.");
	}

	if (!MusicBrainz::Server::Validation::IsGUID($id) || 
	    ($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
	{
		return bad_req($r, "Invalid MBID/entity.");
	}

	my $status = eval 
	{
		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $user, $entity, $id);
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

sub handler_post
{
    my $r = shift;
    my $apr = shift;

	# URLs are of the form:
	# POST http://server/ws/1/rating/?name=<user_name>&entity=<entity>&id=<id>&rating=<rating>

    my $user = $r->user;
    my $entity = $apr->param('entity');
    my $id = $apr->param('id');
    my $rating = $apr->param('rating');

    if (!MusicBrainz::Server::Validation::IsGUID($id) || 
        ($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
    {
		return bad_req($r, "Invalid MBID/entity.");
    }

    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
    {
		return bad_req($r, "You cannot submit ratings to a slave server.");
    }

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db_post($r, $user, [{entity => $entity, id => $id, rating => $rating}]);
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

# handle multiple entities per post
sub handler_post_multiple
{
    my $r = shift;
    my $apr = shift;

	# URLs are of the form:
	# POST http://server/ws/1/rating/?entity.0=<entity>&id.0=<mbid>&rating.0=<rating>&entity.1=<entity>&id.1=<mbid>&rating.1=<rating>..

    my $user = $r->user;
	my @batch;

    # Ensure that the login name is the same as the resource requested 
    if ($r->user ne $user)
    {
		$r->status(FORBIDDEN);
        return FORBIDDEN;
    }

    # Ensure that we're not a replicated server and that we were given a client version
    if (&DBDefs::REPLICATION_TYPE == &DBDefs::RT_SLAVE)
    {
		return bad_req($r, "You cannot submit ratings to a slave server.");
    }

	my ($entity, $id, $rating, $count);
	for($count = 0;; $count++)
	{
		my $entity = $apr->param("entity.$count");
		my $id = $apr->param("id.$count");
		my $rating = $apr->param("rating.$count");

		last if (not defined $entity || not defined $id || not defined $rating);

		if (!MusicBrainz::Server::Validation::IsGUID($id) || 
			($entity ne 'artist' && $entity ne 'release' && $entity ne 'track' && $entity ne 'label'))
		{
			return bad_req($r, "Invalid MBID/entity for set $count.");
		}
		push @batch, { entity => $entity, id => $id, rating => $rating };
	}
	if (!$count)
	{
		return bad_req($r, "No valid ratings were specified in this request.");
	}
	if ($count > MAX_RATINGS_PER_REQUEST)
	{
		return bad_req($r, "Too many ratings for one request. Max " . MAX_RATINGS_PER_REQUEST . " ratings per request.");
	}

	my $status = eval 
    {
		# Try to serve the request from the database
		{
			my $status = serve_from_db_post($r, $user, \@batch);
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
	my ($r, $user, $ratings) = @_;

	my $printer = sub {
		process_user_input($r, $user, $ratings);
	};

	send_response($r, $printer);
	return OK();
}

sub process_user_input
{
	my ($r, $user, $ratings) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login();

    require UserStuff;
    my $us = UserStuff->new($mb->{DBH});
    $us = $us->newFromName($user) or die "Cannot load user.\n";

    require Sql;
    my $sql = Sql->new($mb->{DBH});

    require MusicBrainz::Server::Artist;
    require MusicBrainz::Server::Release;
    require MusicBrainz::Server::Label;
    require MusicBrainz::Server::Track;

	my ($obj, $count);
	foreach my $rating (@{$ratings})
	{
		if ($rating->{entity} eq 'artist')
		{
			$obj = MusicBrainz::Server::Artist->new($sql->{DBH});
		}
		elsif ($rating->{entity} eq 'release')
		{
			$obj = MusicBrainz::Server::Release->new($sql->{DBH});
		}
		elsif ($rating->{entity} eq 'track')
		{
			$obj = MusicBrainz::Server::Track->new($sql->{DBH});
		}
		elsif ($rating->{entity} eq 'label')
		{
			$obj = MusicBrainz::Server::Label->new($sql->{DBH});
		}
		$obj->SetMBId($rating->{id});
		unless ($obj->LoadFromId)
		{
			return bad_req($r, "Cannot load " . $rating->{entity} . ' ' . $rating->{id} . ". Bad entity id given?");
		} 

		my $ratings = MusicBrainz::Server::Rating->new($mb->{DBH});
		$ratings->Update($rating->{entity}, $obj->GetId, $us->GetId, $rating->{rating});
	}

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>';
}

sub serve_from_db
{
	my ($r, $user_name, $entity_type, $entity_id) = @_;

	# Login to the main DB
	my $main = MusicBrainz->new;
	$main->Login();
	my $maindb = Sql->new($main->{DBH});

	require UserStuff;
	my $user = UserStuff->new($maindb->{DBH});
	$user = $user->newFromName($user_name) or die "Cannot load user.\n";

    require MusicBrainz::Server::Artist;
    require MusicBrainz::Server::Release;
    require MusicBrainz::Server::Label;
    require MusicBrainz::Server::Track;

    my $obj;
    if ($entity_type eq 'artist')
    {
        $obj = MusicBrainz::Server::Artist->new($maindb->{DBH});
    }
    elsif ($entity_type eq 'release')
    {
        $obj = MusicBrainz::Server::Release->new($maindb->{DBH});
    }
    elsif ($entity_type eq 'track')
    {
        $obj = MusicBrainz::Server::Track->new($maindb->{DBH});
    }
    elsif ($entity_type eq 'label')
    {
        $obj = MusicBrainz::Server::Label->new($maindb->{DBH});
    }
    $obj->SetMBId($entity_id);
    unless ($obj->LoadFromId)
    {
		return bad_req($r, "Cannot load $entity_type $entity_id. Bad entity id given?");
    }

	my $rt = MusicBrainz::Server::Rating->new($maindb->{DBH});
	my $rating = $rt->GetUserRatingForEntity($entity_type, $obj->GetId, $user->GetId);

	my $printer = sub {
		print_xml($rating);
	};

	send_response($r, $printer);
	return Apache::Constants::OK();
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
