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
	$newname =~ /\S/ or die;

	$self->SetArtist($al->GetRowId);
	$self->SetPrev($al->GetName);
	$self->SetNew($newname);
	$self->SetTable("artistalias");
	$self->SetColumn("name");
	$self->SetRowId($al->GetId);

	# Currently there's a unique index on artistalias.name.
	# Refuse to insert the mod if that index would be violated.
	require Alias;
	my $test = Alias->new($self->{DBH}, 'artistalias');

	if (my $id = $test->Resolve($newname))
	{
		if ($id != $al->GetId)
		{
			$self->SetError(
				"There is already an alias called '$newname'"
				. " - duplicate aliases are not allowed (yet)"
			);
			die $self;
		}
	}
}

sub IsAutoMod
{
	my $self = shift;
	my ($old, $new) = $self->_normalise_strings($self->GetPrev, $self->GetNew);
	$old eq $new;
}

sub CheckPrerequisites
{
	my $self = shift;

	require Alias;
	my $alias = Alias->new($self->{DBH}, "artistalias");
	$alias->SetId($self->GetRowId);

	unless ($alias->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This alias has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($alias->GetName eq $self->GetPrev)
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

	# There's currently a unique index on artistalias.name
	# Try to detect likely violations of that index, and gracefully
	# add a note to offending moderations.

	require Alias;
	my $test = Alias->new($self->{DBH}, 'artistalias');
	my $newname = $self->GetNew;

	if (my $id = $test->Resolve($newname))
	{
		if ($id != $self->GetRowId)
		{
			my $url = "http://" . &DBDefs::WEB_SERVER
				. "/showaliases.html?artistid=" . $id;

		 	$self->InsertNote(
				MODBOT_MODERATOR,
				"There is already an alias called '$newname' (see $url)"
				. " - duplicate aliases are not allowed (yet)"
			);

			return STATUS_ERROR;
		}
	}

	$alias->SetName($self->GetNew);
	$alias->UpdateName;

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_ARTISTALIAS.pm
