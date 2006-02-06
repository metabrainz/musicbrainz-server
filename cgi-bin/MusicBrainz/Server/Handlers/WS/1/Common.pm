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

package MusicBrainz::Server::Handlers::WS::1::Common;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(convert_inc bad_req serve_from_cache send_response 
                    xml_artist xml_release_type xml_language xml_release_events
                    xml_discs xml_track_list xml_track xml_trm xml_escape 
                    store_in_cache xml_release find_meta_in_cache find_data_in_cache
                    INC_ARTIST INC_COUNTS INC_LIMIT INC_TRACKS INC_RELEASES 
                    INC_VARELEASES INC_DURATION INC_ARTISTREL INC_RELEASEREL 
                    INC_DISCS INC_TRACKREL INC_URLREL INC_RELEASEINFO 
                    INC_ARTISTID INC_RELEASEID INC_TRACKID INC_TITLE 
                    INC_TRACKNUM INC_TRMIDS);

use Apache::Constants qw( );
use Apache::File ();

# TODO: how is the limit passed for searches?

use constant INC_ARTIST      => 0x00001;
use constant INC_COUNTS      => 0x00002;
use constant INC_LIMIT       => 0x00004;
use constant INC_TRACKS      => 0x00008;
use constant INC_RELEASES    => 0x00010;
use constant INC_VARELEASES  => 0x00020;
use constant INC_DURATION    => 0x00040;
use constant INC_ARTISTREL   => 0x00080;
use constant INC_RELEASEREL  => 0x00100;
use constant INC_DISCS       => 0x00200;
use constant INC_TRACKREL    => 0x00400;
use constant INC_URLREL      => 0x00800;
use constant INC_RELEASEINFO => 0x01000;
use constant INC_ARTISTID    => 0x02000;
use constant INC_RELEASEID   => 0x04000;
use constant INC_TRACKID     => 0x08000;
use constant INC_TITLE       => 0x10000;
use constant INC_TRACKNUM    => 0x20000;
use constant INC_TRMIDS      => 0x40000;

# This hash is used to convert the long form of the args into a short form that can 
# be used easier and be used as the key modifier for memcached.
my %incShortcuts = 
(
    'artist'         => INC_ARTIST,    
    'counts'         => INC_COUNTS,
    'limit'          => INC_LIMIT,
    'tracks'         => INC_TRACKS,
    'releases'       => INC_RELEASES,
    'va-releases'    => INC_VARELEASES,
    'duration'       => INC_DURATION,
    'artist-rels'    => INC_ARTISTREL,
    'release-rels'   => INC_RELEASEREL,
    'discs'          => INC_DISCS,
    'track-rels'     => INC_TRACKREL,
    'url-rels'       => INC_URLREL,
    'release-events' => INC_RELEASEINFO,
    'artistid'       => INC_ARTISTID,
    'releaseid'      => INC_RELEASEID,
    'trackid'        => INC_TRACKID,
    'title'          => INC_TITLE,
    'tracknum'       => INC_TRACKNUM,
    'trmids'         => INC_TRMIDS,
);

# Convert the passed inc argument into a bitflag with the given constants form above
# Return and array of the bitflag and the arguments that were not used.
sub convert_inc
{
    my ($inc) = @_;

    my $shinc = 0;
    my @bad;
    foreach (split ' ', $inc)
    {
        if (exists $incShortcuts{$_})
        {
            $shinc |= $incShortcuts{$_};
        }
        else
        {
            push @bad, $_;
        }
    }
    return ($shinc, join(' ', @bad));
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
	my ($r, $mbid, $type, $inc) = @_;

	# If we don't have it cached, return undef.  This means we have to fetch
	# it from the DB.
	my ($length, $checksum, $time) = find_meta_in_cache($mbid, $type, $inc)
		or return undef;

	$r->set_content_length($length);
	$r->header_out("ETag", "$mbid-$type-$inc-$checksum");
	$r->set_last_modified($time);

	# Is the user's cached copy up-to-date?
	{
		my $rc = $r->meets_conditions;
		if ($rc != Apache::Constants::OK()) { return $rc }
	}

	# No - send our copy (from the cache) to the user
	# First we need to fetch the data itself
	my $xmlref = find_data_in_cache($mbid, $type, $inc)
		or return undef;

	# Now send the data
	$r->send_http_header("text/xml; charset=utf-8");
	$r->print($xmlref);
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
    print '<disambiguation>' . $ar->GetResolution() . '</disambiguation>' if ($ar->GetResolution());
    print "</artist>";

    return undef;
}

sub xml_release
{
	my ($ar, $al, $inc) = @_;

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
    print xml_release_events($al, $inc) if ($inc & INC_RELEASEINFO || $inc & INC_COUNTS);
    print xml_discs($al, $inc) if ($inc & INC_DISCS || $inc & INC_COUNTS);
    print xml_track_list($ar, $al, $inc) if ($inc & INC_TRACKS || $inc & INC_COUNTS);
    
	print '</release>';
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

sub xml_release_events
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
         print "</release-event-list>";
    }
    return undef;
}

sub xml_discs
{
	my ($al, $inc) = @_;
	my (@ids) = @{ $al->GetDiscIDs };

	if (scalar(@ids) > 0) 
	{		
        if (($inc & INC_DISCS) == 0)
        {
            printf '<disc-list count="%s"/>', scalar(@ids);
            return undef;
        }
        print "<disc-list>";
		foreach my $id (@ids)
		{
			my ($cdtoc) = $id->GetCDTOC;
			my ($sectors) = $cdtoc->GetLeadoutOffset;
			my ($discid) = $cdtoc->GetDiscID;

			# create a cdindexId element
			print '<disc sectors="';
			print $sectors;
			print '" id="';
			print $discid;
			print '"/>';
		}
        print "</disc-list>";
	}
	return undef;
}

sub xml_track_list
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

            if ($ar->GetId != $tr->GetArtist)
            {
                my $ar;
                $ar = Artist->new($tr->{DBH});
                $ar->SetId($tr->GetArtist);
                $ar->LoadFromId();
                xml_track($ar, $tr, $inc);
            }
            else
            {
                xml_track(undef, $tr, $inc);
            }
        }
        print '</track-list>';
    }
    return undef;
}

sub xml_track
{
	require Track;
	my ($ar, $tr, $inc) = @_;


	printf '<track id="%s"', $tr->GetMBId;
    print '><title>';
    print xml_escape($tr->GetName());
    print '</title>';
    print '<duration>';
    print xml_escape($tr->GetLength());
    print '</duration>';
    xml_artist($ar) if (defined $ar);
    xml_trm($tr) if ($inc & INC_TRMIDS);
    print '</track>';

    return undef;
}

sub xml_trm
{
    require TRM;
	my ($tr) = @_;

    my $id;
    my $trm = TRM->new($tr->{DBH});
    my @TRM = $trm->GetTRMFromTrackId($tr->GetId);
    return undef if (scalar(@TRM) == 0);
    print '<trm-list>';
    foreach $id (@TRM)
    {
        print '<trmid id="';
        print $id->{TRM};
        print '"/>';
    }
    print '</trm-list>';
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
# eof Common.pm
