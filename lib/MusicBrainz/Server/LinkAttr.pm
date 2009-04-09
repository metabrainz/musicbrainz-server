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

package MusicBrainz::Server::LinkAttr;

use base qw( TableBase );

################################################################################
# Ensure each link table has a "root" row
################################################################################

sub InsertDefaultRows
{
	use MusicBrainz::Server::Replication 'RT_SLAVE';
	return if &DBDefs::REPLICATION_TYPE == RT_SLAVE;

	require MusicBrainz;
	my $mb = MusicBrainz->new;
	$mb->Login;

	require Sql;
	my $sql = Sql->new($mb->{dbh});
	$sql->Begin;
	$sql->SelectSingleValue("SELECT 1 FROM link_attribute_type WHERE id = 0")
		or $sql->Do(
			"INSERT INTO link_attribute_type (id, parent, name, mbid, description) VALUES (0, 0, 'ROOT', ?, '')",
			TableBase::CreateNewGlobalId(),
		);
	$sql->Commit;
}

################################################################################
# Bare Constructor
################################################################################

sub new
{
    my ($class, $dbh) = @_;

    my $self = $class->SUPER::new($dbh);
	$self->{_table} = "link_attribute_type";
    $self;
}

################################################################################
# Properties
################################################################################

sub description
{
    my ($self, $new_desc) = @_;

    if (defined $new_desc) { $self->{description} = $new_desc; }
    return $self->{description};
}

sub GetParentId		{ $_[0]->{parent} }
sub SetParentId		{ $_[0]->{parent} = $_[1] }
sub Parent			{ $_[0]->newFromId($_[0]->GetParentId) }
sub Children		{ $_[0]->newFromParentId($_[0]->id) }
sub GetChildOrder	{ $_[0]->{childorder} }
sub SetChildOrder	{ $_[0]->{childorder} = $_[1] }

################################################################################
# Data Retrieval
################################################################################

sub _new_from_row
{
    my ($this, $row) = @_;
    my $self = $this->SUPER::_new_from_row($this->dbh, $row)
        or return;

    $self->{childorder} = $row->{childorder};
    $self->{parent} = $row->{parent};
    $self->{modpending} = $row->{modpending};
    $self->{name} = $row->{name};
    $self->{id} = $row->{id};
    $self->{description} = $row->{description};
    $self->{mbid} = $row->{mbid};

    bless $self, ref($this) || $this;
}

sub newFromId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->dbh);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM link_attribute_type WHERE id = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub newFromMBId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->dbh);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM link_attribute_type WHERE mbid = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub newFromParentId
{
	my ($self, $parentid) = @_;
	my $sql = Sql->new($self->dbh);
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM link_attribute_type WHERE parent = ? AND id != parent ORDER BY childorder, name",
		$parentid,
	);
	map { $self->_new_from_row($_) } @$rows;
}

sub newFromParentIdAndChildName
{
	my ($self, $parentid, $childname) = @_;
	my $sql = Sql->new($self->dbh);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM link_attribute_type WHERE parent = ? AND LOWER(name) = LOWER(?)",
		$parentid,
		$childname,
	);
	$self->_new_from_row($row);
}

################################################################################
# Tree Hierarchy
################################################################################

sub Root { $_[0]->newFromId(0) or die }
sub IsRoot { $_[0]->id == 0 }

sub PathFromRoot
{
	my ($self, $root) = @_;
	my @path;

	for (;;)
	{
		unshift @path, $self;
		last if $self->IsRoot;
		last if $root and $self->id == $root->id;
		$self = $self->Parent;
	}

	@path;
}

sub named_child
{
	my ($self, $childname) = @_;
	$self->newFromParentIdAndChildName($self->id, $childname);
}

sub HasChildren
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	my $value = $sql->SelectSingleValue(
		"select count(*) from link_attribute_type where parent = ?",
		$self->id,
	);
	return $value > 0;
}

################################################################################
# Insert, Delete
################################################################################

# Always call named_child first, to check that it doesn't already exist
sub AddChild
{
	my ($self, $childname, $desc, $childorder) = @_;
	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"INSERT INTO link_attribute_type (parent, name, mbid, description, childorder) VALUES (?, ?, ?, ?, ?)",
		$self->id,
		$childname,
		TableBase::CreateNewGlobalId(),
		$desc,
		$childorder,
	);
	$self->newFromId($sql->GetLastInsertId('link_attribute_type'));
}

sub InUse 
{ 
	my $self = shift;
	my $sql = Sql->new($self->dbh);

	my $value = $sql->SelectSingleValue(
		"select count(*) from link_attribute where attribute_type = ?",
		$self->id,
	);
	return $value > 0;
}

sub Delete
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	# Here we trust that the caller has tested "InUse", and found it to be
	# false.  If not, this statement might fail (FK violation).
	$sql->Do(
		"DELETE FROM link_attribute_type WHERE id = ?",
		$self->id,
	);
}

sub Update
{
	my $self = shift;
	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE link_attribute_type SET parent = ?, childorder = ?, name = ?, description = ? WHERE id = ?",
		$self->GetParentId,
		$self->GetChildOrder,
		$self->name,
		$self->description,
		$self->id,
	);
}

################################################################################

#InsertDefaultRows();

1;
# eof LinkAttr.pm
