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

package MusicBrainz::Server::Moderation::MOD_SAC_TO_MAC;

use ModDefs;
use base 'Moderation';

sub Name { "Convert Album to Multiple Artists" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $ar = $opts{artist} or die;

	$self->SetTable("album");
	$self->SetColumn("artist");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($al->GetId);
	$self->SetPrev($ar->GetName);
}

sub ApprovedAction
{
 	my $self = shift;
	my $sql = Sql->new($self->{DBH});

 	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ? AND artist = ?",
		&ModDefs::VARTIST_ID,
		$self->GetRowId,
		$self->GetArtist,
	) or return &ModDefs::STATUS_FAILEDPREREQ;

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_SAC_TO_MAC.pm
