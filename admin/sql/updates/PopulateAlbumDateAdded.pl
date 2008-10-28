#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;
use MusicBrainz::Server::URL;

my $mb = MusicBrainz->new;
$mb->Login();
my $sql = Sql->new($mb->{DBH});

my $set = 0;
my $chunks = shift;
$chunks = 50 if (!$chunks);

if ($sql->Select("SELECT rowid, opentime FROM moderation_all, albummeta 
                   WHERE dateadded = '1970-01-01 00:00:00-00' 
				     AND albummeta.id = moderation_all.rowid 
					 AND type = 16
      			ORDER BY rowid"))
{
    my @row;

	while(@row = $sql->NextRow)
	{
		eval
		{
            $sql->Begin;
            $sql->Do("UPDATE albummeta SET dateadded = ? WHERE id = ?", $row[1], $row[0]);
			$sql->Commit;
		};
		if ($@)
		{
			my $err = $@;

			print $err;
			$sql->Rollback;
			last;
		}
		$set++;
		if ($set % $chunks == 0)
		{
			print "Updated to row $row[0]\n";
			sleep(1) 
		}
	}
    $sql->Finish;
}
