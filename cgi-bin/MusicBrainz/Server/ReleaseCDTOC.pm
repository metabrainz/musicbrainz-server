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
#   $Id$
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::ReleaseCDTOC;

use constant DEBUG_GENERATE_FROM_DISCID => 1;
use constant LOOKUP_AT_FREEDB => 1;
use constant AUTO_FREEDB_IMPORTS => 0;

use TableBase;
use DBDefs;
{ our @ISA = qw( TableBase ) }

use MusicBrainz::Server::CDTOC ':hashlength';
use MusicBrainz::Server::LogFile qw( lprint lprintf );

################################################################################
# Properties
################################################################################

# GetId / SetId - see TableBase
sub GetReleaseId	{ $_[0]{album} }
sub GetCDTOCId	{ $_[0]{cdtoc} }
# GetModPending / SetModPending - see TableBase

################################################################################
# Derived Properties
################################################################################

sub GetRelease	{ $_[0]{_album} ||= $_[0]->_GetRelease }
sub GetCDTOC	{ $_[0]{_cdtoc} ||= $_[0]->_GetCDTOC }

sub _GetCDTOC
{
	my $self = shift;
	my $id = $self->GetCDTOCId;

	my $cdtoc = MusicBrainz::Server::CDTOC->newFromId($self->{DBH}, $id);
	$cdtoc or warn "Failed to fetch CDTOC #$id";

	$cdtoc;
}

sub _GetRelease
{
	my $self = shift;
	my $id = $self->GetReleaseId;

	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->{DBH});
	$release->SetId($id);
	$release->LoadFromId
		and return $release;

	warn "Failed to fetch release #$id";
	undef;
}

################################################################################
# Retrieval
################################################################################

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $sql = Sql->new($self->{DBH});
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM album_cdtoc WHERE id = ?", $id,
	) or return undef;

	$self->_new_from_row($row);
}

# Given a CDTOC (object or ID), get a list of ReleaseCDTOCs

sub newFromCDTOC
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $cdtoc = shift;
	my $id = (ref($cdtoc) ? $cdtoc->GetId : $cdtoc);

	my $sql = Sql->new($self->{DBH});
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM album_cdtoc WHERE cdtoc = ?", $id,
	);

	grep { $_->{_cdtoc} = $cdtoc } @$rows
		if ref($cdtoc);
	$_ = $self->_new_from_row($_) for @$rows;
	$rows;
}

# Given an album (object or ID), get a list of ReleaseCDTOCs, including their
# CDTOCs.  Called by $album->GetDiscIDs.

sub newFromRelease
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $album = shift;
	my $id = (ref($album) ? $album->GetId : $album);

	my $sql = Sql->new($self->{DBH});
	my $rows = $sql->SelectListOfHashes(
		"SELECT	j.id AS j_id,
				j.album AS j_album,
				j.cdtoc AS j_cdtoc,
				j.modpending AS j_modpending,
				c.*
		FROM	album_cdtoc j, cdtoc c
		WHERE	c.id = j.cdtoc
		AND		j.album = ?",
		$id,
	);

	my $cdtoc = MusicBrainz::Server::CDTOC->new($self->{DBH});
	for (@$rows)
	{
		my %j = (
			id			=> delete $_->{j_id},
			album		=> delete $_->{j_album},
			cdtoc		=> delete $_->{j_cdtoc},
			modpending	=> delete $_->{j_modpending},
		);
		$j{_cdtoc} = $cdtoc->_new_from_row($_);
		$_ = $self->_new_from_row(\%j);
	}

	$rows;
}

# Given an album (object or ID) and a CDTOC (object or ID), return the
# album_cdtoc which binds them, or undef.  Used by the DiscID moderations.

sub newFromReleaseAndCDTOC
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $album = shift;
	my $albumid = (ref($album) ? $album->GetId : $album);
	my $cdtoc = shift;
	my $cdtocid = (ref($cdtoc) ? $cdtoc->GetId : $cdtoc);

	my $sql = Sql->new($self->{DBH});
	my $row = $sql->SelectSingleRowHash(
		"SELECT	j.id AS j_id,
				j.album AS j_album,
				j.cdtoc AS j_cdtoc,
				j.modpending AS j_modpending,
				c.*
		FROM	album_cdtoc j, cdtoc c
		WHERE	c.id = j.cdtoc
		AND		j.album = ?
		AND		j.cdtoc = ?",
		$albumid,
		$cdtocid,
	) or return undef;

	$cdtoc = MusicBrainz::Server::CDTOC->new($self->{DBH});
	for ($row)
	{
		my %j = (
			id			=> delete $_->{j_id},
			album		=> delete $_->{j_album},
			cdtoc		=> delete $_->{j_cdtoc},
			modpending	=> delete $_->{j_modpending},
		);
		$j{_cdtoc} = $cdtoc->_new_from_row($_);
		$_ = $self->_new_from_row(\%j);
	}

	$row;
}

# Given a discid / freedbid, get a list of ReleaseCDTOCs, including their CDTOCs

sub newFromDiscID { my $self = shift; $self->_newFromHash("discid", @_) }
sub newFromFreeDBID { my $self = shift; $self->_newFromHash("freedbid", @_) }

sub _newFromHash
{
	my $self = shift;
	my $type = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $correct_length = (
		($type eq "discid") ? CDINDEX_ID_LENGTH
		: ($type eq "freedbid") ? FREEDB_ID_LENGTH
		: die "unknown hash type '$type'"
	);
	return [] unless length($id) == $correct_length;

	my $sql = Sql->new($self->{DBH});
	my $rows = $sql->SelectListOfHashes(
		"SELECT	j.id AS j_id,
				j.album AS j_album,
				j.cdtoc AS j_cdtoc,
				j.modpending AS j_modpending,
				c.*
		FROM	album_cdtoc j, cdtoc c
		WHERE	c.id = j.cdtoc
		AND		c.$type = ?",
		$id,
	);

	my $cdtoc = MusicBrainz::Server::CDTOC->new($self->{DBH});
	for (@$rows)
	{
		my %j = (
			id			=> delete $_->{j_id},
			album		=> delete $_->{j_album},
			cdtoc		=> delete $_->{j_cdtoc},
			modpending	=> delete $_->{j_modpending},
		);
		$j{_cdtoc} = $cdtoc->_new_from_row($_);
		$_ = $self->_new_from_row(\%j);
	}

	$rows;
}

# Given a discid / freedbid, get a list of matching album IDs

sub GetReleaseIDsFromDiscID { my $self = shift; $self->_GetReleaseIDsFromHash("discid", @_) }
sub GetReleaseIDsFromFreeDBID { my $self = shift; $self->_GetReleaseIDsFromHash("freedbid", @_) }

sub _GetReleaseIDsFromHash
{
	my $self = shift;
	my $type = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $correct_length = (
		($type eq "discid") ? CDINDEX_ID_LENGTH
		: ($type eq "freedbid") ? FREEDB_ID_LENGTH
		: die "unknown hash type '$type'"
	);
	return [] unless length($id) == $correct_length;

	my $sql = Sql->new($self->{DBH});
	$sql->SelectSingleColumnArray(
		"SELECT DISTINCT album
		FROM	album_cdtoc, cdtoc
		WHERE	album_cdtoc.cdtoc = cdtoc.id
		AND		cdtoc.$type = ?",
		$id,
	);
}

sub GenerateAlbumFromDiscid
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my ($rdf, $discid, $toc) = @_;

	# Validate the arguments
	return $rdf->ErrorRDF("No Discid given.")
		if not defined $discid;

	lprintf "generatefromdiscid", "GenerateAlbumFromDiscid start: discid=%s toc=[%s]",
		$discid, $toc || "?",
		if DEBUG_GENERATE_FROM_DISCID;

	if (defined($toc))
	{
		my %info = MusicBrainz::Server::CDTOC->ParseTOC($toc);
		if (not %info)
		{
			lprintf "generatefromdiscid", "GenerateAlbumFromDiscid error: invalid TOC",
				if DEBUG_GENERATE_FROM_DISCID;
			return $rdf->ErrorRDF("Invalid TOC.");
		}

		if ($discid ne $info{'discid'})
		{
			lprintf "generatefromdiscid", "GenerateAlbumFromDiscid error: TOC/discid mismatch; discid=%s/%s",
				$discid, $info{'discid'},
				if DEBUG_GENERATE_FROM_DISCID;
			return $rdf->ErrorRDF("TOC doesn't match discid / track count.");
		}
	}

	# Check to see if the album is in the main database
	my $albumids = $self->GetReleaseIDsFromDiscID($discid);
    # If we found something, return it
	if (@$albumids)
	{
		my @mbids;

		for my $id (@$albumids)
		{
			my $al = MusicBrainz::Server::Release->new($self->{DBH});
			$al->SetId($id);
			$al->LoadFromId();
			push @mbids, $al->GetMBId;
		}

		lprintf "generatefromdiscid", "GenerateAlbumFromDiscid success: already got album%s %s",
			(@mbids == 1 ? "" : "s"),
			join(",", @mbids),
			if DEBUG_GENERATE_FROM_DISCID;

		return $rdf->CreateDenseAlbum(0, \@mbids);
	}

	# If we were querying on discid only (no TOC), we can't go any further
	if (not defined $toc)
	{
		lprintf "generatefromdiscid", "GenerateAlbumFromDiscid no-match: No album match, and no TOC submitted; can't proceed",
			if DEBUG_GENERATE_FROM_DISCID;
		return $rdf->CreateStatus(0);
	}


	if (LOOKUP_AT_FREEDB)
	{
		# Let's pull the records from FreeDB and insert it into the db if we find it
		require FreeDB;
		my $fd = FreeDB->new($self->{DBH});
		my $ref = $fd->Lookup($discid, $toc);

		if (defined $ref)
		{
            if (AUTO_FREEDB_IMPORTS)
            {
                my ($artistid, $albumid, $mods) = $fd->InsertForModeration($ref);

                lprintf "generatefromdiscid", "GenerateAlbumFromDiscid success: FreeDB lookup succeeded (%s insert)",
                    ($albumid ? "with" : "without"),
                    if DEBUG_GENERATE_FROM_DISCID;
            }

			# If $albumid is true (indicating a FreeDB insert just happened),
			# maybe we could return $rdf->CreateDenseAlbum(0, [ $mbid-of-$albumid ]) ?
			return $rdf->CreateFreeDBLookup($ref);
		}
	}

	# This CD can't be found
	lprintf "generatefromdiscid", "GenerateAlbumFromDiscid no-match: returning nothing",
		if DEBUG_GENERATE_FROM_DISCID;

	return $rdf->CreateStatus(0);
}

################################################################################
# Modification
################################################################################

sub Insert
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $album = shift;
	my $toc = shift;
	my %opts = @_;
	$album = $album->GetId if ref $album;
	die "Expected a TOC string, not a '$toc'" if ref $toc;

	require MusicBrainz::Server::CDTOC;
	my $tocid = MusicBrainz::Server::CDTOC->GetOrInsertTOC($self->{DBH}, $toc);
	if (my $t = $opts{'tocid'}) { $$t = $tocid }

	my $sql = Sql->new($self->{DBH});
	$sql->Do("LOCK TABLE album_cdtoc IN EXCLUSIVE MODE");

	my $id = $sql->SelectSingleValue(
		"SELECT id FROM album_cdtoc WHERE album = ? AND cdtoc = ?",
		$album,
		$tocid,
	);
	if (my $t = $opts{'added'}) { $$t = not $id }
	return $id if $id;

	my $ret = $sql->InsertRow(
		"album_cdtoc",
		{
			album	=> $album,
			cdtoc	=> $tocid,
		},
	);

	# Remove the Raw CD
	require MusicBrainz::Server::RawCD;
	my $rawdb = $Moderation::DBConnections{RAWDATA};
	my $rc = MusicBrainz::Server::RawCD->new($rawdb->{DBH});
	my %info = MusicBrainz::Server::CDTOC->ParseTOC($toc);
	my $rawcd = $rc->Lookup($info{discid});

	# Pass in the rawdb object that has the transaction open
	$rc->Remove($rawcd->{id}, $rawdb);

    return $ret;
}

sub MoveToRelease
{
	my ($self, $album, $already_there_flagref) = @_;
	my $sql = Sql->new($self->{DBH});
	$album = $album->GetId if ref $album;

	$$already_there_flagref = 0
		if $already_there_flagref;

	# Move if this cdtoc is not already on the new album
	$sql->Do(
		"UPDATE album_cdtoc SET album = ?
		WHERE id = ?
		AND NOT EXISTS (
			SELECT 1 FROM album_cdtoc b
			WHERE album = ?
			AND cdtoc = ?
		)",
		$album,
		$self->GetId,
		$album,
		$self->GetCDTOCId,) 
    and return;

	# Otherwise, it's already there; just delete this one
	$sql->Do("DELETE FROM album_cdtoc WHERE id = ?", $self->GetId);
	$$already_there_flagref = 1
		if $already_there_flagref;
}

sub MergeReleases
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $oldalbum = shift;
	my $newalbum = shift;
	$oldalbum = $oldalbum->GetId if ref $oldalbum;
	$newalbum = $newalbum->GetId if ref $newalbum;

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE album_cdtoc SET album = ? WHERE album = ?
			AND cdtoc NOT IN (SELECT cdtoc FROM album_cdtoc t WHERE album = ?)",
		$newalbum,
		$oldalbum,
		$newalbum,
	);
	$sql->Do(
		"DELETE FROM album_cdtoc WHERE album = ?",
		$oldalbum,
	);
}

sub Remove
{
	my ($self) = @_;

	my $sql = Sql->new($self->{DBH});
    print STDERR "DELETE: Removed album_cdtoc where id was " . $self->GetId . "\n";
	$sql->Do("DELETE FROM album_cdtoc WHERE id = ?", $self->GetId);
	# TODO remove unused cdtoc?
}

sub RemoveAlbum
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $album = shift;

	my $sql = Sql->new($self->{DBH});
	$sql->Do("DELETE FROM album_cdtoc WHERE album = ?", $album);
	# TODO remove unused cdtoc?
}

1;
# eof ReleaseCDTOC.pm
