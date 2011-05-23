#!/usr/bin/env perl

use warnings;
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2007 Robert Kaye
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

use FindBin;
use lib "$FindBin::Bin/../../lib";

use strict;
use DBDefs;
use MusicBrainz::Server::Release;
use MusicBrainz;
use MusicBrainz::Server::CoverArt;

use Getopt::Long;
my $dry_run = 0;
my $help = 0;
GetOptions(
    "dry-run|dryrun!"   => \$dry_run,
    "help"                              => \$help,
) or exit 2;
$help = 1 if @ARGV;

die <<EOF if $help;
Usage: UpdateCoverArt.pl [OPTIONS]

Allowed options are:
        --[no]dry-run     don't actually make any changes (default is to make the changes)
        --help            show this help

EOF

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});
$| = 1;

# Update Amazon Cover Art
$sql->Select("select album.id, asin, coverarturl, url 
                from album, albummeta, l_album_url, url 
               where album.id = albummeta.id 
                 and album.id = link0 
                 and link_type = 30 
                 and link1 = url.id 
                 and (coverarturl = '' OR coverarturl is null)");
while (my ($id, $asin, $coverarturl, $url) = $sql->NextRow)
{
    my $al = MusicBrainz::Server::Release->new($mb->{dbh});
    $al->SetId($id);
    if ($al->LoadFromId(1))
    {
        my ($newasin, $newcoverurl, $newstore) = MusicBrainz::Server::CoverArt->ParseAmazonURL($url, $al);
        if ($newasin && $newcoverurl)
        {
            $al->SetCoverartURL($newcoverurl);
            $al->SetAsin($newasin);
#print "Update cover art for " . $al->GetId . " to $newasin / $newcoverurl\n";

            eval {
                $sql->Begin();
                MusicBrainz::Server::CoverArt->UpdateAmazonData($al, 1) if !$dry_run;
                $sql->Commit();
            };
            if ($@)
            {
                print "Error: $@\n";
                eval { $sql->Rollback; };
            }
        }
        else
        {
            print "Could not parse amazon url: $url for album " . $al->GetId . "\n";
        }
    }
    else
    {
        print "Could not load release: " . $al->GetId . "\n";
    }
}
# eof UpdateCoverArt.pl
