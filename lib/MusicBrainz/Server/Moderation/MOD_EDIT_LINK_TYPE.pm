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

package MusicBrainz::Server::Moderation::MOD_EDIT_LINK_TYPE;

use ModDefs qw( :modstatus DARTIST_ID MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Relationship Type" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $parent = $opts{'parent'} or die; # a LinkType object 
	my $node = $opts{'node'} or die; # a LinkType object
	my $name = $opts{'name'};
	my $linkphrase = $opts{'linkphrase'};
	my $rlinkphrase = $opts{'rlinkphrase'};
	my $description = $opts{'description'};
	my $attribute = $opts{'attribute'};
	my $childorder = $opts{'childorder'};
	my $shortlinkphrase = $opts{'shortlinkphrase'};
	my $priority = $opts{'priority'};

	defined() or die
		for $linkphrase, $rlinkphrase, $description, $attribute;

	MusicBrainz::Server::Validation::TrimInPlace($name);
	die if $name eq "";
	MusicBrainz::Server::Validation::TrimInPlace($linkphrase);
	die if $linkphrase eq "";
	MusicBrainz::Server::Validation::TrimInPlace($rlinkphrase);
	die if $rlinkphrase eq "";
	MusicBrainz::Server::Validation::TrimInPlace($shortlinkphrase);
	die if $shortlinkphrase eq "";
	MusicBrainz::Server::Validation::TrimInPlace($description);
	MusicBrainz::Server::Validation::TrimInPlace($attribute);

	my $c = $parent->named_child($name);
	if ($c and $c->id != $node->id)
	{
		my $note = "There is already a link type called '$name' here";
		$self->SetError($note);
		die $self;
	}

	$self->artist(DARTIST_ID);
	$self->table($node->{_table}); # FIXME internal field
	$self->column("name");
	$self->row_id($node->id);
	$self->previous_data($node->name);

	my %new = (
		parent				=> $parent->name, 
		types				=> $node->PackTypes,
		name				=> $name,
		childorder			=> $childorder,
		linkphrase			=> $linkphrase,
		rlinkphrase			=> $rlinkphrase,
		shortlinkphrase		=> $shortlinkphrase,
		description			=> $description,
		attribute			=> $attribute,
		priority			=> $priority,
		old_parent			=> $node->Parent->name, 
		old_name			=> $node->name,
		old_childorder		=> $node->GetChildOrder,
		old_linkphrase		=> $node->GetLinkPhrase,
		old_rlinkphrase		=> $node->GetReverseLinkPhrase,
		old_shortlinkphrase	=> $node->GetShortLinkPhrase,
		old_description		=> $node->description,
		old_attribute		=> $node->attributes,
		old_priority		=> $node->GetPriority,
	);

	$node->SetParentId($parent->id); 
	$node->name($name);
	$node->SetLinkPhrase($linkphrase);
	$node->SetReverseLinkPhrase($rlinkphrase);
	$node->SetShortLinkPhrase($shortlinkphrase);
	$node->description($description);
	$node->attributes($attribute);
	$node->SetChildOrder($childorder);
	$node->SetPriority($priority);
	$node->Update;

	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
}

# Since I changed this to by an auto mod type, I think this entire block is useless, right?
sub DeniedAction
{
  	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $link = MusicBrainz::Server::LinkType->newFromPackedTypes(
		$self->{dbh},
		$self->{'new_unpacked'}{'types'},
	);

	my $node = $link->newFromId($self->row_id);
	if (not $node)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This link type has been deleted");
		return;
	}

	my $name = $self->previous_data;
	my $c = $node->Parent->named_child($name);
	if ($c and $c->id != $node->id)
	{
		$self->InsertNote(MODBOT_MODERATOR, "There is already a link type called '$name' here");
		return;
	}

	$node->name($name);
	$node->Update;
}

1;
# eof MOD_EDIT_LINK_TYPE.pm
