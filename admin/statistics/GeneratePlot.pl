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
use lib "$FindBin::Bin/../../cgi-bin";

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;

$mb = MusicBrainz->new;
$mb->Login;
$sql = Sql->new($mb->{DBH});

my $ImageDir = shift;
-d $ImageDir or die "Usage: GeneratePlot.pl <imagedir>";

sub count_and_delta
{
	my $statname = shift;

	my $data = $sql->SelectListOfLists(
		"SELECT snapshotdate, value FROM historicalstat
		WHERE name = ? ORDER BY 1",
		$statname,
	);

	require Statistic;
	my $name = Statistic->GetStatDescription($statname);
	plot($data, $name, "plot_$statname.png");

	$data = $sql->SelectListOfLists(
		"SELECT b.snapshotdate, b.value - a.value
		FROM historicalstat a, historicalstat b
		WHERE a.name = ? AND b.name = a.name
		AND b.snapshotdate - a.snapshotdate = 7
		ORDER BY 1",
		$statname,
	);

	$name = Statistic->GetStatDescription($statname);
	plot($data, $name . " (7 day delta)", "plot_${statname}_delta.png");
}

sub plot
{
	my ($data, $title, $file) = @_;

	printf "%s => %s (%d)\n",
		$title, $file,
		scalar(@$data),
		if -t STDOUT;

	my $tmpfile = "/tmp/plot-$$";

	open(DAT, ">$tmpfile") or die $!;

	for (@$data)
	{
		print DAT "$_->[0] $_->[1]\n";
	}
	close DAT;

	open(GNUPLOT, "| gnuplot") or die $!;
	print GNUPLOT <<EOF;

set terminal png small color
set xdata time
set timefmt "%Y-%m-%d"
set xlabel "Date"
#set yrange [0:*]
set format x "%m/%Y"
set key left
set ylabel "$title"

set output "$ImageDir/$file"

plot	"$tmpfile" using 1:(\$2) title "$title" with linespoints

EOF
	close GNUPLOT;

	unlink $tmpfile or warn "unlink $tmpfile: $!"
		if -f $tmpfile;
}

count_and_delta("count.artist");
count_and_delta("count.album");
count_and_delta("count.track");
count_and_delta("count.trm");
count_and_delta("count.discid");
count_and_delta("count.moderator");
count_and_delta("count.moderation");
count_and_delta("count.vote");

# Disconnect
$mb->Logout;
