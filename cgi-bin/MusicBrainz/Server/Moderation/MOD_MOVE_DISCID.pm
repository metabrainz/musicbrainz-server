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

package MusicBrainz::Server::Moderation::MOD_MOVE_DISCID;

use ModDefs;
use base 'Moderation';

sub Name { "Move Disc ID" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $oldal = $opts{'oldalbum'} or die;
	my $newal = $opts{'newalbum'} or die;
	my $discid = $opts{'discid'} or die;
	my $rowid = $opts{'rowid'} or die;

	$self->SetTable("discid");
	$self->SetColumn("disc");
	$self->SetRowId($rowid);
	$self->SetArtist($oldal->GetArtist);
	$self->SetPrev($oldal->GetId);

	my %new = (
		OldAlbumName	=> $oldal->GetName,
		NewAlbumId		=> $newal->GetId,
		NewAlbumName	=> $newal->GetName,
		DiscId			=> $discid,
	);

	$self->SetNew($self->ConvertHashToNew(\%new));

	# This is one of those mods where we give the user instant gratification,
	# then undo the mod later if it's rejected.
 	my $sql = Sql->new($self->{DBH});

	$sql->Do(
		"UPDATE discid SET album = ? WHERE disc = ?",
		$newal->GetId,
		$discid,
	);

	$sql->Do(
		"UPDATE toc SET album = ? WHERE discid = ?",
		$newal->GetId,
		$discid,
	);
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});
	my $new = $self->{'new_unpacked'};
	
	$sql->Do(
		"UPDATE discid SET album = ? WHERE disc = ?",
		$self->GetPrev,
		$new->{'DiscId'},
	);

	$sql->Do(
		"UPDATE toc SET album = ? WHERE discid = ?",
		$self->GetPrev,
		$new->{'DiscId'},
	);
}

1;
# eof MOD_MOVE_DISCID.pm
