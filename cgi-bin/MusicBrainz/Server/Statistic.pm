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

package MusicBrainz::Server::Statistic;

use Exporter;
use POSIX;
use TableBase;
{ our @ISA = qw( Exporter TableBase ) }
use strict;
use ModDefs;
use Sql;
use MusicBrainz::Server::Cache;

sub new
{
	my ($type, $dbh) = @_;

	my $this = { DBH => $dbh };
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

# Find "the time" at which the current stats were taken.
# Actually the timestamp of the oldest stat.

sub LastRefreshed
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});
	$sql->SelectSingleValue("SELECT MIN(lastupdated) FROM currentstat");
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
		DESC => "Count of all releases",
		SQL => "SELECT COUNT(*) FROM album",
	},
	"count.artist" => {
		DESC => "Count of all artists",
		SQL => "SELECT COUNT(*) FROM artist",
	},
	"count.label" => {
		DESC => "Count of all labels",
		SQL => "SELECT COUNT(*) FROM label",
	},
	"count.discid" => {
		DESC => "Count of all disc IDs",
		SQL => "SELECT COUNT(*) FROM album_cdtoc",
	},
	"count.moderation" => {
		DESC => "Count of all edits",
		SQL => "SELECT COUNT(*) FROM moderation_all",
	},
	"count.moderator" => {
		DESC => "Count of all editors",
		SQL => "SELECT COUNT(*) FROM moderator",
	},
	"count.puid" => {
		DESC => "Count of all PUIDs joined to tracks",
		SQL => "SELECT COUNT(*) FROM puidjoin",
	},
	"count.puid.ids" => {
		DESC => "Count of unique PUIDs",
		SQL => "SELECT COUNT(DISTINCT puid) FROM puidjoin",
	},
	"count.track" => {
		DESC => "Count of all tracks",
		SQL => "SELECT COUNT(*) FROM track",
	},
	"count.vote" => {
		DESC => "Count of all votes",
		SQL => "SELECT COUNT(*) FROM vote_all",
	},

	"count.album.various" => {
		DESC => "Count of all 'Various Artists' releases",
		SQL => "SELECT COUNT(*) FROM album WHERE artist = " . &ModDefs::VARTIST_ID,
	},
	"count.album.nonvarious" => {
		DESC => "Count of all 'Various Artists' releases",
		PREREQ => [qw[ count.album count.album.various ]],
		CALC => sub {
			my ($self, $sql) = @_;

			$self->Fetch("count.album")
				- $self->Fetch("count.album.various")
		},
	},

	"count.album.has_discid" => {
		DESC => "Count of releases with at least one disc ID",
		SQL => "SELECT COUNT(DISTINCT album) FROM album_cdtoc",
	},
	"count.album.Ndiscids" => {
		DESC => "Distribution of disc IDs per release (varying disc IDs)",
		PREREQ => [qw[ count.album count.album.has_discid ]],
		CALC => sub {
			my ($self, $sql) = @_;

			my $max_dist_tail = 10;

			my $data = $sql->SelectListOfLists(
				"SELECT c, COUNT(*) AS freq
				FROM (
					SELECT album, COUNT(*) AS c
					FROM album_cdtoc
					GROUP BY album
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

			$dist{0} = $self->Fetch("count.album")
				- $self->Fetch("count.album.has_discid");
			
			+{
				map {
					"count.album.".$_."discids" => $dist{$_}
				} keys %dist
			};
		},
	},

	"count.quality.album.high" => {
		DESC => "Count of high quality releases",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectListOfLists(
				"SELECT quality, COUNT(*) FROM album GROUP BY quality",
			);

			my %dist = map { @$_ } @$data;
			# Transfer unknown quality count to the level represented by &ModDefs::QUALITY_UNKNOWN_MAPPED
			# but still keep unknown quality count on its own, for reference
			$dist{&ModDefs::QUALITY_UNKNOWN_MAPPED} += $dist{&ModDefs::QUALITY_UNKNOWN};

			+{
				"count.quality.album.high"		=> $dist{&ModDefs::QUALITY_HIGH}	|| 0,
				"count.quality.album.low"		=> $dist{&ModDefs::QUALITY_LOW}		|| 0,
				"count.quality.album.normal"	=> $dist{&ModDefs::QUALITY_NORMAL}	|| 0,
				"count.quality.album.unknown"	=> $dist{&ModDefs::QUALITY_UNKNOWN}	|| 0,
			};
		},
	},
	"count.quality.album.low" => {
		DESC => "Count of low quality releases",
		PREREQ => [qw[ count.quality.album.high ]],
		PREREQ_ONLY => 1,
	},
	"count.quality.album.normal" => {
		DESC => "Count of normal quality releases",
		PREREQ => [qw[ count.quality.album.high ]],
		PREREQ_ONLY => 1,
	},
	"count.quality.album.unknown" => {
		DESC => "Count of unknow quality releases",
		PREREQ => [qw[ count.quality.album.high ]],
		PREREQ_ONLY => 1,
	},

	"count.quality.artist.high" => {
		DESC => "Count of high quality releases",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectListOfLists(
				"SELECT quality, COUNT(*) FROM artist GROUP BY quality",
			);

			my %dist = map { @$_ } @$data;

			# Transfer unknown quality count to the level represented by &ModDefs::QUALITY_UNKNOWN_MAPPED
			# but still keep unknown quality count on its own, for reference
			$dist{&ModDefs::QUALITY_UNKNOWN_MAPPED} += $dist{&ModDefs::QUALITY_UNKNOWN};

			+{
				"count.quality.artist.high"		=> $dist{&ModDefs::QUALITY_HIGH}	|| 0,
				"count.quality.artist.low"		=> $dist{&ModDefs::QUALITY_LOW}		|| 0,
				"count.quality.artist.normal"	=> $dist{&ModDefs::QUALITY_NORMAL}	|| 0,
				"count.quality.artist.unknown"	=> $dist{&ModDefs::QUALITY_UNKNOWN}	|| 0,
			};
		},
	},
	"count.quality.artist.low" => {
		DESC => "Count of low quality artists",
		PREREQ => [qw[ count.quality.artist.high ]],
		PREREQ_ONLY => 1,
	},
	"count.quality.artist.normal" => {
		DESC => "Count of normal quality artists",
		PREREQ => [qw[ count.quality.artist.high ]],
		PREREQ_ONLY => 1,
	},
	"count.quality.artist.unknown" => {
		DESC => "Count of unknow quality artists",
		PREREQ => [qw[ count.quality.artist.high ]],
		PREREQ_ONLY => 1,
	},

	"count.puid.Ntracks" => {
		DESC => "Distribution of tracks per PUID (collisions)",
		CALC => sub {
			my ($self, $sql) = @_;

			my $max_dist_tail = 10;

			my $data = $sql->SelectListOfLists(
				"SELECT c, COUNT(*) AS freq
				FROM (
					SELECT puid, COUNT(*) AS c
					FROM puidjoin
					GROUP BY puid
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
			
			+{
				map {
					"count.puid.".$_."tracks" => $dist{$_}
				} keys %dist
			};
		},
	},

	"count.track.has_puid" => {
		DESC => "Count of tracks with at least one PUID",
		SQL => "SELECT COUNT(DISTINCT track) FROM puidjoin",
	},
	"count.track.Npuids" => {
		DESC => "Distribution of PUIDs per track (varying PUIDs)",
		PREREQ => [qw[ count.track count.track.has_puid ]],
		CALC => sub {
			my ($self, $sql) = @_;

			my $max_dist_tail = 10;

			my $data = $sql->SelectListOfLists(
				"SELECT c, COUNT(*) AS freq
				FROM (
					SELECT track, COUNT(*) AS c
					FROM puidjoin
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

			$dist{0} = $self->Fetch("count.track")
				- $self->Fetch("count.track.has_puid");
			
			+{
				map {
					"count.track.".$_."puids" => $dist{$_}
				} keys %dist
			};
		},
	},

	"count.moderation.open" => {
		DESC => "Count of open edits",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectListOfLists(
				"SELECT status, COUNT(*) FROM moderation_all GROUP BY status",
			);

			my %dist = map { @$_ } @$data;

			+{
				"count.moderation.open"			=> $dist{&ModDefs::STATUS_OPEN}			|| 0,
				"count.moderation.applied"		=> $dist{&ModDefs::STATUS_APPLIED}		|| 0,
				"count.moderation.failedvote"	=> $dist{&ModDefs::STATUS_FAILEDVOTE}	|| 0,
				"count.moderation.faileddep"	=> $dist{&ModDefs::STATUS_FAILEDDEP}	|| 0,
				"count.moderation.error"		=> $dist{&ModDefs::STATUS_ERROR}		|| 0,
				"count.moderation.failedprereq"	=> $dist{&ModDefs::STATUS_FAILEDPREREQ}	|| 0,
				"count.moderation.evalnochange"	=> 0,
				"count.moderation.tobedeleted"	=> $dist{&ModDefs::STATUS_TOBEDELETED}	|| 0,
				"count.moderation.deleted"		=> $dist{&ModDefs::STATUS_DELETED}		|| 0,
			};
		},
	},
	"count.moderation.applied" => {
		DESC => "Count of applied edits",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.failedvote" => {
		DESC => "Count of edits which were voted down",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.faileddep" => {
		DESC => "Count of edits which failed their dependency check",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.error" => {
		DESC => "Count of edits which failed because of an internal error",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.failedprereq" => {
		DESC => "Count of edits which failed because a prerequisitite moderation failed",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.evalnochange" => {
		DESC => "Count of evalnochange edits",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.tobedeleted" => {
		DESC => "Count of edits marked as 'to be deleted'",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.deleted" => {
		DESC => "Count of deleted edits",
		PREREQ => [qw[ count.moderation.open ]],
		PREREQ_ONLY => 1,
	},
	"count.moderation.perday" => {
		DESC => "Count of edits per day",
		SQL => "SELECT count(id) FROM moderation_all
				WHERE opentime >= (now() - interval '1 day')
					and moderator not in (". &ModDefs::FREEDB_MODERATOR .", ". &ModDefs::MODBOT_MODERATOR .")",
	},
	"count.moderation.perweek" => {
		DESC => "Count of edits per week",
		SQL => "SELECT count(id) FROM moderation_all
				WHERE opentime >= (now() - interval '7 days')
					and moderator not in (". &ModDefs::FREEDB_MODERATOR .", ". &ModDefs::MODBOT_MODERATOR .")",
	},

	"count.vote.yes" => {
		DESC => "Count of 'yes' votes",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectListOfLists(
				"SELECT vote, COUNT(*) FROM vote_all GROUP BY vote",
			);

			my %dist = map { @$_ } @$data;

			+{
				"count.vote.yes"		=> $dist{&ModDefs::VOTE_YES}	|| 0,
				"count.vote.no"			=> $dist{&ModDefs::VOTE_NO}		|| 0,
				"count.vote.abstain"	=> $dist{&ModDefs::VOTE_ABS}	|| 0,
			};
		},
	},
	"count.vote.no" => {
		DESC => "Count of 'no' votes",
		PREREQ => [qw[ count.vote.yes ]],
		PREREQ_ONLY => 1,
	},
	"count.vote.abstain" => {
		DESC => "Count of 'abstain' votes",
		PREREQ => [qw[ count.vote.yes ]],
		PREREQ_ONLY => 1,
	},
	"count.vote.perday" => {
		DESC => "Count of votes per day",
		SQL => "SELECT count(id) FROM vote_all
				WHERE votetime >= (now() - interval '1 day')
					and vote <> ". &ModDefs::VOTE_ABS,
	},
	"count.vote.perweek" => {
		DESC => "Count of votes per week",
		SQL => "SELECT count(id) FROM vote_all
				WHERE votetime >= (now() - interval '7 days')
					and vote <> ". &ModDefs::VOTE_ABS,
	},

	# count active moderators in last week(?)
	# editing / voting / overall

	"count.moderator.editlastweek" => {
		DESC => "Count of editors who have submitted edits during the last week",
		CALC => sub {
			my ($self, $sql) = @_;

			my $threshold_id = $sql->SelectSingleValue(
				"SELECT MAX(id) FROM moderation_all
				WHERE opentime <= (now() - interval '7 days')",
			);

			# Active voters
			my $voters = $sql->SelectSingleValue(
				"SELECT COUNT(DISTINCT moderator)
				FROM vote_all
				WHERE moderation > ?
				AND moderator != ?",
				$threshold_id,
				&ModDefs::FREEDB_MODERATOR,
			);

			# Editors
			my $editors = $sql->SelectSingleValue(
				"SELECT COUNT(DISTINCT moderator)
				FROM moderation_all
				WHERE id > ?
				AND moderator != ?",
				$threshold_id,
				&ModDefs::FREEDB_MODERATOR,
			);

			# Either
			my $both = $sql->SelectSingleValue(
				"SELECT COUNT(DISTINCT m) FROM (
					SELECT moderator AS m
					FROM moderation_all
					WHERE id > ?
					UNION
					SELECT moderator AS m
					FROM vote_all
					WHERE moderation > ?
				) t WHERE m != ?",
				$threshold_id,
				$threshold_id,
				&ModDefs::FREEDB_MODERATOR,
			);
			
			+{
				"count.moderator.editlastweek"	=> $editors,
				"count.moderator.votelastweek"	=> $voters,
				"count.moderator.activelastweek"=> $both,
			};
		},
	},
	"count.moderator.votelastweek" => {
		DESC => "Count of editors who have voted on edits during the last week",
		PREREQ => [qw[ count.moderator.editlastweek ]],
		PREREQ_ONLY => 1,
	},
	"count.moderator.activelastweek" => {
		DESC => "Count of active editors (editing or voting) during the last week",
		PREREQ => [qw[ count.moderator.editlastweek ]],
		PREREQ_ONLY => 1,
	},

	# To add?
	# - top 10 moderators
	#   - open and accepted last week
	#   - accepted all time
	# Top 10 voters all time

	"count.ar.links" => {
		DESC => "Count of all advanced relationships links",
		CALC => sub {
			my ($self, $sql) = @_;
			my %r;
			$r{'count.ar.links'} = 0;

			require MusicBrainz::Server::LinkEntity;

			for my $t (@{ MusicBrainz::Server::LinkEntity->AllLinkTypes })
			{
				require MusicBrainz::Server::Link;
				my $l = MusicBrainz::Server::Link->new($sql->{DBH}, $t);
				my $n = $l->CountLinksByType;
				$r{"count.ar.links.".$l->Table} = $n;
				$r{'count.ar.links'} += $n;
			}

			return \%r;
		},
	},
	"count.ar.links.l_album_album" => {
		DESC => "Count of release-release advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_album_artist" => {
		DESC => "Count of release-artist advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_album_label" => {
		DESC => "Count of release-label advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_album_track" => {
		DESC => "Count of release-track advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_album_url" => {
		DESC => "Count of release-URL advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_artist_artist" => {
		DESC => "Count of artist-artist advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_artist_label" => {
		DESC => "Count of artist-label advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_artist_track" => {
		DESC => "Count of artist-track advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_artist_url" => {
		DESC => "Count of artist-URL advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_label_label" => {
		DESC => "Count of label-label advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_label_track" => {
		DESC => "Count of label-track advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_label_url" => {
		DESC => "Count of label-URL advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_track_track" => {
		DESC => "Count of track-track advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_track_url" => {
		DESC => "Count of track-URL advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},
	"count.ar.links.l_url_url" => {
		DESC => "Count of URL-URL advanced relationships links",
		PREREQ => [qw[ count.ar.links ]],
		PREREQ_ONLY => 1,
	},

	# Tags
	"count.tag" => {
		DESC => "Count of all tags",
		SQL => "SELECT COUNT(*) FROM tag",
	},
	"count.tag.raw.artist" => {
		DESC => "Count of all artist raw tags",
		SQL => "SELECT COUNT(*) FROM artist_tag_raw",
		RAWDATA_DB => 1,
	},
	"count.tag.raw.label" => {
		DESC => "Count of all label raw tags",
		SQL => "SELECT COUNT(*) FROM label_tag_raw",
		RAWDATA_DB => 1,
	},
	"count.tag.raw.release" => {
		DESC => "Count of all release raw tags",
		SQL => "SELECT COUNT(*) FROM release_tag_raw",
		RAWDATA_DB => 1,
	},
	"count.tag.raw.track" => {
		DESC => "Count of all track raw tags",
		SQL => "SELECT COUNT(*) FROM track_tag_raw",
		RAWDATA_DB => 1,
	},
	"count.tag.raw" => {
		DESC => "Count of all raw tags",
		PREREQ => [qw[ count.tag.raw.artist count.tag.raw.label count.tag.raw.release count.tag.raw.track ]],
		CALC => sub {
			my ($self, $sql) = @_;
			return $self->Fetch('count.tag.raw.artist') + 
			       $self->Fetch('count.tag.raw.label') +
			       $self->Fetch('count.tag.raw.release') +
			       $self->Fetch('count.tag.raw.track');
		},
	},

	# Ratings
	"count.rating.artist" => {
		DESC => "Count of artist ratings",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectSingleRowArray(
				"SELECT COUNT(*), SUM(rating_count) FROM artist_meta WHERE rating_count > 0",
			);

			+{
				"count.rating.artist"		=> $data->[0]	|| 0,
				"count.rating.raw.artist"	=> $data->[1]	|| 0,
			};
		},
	},
	"count.rating.raw.artist" => {
		DESC => "Count of all artist raw ratings",
		PREREQ => [qw[ count.rating.artist ]],
		PREREQ_ONLY => 1,
	},
	"count.rating.release" => {
		DESC => "Count of release ratings",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectSingleRowArray(
				"SELECT COUNT(*), SUM(rating_count) FROM albummeta WHERE rating_count > 0",
			);

			+{
				"count.rating.release"		=> $data->[0]	|| 0,
				"count.rating.raw.release"	=> $data->[1]	|| 0,
			};
		},
	},
	"count.rating.raw.release" => {
		DESC => "Count of all release raw ratings",
		PREREQ => [qw[ count.rating.release ]],
		PREREQ_ONLY => 1,
	},
	"count.rating.track" => {
		DESC => "Count of track ratings",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectSingleRowArray(
				"SELECT COUNT(*), SUM(rating_count) FROM track_meta WHERE rating_count > 0",
			);

			+{
				"count.rating.track"		=> $data->[0]	|| 0,
				"count.rating.raw.track"	=> $data->[1]	|| 0,
			};
		},
	},
	"count.rating.raw.track" => {
		DESC => "Count of all track raw ratings",
		PREREQ => [qw[ count.rating.track ]],
		PREREQ_ONLY => 1,
	},
	"count.rating.label" => {
		DESC => "Count of label ratings",
		CALC => sub {
			my ($self, $sql) = @_;

			my $data = $sql->SelectSingleRowArray(
				"SELECT COUNT(*), SUM(rating_count)	FROM label_meta WHERE rating_count > 0",
			);

			+{
				"count.rating.label"		=> $data->[0]	|| 0,
				"count.rating.raw.label"	=> $data->[1]	|| 0,
			};
		},
	},
	"count.rating.raw.label" => {
		DESC => "Count of all label raw ratings",
		PREREQ => [qw[ count.rating.label ]],
		PREREQ_ONLY => 1,
	},
	"count.rating" => {
		DESC => "Count of all ratings",
		PREREQ => [qw[ count.rating.artist count.rating.label count.rating.release count.rating.track ]],
		CALC => sub {
			my ($self, $sql) = @_;
			return $self->Fetch('count.rating.artist') + 
			       $self->Fetch('count.rating.label') +
			       $self->Fetch('count.rating.release') +
			       $self->Fetch('count.rating.track');
		},
	},
	"count.rating.raw" => {
		DESC => "Count of all raw ratings",
		PREREQ => [qw[ count.rating.raw.artist count.rating.raw.label count.rating.raw.release count.rating.raw.track ]],
		CALC => sub {
			my ($self, $sql) = @_;
			return $self->Fetch('count.rating.raw.artist') + 
			       $self->Fetch('count.rating.raw.label') +
			       $self->Fetch('count.rating.raw.release') +
			       $self->Fetch('count.rating.raw.track');
		},
	},
);

sub RecalculateStat
{
	my ($self, $name) = @_;
	my $sql = Sql->new($self->{DBH});

	my $vertmb = new MusicBrainz;
	$vertmb->Login(db => 'RAWDATA');
	my $vertsql = Sql->new($vertmb->{DBH});

	my $def = $stats{$name}
		or warn("Unknown stat name '$name'"), return;

	return if $def->{PREREQ_ONLY};

	if (my $query = $def->{SQL})
	{
		my $value;
		if ($def->{RAWDATA_DB})
		{
			$value = $vertsql->SelectSingleValue($query);
		}
		else
		{
			$value = $sql->SelectSingleValue($query);
		}
		$self->Update($name, $value);
		return;
	}

	if (my $sub = $def->{CALC})
	{
		my $towrite = $sub->($self, $sql, $vertsql);

		if (ref($towrite) eq "HASH")
		{
			$self->Update(%$towrite);
		} else {
			$self->Update($name => $towrite);
		}
		return;
	}

	warn "Can't calculate $name yet";
}

sub RecalculateAll
{
	my $self = shift;

	my %notdone = %stats;
	my %done;

	for (;;)
	{
		last unless %notdone;

		my $count = 0;

		# Work out which stats from %notdone we can do this time around
		for my $name (sort keys %notdone)
		{
			my $d = $stats{$name}{PREREQ} || [];
			next if grep { $notdone{$_} } @$d;

			# $name has no unsatisfied dependencies.  Let's do it!
			$self->RecalculateStat($name);

			$done{$name} = delete $notdone{$name};
			++$count;
		}

		next if $count;

		my $s = join ", ", keys %notdone;
		die "Failed to solve stats dependencies: circular dependency? ($s)";
	}
}

sub GetStatDescription
{
	my ($self, $name) = @_;
	$stats{$name}{DESC};
}

sub GetStats
{
    my ($self, $list) = @_;
	my $sql = Sql->new($self->{DBH});

	my @columns = split(',', $list);

    my @data;
	my %ret;
	foreach my $column (@columns)
	{
		if ($sql->Select("SELECT d.date, ROUND(AVG(d.value)) FROM (
													SELECT to_char(snapshotdate, 'YYYY-WW') AS date, value 
													  FROM historicalstat 
													 WHERE name =  ?
												  GROUP by snapshotdate, value 
												  ORDER BY snapshotdate) AS d 
										 GROUP BY d.date 
										 ORDER BY d.date", $column))
		{
			my @row;
			while(@row = $sql->NextRow)
			{
				my ($year, $week) = split('-', $row[0]);

				# Convert week of year to epoch and then to an actual date
				my $epoch = mktime (0, 0, 0, 1, 0, $year - 1900, 0, 0);
				my @data = gmtime($epoch + ($week * 7 * 24 * 60 * 60));
				my $date = sprintf("%04d-%02d-%02d", (1900 + $data[5]), ($data[4]+1), $data[3]);
				$ret{$date} = () if (!exists $ret{$date});
				$ret{$date}->{$column} = $row[1];
			}
		}
		$sql->Finish;
	}

	my $out;
	foreach my $key (sort keys %ret)
	{
		my @row;
		foreach my $column (@columns)
		{
			if (!exists $ret{$key}->{$column})
			{
				push @row, 0;
				next;
			}
			push @row, $ret{$key}->{$column};
		}
		$out .= "$key," . join(",", @row) . "\n";
	}

	return $out;
}

sub GetEditStats
{
    my ($self) = @_;
	my %data;

	my $sql = Sql->new($self->{DBH});

	my $obj = MusicBrainz::Server::Cache->get("statistics-edit-stats");
	my ($data, $timestamp) = ($obj->[0], $obj->[1]);
	return ($data, $timestamp) if (defined $data);

	$data = {};
	# Average edit life in the last 14 days
	$data->{edit_life_14_days} = $sql->SelectSingleValue("SELECT to_char(AVG(m.duration), 'DD HH') FROM (
                                                       SELECT closetime - opentime AS duration 
														 FROM moderation_closed 
														WHERE opentime != closetime 
														  AND closetime - opentime < interval '14 days' 
												     ORDER BY closetime desc) as m");
	$data->{edit_life_14_days} =~ s/(\d\d) (\d\d)/$1 days $2 hours/;

	# Edits by <timeperiod>
	#$data->{edits_by_week_4_weeks} = $sql->SelectListOfLists("select date_trunc('month', closetime) as date, count(id) as edits from moderation_closed group by date");

	# Edits in the last <timeperiod>
	$data->{edits_in_24_hours} = $sql->SelectSingleValue("select count(id) as edits from moderation_closed where closetime >= now() - interval '1 day'");

	# Edits in the last <timeperiod>
	$data->{edits_in_30_days} = $sql->SelectSingleValue("select count(id) as edits from moderation_closed where closetime >= now() - interval '30 day'");

    $timestamp = time();
	MusicBrainz::Server::Cache->set("statistics-edit-stats", [$data, $timestamp], 60 * 60 * 24);

	return ($data, $timestamp);
}

sub GetHotEdits
{
    my ($self, $maxitems, $offset) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $obj = MusicBrainz::Server::Cache->get("statistics-hot-edits");
	my ($hot, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);

	if (!defined $hot)
	{
		$hot = $sql->SelectListOfLists(
			"SELECT c.cmod as edit, c.ctype, comments, votes, c.expiretime, 
					CAST((EXTRACT(EPOCH FROM c.expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
				   FROM (
							  SELECT moderation_open.id AS cmod, moderation_open.type AS ctype, 
									 COUNT(moderation_note_open.id) AS comments, expiretime
								FROM moderation_open, moderation_note_open 
							   WHERE moderation_note_open.moderation = moderation_open.id 
							GROUP BY moderation_open.id, ctype, expiretime
							ORDER BY comments DESC
							   LIMIT 500  
						) AS c, 
						(
							  SELECT moderation_open.id AS nmod, moderation_open.type AS vtype, 
									 count(vote_open.id) AS votes, expiretime
								FROM moderation_open, vote_open 
							   WHERE moderation_open.id = vote_open.moderation 
							GROUP BY moderation_open.id, vtype, expiretime
							ORDER BY votes desc
							   LIMIT 500
						) AS v
				  WHERE c.cmod = v.nmod 
				    AND c.comments > 2
			   ORDER BY votes + comments DESC");

		my $moderation = Moderation->new($self->{DBH});
		for(0..scalar(@$hot)-1)
		{
			my $obj = $moderation->CreateModerationObject($hot->[$_][1]);
			$hot->[$_][1] = $obj->Name();
		}

		$timestamp = time();
		$numitems = scalar(@$hot);
		MusicBrainz::Server::Cache->set("statistics-hot-edits", [$hot, $numitems, $timestamp], 5 * 60);
	}   

	splice(@$hot, 0, $offset) if ($offset);
	splice(@$hot, $maxitems) if (scalar(@$hot) > $maxitems);

	return ($hot, $numitems, $timestamp);
}

sub GetNeedLoveEdits
{
    my ($self, $maxitems, $offset) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $obj = MusicBrainz::Server::Cache->get("statistics-needlove-edits");
	my ($needlove, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!defined $needlove)
	{
		$needlove = $sql->SelectListOfLists(
			"SELECT moderation_open.id, moderation_open.type, expiretime, CAST((EXTRACT(EPOCH FROM expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
			   FROM moderation_open 
		  LEFT JOIN vote_open 
				 ON moderation_open.id = vote_open.moderation 
				AND vote_open.id IS NULL 
			  WHERE expiretime > now()
		   GROUP BY t, moderation_open.id, moderation_open.type, moderation_open.expiretime
		   ORDER BY t desc
		      LIMIT 500");

		my $moderation = Moderation->new($self->{DBH});
		for(0..scalar(@$needlove)-1)
		{
			my $obj = $moderation->CreateModerationObject($needlove->[$_][1]);
			$needlove->[$_][1] = $obj->Name();
		}

		$timestamp = time();
		$numitems = scalar(@$needlove);
		MusicBrainz::Server::Cache->set("statistics-needlove-edits", [$needlove, $numitems, $timestamp], 5 * 60);

	}   

	splice(@$needlove, 0, $offset) if ($offset);
	splice(@$needlove, $maxitems) if (scalar(@$needlove) > $maxitems);

	return ($needlove, $numitems, $timestamp);
}
  
sub GetExpiredEdits
{
    my ($self, $maxitems, $offset) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $obj = MusicBrainz::Server::Cache->get("statistics-expired-edits");
	my ($expired, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!defined $expired)
	{
		$expired = $sql->SelectListOfLists(
			"SELECT moderation_open.id, moderation_open.type, expiretime, CAST((EXTRACT(EPOCH FROM expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
			   FROM moderation_open 
		  LEFT JOIN vote_open 
				 ON moderation_open.id = vote_open.moderation 
				AND vote_open.id IS NULL 
			  WHERE expiretime <= now()
		   GROUP BY t, moderation_open.id, moderation_open.type, moderation_open.expiretime
		   ORDER BY t desc
			  LIMIT 500");

		my $moderation = Moderation->new($self->{DBH});
		for(0..scalar(@$expired)-1)
		{
			my $obj = $moderation->CreateModerationObject($expired->[$_][1]);
			$expired->[$_][1] = $obj->Name();
		}

		$timestamp = time();
		$numitems = scalar(@$expired);
		MusicBrainz::Server::Cache->set("statistics-expired-edits", [$expired, $numitems, $timestamp], 5 * 60);
	}   

	splice(@$expired, 0, $offset) if ($offset);
	splice(@$expired, $maxitems) if (scalar(@$expired) > $maxitems);

	return ($expired, $numitems, $timestamp);
}

# This function fetches the latest changed rows from a given entity. Supported entities are
# "artist", "release", "label". Returned is a refrence to an array of (aritst mbid, artist name, update timestamp).
sub GetLastUpdates
{
    my ($self, $entity, $maxitems, $offset) = @_;
	my $cachekey;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	$cachekey = "statistics-lu-$entity";
	my $obj = MusicBrainz::Server::Cache->get($cachekey);
	my ($lu, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!defined $lu)
	{
		my $meta_entity;
		if ($entity eq "release")
		{
			$entity = "album";
			$meta_entity = "albummeta";
		}
		else
		{
			$meta_entity = $entity . "_meta";
		}

		my $data = $sql->SelectListOfLists("SELECT gid, name, lastupdate 
											  FROM $entity, $meta_entity  
											 WHERE $entity.id = $meta_entity.id 
											   AND lastupdate IN (SELECT DISTINCT lastupdate 
																			 FROM $meta_entity 
																		 ORDER BY lastupdate DESC 
																			LIMIT 500)
										  ORDER BY lastupdate DESC
										     LIMIT 500");

		my (@ret, $row);
		my $items = [];
		my $last;
		foreach $row (@$data)
		{
			if ($last ne $row->[2])
			{
				push @ret, [$last, $items] if (scalar(@$items));
				$last = $row->[2];
				$items = [];
			}
			push @$items, [$row->[0], $row->[1]];
		}
		push @ret, [$last, $items] if (scalar(@$items));
		$lu = \@ret;

		$timestamp = time();
		$numitems = scalar(@$lu);
		MusicBrainz::Server::Cache->set($cachekey, [$lu, $numitems, $timestamp], 5 * 60);
	}

	splice(@$lu, 0, $offset) if ($offset);
	splice(@$lu, $maxitems) if (scalar(@$lu) > $maxitems);

	return ($lu, $numitems, $timestamp);
}

sub GetLastUpdatesByDate
{
    my ($self, $entity, $date, $maxitems, $offset) = @_;
	my $cachekey;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	$cachekey = "statistics-lu-$entity-$date";
	my $obj = MusicBrainz::Server::Cache->get($cachekey);
	my ($lu, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!defined $lu)
	{
		my $meta_entity;
		if ($entity eq "release")
		{
			$entity = "album";
			$meta_entity = "albummeta";
		}
		else
		{
			$meta_entity = $entity . "_meta";
		}

		$lu = $sql->SelectListOfLists("SELECT gid, name, lastupdate 
											  FROM $entity, $meta_entity  
											 WHERE $entity.id = $meta_entity.id 
											   AND lastupdate = timestamp ?
										  ORDER BY lastupdate DESC
										     LIMIT 500", $date);

		$timestamp = time();
		$numitems = scalar(@$lu);
		MusicBrainz::Server::Cache->set($cachekey, [$lu, $numitems, $timestamp], 10 * 60);
	}

	splice(@$lu, 0, $offset) if ($offset);
	splice(@$lu, $maxitems) if (scalar(@$lu) > $maxitems);

	return ($lu, $numitems, $timestamp);
}

sub GetRecentReleases
{
    my ($self, $maxitems, $offset) = @_;

	$maxitems = 10 if (!defined $maxitems);

	my $obj = MusicBrainz::Server::Cache->get("statistics-recent-releases");
	my ($recent, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!$recent)
	{
		my $sql = Sql->new($self->{DBH});
		$recent = $sql->SelectListOfLists("SELECT album.gid, album.name, artist.gid, artist.name, releasedate, isocode AS country, format 
										  FROM release, album, artist, country 
										 WHERE album.id IN (
												SELECT album 
												  FROM release 
												 WHERE releasedate <= now() 
												   AND now() - to_timestamp(releasedate, 'YYYY-MM-DD') < interval '30 days'
											  ORDER BY releasedate DESC, album) 
										   AND release.album = album.id 
										   AND release.country = country.id 
										   AND album.artist = artist.id 
										   AND releasedate <= now() 
									  ORDER BY releasedate DESC, album.id, country, format");
		$timestamp = time();
		$numitems = $sql->SelectSingleValue("SELECT count(*) 
		                                  FROM release 
										 WHERE releasedate <= now() 
										   AND now() - to_timestamp(releasedate, 'YYYY-MM-DD') < interval '30 days'");
		MusicBrainz::Server::Cache->set("statistics-recent-releases", [$recent, $numitems, $timestamp], 60 * 60);
	}

	splice(@$recent, 0, $offset) if ($offset);
	splice(@$recent, $maxitems) if (scalar(@$recent) > $maxitems);

	return ($recent, $numitems, $timestamp);
}

sub GetUpcomingReleases
{
    my ($self, $maxitems, $offset) = @_;

	$maxitems = 10 if (!defined $maxitems);
	my $obj = MusicBrainz::Server::Cache->get("statistics-upcoming-releases");
	my ($upcoming, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!$upcoming)
	{
		my $sql = Sql->new($self->{DBH});
		$upcoming = $sql->SelectListOfLists("SELECT album.gid, album.name, artist.gid, artist.name, releasedate, isocode AS country, format 
										  FROM release, album, artist, country 
										 WHERE album.id IN (
												SELECT album 
												  FROM release 
												 WHERE releasedate > now() 
											  ORDER BY releasedate, album) 
										   AND release.album = album.id 
										   AND release.country = country.id 
										   AND album.artist = artist.id 
										   AND releasedate > now() 
									  ORDER BY releasedate, album.id, country, format");
		$timestamp = time();
		$numitems = $sql->SelectSingleValue("SELECT count(*) 
		                                  FROM release 
										 WHERE releasedate > now()");
		MusicBrainz::Server::Cache->set("statistics-upcoming-releases", [$upcoming, $numitems, $timestamp], 60 * 60);
	}
	splice(@$upcoming, 0, $offset) if ($offset);
	splice(@$upcoming, $maxitems) if (scalar(@$upcoming) > $maxitems);

	return ($upcoming, $numitems, $timestamp);
}

sub GetRecentlyDeceased
{
    my ($self, $maxitems, $offset) = @_;
	my %data;

	$maxitems = 10 if (!defined $maxitems);
	my $obj = MusicBrainz::Server::Cache->get("statistics-recently-deceased");
	my ($deceased, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!$deceased)
	{
		my $sql = Sql->new($self->{DBH});
		$deceased = $sql->SelectListOfLists("SELECT gid, name, enddate, begindate 
										  FROM artist 
										 WHERE type = 1 
										   AND enddate != '' 
									  ORDER BY enddate DESC");

		$timestamp = time();
		$numitems = $sql->SelectSingleValue("SELECT count(*) 
		                                  FROM artist 
										 WHERE enddate != '' 
										   AND enddate <= now() 
										   AND type = 1
										   AND now() - to_timestamp(enddate, 'YYYY-MM-DD') < interval '12 months'");
		MusicBrainz::Server::Cache->set("statistics-recently-deceased", [$deceased, $numitems, $timestamp], 60 * 60);
	}
	splice(@$deceased, 0, $offset) if ($offset);
	splice(@$deceased, $maxitems) if (scalar(@$deceased) > $maxitems);

	return ($deceased, $numitems, $timestamp);
}

sub GetRecentlyBrokenUp
{
    my ($self, $maxitems, $offset) = @_;
	my %data;

	$maxitems = 10 if (!defined $maxitems);

	my $obj = MusicBrainz::Server::Cache->get("statistics-recently-brokenup");
	my ($brokenup, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);
	if (!$brokenup)
	{
		my $sql = Sql->new($self->{DBH});
		$brokenup = $sql->SelectListOfLists("SELECT gid, name, enddate, begindate 
									  FROM artist 
									 WHERE type = 2 
									   AND enddate != '' 
					              ORDER BY enddate DESC");

		$timestamp = time();
		$numitems = $sql->SelectSingleValue("SELECT count(*) 
		                                  FROM artist 
										 WHERE enddate != '' 
										   AND enddate <= now() 
										   AND type = 2
										   AND now() - to_timestamp(enddate, 'YYYY-MM-DD') < interval '12 months'");
		MusicBrainz::Server::Cache->set("statistics-recently-brokenup", [$brokenup, $numitems, $timestamp], 60 * 60);
	}
	splice(@$brokenup, 0, $offset) if ($offset);
	splice(@$brokenup, $maxitems) if (scalar(@$brokenup) > $maxitems);

	return ($brokenup, $numitems, $timestamp);
}

1;
# vi: set ts=4 sw=4 :
