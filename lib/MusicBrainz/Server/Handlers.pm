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

package MusicBrainz::Server::Handlers;

use Apache::Constants qw( DECLINED HTTP_NOT_ACCEPTABLE );
use HTTP::Headers;
use HTTP::Negotiate;

my $hex = "[0-9A-Fa-f]";
my $GUID = join "-", map { scalar($hex x $_) } qw( 8 4 4 4 12 );
my $discid_char = "[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789._]";
my $discid = "$discid_char+-{0,2}";

sub TransHandler
{
	my ($r) = @_;
	my $uri = $r->uri;

	if ($uri =~ s/;remote_ip=(.*?)$//)
	{
		my $ip = $1;
		$r->connection->remote_ip($ip);
		$r->uri($uri);

		my $request = $r->the_request;

		if ($request =~ s/;remote_ip=\Q$ip\E//)
		{
			$r->the_request($request);
		}
	}

	# Temporary hack: keep track of which IPs are running MB Taggers
	track_mb_taggers($r);

	# implement http://wiki.musicbrainz.org/SearchURLs
	# if ($uri =~ m[^/search/(artist|release|track)/(.+)\z])
	# {
	# 	my $entity = ($1 eq "album" ? "release" : $1);
	# 	my $new_uri = "/search/textsearch.html?type=".$entity."&query=$2";
	# 	return use_new_uri($r, $new_uri);
	# }

	# implement http://wiki.musicbrainz.org/SearchURLs
	# if ($uri =~ m[^/(artist|release|track)/\?name\=(.+)\z])
	# {
	# 	my $entity = ($1 eq "album" ? "release" : $1);
	# 	my $new_uri = "/search/textsearch.html?type=".$entity."&query=$2";
	# 	return use_new_uri($r, $new_uri);
	# }

	# These ones are the "permanent URLs" using the MBID
	# as the query parameter to redirect to the /show/entity/ HTML page
	# /(artist|album|track)/$GUID.html
	if ($uri =~ m[^/(artist|release|album|track|label)/($GUID)\.html\z])
	{
		my $entity = ($1 eq "album" ? "release" : $1);
		my $new_uri = "/show/".$entity."/?mbid=$2";
		$new_uri .= "&" . $r->args if defined $r->args;
		return use_new_uri($r, $new_uri);
	}

	# These ones are the "impermanent URLs" using the ROWID
	# as the query parameter to redirect to the /show/entity/ HTML page
	# /(artist|album|track)/\d+.html
	# if ($uri =~ m[^/(artist|release|album|track)/(\d+)\.html\z])
	# {
	# 	my $entity = ($1 eq "album" ? "release" : $1);
	# 	my $new_uri = "/show/".$entity."/?".$entity."id=$2";
	# 	$new_uri .= "&" . $r->args if defined $r->args;
	# 	return use_new_uri($r, $new_uri);
	# }

	# Obsolete?
	# /show(artist|album|track)/$GUID
	if ($uri =~ m[^/show(artist|release|album|track)/($GUID)\z])
	{
		my $entity = ($1 eq "album" ? "release" : $1);
		return use_new_uri($r, "/show/$entity/?mbid=$2");
	}

	# /mm-2.1/(artist|album|track|trm|trmid|cdindex)/$GUID [/$depth]
	if ($uri =~ m[^/mm-2.1/(artist|album|track|trmid|trm|cdindex)/($GUID)(?:/(\d+))?\z])
	{
		my $what = $1; $what = "trmid" if $what eq "trm";
		my $guid = $2;
		my $depth = (defined($3) ? "&depth=$3" : "");
		return use_new_uri($r, "/cgi-bin/rdf_2_1.pl?query=$what&id=$guid$depth");
	}
	
	# /mm-2.1/(artistrel|albumrel|trackrel)/$GUID
	if ($uri =~ m[^/mm-2.1/(artistrel|albumrel|trackrel)/($GUID)\z])
	{
		my $what = $1;
		my $guid = $2;
		return use_new_uri($r, "/cgi-bin/rdf_2_1.pl?query=$what&id=$guid");
	}

	# /(artist|album|track)/$GUID [/$depth] [?query...]
	# Includes mm-2.0 (RDF) and also can negotiate to HTML.
	return negotiate_artist($r, $1, $2, $3)
		if $uri =~ m[^/artist/($GUID)(?:/(.*?))?(?:\?(.*))?\z];

	return negotiate_album($r, $1, $2, $3)
		if $uri =~ m[^/album/($GUID)(?:/(.*?))?(?:\?(.*))?\z];

	return negotiate_track($r, $1, $2, $3)
		if $uri =~ m[^/track/($GUID)(?:/(.*?))?(?:\?(.*))?\z];

	# /(trm|trmid)/$GUID [/path...] [?query...]
	return negotiate_trm($r, $1, $2, $3)
		if $uri =~ m[^/(?:trm|trmid)/($GUID)(?:/(.*?))?(?:\?(.*))?\z];

	# /(cdindex|discid)/$GUID [/path...] [?query...]
	return negotiate_discid($r, $1, $2, $3)
		if $uri =~ m[^/(?:cdindex|discid)/($discid)(?:/(.*?))?(?:\?(.*))?\z];

	DECLINED;
}

sub negotiate_artist
{
	my ($r, $guid, $path, $query) = @_;

	negotiate($r, {
		"text/xml+rdf"	=> "/cgi-bin/rdf.pl?query=artist&id=$guid"
			. (defined($path) ? "&depth=$path" : ""),
		"text/html"		=> "/showartist.html?mbid=$guid",
	});
}

sub negotiate_album
{
	my ($r, $guid, $path, $query) = @_;

	negotiate($r, {
		"text/xml+rdf"	=> "/cgi-bin/rdf.pl?query=album&id=$guid"
			. (defined($path) ? "&depth=$path" : ""),
		"text/html"		=> "/showalbum.html?mbid=$guid",
	});
}

sub negotiate_track
{
	my ($r, $guid, $path, $query) = @_;

	negotiate($r, {
		"text/xml+rdf"	=> "/cgi-bin/rdf.pl?query=track&id=$guid"
			. (defined($path) ? "&depth=$path" : ""),
		"text/html"		=> "/showtrack.html?mbid=$guid",
	});
}

sub negotiate_trm
{
	my ($r, $guid, $path, $query) = @_;

	negotiate($r, {
		"text/xml+rdf"	=> "/cgi-bin/rdf.pl?query=trmid&id=$guid"
			. (defined($path) ? "&depth=$path" : ""),
		"text/html"		=> "/showtrm.html?trm=$guid",
	});
}

sub negotiate_discid
{
	my ($r, $guid, $path, $query) = @_;

	negotiate($r, {
		# Hmm, that's odd.  It's in vh_httpd.conf, but rdf.pl doesn't support
		# this query.
		# "text/xml+rdf"	=> "/cgi-bin/rdf.pl?query=cdindexid&id=$guid"
		# 	. (defined($path) ? "&depth=$path" : ""),
		"text/html"		=> "/showalbum.html?discid=$guid",
	});
}

sub negotiate
{
	my ($r, $map) = @_;

	# Not perfect; $r->args in list context doesn't grok key/value pairs, so
	# for example ?foo&bar=baz would come out as { foo => 'bar', baz => undef }
	my $args = do { no warnings; +{ map { lc $_ } $r->args } };

	# If the requested content-type is available, use that.
	my $requested_type = $args->{"content-type"} || "";
	if (my $uri = $map->{$requested_type})
	{
		return use_new_uri($r, $uri);
	}

	# Otherwise, negotiate the best fit based on the "Accept" header.
	my $use_type = best_type($r, keys %$map) || "";
	if (my $uri = $map->{$use_type})
	{
		return use_new_uri($r, $uri);
	}
	
	# Otherwise, fail.
	HTTP_NOT_ACCEPTABLE;
}

sub use_new_uri
{
	my ($r, $uri) = @_;

	my $subr = $r->lookup_uri($uri);
	$r->uri($subr->uri);
	$r->filename($subr->filename);
	$r->path_info($subr->path_info);
	$r->args(scalar $subr->args);

	DECLINED;
}

sub best_type
{
	my ($r, @types) = @_;

	my @variants = map {
		[ $_, 1, $_, undef, undef, undef, undef ]
	} @types;

	my $headers = new HTTP::Headers;
	for (qw( Accept Accept-Charset Accept-Encoding Accept-Language ))
	{
		$headers->header($_, $r->header_in($_));
	}

	scalar HTTP::Negotiate::choose(\@variants, $headers);
}

################################################################################

sub track_mb_taggers
{
	my ($r) = @_;

	require MusicBrainz::Server::Cache;
	my $key = "istagger-" . $r->connection->remote_ip;
	my $is_tagger;

	# See http://wiki.musicbrainz.org/ServerAccessPaths?highlight=mbt=1
	# "mbt=0" is a debugging mechanism - a way of resetting mbt=1.
	if ($r->args =~ /\bmbt=([01])\b/) {
		MusicBrainz::Server::Cache->set($key, $is_tagger = $1, 3600);
	} else {
		$is_tagger = MusicBrainz::Server::Cache->get($key);
	}

	$r->pnotes("is-mbtagger", $is_tagger||"");
}

sub LogHandler
{
	my ($r) = @_;
	return &Apache::Constants::DECLINED unless $r->is_main;

	# Reset any overridden db, just to make sure
	$MusicBrainz::db = undef;

	eval {auto_detect_taggers($r) };
	return &Apache::Constants::DECLINED;
}

sub auto_detect_taggers
{
	my ($r) = @_;
	my $req = $r->the_request;
	my $ip = $r->connection->remote_ip;
	my $ua = $r->header_in("User-Agent") || "";

	my $tag = (
		$ua !~ m/^libmusicbrainz\/2\.1\.[01]$/ ? "O"
		: $req =~ m/^POST \/cgi-bin\/gateway/ ? "T"
		: $req =~ m/^POST \/mm-2.1\/TrackInfoFromTRMId\?/ ? "I"
		: "O"
	);

	my $key = "autotagger-" . $ip;
	my $recent = MusicBrainz::Server::Cache->get($key) || "";
	{ no warnings; $recent = $tag . substr($recent, 0, 49) };
	MusicBrainz::Server::Cache->set($key, $recent, 3600);
	# print "history for $ip = $recent\n";

	if ($recent =~ /^[IT]{32}/
		and $recent =~ tr/I// >= 10
		and $recent =~ tr/T// >= 10
	) {
		$key = "istagger-" . $ip;
		MusicBrainz::Server::Cache->set($key, 1, 3600);
	}
}

1;
# eof Handlers.pm
