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

package MusicBrainz::Server::TRM;

use TableBase;
{ our @ISA = qw( TableBase ) }

use strict;
use DBDefs;
use Carp qw( carp croak );

# Accessor functions to set/get the artist id of this album
sub GetTRM
{
   return $_[0]->{trm};
}

sub SetTRM
{
   $_[0]->{trm} = $_[1];
}

sub GetTrackIdsFromTRM
{
 	my ($this, $TRM) = @_;
	my $sql = Sql->new($this->{DBH});

	$sql->SelectSingleColumnArray(
		"SELECT	trmjoin.track
		FROM	trm, trmjoin
		WHERE	trm.trm = ?
		AND		trmjoin.trm = trm.id",
		lc $TRM,
	);
}

sub id_from_trm
{
	my ($this, $TRM) = @_;
	my $sql = Sql->new($this->{DBH});
	$sql->SelectSingleValue("SELECT id FROM trm WHERE trm = ?", lc $TRM);
}

sub GetTRMFromTrackId
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
		"SELECT	t.trm, j.id, t.lookupcount, j.usecount
           FROM trm t, trmjoin j
          WHERE j.track = ?
		    AND j.trm = t.id
       ORDER BY t.lookupcount desc, j.usecount",
	   $id,
	);

	map {
		+{
			TRM			=> $_->[0],
			TRMjoinid	=> $_->[1],
			lookupcount	=> $_->[2],
			usecount	=> $_->[3],
		}
	} @$data;
}

sub Insert
{
    my ($this, $TRM, $trackid, $clientver) = @_;

    my $sql = Sql->new($this->{DBH});
    my $id = $this->id_from_trm($TRM);
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

        $sql->Do("INSERT INTO trm (trm, version) VALUES (?, ?)", $TRM, $verid)
			or die;
		$id = $sql->GetLastInsertId("trm")
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
			"INSERT INTO trmjoin (trm, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (SELECT 1 FROM trmjoin WHERE trm = ?::integer AND track = ?::integer)",
			$id, $trackid,
			$id, $trackid,
		);
    }

    return $id;
}

sub FindTRMClientVersion
{
	my ($self, $trm) = @_;
	$trm = $self->GetTRM if not defined $trm;
	my $sql = Sql->new($self->{DBH});
	$sql->SelectSingleValue(
		"SELECT cv.version FROM trm t, clientversion cv
		WHERE t.trm = ? AND cv.id = t.version",
		$trm,
	);
}

# Remove a TRM from the database. Set the id via the accessor function.
sub Remove
{
    my ($this) = @_;
    my ($sql);

    return undef if (!defined $this->id());
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("DELETE FROM trmjoin WHERE trm = ?", $this->id);
    $sql->Do("DELETE FROM trm WHERE id = ?", $this->id);

    return 1;
}

# Remove all the TRM/TRMJoins from the database for a given track id. 
sub RemoveByTrackId
{
    my ($this, $trackid) = @_;
    return undef if (!defined $trackid);
    my $sql = Sql->new($this->{DBH});

	my $rows = $sql->SelectListOfLists(
		"SELECT id, trm FROM trmjoin WHERE track = ?", $trackid,
	);

	for (@$rows)
	{
		my ($joinid, $trmid) = @$_;

   		$sql->Do("DELETE FROM trmjoin WHERE id = ?", $joinid);

		my $refcount = $sql->SelectSingleValue(
			"SELECT COUNT(*) FROM trmjoin WHERE trm = ?", $trmid,
		);
		if ($refcount == 0)
		{
			$sql->Do("DELETE FROM trm WHERE id = ?", $trmid);
		}
	}

    return 1;
}

# Remove a specific single TRM from a given track
sub RemoveTRMByTRMJoin
{
    my ($this, $joinid) = @_;
    return undef if (!defined $joinid);
	my $sql = Sql->new($this->{DBH});

	my $oldtrmid = $sql->SelectSingleValue(
		"SELECT trm FROM trmjoin WHERE id = ?", $joinid,
	) or return undef;

	$sql->Do("DELETE FROM trmjoin WHERE id = ?", $joinid);

	my $refcount = $sql->SelectSingleValue(
		"SELECT COUNT(*) FROM trmjoin WHERE trm = ?", $oldtrmid,
	);

	if ($refcount == 0)
	{
		$sql->Do("DELETE FROM trm WHERE id = ?", $oldtrmid);
	}

    return 1;
}

sub IncrementLookupCount
{
	my ($class, $trm) = @_;
	
	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"TRM::IncrementLookupCount",
		$trm,
	);
}

sub UpdateLookupCount
{
	my ($self, $trm, $timesused) = @_;
	$timesused ||= 1;
    my $sql = Sql->new($self->{DBH});

	my $trmid = $sql->SelectSingleValue(
		"SELECT id FROM trm WHERE trm = ?", $trm,
	) or return;

	my @gmtime = gmtime; 
	my $month_id = 12*$gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE trm_stat SET lookupcount = lookupcount + ? WHERE trm_id = ? AND month_id = ?",
		$timesused, $trmid, $month_id,
	) or
	$sql->Do(
		"INSERT INTO trm_stat (trm_id, month_id, lookupcount) values (?, ?, ?)",
		$trmid, $month_id, $timesused,
	);
}

sub IncrementUsageCount
{
	my ($class, $trm, $trackid) = @_;
	
	use MusicBrainz::Server::DeferredUpdate;
	MusicBrainz::Server::DeferredUpdate->Write(
		"TRM::IncrementUsageCount",
		$trm, $trackid,
	);
}

sub UpdateUsageCount
{
	my ($self, $trm, $trackid, $timesused) = @_;
	$timesused ||= 1;
    my $sql = Sql->new($self->{DBH});

	my $joinid = $sql->SelectSingleValue(
		"select trmjoin.id 
		   from trm, trmjoin
		  where trmjoin.track = ?
		    and trm.trm = ? 
			and trmjoin.trm = trm.id", $trackid, $trm,
	) or return;

	my @gmtime = gmtime; 
	my $month_id = 12*$gmtime[5] + $gmtime[4];

	$sql->Do(
		"UPDATE trmjoin_stat SET usecount = usecount + ? WHERE trmjoin_id = ? AND month_id = ?",
		$timesused, $joinid, $month_id,
	) or
	$sql->Do(
		"INSERT INTO trmjoin_stat (trmjoin_id, month_id, usecount) values (?, ?, ?)",
		$joinid, $month_id, $timesused,
	);
}

sub MergeTracks
{
	my ($self, $fromtrack, $totrack) = @_;
    my $sql = Sql->new($self->{DBH});

	my $trmjoins = $sql->SelectListOfHashes(
		"SELECT * FROM trmjoin WHERE track = ?",
		$fromtrack,
	);

	for my $oldjoin (@$trmjoins)
	{
		# Ensure the new trmjoin exists
		$sql->Do(
			"INSERT INTO trmjoin (trm, track)
				SELECT * FROM (SELECT ?::integer, ?::integer) AS data
				WHERE NOT EXISTS (SELECT 1 FROM trmjoin WHERE trm = ?::integer AND track = ?::integer)",
			$oldjoin->{trm}, $totrack,
			$oldjoin->{trm}, $totrack,
		);
		my $newjoinid = $sql->SelectSingleValue(
			"SELECT id FROM trmjoin WHERE trm = ? AND track = ?",
			$oldjoin->{trm}, $totrack,
		);

		# Merge the stats from $oldjoin->{id} to $newjoinid
		$sql->Do(
			"SELECT month_id, SUM(usecount) AS usecount
			INTO TEMPORARY TABLE tmp_merge_trmjoin_stat
			FROM	trmjoin_stat
			WHERE	trmjoin_id IN (?, ?)
			GROUP BY month_id",
			$oldjoin->{id},
			$newjoinid,
		);
		$sql->Do(
			"DELETE FROM trmjoin_stat WHERE trmjoin_id IN (?, ?)",
			$oldjoin->{id},
			$newjoinid,
		);
		$sql->Do(
			"INSERT INTO trmjoin_stat (trmjoin_id, month_id, usecount)
			SELECT	?, month_id, usecount
			FROM	tmp_merge_trmjoin_stat",
			$newjoinid,
		);
		$sql->Do(
			"DROP TABLE tmp_merge_trmjoin_stat",
		);
	}

	# Delete the old join row
	$sql->Do(
		"DELETE FROM trmjoin WHERE track = ?",
		$fromtrack,
	);
}

1;
# vi: set ts=4 sw=4 :
