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

	# Check that the alias $self->GetNew does not exist
	my $al = Alias->new($self->{DBH});
	$al->SetTable("ArtistAlias");

	if (my $artist = $al->Resolve($newalias))
	{
		my $url = "http://" . &DBDefs::WEB_SERVER
			. "/showaliases.html?artistid=" . $artist;

		my $note = "There is already an alias called '$newalias'"
			. " (see $url)";
		$note .= " - duplicate aliases are not allowed (yet)"
			unless $artist == $ar->GetId;

		$self->SetError($note);
		die $self;
	}

	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($newalias);
	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetRowId($ar->GetId);
}

sub CheckPrerequisites
{
	my $self = shift;

	# Check that the referenced artist is still around
	my $ar = Artist->new($self->{DBH});
	$ar->SetId($self->GetRowId);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(
			MODBOT_MODERATOR,
			"This artist has been deleted",
		);
		return STATUS_FAILEDPREREQ;
	}

	# Check that the alias $self->GetNew does not exist
	my $al = Alias->new($self->{DBH});
	$al->SetTable("ArtistAlias");

	if (my $artist = $al->Resolve($self->GetNew))
	{
		my $url = "http://" . &DBDefs::WEB_SERVER
			. "/showaliases.html?artistid=" . $artist;

		my $note = "There is already an alias called '".$self->GetNew."'"
			. " (see $url)";
		$note .= " - duplicate aliases are not allowed (yet)"
			unless $artist == $self->GetRowId;

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

	my $al = Alias->new($self->{DBH});
	$al->SetTable("ArtistAlias");
	$al->Insert($self->GetRowId, $self->GetNew);

	STATUS_APPLIED;
}

1;
# eof MOD_ADD_ARTISTALIAS.pm
