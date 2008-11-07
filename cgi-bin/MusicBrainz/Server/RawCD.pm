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
#
#   RawCD is a "Wisdom of Crowds" place where people who do not care
#   to be part of MusicBrainz (read: don't want to put in the effort to
#   learn about and participate in) but who care about getting metadata
#   for their CD so they can listen to/rip the CD.
#

use strict;

package MusicBrainz::Server::RawCD;

use Exporter;
use TableBase;
{ our @ISA = qw( Exporter TableBase ) }

use MusicBrainz::Server::Validation;
use MusicBrainz::Server::CDTOC;
use MusicBrainz::Server::Cache;

# Constants for the release_raw source column
use constant RAWCD_SOURCE_USERS     => 0;
use constant RAWCD_SOURCE_CDBABY    => 1;
use constant RAWCD_SOURCE_JAMENDO   => 2;

# Given a discid or cdtoc_raw rowid, load the raw release
sub Lookup
{
	my $self = shift;
	my $id = shift;
	my $sql = Sql->new($self->{DBH});

	my $releaseid;
    if (MusicBrainz::Server::Validation::IsNonNegInteger($id))
	{
		$releaseid = $sql->SelectSingleValue("SELECT release FROM cdtoc_raw WHERE id = ?", $id);
    }
	elsif (length($id) == &MusicBrainz::Server::CDTOC::CDINDEX_ID_LENGTH)
	{
		$releaseid = $sql->SelectSingleValue("SELECT release FROM cdtoc_raw WHERE discid = ?", $id);
    }
	else
	{
		return undef;
    }

	return $self->Load($releaseid);
}

# Given an releaseid, return the RawCD
sub Load
{
	my $self = shift;
	my $releaseid = shift;
	my $sql = Sql->new($self->{DBH});

    my $data = $sql->SelectSingleRowHash("SELECT *, date_part('days', now() - lastmodified) as age 
                                            FROM release_raw
                                           WHERE id = ?", $releaseid);
	return undef if (!defined $data);

	$data->{tracks} = $sql->SelectListOfHashes("SELECT id, sequence, title, artist 
			                                      FROM track_raw
												 WHERE release = ?
									          ORDER BY sequence", $releaseid);
	return undef if (!defined $data->{tracks});

	$data->{cdtoc} = $sql->SelectSingleRowHash("SELECT * FROM cdtoc_raw WHERE release = ?", $releaseid);
	return undef if (!defined $data->{cdtoc});

	my $toc = "1 " . scalar(@{$data->{tracks}}) . " " . $data->{cdtoc}->{leadoutoffset} . " " . $data->{cdtoc}->{trackoffset};
	$toc =~ tr/{}//d;
	$toc =~ tr/,/ /d;
	my %tocdata = MusicBrainz::Server::CDTOC::ParseTOC(undef, $toc);
	my $index;
	foreach my $tr (@{$data->{tracks}})
	{
		$tr->{duration} = $tocdata{tracklengths}->[$index++];
	}

	return $data;
};

# Given a raw release id, increment the lookup count
sub IncrementLookupCount
{
	my $self = shift;
	my $id = shift;
	my $sql = Sql->new($self->{DBH});

	$sql->AutoCommit;
	$sql->Do("UPDATE release_raw SET lookupcount = lookupcount + 1 WHERE id = ?", $id);
}

# Get list of most "active" Raw CDs
sub GetActiveCDs
{
	my ($self, $maxitems, $offset) = @_;

	my $sql = Sql->new($self->{DBH});

	$maxitems = 25 if ($maxitems <= 0 || $maxitems > 1000);

	my $obj = MusicBrainz::Server::Cache->get("rawcd-active-cds");
	my ($active, $numitems, $timestamp) = ($obj->[0], $obj->[1], $obj->[2]);

	if (!$active)
	{
		$active = $sql->SelectListOfHashes("SELECT release_raw.id, title, artist, added, lastmodified,
											lookupcount, modifycount,
			                                (lookupcount + modifycount) AS count,
											discid, trackcount, leadoutoffset, trackoffset
			                           FROM release_raw, cdtoc_raw
								      WHERE release_raw.id = cdtoc_raw.release
									    AND lookupcount + modifycount > 0
								   ORDER BY count desc
							          LIMIT 1000");
		$timestamp = time();
		$numitems = scalar(@$active);
        MusicBrainz::Server::Cache->set("statistics-hot-edits", [$active, $numitems, $timestamp], 5 * 60);
    }

	splice(@$active, 0, $offset) if ($offset);
	splice(@$active, $maxitems) if (scalar(@$active) > $maxitems);

	return ($active, $numitems, $timestamp);
}

# Sanity check the data that was passed in
sub _CheckData
{
	my $self = shift;
	my $data = shift;

	return ("No title for CD provided.", 0, 0) if (!exists $data->{title} || !$data->{title});

	my ($artists, $tracks, $total) = (0, 0, 0);
	foreach my $ref (@{$data->{tracks}})
	{
		$artists++ if ($ref->{artist});
		$tracks++ if ($ref->{title});
		$total++;
	}

	return ("No artist names provided.", 0, 0) if ((!exists $data->{artist} || !$data->{artist}) && $artists == 0);
	return ("Not all tracks specify an artist.", 0, 0) if ($artists && $artists != $total);

	# If the release artist is given AND artists are given for each track, clear the release artist
	$data->{artist} = "" if ($artists == $total && $data->{artist});

	return ("Not all tracks have a title.", 0, 0) if ($tracks != $total);
	return ("Missing Disc Id.", 0, 0) if (!exists $data->{discid} || !$data->{discid});
	return ("Incomplete CD TOC information given.", 0, 0) if (!exists $data->{toc} || !$data->{toc});
	my %tocdata = MusicBrainz::Server::CDTOC::ParseTOC(undef, $data->{toc});
    return ("Invalid TOC data passed in.", 0, 0) if (!%tocdata);
    return ("TOC data does not match passed in Disc Id.", 0, 0) if ($tocdata{discid} ne $data->{discid});
	return ("Invalid Disc Id.", 0, 0) if (length($data->{discid}) != &MusicBrainz::Server::CDTOC::CDINDEX_ID_LENGTH);
	return ("Number of tracks passed does not match passed TOC", 0, 0) if ($total != $tocdata{tracks});

    return ("", $total, \%tocdata);
}

# Add a new raw release to the DB. Pass in a hash ref with the following keys:
#   title => string of the title of the release
#   artist => string of the name of the artist of this release. If VA, leave blank
#   toc => the CD toc for this release (in string TOC format)
#   discid => The discid for this release.
#   tracks => a ref of an array of hashrefs with the following keys:
#      artist => the name of the artist for this track. Ignored if artist is given for release.
#      title => the title of the track.

# Insert a new raw release
sub Insert
{
	my $self = shift;
	my $data = shift;

    # Sanity check the data that was passed in
	my ($err, $total, $tocdata) = $self->_CheckData($data);
	return $err if ($err);

    # Now go insert the release
	my $sql = Sql->new($self->{DBH});
	eval
	{
		$sql->Begin;
		$sql->Do("INSERT INTO release_raw (title, artist) values (?,?)", $data->{title}, $data->{artist});
		my $alid = $sql->GetLastInsertId("release_raw");
		$sql->Do("INSERT INTO cdtoc_raw (release, discid, trackcount, leadoutoffset, trackoffset) values (?, ?, ?, ?, ?)",
				$alid, $data->{discid}, $total, $tocdata->{leadoutoffset}, "{".join(',',@{$tocdata->{trackoffsets}})."}");
		my $index = 1;
		foreach my $ref (@{$data->{tracks}})
		{
			$sql->Do("INSERT INTO track_raw (release, title, artist, sequence) values (?, ?, ?, ?)",
					$alid, $ref->{title}, $ref->{artist}, $index++);
		}

		$sql->Commit;

		return "";
    }; 
    if ($@)
	{
		$err = $@;
		$sql->Rollback();
		return $err;
	}
}

# Update a raw release. The data argument should be a ref to a hash with the same keys as the
# Insert function, except that a key id must be included that gives the id of the release to update,
# and that each track item also needs an id key.
sub Update
{
	my $self = shift;
	my $data = shift;
  
    # TODO: Do not allow updates of third party RawCDs

    # Sanity check the data that was passed in
	my ($err, $total, $tocdata) = $self->_CheckData($data);
	return $err if ($err);

	my $alid = $data->{id};
	return "No release id given" if (!MusicBrainz::Server::Validation::IsNonNegInteger($alid));

    # Now go update the release
	my $sql = Sql->new($self->{DBH});
	eval
	{
		$sql->Begin;
		$sql->Do("UPDATE release_raw 
				     SET title=?, artist=?,lastmodified=now(), modifycount = modifycount + 1 
				   WHERE id = ?", $data->{title}, $data->{artist}, $alid);
  
		# Update lastmodified
		$sql->Do("UPDATE cdtoc_raw 
				     SET discid = ?, trackcount = ?, leadoutoffset = ?, trackoffset = ?
				   WHERE release = ?",
				$data->{discid}, $total, $tocdata->{leadoutoffset}, "{".join(',',@{$tocdata->{trackoffsets}})."}", $alid);
		my $index = 1;
		foreach my $ref (@{$data->{tracks}})
		{
			$sql->Do("UPDATE track_raw SET title = ?, artist = ?, sequence = ? WHERE id = ?",
					 $ref->{title}, $ref->{artist}, $index++, $ref->{id});
		}

		$sql->Commit;

		return "";
    }; 
    if ($@)
	{
		$err = $@;
		$sql->Rollback();
		return $err;
	}
}

# Remove 
sub Remove
{
	my $self = shift;
	my $alid = shift;
	my $sql= shift;

	return "No release id given" if (!MusicBrainz::Server::Validation::IsNonNegInteger($alid));

    # Now go remove the release
    # We use no Begin/Commit block here since this function should only be called as part of
    # a larger transaction. (e.g. MOD_ADD_ALBUM)
	$sql->Do("DELETE FROM cdtoc_raw WHERE release = ?", $alid);
	$sql->Do("DELETE FROM track_raw WHERE release = ?", $alid);
	$sql->Do("DELETE FROM release_raw WHERE id = ?", $alid);
}

1;
# eof RawCD.pm
