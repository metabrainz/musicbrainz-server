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

package MusicBrainz::Server::Moderation::MOD_CHANGE_TRACK_ARTIST;

use ModDefs;
use base 'Moderation';

sub Name { "Change Track Artist" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $ar = $opts{'oldartist'} or die;
	my $name = $opts{'artistname'} or die;
	my $sortname = $opts{'artistsortname'} or die;

	$self->SetTable("track");
	$self->SetColumn("artist");
	$self->SetRowId($tr->GetId);
	$self->SetArtist($ar->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($sortname . "\n" . $name);
	# TODO depmod?
}

sub PostLoad
{
	my $this = shift;
	
	my ($sortname, $name) = split /\n/, $this->GetNew;
	$name = $sortname if not defined $name;

	@$this{qw( new.sortname new.name )} = ($sortname, $name);
}

sub ApprovedAction
{
 	my ($this, $id) = @_;

	my ($sortname, $name) = @$this{qw( new.sortname new.name )};

	# If there's an artist with this name, use them.

	my $sql = Sql->new($this->{DBH});
	my $artistid = $sql->SelectSingleValue(
		"SELECT id FROM artist WHERE name = ?",
		$name,
	);

	# No artist with that name - add one.

	if (not $artistid)
	{
	  	my $ar = Artist->new($this->{DBH});
	   	$ar->SetName($name);
		$ar->SetSortName($sortname);
		$artistid = $ar->Insert;
	}

	$sql->Do(
		"UPDATE track SET artist = ? WHERE id = ?",
		$artistid,
		$this->GetRowId,
	);

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_TRACK_ARTIST.pm
