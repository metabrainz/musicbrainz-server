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

use lib "../../cgi-bin";
use DBI;
use DBDefs;
use MusicBrainz;
use Artist;
use ModDefs;
use Sql;

sub DumpStats
{
    my ($sql) = @_;

    if ($sql->Select("select * from Stats order by timestamp desc"))
    {
        my @row;

        open STATS, ">mb.dat" or die "Cannot create temp file.\n";
        while(@row = $sql->NextRow())
        {
            if ($row[9] =~ /(\d\d\d\d)-(\d\d)-(\d\d)/)
            {
                print STATS "$2 $3 $1 $row[3] $row[2] $row[1] $row[6] $row[5]\n";
            }
        }
        close STATS;

        system("gnuplot mb_plot_last_30_days");
        unlink "mb.dat";

        $sql->Finish();
    }

    return 1;
}

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

DumpStats($sql);

# Disconnect
$mb->Logout;
