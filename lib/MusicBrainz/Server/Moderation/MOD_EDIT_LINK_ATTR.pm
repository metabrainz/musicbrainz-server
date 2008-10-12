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

package MusicBrainz::Server::Moderation::MOD_EDIT_LINK_ATTR;

use ModDefs qw( :modstatus DARTIST_ID MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Relationship Attribute" }
sub moderation_id   { 42 }

sub edit_conditions
{
    return {
        ModDefs::QUALITY_LOW => {
            duration     => 4,
            votes        => 1,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },  
        ModDefs::QUALITY_NORMAL => {
            duration     => 14,
            votes        => 3,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 1,
            name         => $_[0]->Name,
        },
        ModDefs::QUALITY_HIGH => {
            duration     => 14,
            votes        => 4,
            expireaction => ModDefs::EXPIRE_REJECT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },
    }
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $parent = $opts{'parent'} or die; # a LinkAttr object
	my $node = $opts{'node'} or die; # a LinkAttr object
	my $name = $opts{'name'};
	my $desc = $opts{'description'};
	my $childorder = $opts{'childorder'};

	MusicBrainz::Server::Validation::TrimInPlace($name);
	die if $name eq "";

	my $c = $parent->named_child($name);
	if ($c and $c->id != $node->id)
	{
		my $note = "There is already an attribute called '$name' here";
		$self->SetError($note);
		die $self;
	}

	$self->artist(DARTIST_ID);
	$self->table($node->{_table});
	$self->SetColumn("name");
	$self->row_id($node->id);
	my $prev = $node->name . " (" . $node->description . ")";
    $prev = substr($prev, 0, 251) . " ..." if (length($prev) > 255);
	$self->SetPrev($prev);

	my %new = (
		name        	=> $name,
		desc        	=> $desc,
		old_parent		=> $parent->Parent->name,
		parent			=> $parent->name,
		childorder		=> $childorder,
		old_childorder	=> $node->GetChildOrder,
	);

	$node->SetParentId($parent->id);
	$node->name($name);
	$node->description($desc);
	$node->SetChildOrder($childorder);
	$node->Update;

	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

# Since I changed this to by an auto mod type, I think this entire block is useless, right?
sub DeniedAction
{
  	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $link = MusicBrainz::Server::LinkType->new(
		$self->{DBH},
	);

	my $node = $link->newFromId($self->row_id);
	if (not $node)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This link attribute has been deleted");
		return;
	}

	my $name = $self->GetPrev;
	my $c = $node->Parent->named_child($name);
	if ($c and $c->id != $node->id)
	{
		$self->InsertNote(MODBOT_MODERATOR, "There is already a link attribute called '$name' here");
		return;
	}

	$node->name($name);
	$node->Update;
}

1;
# eof MOD_EDIT_LINK_ATTR.pm
