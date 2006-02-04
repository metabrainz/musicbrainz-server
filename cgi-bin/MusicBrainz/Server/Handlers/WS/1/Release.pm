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

package MusicBrainz::Server::Handlers::WS::1::Release;

use Apache::Constants qw( );
use Apache::File ();
use Data::Dumper;

#TODO: Change spec to make inc args singluar
#      change inc discids -> disc to match output xml. Add duration attr to disc

use constant INC_ARTIST      => 0x01;
use constant INC_COUNT       => 0x02;
use constant INC_RELEASEINFO => 0x04;
use constant INC_DISC        => 0x08;
use constant INC_TRMID       => 0x10;
use constant INC_TRACKS      => 0x11;
use constant INC_ARTISTREL   => 0x12;
use constant INC_RELEASEREL  => 0x14;
use constant INC_TRACKREL    => 0x18;
use constant INC_URLREL      => 0x20;
use constant INC_VA          => 0x21;

# This hash is used to convert the long form of the args into a short form that can 
# be used easier and be used as the key modifier for memcached.
my %incShortcuts = 
(
    'artist'       => INC_ARTIST,    
    'count'        => INC_COUNT,
    'release-info' => INC_RELEASEINFO,
    'disc'         => INC_DISC,
    'trmid'        => INC_TRMID,
    'tracks'       => INC_TRACKS,
    'artist-rel'   => INC_ARTISTREL,
    'release-rel'  => INC_RELEASEREL,
    'track-rel'    => INC_TRACKREL,
    'url-rel'      => INC_URLREL,
    'va'           => INC_VA        
);

sub convert_inc
{
    my ($inc, $xref) = @_;

    my $shinc = 0;
    $shinc |= $xref->{$_}
        foreach (split ' ', $inc);
    return $shinc;
}

sub handler
{
	my ($r) = @_;
	# URLs are of the form:
	# http://server/ws/1/release or
	# http://server/ws/1/release/MBID 

	return bad_req($r, "Only GET is acceptable")
		unless $r->method eq "GET";

    my $mbid = $1 if ($r->uri =~ /ws\/1\/release\/([a-z0-9-]*)/);

	my %args; { no warnings; %args = $r->args };
    my $inc = convert_inc($args{inc}, \%incShortcuts);

	if ((!MusicBrainz::IsGUID($mbid) && $mbid ne '') || $inc eq 'error')
	{
		return bad_req($r, "Incorrect URI. For usage, please see: http://musicbrainz.org/development/mmd");
	}

    if (!$mbid)
    {
		return bad_req($r, "Collections not supported yet.");
    }

	eval {
		# Try to serve the request from our cached copy
		{
			my $status = serve_from_cache($r, $mbid, $inc);
			return $status if defined $status;
		}

		# Try to serve the request from the database
		{
			my $status = serve_from_db($r, $mbid, $inc);
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
	my ($r, $mbid, $inc) = @_;

	# If we don't have it cached, return undef.  This means we have to fetch
	# it from the DB.
	my ($length, $checksum, $time) = find_meta_in_cache($mbid, $inc)
		or return undef;

	$r->set_content_length($length);
	$r->header_out("ETag", "$mbid-$inc-$checksum");
	$r->set_last_modified($time);

	# Is the user's cached copy up-to-date?
	{
		my $rc = $r->meets_conditions;
		if ($rc != Apache::Constants::OK()) { return $rc }
	}

	# No - send our copy (from the cache) to the user
	# First we need to fetch the data itself
	my $xmlref = find_data_in_cache($mbid, $inc)
		or return undef;

	# Now send the data
	$r->send_http_header("text/xml; charset=utf-8");
	$r->print($xmlref);
	return Apache::Constants::OK();
}

sub serve_from_db
{
	my ($r, $mbid, $inc) = @_;

	my $ar;
	my $al;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;
	require Album;

	$al = Album->new($mb->{DBH});
    $al->SetMBId($mbid);
	$al->LoadFromId(1);

    if ($inc & INC_ARTIST)
    {
        $ar = Artist->new($mb->{DBH});
        $ar->SetId($al->GetArtist);
        $ar->LoadFromId();
    }

	my $printer = sub {
		print_xml($mbid, $inc, $ar, $al);
	};

	my $fixup = sub {
		my ($xmlref) = @_;

		# These form the basis of the HTTP cache control system
		require String::CRC32;
		my $length = length($$xmlref);
		my $checksum = String::CRC32::crc32($$xmlref);
		my $time = time;

		store_in_cache($mbid, $inc, $xmlref, $length, $checksum, $time);

		# Set HTTP cache control headers
		$r->set_content_length($length);
		$r->header_out("ETag", "$mbid-$inc-$checksum");
		$r->set_last_modified($time);
	};

	send_response($r, $printer, $fixup);
	return Apache::Constants::OK();
}

# This is a perfectly functional way of sending the response, but it's not
# cacheable:
#sub send_response
#{
#	my ($r, $printer) = @_;
#	$r->send_http_header("text/xml; charset=utf-8");
#	&$printer()
#		unless $r->header_only;
#}

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
	my ($mbid, $inc, $ar, $al, $tracks) = @_;

	print '<?xml version="1.0" encoding="UTF-8"?>';
	print '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
    print '<release id="' . $al->GetMBId . '"';
    xml_release_type($al);
    print '><title>' . xml_escape($al->GetName) . '</title>';

    my ($lang, $script);
    $lang = $al->GetLanguageId;
    $script = $al->GetScriptId;
    if ($lang || $script)
    {
        print '<text-representation';
        print ' language="' . uc($al->GetLanguage->GetISOCode3T()) . '"' if ($lang);
        print ' script="' . $al->GetScript->GetISOCode . '"' if ($script);
        print '/>';
    }

    my $asin = $al->GetAsin;
    print "<asin>$asin</asin>" if $asin;

    print xml_artist($ar) if ($inc & INC_ARTIST);
    print xml_releases($al, $inc) if ($inc & INC_RELEASEINFO || $inc & INC_COUNT);
    print xml_discs($al, $inc) if ($inc & INC_DISC || $inc & INC_COUNT);
    print xml_tracks($ar, $al, $inc) if ($inc & INC_TRACKS || $inc & INC_COUNT);
    
	print '</release></metadata>';
}

sub xml_artist
{
	my ($ar) = @_;

	printf '<artist id="%s"', $ar->GetMBId;
    printf ' type="%s"', &Artist::GetTypeName($ar->GetType()) if ($ar->GetType);
    printf '><name>%s</name><sort-name>%s</sort-name>',
		xml_escape($ar->GetName),
		xml_escape($ar->GetSortName);

    my ($b, $e) = ($ar->GetBeginDate, $ar->GetEndDate);
    if ($b|| $e)
    {
        print '<life-span';
        print " begin=\"$b\"" if ($b); 
        print " end=\"$e\"" if ($e); 
        print '/>';
    }
    print "</artist>";

    return undef;
}

sub xml_release_type
{
	my $al = $_[0];

	my ($type, $status) = $al->GetReleaseTypeAndStatus;
	$type = (defined $type ? $al->GetAttributeName($type) : "");
	$status = (defined $status ? $al->GetAttributeName($status) : "");

    print " type=\"$type $status\" " if ($type or $status);
}

sub xml_language
{
	my $al = $_[0];
	my ($lang) = $al->GetLanguage;
	my ($name) = (defined $lang ? $lang->GetName : "?");
	my ($code) = (defined $lang ? $al->GetLanguage->GetISOCode3T() : "?");
	my ($script) = (defined $al->GetScript ? $al->GetScript->GetName : "?");
	my ($editpending) = ($al->GetLanguageModPending() ? 'editpending="1"' : '');

	return '<mm:language '.$editpending.' '
	     . 'code="'.xml_escape($code).'" '
	     . 'script="'.xml_escape($script).'">'
	     . xml_escape($name).'</mm:language>';
}

sub xml_releases
{
    require MusicBrainz::Server::Country;

	my ($al, $inc) = @_;
    my (@releases) = $al->Releases;
    my $country_obj = MusicBrainz::Server::Country->new($al->{DBH})
       if @releases;
	
	my ($xml) = "";
    if (@releases)
    {
        if (($inc & INC_RELEASEINFO) == 0)
        {
            printf '<release-info-list count="%s"/>', scalar(@releases);
            return undef;
        }
        print "<release-info-list>";
        for my $rel (@releases)
        {
			my $cid = $rel->GetCountry;
			my $c = $country_obj->newFromId($cid);
			my ($year, $month, $day) = $rel->GetYMD();
			my ($releasedate) = $year;
			$releasedate .= sprintf "-%02d", $month if ($month != 0);
			$releasedate .= sprintf "-%02d", $day if ($day != 0);
			my ($editpending) = ($rel->GetModPending ? 'editpending="1"' : '');

			# create a releasedate element
			print '<info date="';
			print ($releasedate);
			print '" country="'; 
			print ($c ? $c->GetISOCode : "?");
			print '"/>';
         }
         print "</release-info-list>";
    }
    return undef;
}

sub xml_discs
{
	my ($al, $inc) = @_;
	my (@ids) = @{ $al->GetDiscIDs };

	if (scalar(@ids) > 0) 
	{		
        if (($inc & INC_DISC) == 0)
        {
            printf '<disc-list count="%s"/>', scalar(@ids);
            return undef;
        }
        print "<disc-list>";
		foreach my $id (@ids)
		{
			my ($cdtoc) = $id->GetCDTOC;
			my ($duration) = int($cdtoc->GetLeadoutOffset / 75 * 1000);
			my ($discid) = $cdtoc->GetDiscID;

			# create a cdindexId element
			print '<disc duration="';
			print $duration;
			print '" id="';
			print $discid;
			print '"/>';
		}
        print "</disc-list>";
	}
	return undef;
}

sub xml_tracks
{
	require Track;
	my ($ar, $al, $inc) = @_;

    my $tracks = $al->GetTracks;
    if (scalar(@$tracks))
    {
        if (($inc & INC_TRACKS) == 0)
        {
            printf '<track-list count="%s"/>', scalar(@$tracks);
            return undef;
        }
        print '<track-list>';
        foreach my $tr (@$tracks)
        {
	        printf '<track id="%s"', $tr->GetMBId;
            print '><title>';
            print xml_escape($tr->GetName());
            print '</title>';
            print '<duration>';
            print xml_escape($tr->GetLength());
            print '</duration>';
            if ($tr->GetArtist != $ar->GetId)
            {
                my $ar = Artist->new($tr->{DBH});
                $ar->SetId($tr->GetArtist);
                $ar->LoadFromId();
                xml_artist($ar);
            }
            print '</track>';
        }
        print '</track-list>';
    }
    return undef;
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
	my ($mbid, $type, $xmlref, $length, $checksum, $time) = @_;
	# TODO implement this
	return;
}

sub find_meta_in_cache
{
	my ($mbid, $type) = @_;
	# TODO implement this
	# return ($length, $checksum, $time);
	return ();
}

sub find_data_in_cache
{
	my ($mbid, $type) = @_;
	# TODO implement this
	# return \$xml;
	return undef;
}

# TODO of course we also need a cache invalidation policy
# - either expire after some time (e.g. 1 hr), or clear when the data changes.

1;
# eof ArtistAlbums.pm
