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

package MusicBrainz::Server::Moderation::MOD_EDIT_LABELALIAS;

use strict;
use warnings;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Label Alias" }
sub id   { 61 }

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
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },
    }
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'alias'} or die;
	my $newname = $opts{'newname'};
	$newname =~ /\S/ or die;

	$self->SetPrev($al->name);
	$self->SetNew($newname);
	$self->table("labelalias");
	$self->SetColumn("name");
	$self->row_id($al->id);
}

sub IsAutoEdit
{
	my $self = shift;
	my ($old, $new) = $self->_normalise_strings($self->GetPrev, $self->GetNew);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	require MusicBrainz::Server::Alias;
	my $alias = MusicBrainz::Server::Alias->new($self->{DBH}, "labelalias");
	$alias->id($self->row_id);

	unless ($alias->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This alias has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($alias->name eq $self->GetPrev)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This alias has already been changed");
		return STATUS_FAILEDDEP;
	}

	# Save for ApprovedAction
	$self->{_alias} = $alias;

	undef;
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $alias = $self->{_alias}
		or die;

	$alias->name($self->GetNew);
	my $other;
	if ($alias->UpdateName(\$other))
	{
		return STATUS_APPLIED;
	}

	# Something went wrong - what?
	my $message = "Failed to update alias name";

	$self->InsertNote(MODBOT_MODERATOR, $message);
	return STATUS_ERROR;
}

1;
# eof MOD_EDIT_ARTISTALIAS.pm
