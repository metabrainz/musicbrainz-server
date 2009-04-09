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
use constant RELEASE_FORMAT_DVD_AUDIO       => 16;
use constant RELEASE_FORMAT_BLU_RAY         => 17;
use constant RELEASE_FORMAT_HD_DVD          => 18;
use constant LAST_RELEASE_FORMAT			=> 18;

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
   16 => 'DVD Audio',
   17 => 'Blu-ray',
   18 => 'HD-DVD',
);

sub release_formats
{
	my @types;

	for (my $id = 1; $id <= LAST_RELEASE_FORMAT; $id++)
	{
		push @types, ($id, $ReleaseFormatNames{$id});
	}
	return \@types;
}

sub release_format_name
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

# id / id - see TableBase

sub release
{
    my ($self, $new_release) = @_;

    if (defined $new_release) { $self->{album} = $new_release; }
    return $self->{album};
}

sub label
{
    my ($self, $new_label) = @_;

    if (defined $new_label) { $self->{_label} = $new_label; }
    return $self->{_label};
}

sub country
{
    my ($self, $new_country) = @_;

    if (defined $new_country) { $self->{country} = $new_country; }
    return $self->{country};
}

sub Country
{
	my $self = shift;
	my $c = MusicBrainz::Server::Country->new($self->dbh);
	$c = $c->newFromId($self->country);
	$c;
}

sub cat_no
{
    my ($self, $new_cat_no) = @_;

    if (defined $new_cat_no) { $self->{catno} = $new_cat_no; }
    return $self->{catno};
}

sub barcode
{
    my ($self, $new_barcode) = @_;

    if (defined $new_barcode) { $self->{barcode} = $new_barcode; }
    return $self->{barcode};
}

sub format
{
    my ($self, $new_format) = @_;

    if (defined $new_format) { $self->{format} = $new_format; }
    return $self->{format};
}

sub format_name	{ $ReleaseFormatNames{$_[0]{format}} }

sub date
{
    my $self = shift;

    if (@_)
    {
        my ($y, $m, $d) = @_;

        $self->{'releasedate'} = sprintf "%04d-%02d-%02d",
            $y || 0, $m || 0, $d || 0;
    }
    
    map { 0 + $_ } split('-', $self->{releasedate});
}

sub year  { ($_[0]->date)[0]; }
sub month { ($_[0]->date)[1]; }
sub day   { ($_[0]->date)[2]; }

sub sort_date
{
    my ($self, $new_date) = @_;

    if (defined $new_date) { $self->date(split /-/, $new_date); }
    return $self->{releasedate};
}

# GetModPending / SetModPending - see TableBase

sub ToString { 
	my $self = shift;
	return 	"ReleaseEvent { Id: " . $self->id . 
			", Release: " . $self->release . 
			", Date: " . $self->{"releasedate"} . 
			", Country: ".$self->country .
			"}";
}

################################################################################
# Constructors
################################################################################

sub newFromId
{
	my ($self, $id) = @_;
   	my $sql = Sql->new($self->dbh);
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
	my $sql = Sql->new($self->dbh);
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
	map { $self->_new_from_row($_, $loadlabels) }
		@{
			$sql->SelectListOfHashes($query, $album),
		};
}

sub _new_from_row
{
    my ($self, $row, $has_label_info) = @_;

    my $event = MusicBrainz::Server::ReleaseEvent->new($self->dbh);

    my $label = MusicBrainz::Server::Label->new($self->dbh);
    $label->id($row->{label});

    if ($has_label_info)
    {
        $label->name($row->{labelname});
        $label->mbid($row->{labelgid});
    }

    $event->id($row->{id});
    $event->release($row->{album});
    $event->country($row->{country});
    $event->date(split m/-/, $row->{releasedate});
    $event->label($label);
    $event->cat_no($row->{catno});
    $event->barcode($row->{barcode});
    $event->format($row->{format});

    return $event;
}

################################################################################
# Insert, Update, Delete
################################################################################

sub InsertSelf
{
	my $self = shift;
   	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"INSERT INTO release (album, country, releasedate, label, catno, barcode, format) VALUES (?, ?, ?, ?, ?, ?, ?)",
		$self->release,
		$self->country,
		$self->sort_date,
		$self->label->id || undef,
		$self->cat_no || undef,
		$self->barcode || undef,
		$self->format || undef,
	);
	$self->id($sql->GetLastInsertId("release"));
}

sub Update
{
	my ($self, %new) = @_;
   	my $sql = Sql->new($self->dbh);
	$self->country($new{"country"});
	$self->sort_date($new{"date"});
	$self->label->id($new{"label"});
	$self->cat_no($new{"catno"});
	$self->barcode($new{"barcode"});
	$self->format($new{"format"});
	$sql->Do(
		"UPDATE release SET country = ?, releasedate = ?, label = ?, catno = ?, barcode = ?, format = ? WHERE id = ?",
		$self->country,
		$self->sort_date,
		$self->label->id || undef,
		$self->cat_no || undef,
		$self->barcode || undef,
		$self->format || undef,
		$self->id,
	);
}

sub UpdateModPending
{
	my ($self, $adjust) = @_;

	my $id = $self->id
		or croak "Missing release ID in UpdateModPending";
	defined($adjust)
		or croak "Missing adjustment in UpdateModPending";

	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE release SET modpending = NUMERIC_LARGER(modpending+?, 0) WHERE id = ?",
		$adjust,
		$id,
	);
}

sub RemoveById
{
	my ($self, $id) = @_;
   	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"DELETE FROM release WHERE id = ?",
		$id,
	);
}

sub RemoveByRelease
{
	my ($self, $albumid) = @_;
   	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"DELETE FROM release WHERE album = ?",
		$albumid,
	);
}

sub MoveFromReleaseToRelease
{
	my ($self, $fromalbumid, $toalbumid) = @_;
   	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE release SET album = ? WHERE album = ?",
		$toalbumid,
		$fromalbumid,
	);
}

1;
# eof Release.pm
