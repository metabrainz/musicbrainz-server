#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Robert Kaye
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
#   $Id: Release.pm 8817 2007-02-17 17:39:55Z luks $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::CoverArt;

use Carp;

# make this a package/class variable, it can change 
our $ASIN_LINK_TYPE_ID = undef;
our $COVERART_LINK_TYPE_ID = undef;
our $INFO_LINK_TYPE_ID = undef;

# -------------------------- Amazon Cover Art Support -------------------------------------

my @CoverArtSites = 
(
   {
       name       => "CD Baby",
       domain     => "cdbaby.com",
       regexp     => 'http://cdbaby\.com/cd/(\w)(\w)(\w*)',
       imguri     => 'http://cdbaby.name/$1/$2/$1$2$3.jpg',
       releaseuri => 'http://cdbaby.com/cd/$1$2$3/from/musicbrainz',
   },
   {
       name       => "CD Baby",
       domain     => "cdbaby.name",
       regexp     => "http://cdbaby\.name/([a-z0-9])/([a-z0-9])/([A-Za-z0-9]*).jpg",
       imguri     => 'http://cdbaby.name/$1/$2/$3.jpg',
       releaseuri => 'http://cdbaby.com/cd/$3/from/musicbrainz',
   },
   {
       name       => 'archive.org',
       domain     => 'archive.org',
       regexp     => '^(.*\.(jpg|jpeg|png|gif))$',
       imguri     => '$1',
       releaseuri => '',
   },
   {
       name       => "Jamendo",
       domain     => "www.jamendo.com",
       regexp     => 'http://www\.jamendo\.com/(\w\w/)?album/(\d+)',
       imguri     => 'http://img.jamendo.com/albums/$2/covers/1.200.jpg',
       releaseuri => 'http://www.jamendo.com/album/$2',
   },
   {
       name       => '8bitpeoples.com',
       domain     => '8bitpeoples.com',
       regexp     => '^(.*)$',
       imguri     => '$1',
       releaseuri => '',
   },
   { 
       name       => 'www.ozon.ru',
       domain     => 'www.ozon.ru',
       regexp     => 'http://www.ozon\.ru/context/detail/id/(\d+)',
       imguri     => '',
       releaseuri => 'http://www.ozon.ru/context/detail/id/$1/?partner=musicbrainz',
   },
   { 
       name       => 'Encyclopédisque',
       domain     => 'encyclopedisque.fr',
       regexp     => 'http://www.encyclopedisque.fr/images/imgdb/(thumb250|main)/(\d+).jpg',
       imguri     => 'http://www.encyclopedisque.fr/images/imgdb/thumb250/$2.jpg',
       releaseuri => 'http://www.encyclopedisque.fr/',
   },
   { 
       name       => 'Thastrom',
       domain     => 'www.thastrom.se',
       regexp     => '^(.*)$',
       imguri     => '$1',
       releaseuri => '',
   },
   { 
       name       => 'Universal Poplab',
       domain     => 'www.universalpoplab.com',
       regexp     => '^(.*)$',
       imguri     => '$1',
       releaseuri => '',
   },
);

# amazon image file names are unique on all servers and constructed like
# <ASIN>.<ServerNumber>.[SML]ZZZZZZZ.jpg
# A release sold on amazon.de has always <ServerNumber> = 03, for example.
# Releases not sold on amazon.com, don't have a "01"-version of the image,
# so we need to make sure we grab an existing image.
my %CoverArtServer = (
    "amazon.jp" => {
		"server" => "ec1.images-amazon.com",
		"id"     => "09",
	},
    "amazon.co.jp" => {
		"server" => "ec1.images-amazon.com",
		"id"     => "09",
	},
    "amazon.co.uk" => {
		"server" => "ec1.images-amazon.com",
		"id"     => "02",
	},
    "amazon.de"    => {
		"server" => "ec2.images-amazon.com",
		"id"     => "03",
	},
    "amazon.com"   => {
		"server" => "ec1.images-amazon.com",
		"id"     => "01",
	},
    "amazon.ca"    => {
		"server" => "ec1.images-amazon.com",
		"id"     => "01",                   # .com and .ca are identical
	},
    "amazon.fr"    => {
		"server" => "ec1.images-amazon.com",
		"id"     => "08"
	},
);

# This cross reference allows us to take the ServerNumber and get a corresponding store from it
my %CoverArtStore = (
    "01" => "amazon.com",
    "02" => "amazon.co.uk",
    "03" => "amazon.de",
    "08" => "amazon.fr",
    "09" => "amazon.co.jp"
);

my %AmazonStoreRedirects = (
    "amazon.jp" => "amazon.co.jp",
    "amazon.at" => "amazon.de",
);

# Parse any amazon product URL 
# returns (asin, coverarturl, store) on success, ("", "", "") otherwise
sub ParseAmazonURL
{
	my ($self, $url, $al) = @_;
	my ($asin, $coverurl, $store);

    # default
    $store = "amazon.com";

    if ($url =~ m{^http://(?:www.)?(.*?)(?:\:[0-9]+)?/.*/([0-9B][0-9A-Z]{9})(?:[^0-9A-Z]|$)})
	{
		$asin = $2;
		my $cas = $1;
        $store = $1;
		my $cin = $CoverArtServer{$cas}{'id'};
		$cas = $CoverArtServer{$cas}{'server'};
		$coverurl = sprintf("http://%s/images/P/%s.%s.MZZZZZZZ.jpg", $cas, $asin, $cin)
			if ($cas && $asin);
	}
	else
	{
		return ("", "", "");
	}

	if (exists $AmazonStoreRedirects{$store})
	{
		$store = $AmazonStoreRedirects{$store};
	}

	# update the object data if called from an instance
	if ($al)
    {
	    $al->SetAsin($asin);
        $al->SetCoverartURL($coverurl);
        $al->SetCoverartStore($store);
    }

	return ($asin, $coverurl, $store);
}

# This updates the content of the album_amazon_asin table with the current
# asin and coverarturl for this album.
#
# $mode specifies the operation mode:
#   <0  delete the current entry
#    0  insert if not already present
#    1  insert or update
# In any case, the album must have a row in the album table, otherwise 0 is
# returned.
sub UpdateAmazonData
{
	my ($self, $release, $mode) = @_;
	my ($coverurl, $asin)  = ($release->GetCoverartURL, $release->GetAsin);
	my $ret = 0;
	
    return $ret unless ($coverurl && $asin && $release->GetId);

	# make sure the album exists and get current asin and cover data	
	my $sql = Sql->new($release->{DBH});
	my $old = $sql->SelectSingleRowArray(
		"SELECT asin, coverarturl FROM album_amazon_asin WHERE album = ?", $release->GetId
	);

	# old data from automatic update script can be either NULL or a real string or /' '{10}/
	my $oldasin = (defined $old && defined @$old[0] ? @$old[0] : '');
	my $oldcoverurl = (defined $old && defined @$old[1] ? @$old[1] : '');
	$oldasin =~ s/\s//g;
	$oldcoverurl =~ s/\s//g;
	
	# remove mode
	if ($mode == -1 && $old)
	{
		# check if there is another ASIN AR and update the asin and cover data
		# using this AR
		my @altlinks = MusicBrainz::Server::Link->FindLinkedEntities(
			$release->{DBH}, $release->GetId, 'album', ( 'to_type' => 'url' )
		);

		for my $item (@altlinks)
		{
			next unless ($item->{link_id} == MusicBrainz::Server::CoverArt::GetAsinLinkTypeId($release->{DBH}));
			
			($asin, $coverurl,,) = MusicBrainz::Server::CoverArt->ParseAmazonURL($item->{entity1name});
			next if ($asin eq $oldasin);

			# change the mode and old data, to allow inserting the alternative data
			$mode = 1;
			last;
		}

		# if there was no alternative ASIN AR, do a delete instead of just overwriting
		if ($mode == -1)
		{
			$sql->Do(
				qq|DELETE FROM album_amazon_asin
				   WHERE album = ?;|,
				$release->GetId
			) unless ($oldcoverurl eq "" && $oldasin eq "");
			$release->SetCoverartURL("");
			$release->SetAsin("");
			$ret =1;
		}
	}
	if ($mode >= 0 && !defined $old)
	{
		# insert mode
		# insert new row, if not present
		$ret = $sql->Do(
			qq|INSERT INTO album_amazon_asin
			   (album, asin, coverarturl, lastupdate)
			   VALUES (?, ?, ?, now());|,
			$release->GetId, $asin, $coverurl,
		);
	}
	elsif (($mode == 1 && defined $old && ($oldcoverurl ne $coverurl || $oldasin ne $asin))
			|| ($mode == 0 && ($oldasin eq '' || $oldcoverurl =~ m{^(/|\s*$)})))
	{
		# update mode
		# overwrite unconditionally if $mode == 1
		# overwrite old cover art url or NULL values if $mode == 0
		$ret = $sql->Do(
			qq|UPDATE album_amazon_asin
			   SET asin = ?, coverarturl = ?, lastupdate = now()
			   WHERE album = ?;|,
			$asin, $coverurl, $release->GetId,
		);
	}

	# reset $self data, to the new values
	$release->SetCoverartURL($coverurl);
	$release->SetAsin($asin);

	return $ret;
}

# Get the current link type id for the amazon asin AR.
# It should be used for any access to this class variable.
sub GetAsinLinkTypeId
{
	my $self = shift;
	return $ASIN_LINK_TYPE_ID if (defined $ASIN_LINK_TYPE_ID);
	
	# try to extract the id from the DB
	my $dbh = (ref $self ? $self->{DBH} : shift);

	my $sql = Sql->new($dbh);
	$ASIN_LINK_TYPE_ID = $sql->SelectSingleValue("SELECT id FROM lt_album_url WHERE name = 'amazon asin'")
		if (defined $sql);

	return $ASIN_LINK_TYPE_ID;
}

# -------------------------- Generic Cover Art Support -------------------------------------

# Parse a cover art URL and return the name of the store, the image url, and the info url.
sub ParseCoverArtURL
{
    my ($self, $uri, $al) = @_;

    for my $site (@CoverArtSites)
    {
        if ($uri =~ /$site->{domain}/)
        {
            if ($uri =~ /$site->{regexp}/)
            {
                my @a = (0, $1, $2, $3, $4, $5, $6, $7, $8, $9); 
                my $img = $site->{imguri};
                my $release = $site->{releaseuri};

                $img =~ s/\$$_/$a[$_]/g for(1..9);
                $release =~ s/\$$_/$a[$_]/g for(1..9);

                if (defined $al)
                {
                    $al->SetCoverartURL($img);
                    $al->SetInfoURL($release);
                }
                return ($site->{name}, $img, $release);
            }
            else
            {
                return ($site->{name}, '', '');
            }
        }
    }
    return ("", "", "");
}

# This updates the content of the album_amazon_asin table with the current
# coverarturl for the given album.
#
# $mode specifies the operation mode:
#   <0  delete the current entry
#    0  insert if not already present
#    1  insert or update
# In any case, the album must have a row in the album table, otherwise 0 is
# returned.
sub UpdateCoverArtData
{
	my ($self, $release, $mode) = @_;
	my $coverurl = $release->GetCoverartURL;
	my $ret = 0;
	
	return $ret unless ($coverurl && $release->GetId);

	# make sure the album exists and get current cover url	
	my $sql = Sql->new($release->{DBH});
	my $old = $sql->SelectSingleRowArray(
		"SELECT coverarturl FROM album_amazon_asin WHERE album = ?", $release->GetId
	);

	# old data from automatic update script can be either NULL or a real string or /' '{10}/
	my $oldcoverurl = (defined $old && defined @$old[0] ? @$old[0] : '');
	$oldcoverurl =~ s/\s//g;
	
	# remove mode
	if ($mode == -1 && $old)
	{
        my $dummy;

		# check if there is another coverart AR and update the cover data using this AR
		my @altlinks = MusicBrainz::Server::Link->FindLinkedEntities(
			$release->{DBH}, $release->GetId, 'album', ( 'to_type' => 'url' )
		);

		for my $item (@altlinks)
		{
			next unless ($item->{link_id} == MusicBrainz::Server::CoverArt::GetCoverArtLinkTypeId($release->{DBH}));
			
			($dummy, $coverurl,) = MusicBrainz::Server::CoverArt->ParseCoverArtURL($item->{entity1name});
			next if ($coverurl eq $oldcoverurl);

			# change the mode and old data, to allow inserting the alternative data
			$mode = 1;
			last;
		}

		# if there was no alternative coverart AR, do a delete instead of just overwriting
		if ($mode == -1)
		{
			$sql->Do(
				qq|DELETE FROM album_amazon_asin
				   WHERE album = ?;|,
				$release->GetId
			) unless ($oldcoverurl eq "");
			$release->SetCoverartURL("");
			$release->SetAsin("");
			$ret =1;
		}
	}
	if ($mode >= 0 && !defined $old)
	{
		# insert mode
		# insert new row, if not present
		$ret = $sql->Do(
			qq|INSERT INTO album_amazon_asin
			   (album, asin, coverarturl, lastupdate)
			   VALUES (?, '', ?, now())|,
			$release->GetId, $coverurl
		);
	}
	elsif (($mode == 1 && defined $old && ($oldcoverurl ne $coverurl))
			|| ($mode == 0 && ($oldcoverurl =~ m{^(/|\s*$)})))
	{
		# update mode
		# overwrite unconditionally if $mode == 1
		# overwrite old cover art url or NULL values if $mode == 0
		$ret = $sql->Do(
			qq|UPDATE album_amazon_asin
			   SET asin = '', coverarturl = ?, lastupdate = now()
			   WHERE album = ?;|,
			$coverurl, $release->GetId,
		);
    }

	# reset $self data, to the new values
	$release->SetCoverartURL($coverurl);
	$release->SetAsin("");

	return $ret;
}

# Get the current link type id for the cover art AR.
sub GetCoverArtLinkTypeId
{
	my $self = shift;
	return $COVERART_LINK_TYPE_ID if (defined $COVERART_LINK_TYPE_ID);

	# try to extract the id from the DB
	my $dbh = (ref $self ? $self->{DBH} : shift);

	my $sql = Sql->new($dbh);
	$COVERART_LINK_TYPE_ID = $sql->SelectSingleValue("SELECT id FROM lt_album_url WHERE name = 'cover art link'")
		if (defined $sql);

	return $COVERART_LINK_TYPE_ID;
}

sub IsValidCoverArtURL
{
    my ($self, $url) = @_;

    my ($sitename,,) = MusicBrainz::Server::CoverArt->ParseCoverArtURL($url);
    return $sitename eq "" ? 0 : 1;
}

# Return a list of acceptable cover art uri regexps.
sub GetValidRegExps
{
    my $self = shift;
    return grep { $_ ne '^(.*)$' } map $_->{regexp}, @CoverArtSites;
}

1;
# eof CoverArt.pm
