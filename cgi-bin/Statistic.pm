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
#   $Id$
#____________________________________________________________________________

use 5.6.1;

package Statistic;

use strict;
use Sql;

sub new
{
	my ($type, $dbh) = @_;

	my $this = TableBase->new($dbh);
	return bless $this, $type;
}

# Fetch current stat(s)
# $value = $stat->Fetch($name)
# @values = $stat->Fetch(@names)

sub Fetch
{
	my ($self, @names) = @_;
	return unless @names;

	my $sql = Sql->new($self->{DBH});

	my %s;
	@s{@names} = ();

	my $qs = join ", ", (("?") x scalar(keys %s));
	my $data = $sql->SelectListOfLists(
		"SELECT name, value FROM currentstat WHERE name IN ($qs)",
		keys(%s),
	);

	for (@$data)
	{
		$s{ $_->[0] } = $_->[1];
	}

	unless (wantarray)
	{
		my $v = $s{$names[0]};
		warn "No stat data for '$names[0]'" unless defined $v;
		return $v;
	}

	@s{@names};
}

# Fetch all currentstat as a hash reference

sub FetchAllAsHashRef
{
	my $self = shift;

	my $sql = Sql->new($self->{DBH});

	my $data = $sql->SelectListOfLists(
		"SELECT name, value FROM currentstat",
	);

	+{
		map { @$_ } @$data
	};
}

# Write stats into currentstat.
# $stat->Update(name => value, name => value, ...);

sub Update
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	$sql->Do("LOCK TABLE currentstat IN EXCLUSIVE MODE");

	while (my ($name, $value) = splice(@_, 0, 2))
	{
		print "Stat $name = $value\n" if -t STDOUT;

		$sql->Do(
			"UPDATE currentstat SET value = ?, lastupdated = NOW() WHERE name = ?",
			$value,
			$name,
		)
			or
		$sql->Do(
			"INSERT INTO currentstat (name, value, lastupdated) VALUES (?, ?, NOW())",
			$name,
			$value,
		);
	}
}

# Take a snapshot of all of the currentstat data as today's historicalstat
# Deletes today's historicalstat first if required.

sub TakeSnapshot
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $date = $sql->SelectSingleValue("SELECT current_date");

	$sql->Do(
		"DELETE FROM historicalstat WHERE snapshotdate = ?",
		$date,
	);

	$sql->Do(
		"INSERT INTO historicalstat (name, value, snapshotdate)
			SELECT name, value, ? FROM currentstat",
		$date,
	);
}

################################################################################

my %stats = (
	"count.album" => {
		DESC => "Count of all albums",
		SQL => "SELECT COUNT(*) FROM album",
	},
	"count.artist" => {
		DESC => "Count of all artists",
		SQL => "SELECT COUNT(*) FROM artist",
	},
	"count.discid" => {
		DESC => "Count of all discids",
		SQL => "SELECT COUNT(*) FROM discid",
	},
	"count.moderation" => {
		DESC => "Count of all moderations",
		SQL => "SELECT COUNT(*) FROM moderation",
	},
	"count.moderator" => {
		DESC => "Count of all moderators",
		SQL => "SELECT COUNT(*) FROM moderator",
	},
	"count.track" => {
		DESC => "Count of all tracks",
		SQL => "SELECT COUNT(*) FROM track",
	},
	"count.trm" => {
		DESC => "Count of all TRMs joined to tracks",
		SQL => "SELECT COUNT(*) FROM trmjoin",
	},
	"count.vote" => {
		DESC => "Count of all votes",
		SQL => "SELECT COUNT(*) FROM votes",
	},

	"count.various_album" => {
		DESC => "Count of all 'Various Artists' albums",
		SQL => "SELECT COUNT(*) FROM album WHERE artist = " . ModDefs::VARTIST_ID,
	},
	"count.non_various_album" => {
		DESC => "Count of all 'Various Artists' albums",
		PREREQ => [qw[ count.album count.various_album ]],
		CALC => sub {
			my ($self, $sql) = @_;

			$self->Fetch("count.album")
			- $self->Fetch("count.various_album");
		},
	},

	"count.tracks_with_trm" => {
		DESC => "Count of tracks with at least one TRM",
		SQL => "SELECT COUNT(DISTINCT track) FROM trmjoin",
	},

	"trm.trackspertrm" => {
		DESC => "Distribution of tracks per TRM (collisions)",
		CALC => sub {
			my ($self, $sql) = @_;

			my $max_dist_tail = 10;

			my $data = $sql->SelectListOfLists(
				"SELECT c, COUNT(*) AS freq
				FROM (
					SELECT trm, COUNT(*) AS c
					FROM trmjoin
					GROUP BY trm
				) AS t
				GROUP BY c
				",
			);

			my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

			for (@$data)
			{
				$dist{ $_->[0] } = $_->[1], next
					if $_->[0] < $max_dist_tail;

				$dist{$max_dist_tail} += $_->[1];
			}
			
			my $prefix = "trm.trackspertrm.";
			+{ map { $prefix.$_ => $dist{$_} } keys %dist };
		},
	},
	"trm.trmspertrack" => {
		DESC => "Distribution of TRMs per track (varying TRMs)",
		PREREQ => [qw[ count.track count.tracks_with_trm ]],
		CALC => sub {
			my ($self, $sql) = @_;

			my $max_dist_tail = 10;

			my $data = $sql->SelectListOfLists(
				"SELECT c, COUNT(*) AS freq
				FROM (
					SELECT track, COUNT(*) AS c
					FROM trmjoin
					GROUP BY track
				) AS t
				GROUP BY c
				",
			);

			my %dist = map { $_ => 0 } 1 .. $max_dist_tail;

			for (@$data)
			{
				$dist{ $_->[0] } = $_->[1], next
					if $_->[0] < $max_dist_tail;

				$dist{$max_dist_tail} += $_->[1];
			}

			$dist{0} = $self->Fetch("count.tracks")
				- $self->Fetch("count.tracks_with_trm");
			
			my $prefix = "trm.trmspertrack.";
			+{ map { $prefix.$_ => $dist{$_} } keys %dist };
		},
	},
);

sub RecalculateStat
{
	my ($self, $name) = @_;
	my $sql = Sql->new($self->{DBH});

	my $def = $stats{$name}
		or warn("Unknown stat name '$name'"), return;

	if (my $query = $def->{SQL})
	{
		my $value = $sql->SelectSingleValue($query);
		$self->Update($name, $value);
		return;
	}

	if (my $sub = $def->{CALC})
	{
		my $towrite = $sub->($self, $sql);
		$self->Update(%$towrite);
		return;
	}

	warn "Can't calculate $name yet";
}

sub RecalculateAll
{
	my $self = shift;

	for my $name (sort keys %stats)
	{
		$self->RecalculateStat($name);
	}
}

1;
# vi: set ts=4 sw=4 :
