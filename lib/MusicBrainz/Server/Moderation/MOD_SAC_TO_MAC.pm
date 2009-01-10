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

use ModDefs qw( :artistid :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Convert Release to Multiple Artists" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{album} or die;
	my $ar = $opts{artist} or die;
	my $movetova = $opts{movetova} or die;

	if ($al->artist == VARTIST_ID)
	{
		$self->SetError("This is already a 'Various Artists' release");
		die $self;
	}

	$self->table("album");
	$self->column("artist");
	$self->artist($al->artist);
	$self->row_id($al->id);
	$self->previous_data($ar->name);
	$self->new_data($movetova);
}

sub PostLoad
{
	my $self = shift;

	# attempt to load the release entitiy from the value
	# stored in this edit type. (@see Moderation::ShowModType)
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->row_id, 1);
}

sub DetermineQuality
{
	my $self = shift;

	my $level = &ModDefs::QUALITY_UNKNOWN_MAPPED;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	$rel->id($self->{rowid});
	if ($rel->LoadFromId())
	{
		$level = $rel->quality > $level ? $rel->quality : $level;
    }

	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
	$ar->id($rel->artist);
	if ($ar->LoadFromId())
	{
        $level = $ar->quality > $level ? $ar->quality : $level;
    }

    return $level;
}

sub CheckPrerequisites
{
	my $self = shift;

	# Load the album by ID
	require MusicBrainz::Server::Release;
	my $release = MusicBrainz::Server::Release->new($self->dbh);
	$release->id($self->row_id);
	unless ($release->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($release->artist == VARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release has already been converted to multiple artists");
		return STATUS_FAILEDPREREQ;
	}
	if ($release->artist != $self->artist)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This release is no longer associated with this artist");
		return STATUS_FAILEDDEP;
	}

	undef;
}

sub PreDisplay
{
	my $this = shift;
	
	# store the current VA artist id
	$this->{'vaid'} = VARTIST_ID;
}

sub ApprovedAction
{
 	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $sql = Sql->new($self->dbh);
 	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ? AND artist = ?",
		&ModDefs::VARTIST_ID,
		$self->row_id,
		$self->artist,
	) or die "Failed to update album in MOD_SAC_TO_MAC";

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_SAC_TO_MAC.pm
