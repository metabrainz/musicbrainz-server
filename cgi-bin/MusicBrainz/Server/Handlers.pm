#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
# vi: set ts=4 sw=4 :

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

	return negotiate_artist($r, $1, $2, $3)
		if $uri =~ m[^/artist/($GUID)(?:/(.*?))?(?:\?(.*))?$]; #]

	return negotiate_album($r, $1, $2, $3)
		if $uri =~ m[^/album/($GUID)(?:/(.*?))?(?:\?(.*))?$]; #]

	return negotiate_track($r, $1, $2, $3)
		if $uri =~ m[^/track/($GUID)(?:/(.*?))?(?:\?(.*))?$]; #]

	return negotiate_trm($r, $1, $2, $3)
		if $uri =~ m[^/(?:trm|trmid)/($GUID)(?:/(.*?))?(?:\?(.*))?$]; #]

	return negotiate_discid($r, $1, $2, $3)
		if $uri =~ m[^/(?:cdindex|discid)/($discid)(?:/(.*?))?(?:\?(.*))?$]; #]

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

1;
# eof Handlers.pm
