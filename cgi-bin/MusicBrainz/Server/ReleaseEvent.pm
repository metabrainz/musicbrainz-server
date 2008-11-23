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

package MusicBrainz::Server::ReleaseEvent;

use base qw( TableBase );
use Carp;

use constant RELEASE_FORMAT_CD				=> 1;
use constant RELEASE_FORMAT_DVD				=> 2;
use constant RELEASE_FORMAT_SACD			=> 3;
use constant RELEASE_FORMAT_DUALDISC		=> 4;
use constant RELEASE_FORMAT_LASERDISC		=> 5;
use constant RELEASE_FORMAT_MINIDISC		=> 6;
use constant RELEASE_FORMAT_VINYL			=> 7;
use constant RELEASE_FORMAT_CASSETTE		=> 8;
use constant RELEASE_FORMAT_CARTRIDGE		=> 9;
use constant RELEASE_FORMAT_REEL_TO_REEL	=> 10;
use constant RELEASE_FORMAT_DAT				=> 11;
use constant RELEASE_FORMAT_DIGITAL			=> 12;
use constant RELEASE_FORMAT_OTHER			=> 13;
use constant RELEASE_FORMAT_WAX_CYLINDER	=> 14;
use constant RELEASE_FORMAT_PIANO_ROLL  	=> 15;
use constant LAST_RELEASE_FORMAT			=> 15;

my %ReleaseFormatNames = (
   1 => 'CD',
   2 => 'DVD',
   3 => 'SACD',
   4 => 'DualDisc',
   5 => 'LaserDisc',
   6 => 'MiniDisc',
   7 => 'Vinyl',
   8 => 'Cassette',
   9 => 'Cartridge (4/8-tracks)',
   10 => 'Reel-to-reel',
   11 => 'DAT',
   12 => 'Digital Media',
   13 => 'Other',
   14 => 'Wax Cylinder',
   15 => 'Piano Roll',
);

sub GetReleaseFormats
{
	my @types;
	my $type = ["", ""];
	push @types, $type;
	for (my $id = 1; $id <= LAST_RELEASE_FORMAT; $id++)
	{
		$type = [$id, $ReleaseFormatNames{$id}];
		push @types, $type;
	}
	return \@types;
}

sub GetReleaseFormatName
{
	my $format = shift;
	return $ReleaseFormatNames{$format}
}

sub IsValidFormat
{
	my $type = shift;
	return (defined $type and ($type eq "" or ($type >= 1 and $type <= LAST_RELEASE_FORMAT)));
}

################################################################################
# Properties
################################################################################

# GetId / SetId - see TableBase

sub GetRelease	{ $_[0]{album} }
sub SetRelease	{ $_[0]{album} = $_[1] }
sub Release
{
	my $self = shift;
	my $c = MusicBrainz::Server::Release->new($self->{DBH});
	$c->SetId($self->GetRelease);
	$c->LoadFromId or return undef;
	$c;
}

sub GetCountry	{ $_[0]{country} }
sub SetCountry	{ $_[0]{country} = $_[1] }
sub Country
{
	my $self = shift;
	my $c = MusicBrainz::Server::Country->new($self->{DBH});
	$c = $c->newFromId($self->GetCountry);
	$c;
}

sub GetCatNo	{ $_[0]{catno} }
sub SetCatNo	{ $_[0]{catno} = $_[1] }

sub GetBarcode	{ $_[0]{barcode} }
sub SetBarcode	{ $_[0]{barcode} = $_[1] }

sub GetLabel	{ $_[0]{label} }
sub SetLabel	{ $_[0]{label} = $_[1] }
sub Label
{
	my $self = shift;
	my $c = MusicBrainz::Server::Label->new($self->{DBH});
	$c->SetId($self->GetLabel);
	$c->LoadFromId or return undef;
	$c;
}
# This doesn't have to always contain the actual label name. Use it
# only on instances loaded by newFromRelease.
sub GetLabelName	{ $_[0]{labelname} }
sub SetLabelName	{ $_[0]{labelname} = $_[1] }
sub GetLabelMBId	{ $_[0]{labelgid} }

sub GetFormat		{ $_[0]{format} }
sub SetFormat		{ $_[0]{format} = $_[1] }
sub GetFormatName	{ $ReleaseFormatNames{$_[0]{format}} }

sub GetYMD
{
	map { 0+$_ } split '-', $_[0]{'releasedate'};
}

sub GetYear
{
	($_[0]->GetYMD)[0];
}

sub GetMonth
{
	($_[0]->GetYMD)[1];
}

sub GetDay
{
	($_[0]->GetYMD)[2];
}

sub SetYMD
{
	my ($self, $y, $m, $d) = @_;
	$self->{'releasedate'} = sprintf "%04d-%02d-%02d",
		$y || 0, $m || 0, $d || 0;
}

sub GetSortDate	{ $_[0]{'releasedate'} }
sub SetSortDate { $_[0]->SetYMD(split /-/, $_[1]) }
# GetModPending / SetModPending - see TableBase

sub ToString { 
	my $self = shift;
	return 	"ReleaseEvent { Id: " . $self->GetId . 
			", Release: " . $self->GetRelease . 
			", Date: " . $self->{"releasedate"} . 
			", Country: ".$self->GetCountry .
			"}";
}


################################################################################
# Constructors
################################################################################

sub newFromId
{
	my ($self, $id) = @_;
   	my $sql = Sql->new($self->{DBH});
	$self->_new_from_row(
		$sql->SelectSingleRowHash(
			"SELECT * FROM release WHERE id = ?",
			$id,
		),
	);
}

sub newFromRelease
{
	my ($self, $album, $loadlabels) = @_;
	my $sql = Sql->new($self->{DBH});
	my $query;
	if ($loadlabels) 
	{
		$query = "SELECT release.*, label.name AS labelname, label.gid AS labelgid
				  FROM release LEFT JOIN label ON release.label = label.id
				  WHERE release.album = ? ORDER BY release.releasedate, release.country";
	}
	else
	{
		$query = "SELECT * FROM release WHERE album = ? ORDER BY releasedate, country";
	}
	map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes($query, $album),
		};
}

################################################################################
# Insert, Update, Delete
################################################################################

sub InsertSelf
{
	my $self = shift;
   	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"INSERT INTO release (album, country, releasedate, label, catno, barcode, format) VALUES (?, ?, ?, ?, ?, ?, ?)",
		$self->GetRelease,
		$self->GetCountry,
		$self->GetSortDate,
		$self->GetLabel || undef,
		$self->GetCatNo || undef,
		$self->GetBarcode || undef,
		$self->GetFormat || undef,
	);
	$self->SetId($sql->GetLastInsertId("release"));
}

sub Update
{
	my ($self, %new) = @_;
   	my $sql = Sql->new($self->{DBH});
	$self->SetCountry($new{"country"});
	$self->SetSortDate($new{"date"});
	$self->SetLabel($new{"label"});
	$self->SetCatNo($new{"catno"});
	$self->SetBarcode($new{"barcode"});
	$self->SetFormat($new{"format"});
	$sql->Do(
		"UPDATE release SET country = ?, releasedate = ?, label = ?, catno = ?, barcode = ?, format = ? WHERE id = ?",
		$self->GetCountry,
		$self->GetSortDate,
		$self->GetLabel || undef,
		$self->GetCatNo || undef,
		$self->GetBarcode || undef,
		$self->GetFormat || undef,
		$self->GetId,
	);
}

sub UpdateModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->GetId
		or croak "Missing release ID in UpdateModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateModPending";

	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE release SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
		$adjust,
		$id,
	);
}

sub RemoveById
{
	my ($self, $id) = @_;
   	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM release WHERE id = ?",
		$id,
	);
}

sub RemoveByRelease
{
	my ($self, $albumid) = @_;
   	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM release WHERE album = ?",
		$albumid,
	);
}

sub MoveFromReleaseToRelease
{
	my ($self, $fromalbumid, $toalbumid) = @_;
   	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"UPDATE release SET album = ? WHERE album = ?",
		$toalbumid,
		$fromalbumid,
	);
}

1;
# eof Release.pm
