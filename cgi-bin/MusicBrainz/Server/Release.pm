#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

package MusicBrainz::Server::Release;

use base qw( TableBase );
use Carp;

################################################################################
# Properties
################################################################################

# GetId / SetId - see TableBase

sub GetAlbum	{ $_[0]{album} }
sub SetAlbum	{ $_[0]{album} = $_[1] }
sub Album
{
	my $self = shift;
	my $c = Album->new($self->{DBH});
	$c->SetId($self->GetAlbum);
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
			", Release: " . $self->GetAlbum . 
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

sub newFromAlbum
{
	my ($self, $album) = @_;
   	my $sql = Sql->new($self->{DBH});
	map { $self->_new_from_row($_) }
		@{
			$sql->SelectListOfHashes(
				"SELECT * FROM release WHERE album = ? ORDER BY releasedate, country",
				$album,
			),
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
		"INSERT INTO release (album, country, releasedate) VALUES (?, ?, ?)",
		$self->GetAlbum,
		$self->GetCountry,
		$self->GetSortDate,
	);
	$self->SetId($sql->GetLastInsertId("release"));
}

sub Update
{
	my ($self, %new) = @_;
   	my $sql = Sql->new($self->{DBH});
	$self->SetCountry($new{"country"}) if $new{"country"};
	$self->SetSortDate($new{"date"}) if $new{"date"};
	$sql->Do(
		"UPDATE release SET country = ?, releasedate = ? WHERE id = ?",
		$self->GetCountry,
		$self->GetSortDate,
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

sub RemoveByAlbum
{
	my ($self, $albumid) = @_;
   	my $sql = Sql->new($self->{DBH});
	$sql->Do(
		"DELETE FROM release WHERE album = ?",
		$albumid,
	);
}

sub MoveFromAlbumToAlbum
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
