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

package MusicBrainz::Server::CDTOC;

use constant FREEDB_ID_LENGTH => 8;
use constant CDINDEX_ID_LENGTH => 28;

use Exporter;
use TableBase;
{ our @ISA = qw( Exporter TableBase ) }

{
	our @EXPORT_OK = qw(
		FREEDB_ID_LENGTH
		CDINDEX_ID_LENGTH
	);
	our %EXPORT_TAGS = (
		hashlength	=> [qw( FREEDB_ID_LENGTH CDINDEX_ID_LENGTH )],
		all => \@EXPORT_OK,
	);
}

sub entity_type { "cdtoc" }

################################################################################
# Properties
################################################################################

# id - see TableBase
sub disc_id         { $_[0]{discid} }
sub freedb_id		{ $_[0]{freedbid} }
sub first_track	{ 1 }
sub last_track	{ $_[0]{trackcount} }
sub track_count	{ $_[0]{trackcount} }
sub leadout_offset{ $_[0]{leadoutoffset} }

################################################################################
# Derived Properties
################################################################################

sub track_offsets	{ $_[0]{_trackoffsets} ||= $_[0]->_DeriveTrackOffsets }
sub toc			{ $_[0]{_toc} ||= $_[0]->_DeriveTOC }
sub track_lengths	{ $_[0]{_tracklengths} ||= $_[0]->_DeriveTrackLengths }

sub track_statistics
{
	my $self = shift;

    my $offsets = $self->track_offsets;
    my $lengths = $self->track_lengths;

	my $tracks = [];

	for my $n ($self->first_track .. $self->last_track)
	{
        my $start  = $offsets->[$n-1];
        my $length = $lengths->[$n-1];

        push @{$tracks}, {
            number   => $n,
            start    => $start,
            length   => $length,
            end      => $start + $length,
        };
	}

	return $tracks;
}

sub duration
{
	my $self = shift;
	return $self->leadout_offset / 75 * 1000;
}

sub _DeriveTrackOffsets
{
	my $self = shift;
	[ $self->{trackoffset} =~ /(\d+)/g ];
}

sub _DeriveTOC
{
	my $self = shift;
	join " ",
		1, $self->{trackcount}, $self->{leadoutoffset},
		@{ $self->track_offsets };
}

sub _DeriveTrackLengths
{
	my $self = shift;
	my $trackoffsets = $self->track_offsets;
	[
		(map {
			$trackoffsets->[$_] - $trackoffsets->[$_-1]
		} 1 .. $#$trackoffsets),
		$self->{leadoutoffset} - $trackoffsets->[-1],
	];
}

################################################################################
# Retrieval
################################################################################

sub newFromId
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $id = shift;

	my $sql = Sql->new($self->dbh);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM cdtoc WHERE id = ?", $id,
	) or return undef;

	$self->_new_from_row($row);
}

sub newFromTOC
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $tocstr = shift;

	my %info = $self->ParseTOC($tocstr)
		or die "Attempt to look up invalid TOC ($tocstr)\n";
	my $trackoffset = "{".join(",", @{ $info{trackoffsets} })."}";

	my $sql = Sql->new($self->dbh);

	# Select on discid (for speed; this is indexed).
	# Then compare all the fields which make up the TOC.
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM cdtoc
		WHERE	discid = ?
		AND		trackcount = ?
		AND		leadoutoffset = ?
		AND		trackoffset = ?",
		$info{discid},
		$info{tracks},
		$info{leadoutoffset},
		$trackoffset,
	) or return undef;

	$self->_new_from_row($row);
}

sub newFromDiscID
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $discid = shift;

	my $sql = Sql->new($self->dbh);
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM cdtoc WHERE discid = ?", $discid,
	);

	$_ = $self->_new_from_row($_) for @$rows;
	$rows;
}

sub newFromFreeDBID
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $freedbid = shift;

	my $sql = Sql->new($self->dbh);
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM cdtoc WHERE freedbid = ?", $freedbid,
	);

	$_ = $self->_new_from_row($_) for @$rows;
	$rows;
}

sub release_cdtocs
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	require MusicBrainz::Server::ReleaseCDTOC;
	MusicBrainz::Server::ReleaseCDTOC->newFromCDTOC($self->{dbh}, $self, @_);
}

################################################################################

sub GetOrInsertTOC
{
	my $self = shift;
	$self = $self->new(shift) if not ref $self;
	my $tocstr = shift;

	my %info = $self->ParseTOC($tocstr)
		or die "Attempt to insert invalid TOC ($tocstr)\n";
	my $trackoffset = "{".join(",", @{ $info{trackoffsets} })."}";
	
	my $sql = Sql->new($self->dbh);
	$sql->Do("LOCK TABLE cdtoc IN EXCLUSIVE MODE");

	# Select on discid (for speed; this is indexed).
	# Then compare all the fields which make up the TOC.
	my $id = $sql->SelectSingleValue(
		"SELECT	id FROM cdtoc
		WHERE	discid = ?
		AND		trackcount = ?
		AND		leadoutoffset = ?
		AND		trackoffset = ?",
		$info{discid},
		$info{tracks},
		$info{leadoutoffset},
		$trackoffset,
	);
	return $id if $id;

	# Otherwise, we need to insert it.
	return $sql->InsertRow(
		"cdtoc",
		{
			discid			=> $info{'discid'},
			freedbid		=> $info{'freedbid'},
			trackcount		=> $info{'tracks'},
			leadoutoffset	=> $info{'leadoutoffset'},
			trackoffset		=> $trackoffset,
		},
	);
}

# Take in a CD TOC in string format.  Parse it, validate it.
# Returns empty list (false) on failure.  Returns the discid (true)
# on success.  In list context, returns a hash of derived information,
# including: toc tracks firsttrack lasttrack leadoutoffset tracklengths
# trackoffsets discid freedbid.

sub ParseTOC
{
	my ($class, $toc) = @_;

	defined($toc) or return;
	$toc =~ s/\A\s+//;
	$toc =~ s/\s+\z//;
	$toc =~ /\A\d+(?: \d+)*\z/ or return;

	my ($firsttrack, $lasttrack, $leadoutoffset, @trackoffsets)
		= split ' ', $toc;

	$firsttrack == 1 or return;
	$lasttrack >=1 and $lasttrack <= 99 or return;
	@trackoffsets == $lasttrack or return;

	for (($firsttrack + 1) .. $lasttrack)
	{
		$trackoffsets[$_-1] > $trackoffsets[$_-1-1]
			or return;
	}

	$leadoutoffset > $trackoffsets[-1]
		or return;

	my $message = "";
	$message .= sprintf("%02X", $firsttrack);
	$message .= sprintf("%02X", $lasttrack);
	$message .= sprintf("%08X", $leadoutoffset);
	$message .= sprintf("%08X", ($trackoffsets[$_-1] || 0))
		for 1 .. 99;

	use Digest::SHA1 qw(sha1_base64);
	my $discid = sha1_base64($message);
	$discid .= "="; # bring up to 28 characters, like the client
	$discid =~ tr[+/=][._-];

	return $discid unless wantarray;

	my @lengths = map {
		($trackoffsets[$_+1-1] || $leadoutoffset) - $trackoffsets[$_-1]
	} $firsttrack .. $lasttrack;

	require FreeDB;
	my $freedbid = FreeDB::_compute_discid(@trackoffsets, $leadoutoffset);

	return (
		toc				=> $toc,
		tracks			=> scalar @trackoffsets,
		firsttrack		=> $firsttrack,
		lasttrack		=> $lasttrack,
		leadoutoffset	=> $leadoutoffset,
		tracklengths	=> \@lengths,
		trackoffsets	=> \@trackoffsets,
		discid			=> $discid,
		freedbid		=> $freedbid,
	);
}

1;
# eof CDTOC.pm
