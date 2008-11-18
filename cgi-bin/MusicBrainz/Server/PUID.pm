#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2006 Robert Kaye
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

package MusicBrainz::Server::PUID;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use DBDefs;
use Carp qw( carp croak );

# Accessor functions to set/get the artist id of this album
sub GetPUID
{
   return $_[0]->{puid};
}

sub SetPUID
{
   $_[0]->{puid} = $_[1];
}

sub GetTrackIdsFromPUID
{
 	my ($this, $PUID) = @_;
	my $sql = Sql->new($this->{DBH});

	$sql->SelectListOfHashes(
		"SELECT	puidjoin.track as track, puidjoin.id as puidjoin
		FROM	puid, puidjoin
		WHERE	puid.puid = ?
		AND		puidjoin.puid = puid.id",
		lc $PUID,
	);
}

sub GetIdFromPUID
{
	my ($this, $PUID) = @_;
	my $sql = Sql->new($this->{DBH});
	$sql->SelectSingleValue("SELECT id FROM puid WHERE puid = ?", lc $PUID);
}

sub GetPUIDFromTrackId
{
    my ($this, $id) = @_;

	unless ($id)
	{
		carp "No track id passed ("
			. (defined($id) ? "'$id'" : "undef")
			. ")";
		return;
	}

	my $sql = Sql->new($this->{DBH});

	my $data = $sql->SelectListOfLists(
		"SELECT	t.puid, j.id, t.lookupcount, j.usecount
           FROM puid t, puidjoin j
          WHERE j.track = ?
		    AND j.puid = t.id
       ORDER BY t.lookupcount desc, j.usecount",
	   $id,
	);

	map {
		+{
			PUID			=> $_->[0],
			PUIDjoinid	=> $_->[1],
			lookupcount	=> $_->[2],
			usecount	=> $_->[3],
		}
	} @$data;
}

sub Insert
{
    my ($this, $PUID, $trackid, $clientver) = @_;

    my $sql = Sql->new($this->{DBH});
    my $id = $this->GetIdFromPUID($PUID);
    $this->{new_insert} = 0;

    if (!defined $id)
    {
		defined($clientver) or return 0;

        my $verid = $sql->SelectSingleValue(
			"SELECT id FROM clientversion WHERE version = ?",
			$clientver,
		);
        
        if (not defined $verid)
        {
            $sql->Do("INSERT INTO clientversion (version) VALUES (?)", $clientver)
				or die;
			$verid = $sql->GetLastInsertId("clientversion")
				or die;
        }

        $sql->Do("INSERT INTO puid (puid, version) VALUES (?, ?)", $PUID, $verid)
			or die;
		$id = $sql->GetLastInsertId("puid")
			or die;
		$this->{new_insert} = 1;
    }

    if (defined $id && defined $trackid)
    {
		# I have no idea why, but for some reason from time to time this query
		# says 'failed to find conversion function from "unknown" to integer'.
		# This workaround (explicit cast to integer) is working at the
		# moment...
		$sql->Do(
			"INSERT INTO puidjoin (puid, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (SELECT 1 FROM puidjoin WHERE puid = ?::integer AND track = ?::integer)",
			$id, $trackid,
			$id, $trackid,
		);
    }

    return $id;
}

sub FindPUIDClientVersion
{
	my ($self, $puid) = @_;
	$puid = $self->GetPUID if not defined $puid;
	my $sql = Sql->new($self->{DBH});
	$sql->SelectSingleValue(
		"SELECT cv.version FROM puid t, clientversion cv
		WHERE t.puid = ? AND cv.id = t.version",
		$puid,
	);
}

# Remove a PUID from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql);

    return undef if (!defined $this->GetId());
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("DELETE FROM puidjoin WHERE puid = ?", $this->GetId);
    $sql->Do("DELETE FROM puid WHERE id = ?", $this->GetId);

    return 1;
}

# Remove all the PUID/PUIDJoins from the database for a given track id. 
sub RemoveByTrackId
{
    my ($this, $trackid) = @_;
    return undef if (!defined $trackid);
    my $sql = Sql->new($this->{DBH});

	my $rows = $sql->SelectListOfLists(
		"SELECT id, puid FROM puidjoin WHERE track = ?", $trackid,
	);

	for (@$rows)
	{
		my ($joinid, $puid) = @$_;

   		$sql->Do("DELETE FROM puidjoin WHERE id = ?", $joinid);

		my $refcount = $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM puidjoin WHERE puid = ?", $puid,
		);
		if ($refcount == 0)
		{
			$sql->Do("DELETE FROM puid WHERE id = ?", $puid);
		}
	}

    return 1;
}

# Remove a specific single PUID from a given track
sub RemovePUIDByPUIDJoin
{
    my ($this, $joinid) = @_;
    return undef if (!defined $joinid);
	my $sql = Sql->new($this->{DBH});

	my $oldpuid = $sql->SelectSingleValue(
		"SELECT puid FROM puidjoin WHERE id = ?", $joinid,
	) or return undef;

	$sql->Do("DELETE FROM puidjoin WHERE id = ?", $joinid);

	my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM puidjoin WHERE puid = ?", $oldpuid,
	);

	if ($refcount == 0)
	{
		$sql->Do("DELETE FROM puid WHERE id = ?", $oldpuid);
	}

    return 1;
}

sub IncrementLookupCount
{
	my ($class, $puid) = @_;
	
	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"PUID::IncrementLookupCount",
		$puid,
	);
}

sub UpdateLookupCount
{
	my ($self, $puid, $timesused) = @_;
	$timesused ||= 1;
    my $sql = Sql->new($self->{DBH});

	my $id = $sql->SelectSingleValue(
		"SELECT id FROM puid WHERE puid = ?", $puid,
	) or return;

	my @gmtime = gmtime; 
	my $month_id = 12*$gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE puid_stat SET lookupcount = lookupcount + ? WHERE puid_id = ? AND month_id = ?",
		$timesused, $id, $month_id,
	) or
	$sql->Do(
		"INSERT INTO puid_stat (puid_id, month_id, lookupcount) values (?, ?, ?)",
		$id, $month_id, $timesused,
	);
}

sub IncrementUsageCount
{
	my ($class, $puid, $trackid) = @_;
	
	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"PUID::IncrementUsageCount",
		$puid, $trackid,
	);
}

sub UpdateUsageCount
{
	my ($self, $puid, $trackid, $timesused) = @_;
	$timesused ||= 1;
    my $sql = Sql->new($self->{DBH});

	my $joinid = $sql->SelectSingleValue(
		"select puidjoin.id 
		   from puid, puidjoin
		  where puidjoin.track = ?
		    and puid.puid = ? 
			and puidjoin.puid = puid.id", $trackid, $puid,
	) or return;

	my @gmtime = gmtime; 
	my $month_id = 12*$gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE puidjoin_stat SET usecount = usecount + ? WHERE puidjoin_id = ? AND month_id = ?",
		$timesused, $joinid, $month_id,
	) or
	$sql->Do(
		"INSERT INTO puidjoin_stat (puidjoin_id, month_id, usecount) values (?, ?, ?)",
		$joinid, $month_id, $timesused,
	);
}

sub MergeTracks
{
	my ($self, $fromtrack, $totrack) = @_;
    my $sql = Sql->new($self->{DBH});

	my $puidjoins = $sql->SelectListOfHashes(
		"SELECT * FROM puidjoin WHERE track = ?",
		$fromtrack,
	);

	for my $oldjoin (@$puidjoins)
	{
		# Ensure the new puidjoin exists
		$sql->Do(
			"INSERT INTO puidjoin (puid, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (SELECT 1 FROM puidjoin WHERE puid = ?::integer AND track = ?::integer)",
			$oldjoin->{puid}, $totrack,
			$oldjoin->{puid}, $totrack,
		);
		my $newjoinid = $sql->SelectSingleValue(
			"SELECT id FROM puidjoin WHERE puid = ? AND track = ?",
			$oldjoin->{puid}, $totrack,
		);

		# Merge the stats from $oldjoin->{id} to $newjoinid
		$sql->Do(
			"SELECT month_id, SUM(usecount) AS usecount
			INTO TEMPORARY TABLE tmp_merge_puidjoin_stat
			FROM	puidjoin_stat
			WHERE	puidjoin_id IN (?, ?)
			GROUP BY month_id",
			$oldjoin->{id},
			$newjoinid,
		);
		$sql->Do(
			"DELETE FROM puidjoin_stat WHERE puidjoin_id IN (?, ?)",
			$oldjoin->{id},
			$newjoinid,
		);
		$sql->Do(
			"INSERT INTO puidjoin_stat (puidjoin_id, month_id, usecount)
			SELECT	?, month_id, usecount
			FROM	tmp_merge_puidjoin_stat",
			$newjoinid,
		);
		$sql->Do(
			"DROP TABLE tmp_merge_puidjoin_stat",
		);
	}

	# Delete the old join row
	$sql->Do(
		"DELETE FROM puidjoin WHERE track = ?",
		$fromtrack,
	);
}

1;
# vi: set ts=4 sw=4 :
