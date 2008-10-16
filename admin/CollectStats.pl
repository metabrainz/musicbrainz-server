#!/usr/bin/perl -w
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

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use DBDefs;
use MusicBrainz;
use Sql;

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

use MusicBrainz::Server::Statistic;
my $s = MusicBrainz::Server::Statistic->new($mb->{DBH});

$sql->Begin;
$s->RecalculateAll;
$s->TakeSnapshot;
$sql->Commit;

if (-t STDOUT)
{
	my $all = $s->FetchAllAsHashRef;
	printf "%10d : %s\n", $all->{$_}, $_
		for sort keys %$all;
}

# Disconnect
$mb->Logout;
