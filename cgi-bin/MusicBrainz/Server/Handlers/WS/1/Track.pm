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
#   $Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Handlers::ArtistTracks;

use Apache::Constants qw( );
use Apache::File ();
use MusicBrainz::Server::View::Utils qw( :all );

my %comparators = (
	'name-asc'		=> sub { $_[0]->{sortname} cmp $_[1]->{sortname} },
	'name-desc'		=> sub { $_[1]->{sortname} cmp $_[0]->{sortname} },
	'count-asc'		=> sub { $_[0]->{count} <=> $_[1]->{count} },
	'count-desc'	=> sub { $_[1]->{count} <=> $_[0]->{count} },
);
my $sortorder = 'name-asc,count-asc';


sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# http://server/ws/data/artist-tracks?artist=GUID

	return bad_req($r, "Only GET is acceptable")
		unless $r->method eq "GET";
	return bad_req($r, "uri contains extra components")
		unless $r->uri eq "/ws/data/artist-tracks";

	my %args; { no warnings; %args = $r->args };
	my $mbid = $args{"artist"};

	unless (MusicBrainz::IsGUID($mbid))
	{
		return bad_req($r, "Usage: GET ".$r->uri."?artist=GUID");
	}

	eval {
		# Try to serve the request from our cached copy
		{
			my $status = serve_from_cache($r, $mbid);
			return $status if defined $status;
		}

		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid);
			return $status if defined $status;
		}
	};

	if ($@)
	{
		my $error = "$@";
		$r->status(Apache::Constants::SERVER_ERROR());
		$r->send_http_header("text/plain; charset=utf-8");
		$r->print($error."\015\012") unless $r->header_only;
		return Apache::Constants::OK();
	}

	# Damn.
	return Apache::Constants::SERVER_ERROR();
}

sub bad_req
{
	my ($r, $error) = @_;
	$r->status(Apache::Constants::BAD_REQUEST());
	$r->send_http_header("text/plain; charset=utf-8");
	$r->print($error."\015\012") unless $r->header_only;
	return Apache::Constants::OK();
}

sub serve_from_cache
{
	my ($r, $mbid) = @_;

	# If we don't have it cached, return undef.  This means we have to fetch
	# it from the DB.
	my ($length, $checksum, $time) = find_meta_in_cache($mbid)
		or return undef;

	$r->set_content_length($length);
	$r->header_out("ETag", "$mbid-$checksum");
	$r->set_last_modified($time);

	# Is the user's cached copy up-to-date?
	{
		my $rc = $r->meets_conditions;
		if ($rc != Apache::Constants::OK()) { return $rc }
	}

	# No - send our copy (from the cache) to the user
	# First we need to fetch the data itself
	my $xmlref = find_data_in_cache($mbid)
		or return undef;

	# Now send the data
	$r->send_http_header("text/xml; charset=utf-8");
	$r->print($xmlref);
	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid) = @_;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require Artist;

	my $ar = Artist->newFromMBId($mb->{DBH}, $mbid);
	# no warnings;

	# load all tracks
	my @tracks = Track::GetTracksByArtist($mb->{DBH}, $ar->GetId());

	# Now expand groups
	my %album_cache;
	foreach my $track ( @tracks )
	{
		foreach my $album ( @{ $track->{albums} } )
		{
			if ( exists $album_cache{$album->{id}} )
			{
				$album->{obj} = $album_cache{$album->{id}};
				next;
			}

			my $al = Album->new($mb->{DBH});
			$al->SetId($album->{id});
			if ( $al->LoadFromId(0) ) # don't join with albummeta
			{
				$track->{expanded} = 1;
				$album->{obj} = $al;
			}
		}
	}
	@tracks = GenericSort($sortorder, \%comparators, @tracks); # TODO: use refs

	my $printer = sub {
		print_xml($mbid, $ar, @tracks);
	};

	my $fixup = sub {
		my ($xmlref) = @_;

		# These form the basis of the HTTP cache control system
		require String::CRC32;
		my $length = length($$xmlref);
		my $checksum = String::CRC32::crc32($$xmlref);
		my $time = time;

		store_in_cache($mbid, $xmlref, $length, $checksum, $time);

		# Set HTTP cache control headers
		$r->set_content_length($length);
		$r->header_out("ETag", "$mbid-$checksum");
		$r->set_last_modified($time);
	};

	send_response($r, $printer, $fixup);
	return Apache::Constants::OK();
}

sub send_response
{
	my ($r, $printer, $fixup) = @_;

	# Collect all XML in memory (or we could use a temporary file), then send it
	my $xml = "";
	{
		open(my $fh, ">", \$xml) or die $!;
		use SelectSaver;
		my $save = SelectSaver->new($fh);
		&$printer();
	}

	&$fixup(\$xml);

	$r->send_http_header("text/xml; charset=utf-8");
	$r->print(\$xml) unless $r->header_only;
}

sub print_xml
{
	my ($mbid, $ar, @tracks) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<mm:ArtistTracks xmlns:dc="http://purl.org/dc/elements/1.1/"';
	print ' xmlns:mq="http://musicbrainz.org/mm/mq-1.1#"';
	print ' xmlns:mm="http://musicbrainz.org/mm/mm-2.1#"';
	print ' xmlns:ar="http://musicbrainz.org/ar/ar-1.0#">';
	print_artist_xml($ar);
	print '<mm:trackList>';
	print_track_xml($_) for @tracks;
	print '</mm:trackList>';
	print '</mm:ArtistTracks>';
}

sub print_artist_xml
{
	my ($ar) = @_;
	printf '<mm:Artist id="%s">'
		. '<dc:title>%s</dc:title>'
		. '<mm:sortName>%s</mm:sortName>'
		. '</mm:Artist>',
		$ar->GetMBId,
		xml_escape($ar->GetName),
		xml_escape($ar->GetSortName),
		;
}

sub print_track_xml
{
	require Track;
	my ($track) = @_;

	my ($xml) = '';
	$xml .= '<mm:Track id="'.$track->{gid}.'">';
	$xml .= '<dc:title>'.xml_escape($track->{name}).'</dc:title>';
  	$xml .= '<mm:albumsList>';
	foreach my $al ( @{ $track->{albums} } ) 
  	{
		$xml .= '<mm:Album id="'.$al->{obj}->GetMBId.'">';
		$xml .= '<dc:title>'.xml_escape($al->{obj}->GetName).'</dc:title>';
		$xml .= '<mm:duration>'.$al->{track_length}.'</mm:duration>';
		$xml .= '</mm:Album>';
	}
	$xml .= '</mm:albumsList>';
	$xml .= '</mm:Track>';
	print $xml;
}

sub xml_escape
{
	my $t = $_[0];
	$t =~ s/&/&amp;/g;
	$t =~ s/</&lt;/g;
	$t =~ s/>/&gt;/g;
	return $t;
}

sub store_in_cache
{
	my ($mbid, $xmlref, $length, $checksum, $time) = @_;
	# TODO implement this
	return;
}

sub find_meta_in_cache
{
	my ($mbid) = @_;
	# TODO implement this
	# return ($length, $checksum, $time);
	return ();
}

sub find_data_in_cache
{
	my ($mbid) = @_;
	# TODO implement this
	# return \$xml;
	return undef;
}

# TODO of course we also need a cache invalidation policy
# - either expire after some time (e.g. 1 hr), or clear when the data changes.

1;
# eof ArtistTracks.pm
