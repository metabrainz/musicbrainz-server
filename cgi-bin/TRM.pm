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
		"SELECT TRM.TRM, TRMJoin.id, TRM.lookupcount
		FROM	TRMJoin, TRM
		WHERE	TRMJoin.track = ?
		AND		TRMJoin.TRM = TRM.id
		ORDER BY TRM.lookupcount DESC",
		$id,
	);

	map {
		+{
			TRM			=> $_->[0],
			TRMjoinid	=> $_->[1],
			lookupcount	=> $_->[2],
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

# Load all the trms for a given track and return an array of references to trms
# objects. Returns undef if error occurs
sub LoadFull
{
   my ($this, $track) = @_;
   my (@info, $query, $sql, @row, $trm);

   $sql = Sql->new($this->{DBH});
   $query = qq|select trm.id, trm.trm
                 from trm, trmjoin
                where trmjoin.track = $track and
                      trmjoin.trm = trm.id|;
   if ($sql->Select($query) && $sql->Rows)
   {
       for(;@row = $sql->NextRow();)
       {
		   require TRM;
           $trm = TRM->new($this->{DBH});
           $trm->SetId($row[0]);
           $trm->SetTRM($row[1]);
           push @info, $trm;
       }
       $sql->Finish;

       return \@info;
   }

   return undef;
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

	$sql->Do(
		"UPDATE trm SET lookupcount = lookupcount + ? WHERE trm = ?",
		$timesused, $trm,
	);
}

1;
# vi: set ts=4 sw=4 :
