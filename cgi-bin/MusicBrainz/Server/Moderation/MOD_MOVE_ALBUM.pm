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

package MusicBrainz::Server::Moderation::MOD_MOVE_ALBUM;

use ModDefs;
use base 'Moderation';

sub Name { "Move Album" }
(__PACKAGE__)->RegisterHandler;

# PLEASE NOTE that MOD_MOVE_ALBUM is almost exactly the same as MOD_MAC_TO_SAC

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $ar = $opts{oldartist} or die;
	my $sortname = $opts{artistsortname} or die;
	my $name = $opts{artistname};

	my $new = $sortname;
	$new .= "\n$name" if defined $name and $name =~ /\S/;

	$self->SetTable("album");
	$self->SetColumn("artist");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($al->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($new);
}

sub PostLoad
{
	my $this = shift;

	# new.name might be undef (in which case, name==sortname)
  	@$this{qw( new.sortname new.name )} = split /\n/, $this->GetNew;
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	# Check album is still where it used to be
	$sql->SelectSingleValue(
		"SELECT 1 FROM album WHERE id = ? AND artist = ?",
		$this->GetRowId,
		$this->GetArtist,
	) or return &ModDefs::STATUS_FAILEDPREREQ;

	# Find the ID of the named artist
	my $name = $this->{'new.name'};
	$name = $this->{'new.sortname'}
		unless defined $name;

	my $newid = $sql->SelectSingleValue(
		"SELECT id FROM artist WHERE name = ?",
		$name,
	);

	if (not defined $newid)
	{
		# No such artist, so create one
		my $ar = Artist->new($this->{DBH});
		$ar->SetName($name);
		$ar->SetSortName($this->{'new.sortname'});
		$newid = $ar->Insert;
	}

	# Move each track on the album

	if ($sql->Select("SELECT track FROM albumjoin WHERE album = ?",
			$this->GetRowId))
	{
	 	while (my @row = $sql->NextRow)
		{
		 	$sql->Do(
				"UPDATE track SET artist = ? WHERE id = ?",
				$newid,
				$row[0],
			);
		}

		$sql->Finish;
	}

	# Move the album itself

	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ?",
		$newid,
		$this->GetRowId,
	);

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_MOVE_ALBUM.pm
