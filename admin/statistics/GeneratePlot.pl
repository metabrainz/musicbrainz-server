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

sub OutputPlotFile
{
    my ($datfile, $plotfile, $outfile, $from_date, $to_date) = @_;

    open PLOT, ">$plotfile" or die "Cannot open plotfile.\n";

print PLOT <<END;
set terminal gif
set xdata time
set timefmt "%d %m %Y"
set xlabel "Time"
set xrange ["$from_date" : "$to_date"]
set format x "%m/%Y"
set key left
set ylabel "Number of entries in MusicBrainz"

set output "$outfile"

plot "$datfile" using 1:(\$5) title "Albums" with linespoints, \\
     "$datfile" using 1:(\$6) title "Artists" with linespoints, \\
     "$datfile" using 1:(\$7) title "Moderations" with linespoints, \\
     "$datfile" using 1:(\$4) title "Discids" with linespoints, \\
     "$datfile" using 1:(\$8) title "TRM Ids" with linespoints
END

    close PLOT;
}

sub DumpStats
{
    my ($sql, $outfile) = @_;
    my ($plotfile, $datfile, $count, $start, $end);

    $plotfile = "/tmp/plotfile.$$";
    $datfile = "/tmp/datfile.$$";
    if ($sql->Select("select * from Stats order by timestamp asc"))
    {
        my @row;

        open STATS, ">$datfile" or die "Cannot create temp file.\n";
        $count = 0;
        while(@row = $sql->NextRow())
        {
            if ($row[9] =~ /(\d\d\d\d)-(\d\d)-(\d\d)/)
            {
                $start = "$2 $3 $1" if ($count == 0);
                $end = "$2 $3 $1";
                print STATS "$2 $3 $1 $row[4] $row[2] $row[1] $row[6] $row[5]\n";
                $count++;
            }
        }
        close STATS;

        OutputPlotFile($datfile, $plotfile, $outfile, $start, $end);
        system("gnuplot $plotfile");
        unlink $datfile;
        unlink $plotfile;

        $sql->Finish();
    }

    return 1;
}

my $giffile = shift;
if (not defined $giffile)
{
    print "Usage: GeneratePlot.pl <output .gif file>\n";
    return;
}

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

DumpStats($sql, $giffile);

# Disconnect
$mb->Logout;
