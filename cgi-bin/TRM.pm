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

package TRM;

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

sub GetIdFromTRM
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
    my $id = $this->GetIdFromTRM($TRM);
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

    return undef if (!defined $this->GetId());
  
    $sql = Sql->new($this->{DBH});
    $sql->Do("DELETE FROM trmjoin WHERE trm = ?", $this->GetId);
    $sql->Do("DELETE FROM trm WHERE id = ?", $this->GetId);

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
		# Does this trm exist for the destination track?
		my $existing_id = $sql->SelectSingleValue(
			"SELECT id FROM trmjoin WHERE trm = ? AND track = ?",
			$oldjoin->{trm}, $totrack,
		);

		if ($existing_id)
		{
			# No need to link the trm to the destination.  But we do need to
			# move the trmjoin stats across to the new join row.
			$sql->Do(
				"UPDATE trmjoin_stat SET trmjoin_id = ? WHERE trmjoin_id = ?",
				$existing_id, $oldjoin->{id},
			);
			$sql->Do(
				"DELETE FROM trmjoin WHERE id = ?",
				$oldjoin->{id},
			);
		} else {
			# Normally we'd just update trmjoin.track and use ON UPDATE
			# CASCADE.  However, to date we haven't found a way of skipping
			# replication for updates to some columns, hence we don't
			# replicate updates to trmjoin at all, hence we can't update
			# trmjoin here.

			# Let usecount default to zero ...
			my $newjoinid = $sql->InsertRow(
				"trmjoin",
				{
					trm => $oldjoin->{trm},
					track => $totrack,
				},
			);
			# ... and now the triggers will fix it, and in doing so will
			# zero the counts on the old row ...
			$sql->Do(
				"UPDATE trmjoin_stat SET trmjoin_id = ? WHERE trmjoin_id = ?",
				$newjoinid,
				$oldjoin->{id},
			),
			# ... which we now delete.
			$sql->Do(
				"DELETE FROM trmjoin WHERE id = ?",
				$oldjoin->{id},
			);
		}
	}
}

1;
# vi: set ts=4 sw=4 :
