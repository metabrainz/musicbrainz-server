#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2006 Björn Krombholz
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
#   
#   This is a simple script that updates the album_amazon_asin and
#   albummeta tables with data from the new ASIN advanced relationships.
#   Required for upgrades to the 20060305 release.
#
#   $Id$
#____________________________________________________________________________

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

require DBDefs;
require MusicBrainz;
require Sql;
require MusicBrainz::Server::Release;

my $verbose = 1;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});

$verbose
	? open(LOG, ">&STDOUT")
	: open(LOG, ">/dev/null");


################################################################################

my $amazon_link_type = $sql->SelectSingleValue("SELECT id FROM lt_album_url WHERE name = 'amazon asin'");

print LOG localtime() . " : Updating old amazon data from ASIN advanced relationships.\n";
# first get interesting rows from l_album_url
my $rows = $sql->SelectListOfHashes('
	SELECT link0 AS alid, url 
	FROM l_album_url JOIN url ON link1 = url.id
	WHERE link_type = ?
	ORDER BY link0',
	$amazon_link_type
);

$sql->Begin;

my ($asin, $coverurl);
my $i = 0;
my %done;
for my $link (@$rows)
{
	my $al = MusicBrainz::Server::Release->new($mb->{dbh});
	my $alid = $link->{alid};
	$al->SetId($alid);

	if (!$done{$alid} && $al->LoadFromId(1))
	{
		($asin, $coverurl,) = $al->ParseAmazonURL($link->{url});
		if ($asin ne "")
		{
			if ($al->UpdateAmazonData(1))
			{ 
				$i++;
				$done{$alid} = 1;
			}
		}
	}
}

$sql->Commit;

print LOG localtime() . " : Done! (Updated " . $i . " row)\n";

# eof UpdateAmazonDataFromAsinAR
