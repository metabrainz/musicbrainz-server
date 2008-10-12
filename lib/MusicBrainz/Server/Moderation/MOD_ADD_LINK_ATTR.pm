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

package MusicBrainz::Server::Moderation::MOD_ADD_LINK_ATTR;

use strict;
use warnings;

use base 'Moderation';

use ModDefs qw( :modstatus DARTIST_ID MODBOT_MODERATOR );

sub Name { "Add Relationship Attribute" }
sub moderation_id   { 41 }

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
	my $name = $opts{'name'} or die;
	my $desc = $opts{'description'} or die;
	my $childorder = $opts{'childorder'};

	MusicBrainz::Server::Validation::TrimInPlace($name);
	die if $name eq "";

	if ($parent->named_child($name))
	{
		my $note = "There is already a relationship attribute called '$name' here";
		$self->SetError($note);
		die $self;
	}

	my $child = $parent->AddChild($name, $desc, $childorder);

	$self->artist(DARTIST_ID);
	$self->table($parent->{_table});
	$self->SetColumn("name");
	$self->row_id($child->id);

	my %new = (
		parent	   => $parent->mbid,
		name	   => $child->name,
		gid		   => $child->mbid,
		desc	   => $desc,
		childorder => $childorder,
		parent_name => $parent->name,
	);

	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub DeniedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $link = MusicBrainz::Server::LinkAttr->new(
		$self->{DBH},
	);
	my $child = $link->newFromId($self->row_id);

	if ($child->InUse)
	{
		# TODO what to do here if the attribute is in use?
		$self->InsertNote(MODBOT_MODERATOR, "This attribute cannot be deleted - it is in use");
	} else {
		$child->Delete;
	}
}

1;
# eof MOD_ADD_LINK_ATTR.pm
