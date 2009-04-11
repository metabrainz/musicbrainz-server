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
#   $Id: Lookup.pm 10691 2008-11-13 09:55:31Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::WS::Private::Lookup;

use HTTP::Status qw(RC_OK RC_NOT_FOUND RC_BAD_REQUEST RC_INTERNAL_SERVER_ERROR RC_FORBIDDEN RC_SERVICE_UNAVAILABLE);
use JSON;
use Encode;

sub handler
{
	my ($c) = @_;
    my $r = $c->req;

	# URLs are of the form:
	# http://server/ws/data/lookup?entitytype=[artist|album|track|label]&query=querystring&callid=[0-9]

	# only accept get requests, and requests which match
	# the definition of the handler in vh_httpd.conf
	return bad_req($c, "Only GET is acceptable")
		unless $r->method eq "GET";
	return bad_req($c, "uri contains extra components")
		unless $r->path eq "ws/priv/lookup";

	# extract the arguments from the args hash.
	my $entitytype = $r->params->{"entitytype"};
	my $query = $r->params->{"query"};
	my $callid = $r->params->{"callid"} || 0;

	# entitytype has to be specified and is either artist|album|label|track
	$entitytype = (
		(defined($entitytype) and $entitytype =~ /\A(artist|album|label|track)\z/)
		? $1 : undef
	);
	unless (defined $entitytype)
	{
		return bad_req($c, "Missing/Wrong Parameter: entitytype=[artist|album|label|track]");
	}
	
	# query has to be specified and cannot be an empty string ""
	if (not defined $query or
		$query eq "")
	{
		return bad_req($c, "Missing/Wrong Parameter: query=[non-emtpy string]");
	}

	eval {
		my $status = serve_from_db($c, $entitytype, $query, $callid);
		return $status if defined $status;
	};

	if ($@)
	{
		my $error = "$@";
		$c->response->status(RC_INTERNAL_SERVER_ERROR);
		$c->response->header("text/plain; charset=utf-8");
		$c->response->body($error."\015\012");
		return RC_OK;
	}
}

sub bad_req
{
	my ($c, $error) = @_;
	$c->response->status(RC_BAD_REQUEST);
	$c->response->header("text/plain; charset=utf-8");
	$c->response->body($error."\015\012");
	return RC_OK;
}

sub serve_from_db
{
	my ($c, $entitytype, $query, $callid) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;

	# retrieve the list of entitiesmatching the query $query
	my $engine = SearchEngine->new($mb->{dbh}, $entitytype);
	$engine->Search(
		query => $query,
		limit => 0,
	);

	# filter out any artist ids we don't want to show.
	# (none currently)
	my @dontshow = ();
	my @r = do {
		my %dontshow = map { $_=>1 } @dontshow;
		my @r;
		while (my $row = $engine->NextRow)
		{
			next if $dontshow{ $row->{'artistid'} };
			push @r, $row;
		}
		@r;
	};

	# loop through the list of results from
	# the search engine , and create a list of hashes
	# for the json conversion.
	my @results;
	if (@r)
	{
		for my $row (@r)
		{
			if ($entitytype eq "artist") 
			{
				push @results, {
					artist => {
						id => $row->{artistid},
						name => $row->{'artistname'},
						sortname => $row->{'artistsortname'},
						resolution => $row->{artistresolution},
					},
				};
			}
			elsif ($entitytype eq "label") 
			{
				push @results, {
					label => {
						id => $row->{labelid},
						name => $row->{'labelname'},
						sortname => $row->{'labelsortname'},
						resolution => $row->{labelresolution},
					},
				};
			}
			elsif ($entitytype eq "album") 
			{
				push @results, {
					artist => {
						id => $row->{artistid},
						name => $row->{'artistname'},
						sortname => $row->{'artistsortname'},
						resolution => $row->{artistresolution},
					},
					album => {
						id => $row->{albumid},
						name => $row->{albumname},
						firstreleasedate => $row->{firstreleasedate},
						discids => $row->{discids},
						tracks => $row->{tracks},
					},
				};
			}
			elsif ($entitytype eq "track") 
			{
				push @results, {
					artist => {
						id => $row->{artistid},
						name => $row->{'artistname'},
						sortname => $row->{'artistsortname'},
						resolution => $row->{artistresolution},
					},
					album => {
						id => $row->{albumid},
						name => $row->{albumname},
						firstreleasedate => $row->{firstreleasedate},
						discids => $row->{discids},
						tracks => $row->{tracks},
					},
					track => {
						id => $row->{trackid},
						name => $row->{trackname},
					},
				};
			}
		}
	}

	my $hits = scalar(@results);
	splice(@results, 10) if $hits > 10;

	# create literal object
	my $obj = {
		"entitytype" => $entitytype,
		"query" => $query,
		"callid" => $callid,
		"hits" => $hits,
		"results" => \@results,
	};

	# convert literal object to json notation
	my $json = new JSON;
	my $js = Encode::decode "utf-8", $json->utf8(0)->encode($obj);

	# send the response
	
	# the content type should be application/json, but
	# Opera 8 can't handle that :(
	$c->response->content_type("text/plain; charset=utf-8");
	$c->response->content_length(length($js));
	$c->response->body($js); # unless $r->header_only;

	return RC_OK;
}

1;
# eof Lookup.pm
