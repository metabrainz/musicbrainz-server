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

	my $startdate = '2003-01-10';

	my $data = $sql->SelectListOfLists(
		"SELECT snapshotdate, value FROM historicalstat
		WHERE name = ?
		AND snapshotdate >= '$startdate'
		ORDER BY 1",
		$statname,
	);

	require Statistic;
	my $name = Statistic->GetStatDescription($statname);
	plot($data, $name, "plot_$statname.png");

	# Weekly deltas.
	$data = $sql->SelectListOfLists(
		"SELECT b.snapshotdate, b.value - a.value
		FROM historicalstat a, historicalstat b
		WHERE a.name = ? AND b.name = a.name
		AND b.snapshotdate - a.snapshotdate = 7
		AND b.snapshotdate >= '$startdate'
		ORDER BY 1",
		$statname,
	);

	return if !scalar(@$data);

	# Certain stats are known to suffer from spikes due to culls.

	my @range = (undef, undef);

	# The 'startdate' above is chosen to be just after the latest cull.
	# Hence, no need to suppress spikes.
	goto PLOT;

	goto PLOT unless $statname =~ /
		^count\.(artist|album|track|puid)$
		/ix;

	# To avoid plotting spikes that result from culls,
	# fetch info about *daily* deltas.  Thus we identify the normal range.
	my ($avg, $stddev) = @{
		$sql->SelectSingleRowArray(
		"SELECT AVG(b.value - a.value), STDDEV(b.value - a.value)
		FROM historicalstat a, historicalstat b
		WHERE a.name = ? AND b.name = a.name
		AND b.snapshotdate - a.snapshotdate = 1",
		$statname,
		)
	};

	# 5 * the standard deviation should cover it.
	my $min = $avg - 5*$stddev;
	my $max = $avg + 5*$stddev;

	my $minabovemin = $max;
	my $maxbelowmax = $min;

	# Find the range of data within 5*stddev of the daily deltas.
	for (@$data)
	{
		my $v = $_->[1];
		next if $v < $min or $v > $max;
		$minabovemin = $v if $v < $minabovemin;
		$maxbelowmax = $v if $v > $maxbelowmax;
	}

	# Extend up and down a little so the plot doesn't quite hit the
	# edges.
	my $size = $maxbelowmax - $minabovemin;
	$minabovemin -= $size/20;
	$maxbelowmax += $size/20;
	@range = ($minabovemin, $maxbelowmax);

	PLOT:
	$name = Statistic->GetStatDescription($statname);
	plot($data, $name . " (7 day delta)", "plot_${statname}_delta.png",
		@range,
	);
}

sub plot
{
	my ($data, $title, $file, $min, $max) = @_;

	# Hard-wire all y-axes to start at zero.
	$min = 0;

	printf "%s => %s (%d) (%s)\n",
		$title, $file,
		scalar(@$data),
		(defined($max) ? "$min-$max" : "auto"),
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

set terminal png small notransparent
set xdata time
set timefmt "%Y-%m-%d"
set xlabel "Date"
EOF

	defined() or $_ = "*"
		for ($min, $max);

	print GNUPLOT "set yrange [$min:$max]\n";

	print GNUPLOT <<EOF;
set format x "%b %Y"
set key left
set ylabel "$title"

set output "$ImageDir/$file"

plot	"$tmpfile" using 1:(\$2) title "$title" with lines

EOF
	close GNUPLOT;

	unlink $tmpfile or warn "unlink $tmpfile: $!"
		if -f $tmpfile;
}

count_and_delta("count.artist");
count_and_delta("count.album");
count_and_delta("count.track");
count_and_delta("count.label");
count_and_delta("count.ar.links");
count_and_delta("count.puid");
count_and_delta("count.discid");
count_and_delta("count.moderator");
count_and_delta("count.moderation");
count_and_delta("count.moderation.open");
count_and_delta("count.vote");
count_and_delta("count.tag");
count_and_delta("count.tag.raw");

# Disconnect
$mb->Logout;
