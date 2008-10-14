#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
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
#   $Id: CDTOC.pm 8551 2006-10-19 20:10:48Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Statistics;

use Exporter;
use TableBase;
{ our @ISA = qw( Exporter TableBase ) }
use Sql;
use Data::Dumper;
use POSIX;

sub GetStats
{
    my ($self, $list) = @_;
	my $sql = Sql->new($self->{DBH});

	print STDERR "Stats: $list\n";

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
			$sql->Finish;
		}
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

# This function fetches the latest changed rows from a given entity. Supported entities are
# "artist", "release", "label". Returned is a refrence to an array of (aritst mbid, artist name, update timestamp).
sub GetLastUpdates
{
    my ($self, $entity, $maxitems) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

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
																	    LIMIT ?)
									  ORDER BY lastupdate DESC
									     LIMIT 100", $maxitems);

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

	return \@ret;
}

sub GetHotEdits
{
    my ($self, $maxitems) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $data = $sql->SelectListOfLists(
		"SELECT c.cmod as edit, c.ctype, comments, votes, c.expiretime, 
		        CAST((EXTRACT(EPOCH FROM c.expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
			   FROM (
						  SELECT moderation_open.id AS cmod, moderation_open.type AS ctype, 
						         COUNT(moderation_note_open.id) AS comments, expiretime
							FROM moderation_open, moderation_note_open 
						   WHERE moderation_note_open.moderation = moderation_open.id 
						GROUP BY moderation_open.id, ctype, expiretime
						ORDER BY comments DESC
						   LIMIT ?  
					) AS c, 
					(
						  SELECT moderation_open.id AS nmod, moderation_open.type AS vtype, 
						         count(vote_open.id) AS votes, expiretime
							FROM moderation_open, vote_open 
						   WHERE moderation_open.id = vote_open.moderation 
						GROUP BY moderation_open.id, vtype, expiretime
						ORDER BY votes desc
						   LIMIT ?  
					) AS v
			  WHERE c.cmod = v.nmod 
		   ORDER BY votes + comments DESC 
		      LIMIT ?", ($maxitems * 10), ($maxitems *10), $maxitems);
	return $data;
}

sub GetNeedLoveEdits
{
    my ($self, $maxitems) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $data = $sql->SelectListOfLists(
	    "SELECT moderation_open.id, expiretime, CAST((EXTRACT(EPOCH FROM expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
		   FROM moderation_open 
	  LEFT JOIN vote_open 
	         ON moderation_open.id = vote_open.moderation 
		    AND vote_open.id IS NULL 
		  WHERE expiretime > now()
       GROUP BY t, moderation_open.id, moderation_open.expiretime
	   ORDER BY t desc 
	      limit ?", $maxitems);
	   
	return $data;
}
  
sub GetExpiredEdits
{
    my ($self, $maxitems) = @_;
	my $sql = Sql->new($self->{DBH});

	$maxitems = 10 if (!defined $maxitems);

	my $data = $sql->SelectListOfLists(
	    "SELECT moderation_open.id, expiretime, CAST((EXTRACT(EPOCH FROM expiretime) - EXTRACT(EPOCH FROM now())) AS INTEGER) AS t 
		   FROM moderation_open 
	  LEFT JOIN vote_open 
	         ON moderation_open.id = vote_open.moderation 
		    AND vote_open.id IS NULL 
		  WHERE expiretime <= now()
       GROUP BY t, moderation_open.id, moderation_open.expiretime
	   ORDER BY t desc 
	      limit ?", $maxitems);
	   
	return $data;
}

sub GetEditStats
{
    my ($self, $maxitems) = @_;
	my %data;

	my $sql = Sql->new($self->{DBH});
	$maxitems = 10 if (!defined $maxitems);

	# Average edit life in the last 14 days
	$data{edit_life_14_days} = $sql->SelectSingleValue("SELECT to_char(AVG(m.duration), 'DD HH') FROM (
                                                       SELECT closetime - opentime AS duration 
														 FROM moderation_closed 
														WHERE opentime != closetime 
														  AND closetime - opentime < interval '14 days' 
												     ORDER BY closetime desc) as m");
	$data{edit_life_14_days} =~ s/(\d\d) (\d\d)/$1 days $2 hours/;

	# Edits by <timeperiod>
	#$data{edits_by_week_4_weeks} = $sql->SelectListOfLists("select date_trunc('month', closetime) as date, count(id) as edits from moderation_closed group by date");

	# Edits in the last <timeperiod>
	$data{edits_in_24_hours} = $sql->SelectSingleValue("select count(id) as edits from moderation_closed where closetime >= now() - interval '1 day'");

	# Edits in the last <timeperiod>
	$data{edits_in_30_days} = $sql->SelectSingleValue("select count(id) as edits from moderation_closed where closetime >= now() - interval '30 day'");

	return \%data;
}

sub GetRecentReleases
{
    my ($self, $maxitems) = @_;
	my %data;

	$maxitems = 10 if (!defined $maxitems);
	my $sql = Sql->new($self->{DBH});
	return $sql->SelectListOfLists("SELECT DISTINCT ON (releasedate, album.gid) album.gid, album.name, artist.gid, artist.name, releasedate
									  FROM release, artist, album 
									 WHERE release.album = album.id 
									   AND album.artist = artist.id 
									   AND releasedate < now() 
					              ORDER BY releasedate DESC, album.gid
								     LIMIT ?", $maxitems);
}

sub GetUpcomingReleases
{
    my ($self, $maxitems) = @_;
	my %data;

	$maxitems = 10 if (!defined $maxitems);
	my $sql = Sql->new($self->{DBH});
	return $sql->SelectListOfLists("SELECT DISTINCT ON (releasedate, album.gid) album.gid, album.name, artist.gid, artist.name, releasedate
									  FROM release, artist, album 
									 WHERE release.album = album.id 
									   AND album.artist = artist.id 
									   AND releasedate >= now() 
					              ORDER BY releasedate, album.gid 
								     LIMIT ?", $maxitems);
}

sub GetRecentlyDeceased
{
    my ($self, $maxitems) = @_;
	my %data;

	$maxitems = 10 if (!defined $maxitems);
	my $sql = Sql->new($self->{DBH});
	return $sql->SelectListOfLists("SELECT gid, name, enddate, begindate 
									  FROM artist 
									 WHERE type = 1 
									   AND enddate != '' 
					              ORDER BY enddate DESC
								     LIMIT ?", $maxitems);
}


1;
# eof Statistics.pm
