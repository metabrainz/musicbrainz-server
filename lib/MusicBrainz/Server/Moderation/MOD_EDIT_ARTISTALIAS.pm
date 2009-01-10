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

package MusicBrainz::Server::Moderation::MOD_EDIT_ARTISTALIAS;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Artist Alias" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'alias'} or die;
	my $newname = $opts{'newname'};
	my $artist = $opts{'artist'} or die;
	$newname =~ /\S/ or die;

	$self->artist($artist);
	$self->previous_data($al->name);
	$self->new_data($newname);
	$self->table("artistalias");
	$self->column("name");
	$self->row_id($al->id);

	# Currently there's a unique index on artistalias.name.
	# Refuse to insert the mod if that index would be violated.
	require MusicBrainz::Server::Alias;
	my $test = MusicBrainz::Server::Alias->new($self->GetDBH, 'artistalias');

	if (my $other = $test->newFromName($newname))
	{
		if ($other->id != $al->id)
		{
			$self->SetError(
				"There is already an alias called '$newname'"
				. " - duplicate aliases are not yet supported"
			);
			die $self;
		}
	}
}

sub DetermineQuality
{
	my $self = shift;

	my $ar = $self->artist;
	if ($ar->LoadFromId())
	{
        return $ar->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub IsAutoEdit
{
	my $self = shift;
	my ($old, $new) = $self->_normalise_strings($self->previous_data, $self->new_data);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	require MusicBrainz::Server::Alias;
	my $alias = MusicBrainz::Server::Alias->new($self->GetDBH, "artistalias");
	$alias->id($self->row_id);

	unless ($alias->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This alias has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($alias->name eq $self->previous_data)
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

	$alias->name($self->new_data);
	my $other;
	if ($alias->UpdateName(\$other))
	{
		return STATUS_APPLIED;
	}

	# Something went wrong - what?
	my $message = "Failed to update alias name";

	# So far this is the only gracefully handled error
	if ($!{EEXIST})
	{
		my $url = "http://" . &DBDefs::WEB_SERVER
			. "/showaliases.html?artistid=" . $other->row_id;
		my $newname = $self->new_data;
		$message = "There is already an alias called '$newname' (see $url)"
			. " - duplicate aliases are not yet supported";
	}

	$self->InsertNote(MODBOT_MODERATOR, $message);
	return STATUS_ERROR;
}

1;
# eof MOD_EDIT_ARTISTALIAS.pm
