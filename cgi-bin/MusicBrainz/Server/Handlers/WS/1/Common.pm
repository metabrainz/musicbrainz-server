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
our @EXPORT = qw(convert_inc bad_req send_response check_types
                 xml_artist xml_release xml_track xml_search xml_escape
                 get_type_and_status_from_inc
                 INC_ARTIST INC_COUNTS INC_LIMIT INC_TRACKS INC_RELEASES 
                 INC_VARELEASES INC_DURATION INC_ARTISTREL INC_RELEASEREL 
                 INC_DISCS INC_TRACKREL INC_URLREL INC_RELEASEINFO 
                 INC_ARTISTID INC_RELEASEID INC_TRACKID INC_TITLE 
                 INC_TRACKNUM INC_TRMIDS);

use Apache::Constants qw( );
use Apache::File ();
use Album;

use constant INC_ARTIST      => 0x00001;
use constant INC_COUNTS      => 0x00002;
use constant INC_LIMIT       => 0x00004;
use constant INC_TRACKS      => 0x00008;
use constant INC_DURATION    => 0x00010;
use constant INC_ARTISTREL   => 0x00020;
use constant INC_RELEASEREL  => 0x00040;
use constant INC_DISCS       => 0x00080;
use constant INC_TRACKREL    => 0x00100;
use constant INC_URLREL      => 0x00200;
use constant INC_RELEASEINFO => 0x00400;
use constant INC_ARTISTID    => 0x00800;
use constant INC_RELEASEID   => 0x01000;
use constant INC_TRACKID     => 0x02000;
use constant INC_TITLE       => 0x04000;
use constant INC_TRACKNUM    => 0x08000;
use constant INC_TRMIDS      => 0x10000;
use constant INC_RELEASES    => 0x20000;

# This hash is used to convert the long form of the args into a short form that can 
# be used easier 
my %incShortcuts = 
(
    'artist'             => INC_ARTIST,    
    'counts'             => INC_COUNTS,
    'limit'              => INC_LIMIT,
    'tracks'             => INC_TRACKS,
    'duration'           => INC_DURATION,
    'artist-rels'        => INC_ARTISTREL,
    'release-rels'       => INC_RELEASEREL,
    'discs'              => INC_DISCS,
    'track-rels'         => INC_TRACKREL,
    'url-rels'           => INC_URLREL,
    'release-events'     => INC_RELEASEINFO,
    'artistid'           => INC_ARTISTID,
    'releaseid'          => INC_RELEASEID,
    'trackid'            => INC_TRACKID,
    'title'              => INC_TITLE,
    'tracknum'           => INC_TRACKNUM,
    'trmids'             => INC_TRMIDS,
    'releases'           => INC_RELEASES,
);

my %typeShortcuts =
( 
    'NonAlbumTrack'   => Album::ALBUM_ATTR_NONALBUMTRACKS,
    'Album'           => Album::ALBUM_ATTR_ALBUM,
    'Single'          => Album::ALBUM_ATTR_SINGLE,
    'EP'              => Album::ALBUM_ATTR_EP,
    'Compilation'     => Album::ALBUM_ATTR_COMPILATION,
    'Soundtrack'      => Album::ALBUM_ATTR_SOUNDTRACK,
    'Spokenword'      => Album::ALBUM_ATTR_SPOKENWORD,
    'Interview'       => Album::ALBUM_ATTR_INTERVIEW,
    'Audiobook'       => Album::ALBUM_ATTR_AUDIOBOOK,
    'Live'            => Album::ALBUM_ATTR_LIVE,
    'Remix'           => Album::ALBUM_ATTR_REMIX,
    'Other'           => Album::ALBUM_ATTR_OTHER        
);

my %statusShortcuts =
( 
    'Official'           => Album::ALBUM_ATTR_OFFICIAL,
    'Promotion'          => Album::ALBUM_ATTR_PROMOTION,
    'Bootleg'            => Album::ALBUM_ATTR_BOOTLEG,
    'sa-Official'        => Album::ALBUM_ATTR_OFFICIAL,
    'sa-Promotion'       => Album::ALBUM_ATTR_PROMOTION,
    'sa-Bootleg'         => Album::ALBUM_ATTR_BOOTLEG,
    'va-Official'        => Album::ALBUM_ATTR_OFFICIAL,
    'va-Promotion'       => Album::ALBUM_ATTR_PROMOTION,
    'va-Bootleg'         => Album::ALBUM_ATTR_BOOTLEG,
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

sub get_type_and_status_from_inc
{
    my ($inc) = @_;

    my $type = 0;
    my $va = 0;
    my @bad;
    foreach my $t (split ' ', $inc)
    {
        my $temp = $t;
        $va = 1 if ($temp =~ s/^va-//);
        $va = 0 if ($temp =~ s/^sa-//);
        if (exists $typeShortcuts{$temp})
        {
            $type = $typeShortcuts{$temp};
        }
        else
        {
            push @bad, $t;
        }
    }
    my @reallybad;
    my $status = 0;
    foreach (@bad)
    {
        if (exists $statusShortcuts{$_})
        {
            $status = $statusShortcuts{$_};
        }
        else
        {
            push @reallybad, $_;
        }
    }
    return ({ type=>$type, status=>$status, va=>$va }, join(' ', @reallybad));
}

sub bad_req
{
	my ($r, $error) = @_;
	$r->status(Apache::Constants::BAD_REQUEST());
	$r->send_http_header("text/plain; charset=utf-8");
	$r->print($error."\015\012") unless $r->header_only;
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

    $r->set_content_length(length($xml));
	$r->send_http_header("text/xml; charset=utf-8");
	$r->print(\$xml) unless $r->header_only;
}

sub xml_artist
{
	my ($ar, $inc, $info) = @_;

	printf '<artist id="%s"', $ar->GetMBId;
    printf ' type="%s"', &Artist::GetTypeName($ar->GetType()) if ($ar->GetType);
    printf '><name>%s</name><sort-name>%s</sort-name>',
		xml_escape($ar->GetName),
		xml_escape($ar->GetSortName);
    print '<disambiguation>' . xml_escape($ar->GetResolution()) . '</disambiguation>' if ($ar->GetResolution());

    my ($b, $e) = ($ar->GetBeginDate, $ar->GetEndDate);
    if ($b|| $e)
    {
        print '<life-span';
        print ' begin="' . MusicBrainz::MakeDisplayDateStr($b) . '"' if ($b); 
        print ' end="' . MusicBrainz::MakeDisplayDateStr($e) . '"' if ($e); 
        print '/>';
    }
    if (defined $info)
    {
        my @albums = $ar->GetAlbums(!$info->{va}, 1, $info->{va});
        if (scalar(@albums))
        {
            print '<release-list>';
            foreach my $al (@albums)
            {
                my ($t, $s) = $al->GetReleaseTypeAndStatus();
                xml_release($ar, $al, $inc) if ($t == $info->{type} && ($info->{status} == 0 || $info->{status} == $s));
            }
            print '</release-list>';
        }
    }
    xml_relations($ar, 'artist', $inc) if ($inc & INC_ARTISTREL || $inc & INC_RELEASEREL || $inc & INC_TRACKREL || $inc & INC_URLREL);
    print "</artist>";

    return undef;
}

sub xml_release
{
	my ($ar, $al, $inc, $tnum) = @_;

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

    xml_artist($ar, 0) if ($inc & INC_ARTIST && $ar);
    xml_release_events($al, $inc) if ($inc & INC_RELEASEINFO || $inc & INC_COUNTS);
    xml_discs($al, $inc) if ($inc & INC_DISCS || $inc & INC_COUNTS);
    if ($inc & INC_TRACKS || $inc & INC_COUNTS && $ar)
    {
        xml_track_list($ar, $al, $inc) 
    }
    elsif (defined $tnum)
    {
        print '<track-list offset="' .($tnum - 1) .'"/>';
    }
    xml_relations($al, 'album', $inc) if ($inc & INC_ARTISTREL || $inc & INC_RELEASEREL || $inc & INC_TRACKREL || $inc & INC_URLREL);
    
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
        print "<release-event-list>";
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
			print '<event date="';
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
                xml_track($ar, $tr, 0);
            }
            else
            {
                xml_track(undef, $tr, 0);
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
    if ($tr->GetLength())
    {
        print '<duration>';
        print xml_escape($tr->GetLength());
        print '</duration>';
    }
    xml_artist($ar, 0) if (defined $ar);
    if ($ar && $inc & INC_RELEASES)
    {
        my @albums = $tr->GetAlbumInfo();
        if (scalar(@albums))
        {
            my $al = Album->new($ar->{DBH});
            print '<release-list>';
            foreach my $i (@albums)
            {
                $al->SetMBId($i->[3]);
                if ($al->LoadFromId())
                {
                    xml_release($ar, $al, 0, $i->[2]) 
                }
            }
            print '</release-list>';
        }
    }
    xml_trm($tr) if ($inc & INC_TRMIDS);
    xml_relations($tr, 'track', $inc) if ($inc & INC_ARTISTREL || $inc & INC_RELEASEREL || $inc & INC_TRACKREL || $inc & INC_URLREL);
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

sub load_object
{
    my ($cache, $dbh, $id, $type) = @_;

    my ($k, $temp);
    if ($type eq 'artist')
    {
        $k = "artist-$id";
        if (exists $cache->{$k})
        {
            return $cache->{$k};
        }
        else
        {
            my $temp = Artist->new($dbh);
            MusicBrainz::IsGUID($id) ? $temp->SetMBId($id) : $temp->SetId($id);
            die "Could not load artist $id\n" if (!$temp->LoadFromId());
            $cache->{$k} = $temp;
            return $temp;
        }
    } 
    elsif ($type eq 'album')
    {
        $k = "album-" . $id;
        if (exists $cache->{$k})
        {
            return $cache->{$k};
        }
        else
        {
            $temp = Album->new($dbh);
            MusicBrainz::IsGUID($id) ? $temp->SetMBId($id) : $temp->SetId($id);
            die "Could not load release $id\n" if (!$temp->LoadFromId());
            $cache->{$k} = $temp;
            return $temp;
        }
    } 
    elsif ($type eq 'track')
    {
        $k = "track-" . $id;
        if (exists $cache->{$k})
        {
            return $cache->{$k};
        }
        else
        {
            $temp = Track->new($dbh);
            MusicBrainz::IsGUID($id) ? $temp->SetMBId($id) : $temp->SetId($id);
            die "Could not load track $id\n" if (!$temp->LoadFromId());
            $cache->{$k} = $temp;
            return $temp;
        }
    }
    undef;
}

sub xml_relations
{
    my ($obj, $type, $inc) = @_;

    require MusicBrainz::Server::Link;
    my @links = MusicBrainz::Server::Link->FindLinkedEntities($obj->{DBH}, $obj->GetId, $type);
    my (%rels);
    $rels{artist} = [];
    $rels{album} = [];
    $rels{track} = [];
    foreach my $item (@links)
    {
        my $temp;

        my $otype = $item->{"link" . (($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type) ? 1 : 0) . "_type"};
        my $oid = $item->{"link" . (($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type) ? 1 : 0) . "_id"};

        if ($item->{link0_id} == $obj->GetId && $item->{link0_type} eq $type)
        {
             if (($inc & INC_ARTISTREL && $item->{link1_type} eq 'artist') ||
                 ($inc & INC_RELEASEREL && $item->{link1_type} eq 'album') ||
                 ($inc & INC_TRACKREL && $item->{link1_type} eq 'track') ||
                 ($inc & INC_URLREL && $item->{link1_type} eq 'url'))
             {
                 my $ref = { 
                             type =>$item->{"link1_type"},
                             id =>$item->{"link1_mbid"}, 
                             name => $item->{"link_name"}, 
                             url => $item->{"link1_name"},
                             begindate => $item->{"begindate"},
                             enddate => $item->{"enddate"},
                           };
                 $ref->{backward} = 0 if $item->{link0_type} eq $item->{link1_type};
                 $ref->{_attrs} = $item->{"_attrs"} if (exists $item->{"_attrs"});
                 push @{$rels{$ref->{type}}}, $ref;
             }
        }
        else
        {
             if (($inc & INC_ARTISTREL && $item->{link0_type} eq 'artist') ||
                 ($inc & INC_RELEASEREL && $item->{link0_type} eq 'album') ||
                 ($inc & INC_TRACKREL && $item->{link0_type} eq 'track') ||
                 ($inc & INC_URLREL && $item->{link0_type} eq 'url'))
             {
                 my $ref = { 
                             type =>$item->{"link0_type"},
                             id =>$item->{"link0_mbid"}, 
                             name => $item->{"link_name"}, 
                             url => $item->{"link0_name"},
                             begindate => $item->{"begindate"},
                             enddate => $item->{"enddate"},
                           };
                 $ref->{backward} = 1 if $item->{link0_type} eq $item->{link1_type};
                 $ref->{_attrs} = $item->{"_attrs"} if (exists $item->{"_attrs"});
                 push @{$rels{$ref->{type}}}, $ref;
            }
        }
    }

    return if (!scalar(%rels));

    my (%cache);
    foreach my $ttype (('artist', 'album', 'track', 'url'))
    {
        next if (!defined($rels{$ttype}) || !scalar(@{$rels{$ttype}}));
        my $ttypename = $ttype;
        $ttypename = 'Release' if $ttype eq 'album';
        print '<relation-list target-type="' . ucfirst($ttypename) . '">';
        foreach my $rel (@{$rels{$ttype}})
        {
            # Set up the default attribute name
            my $name = $rel->{name};
            $name =~ s/(^|[^A-Za-z0-9])+([A-Za-z0-9]?)/uc $2/eg;
            my @attrlist;
    	    if (exists $rel->{"_attrs"})
            {
                # If we have more detailed attributes, collect them
                my $attrs = $rel->{"_attrs"}->GetAttributes();
                if ($attrs)
                {
                    foreach my $ref (@$attrs)
                    {
                        $ref->{value_text} =~ s/^\s*//;
                        push @attrlist, ucfirst($ref->{value_text});
                    }
                }
            }
            print '<relation type="' . $name . '"';
            print ' attributes="' . join(' ', @attrlist) . '"' if (scalar(@attrlist));
            print ' direction="backward" ' if (exists $rel->{backward} && $rel->{backward});
            print ' target="' . ($rel->{type} eq 'url' ? $rel->{url} : $rel->{id}) . '"';
            print ' begin="' . MusicBrainz::MakeDisplayDateStr($rel->{begindate}) . '"' if ($rel->{begindate} ne '          ');
            print ' end="' . MusicBrainz::MakeDisplayDateStr($rel->{enddate}) . '"' if ($rel->{enddate}) ne '          ';

            if ($rel->{type} eq 'artist')
            {
                print '>';
                xml_artist(load_object(\%cache, $obj->{DBH}, $rel->{id}, $rel->{type}, 0));
            } 
            elsif ($rel->{type} eq 'album')
            {
                print '>';
                my $al = load_object(\%cache, $obj->{DBH}, $rel->{id}, $rel->{type}, 0);
                my $ar = load_object(\%cache, $obj->{DBH}, $al->GetArtist, 'artist', 0);
                xml_release($ar, $al, 0);
            } 
            elsif ($rel->{type} eq 'track')
            {
                print '>';
                my $tr = load_object(\%cache, $obj->{DBH}, $rel->{id}, $rel->{type}, 0);
                xml_track(undef, $tr, 0);
            }
            else
            {
                print '/>';
                next;
            }
            print '</relation>';
        }
        print '</relation-list>';
    }
}

sub normalize
{
    my $t = $_[0];
    $t =~ s/[^\w\d ]/ /g;
    $t =~ s/ +/ /g;
    $t;
}

sub xml_search
{
    my ($r, $args) = @_;

    my $type = $args->{type};
    my $query = "";
    if ($type eq 'artist')
    {
        $query = $args->{artist};
    }
    elsif ($type eq 'release')
    {
        $query = normalize($args->{release});
        if ($args->{artistid})
        { 
            $args->{artistid} =~ s/-//g;
            $query .= " arid:" . normalize($args->{artistid});
        }
        else
        { 
            foreach my $term (split(/\s+/, $args->{artist}))
            {
                $query .= " artist:" . $term;
            }
        }
    }
    elsif ($type eq 'track')
    {
        $query = normalize($args->{track});
        if ($args->{artistid})
        { 
            $args->{artistid} =~ s/-//g;
            $query .= " arid:" . normalize($args->{artistid});
        }
        else
        { 
            foreach my $term (split(/\s+/, $args->{artist}))
            {
                $query .= " artist:" . $term;
            }
        }
        if ($args->{releaseid})
        { 
            $args->{releaseid} =~ s/-//g;
            $query .= " reid:" . normalize($args->{releaseid});
        }
        else
        { 
            foreach my $term (split(/\s+/, $args->{release}))
            {
                $query .= " release:" . $term;
            }
        }
    }
    else
    {
        die "Incorrect search type: $type\n";
    }

    use URI::Escape qw( uri_escape );
    my $url = 'http://' . &DBDefs::LUCENE_SERVER . "/ws/1/$type/?" .
              "max=" . $args->{limit} . "&type=$type&fmt=xml&query=". uri_escape($query);
    my $out;

    require LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get($url);
    if ( $response->is_success )
    {
        $out = '<?xml version="1.0" encoding="UTF-8"?>';
        $out .= '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#">';
        $out .= $response->content;
        $out .= '</metadata>';
    }
    else
    {
        if ($response->code == Apache::Constants::NOT_FOUND())
        {
            $out = '<?xml version="1.0" encoding="UTF-8"?>';
            $out .= '<metadata xmlns="http://musicbrainz.org/ns/mmd-1.0#"/>';
        }
        else
        {
            return bad_req($r, "Could not retrieve sub-document page from search server. Error: " .
                           $url . " -> " . $response->status_line);
        }
    }
   
    $r->set_content_length(length($out));
    $r->send_http_header("text/xml; charset=utf-8");
    $r->print($out) unless $r->header_only;
    $r->status(Apache::Constants::OK());
    return Apache::Constants::OK();
}

sub xml_escape
{
	my $t = $_[0];
	$t =~ s/&/&amp;/g;
	$t =~ s/</&lt;/g;
	$t =~ s/>/&gt;/g;
	return $t;
}

1;
# eof Common.pm
