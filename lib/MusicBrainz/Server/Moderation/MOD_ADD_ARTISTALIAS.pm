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

package MusicBrainz::Server::Moderation::MOD_ADD_ARTISTALIAS;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Add Artist Alias" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'artist'} or die;
	my $newalias = $opts{'newalias'};
	defined $newalias or die;

	# Check that the alias $self->new_data does not exist
	require MusicBrainz::Server::Alias;
	my $al = MusicBrainz::Server::Alias->new($self->GetDBH);
	$al->table("ArtistAlias");

	if (my $other = $al->newFromName($newalias))
	{
		my $url = "http://" . &DBDefs::WEB_SERVER
			. "/showaliases.html?artistid=" . $other->row_id;

		my $note = "There is already an alias called '$newalias'"
			. " (see $url)"
			. " - duplicate aliases are not yet supported";

		$self->SetError($note);
		die $self;
	}

	$self->artist($ar->id);
	$self->previous_data($ar->name);
	$self->new_data($newalias);
	$self->table("artist");
	$self->column("name");
	$self->row_id($ar->id);
}

sub DetermineQuality
{
	my $self = shift;

	my $ar = MusicBrainz::Server::Artist->new($self->GetDBH);
	$ar->id($self->{rowid});
	if ($ar->LoadFromId())
	{
        return $ar->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub CheckPrerequisites
{
	my $self = shift;

	# Check that the referenced artist is still around
	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($self->GetDBH);
	$ar->id($self->row_id);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(
			MODBOT_MODERATOR,
			"This artist has been deleted",
		);
		return STATUS_FAILEDPREREQ;
	}

	# Check that the alias $self->new_data does not exist
	require MusicBrainz::Server::Alias;
	my $al = MusicBrainz::Server::Alias->new($self->GetDBH);
	$al->table("ArtistAlias");

	if (my $other = $al->newFromName($self->new_data))
	{
		my $url = "http://" . &DBDefs::WEB_SERVER
			. "/showaliases.html?artistid=" . $other->row_id;

		my $note = "There is already an alias called '".$self->new_data."'"
			. " (see $url)"
			. " - duplicate aliases are not yet supported";

		$self->InsertNote(MODBOT_MODERATOR, $note);
		return STATUS_FAILEDPREREQ;
	}

	undef;
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	require MusicBrainz::Server::Alias;
	my $al = MusicBrainz::Server::Alias->new($self->GetDBH);
	$al->table("ArtistAlias");

	my $other;
	if ($al->Insert($self->row_id, $self->new_data, \$other))
	{
		return STATUS_APPLIED;
	}

	# Something went wrong - what?
	my $message = "Failed to add new alias";

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
# eof MOD_ADD_ARTISTALIAS.pm
