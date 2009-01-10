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

package MusicBrainz::Server::LinkType;

use base qw( TableBase );
require MusicBrainz::Server::LinkEntity;

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
	my $sql = Sql->new($mb->{DBH});
	$sql->Begin;

	my @e = MusicBrainz::Server::LinkEntity->Types;

	for my $left (@e)
	{
		for my $right (@e)
		{
			next if $right lt $left;
			my $table = "lt_${left}_${right}";

			$sql->SelectSingleValue("SELECT 1 FROM $table WHERE id = 0")
				or $sql->Do(
					"INSERT INTO $table (id, parent, name, linkphrase, rlinkphrase, description, attribute, mbid) VALUES (0, 0, 'ROOT', '', '', '', '', ?)",
					TableBase::CreateNewGlobalId(),
				);
		}
	}

	$sql->Commit;
}

################################################################################
# Bare Constructor
################################################################################

sub new
{
    my ($class, $dbh, $types) = @_;

	ref($types) eq "ARRAY" or die;
	# So far, links are always between two things.  This may change one day.
	@$types == 2 or die;

	MusicBrainz::Server::LinkEntity->ValidateTypes($types)
		or die;

    my $self = $class->SUPER::new($dbh);
	my @t = @$types;
    $self->{_types} = \@t;
	$self->{_table} = "lt_" . join "_", @t;

    $self;
}

################################################################################
# Properties
################################################################################

sub Table			{ $_[0]{_table} }

sub GetParentId		{ $_[0]->{parent} }
sub SetParentId		{ $_[0]->{parent} = $_[1] }
sub Parent			{ $_[0]->newFromId($_[0]->GetParentId) }
sub Children		{ $_[0]->newFromParentId($_[0]->id) }

sub Types			{ wantarray ? @{ $_[0]{_types} } : $_[0]{_types} }
sub GetNumberOfLinks{ scalar @{ $_[0]{_types} } }
sub GetLinkPhrase   { $_[0]->{linkphrase} }
sub SetLinkPhrase   { $_[0]->{linkphrase} = $_[1]; }
sub GetReverseLinkPhrase   { $_[0]->{rlinkphrase} }
sub SetReverseLinkPhrase   { $_[0]->{rlinkphrase} = $_[1]; }

sub description
{
    my ($self, $new_desc) = @_;

    if (defined $new_desc) { $self->{description} = $new_desc; }
    return $self->{description};
}

sub attributes
{
    my ($self, $new_attributes) = @_;

    if (defined $new_attributes) { $self->{attribute} = $new_attributes; }
    return $self->{attribute};
}

sub GetShortLinkPhrase { $_[0]->{shortlinkphrase} }
sub SetShortLinkPhrase { $_[0]->{shortlinkphrase} = $_[1]; }

sub GetPriority { $_[0]->{priority} }
sub SetPriority { $_[0]->{priority} = $_[1]; }

sub GetChildOrder	{ $_[0]->{childorder} }
sub SetChildOrder	{ $_[0]->{childorder} = $_[1] }

sub PackTypes
{
	my ($self, $types) = @_;
	$types ||= $self->Types;
	join "-", @$types;
}

sub newFromPackedTypes
{
	my ($class, $dbh, $packed) = @_;
	defined($packed) or return undef;
	my @types = split /-/, $packed, -1;
	MusicBrainz::Server::LinkEntity->ValidateTypes(\@types)
		or return undef;
	$class->new($dbh, \@types);
}

################################################################################
# Data Retrieval
################################################################################

sub _new_from_row
{
	my $this = shift;
	my $self = $this->SUPER::_new_from_row(@_)
		or return;

	while (my ($k, $v) = each %$this)
	{
		$self->{$k} = $v
			if substr($k, 0, 1) eq "_";
	}
	$self->{DBH} = $this->GetDBH;

	bless $self, ref($this) || $this;
}

sub newFromId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->GetDBH);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE id = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub newFromMBId
{
	my ($self, $id) = @_;
	my $sql = Sql->new($self->GetDBH);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE mbid = ?",
		$id,
	);
	$self->_new_from_row($row);
}

sub newFromParentId
{
	my ($self, $parentid) = @_;
	my $sql = Sql->new($self->GetDBH);
	my $rows = $sql->SelectListOfHashes(
		"SELECT * FROM $self->{_table} WHERE parent = ? AND id != parent ORDER BY childorder, name",
		$parentid,
	);
	map { $self->_new_from_row($_) } @$rows;
}

sub newFromParentIdAndChildName
{
	my ($self, $parentid, $childname) = @_;
	my $sql = Sql->new($self->GetDBH);
	my $row = $sql->SelectSingleRowHash(
		"SELECT * FROM $self->{_table} WHERE parent = ? AND LOWER(name) = LOWER(?)",
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

################################################################################
# Insert, Delete
################################################################################

# Always call named_child first, to check that it doesn't already exist
sub AddChild
{
	my ($self, $childname, $linkphrase, $rlinkphrase, $description,
		$attribute, $childorder, $shortlinkphrase, $priority) = @_;
	my $sql = Sql->new($self->GetDBH);
	$sql->Do(
		"INSERT INTO $self->{_table} (
			parent, name, linkphrase, rlinkphrase, description, attribute,
			mbid, childorder, shortlinkphrase, priority
		) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
		$self->id,
		$childname,
		$linkphrase,
		$rlinkphrase,
		$description,
		$attribute,
		TableBase::CreateNewGlobalId(),
		$childorder,
		$shortlinkphrase,
		$priority,
	);
	$self->newFromId($sql->GetLastInsertId($self->{_table}));
}

sub InUse 
{ 
	my $self = shift;
	my $sql = Sql->new($self->GetDBH);
	my $table = "l_" . join "_", @{$self->{_types}};

	my $value = $sql->SelectSingleValue(
		"select count(*) from $table where link_type = ?",
		$self->id,
	);
	return $value > 0;
}

sub Delete
{
	my $self = shift;
	my $sql = Sql->new($self->GetDBH);
	# Here we trust that the caller has tested "InUse", and found it to be
	# false.  If not, this statement might fail (FK violation).
	$sql->Do(
		"DELETE FROM $self->{_table} WHERE id = ?",
		$self->id,
	);
}

sub Update
{
	my $self = shift;
	my $sql = Sql->new($self->GetDBH);
	$sql->Do(
		"UPDATE $self->{_table} SET parent = ?, childorder = ?, name = ?,
			linkphrase = ?, rlinkphrase = ?, description = ?,
			attribute = ?, shortlinkphrase = ?, priority = ? WHERE id = ?",
		$self->GetParentId, 
		$self->GetChildOrder, 
		$self->name,
		$self->GetLinkPhrase,
		$self->GetReverseLinkPhrase,
		$self->description,
		$self->attributes,
		$self->GetShortLinkPhrase,
		$self->GetPriority,
		$self->id,
	);
}

################################################################################

#InsertDefaultRows();

1;
# eof LinkType.pm
