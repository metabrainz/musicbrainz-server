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

	if ($al->GetArtist == VARTIST_ID)
	{
		$self->SetError("This is already a 'Various Artists' release");
		die $self;
	}

	$self->SetTable("album");
	$self->SetColumn("artist");
	$self->SetArtist($al->GetArtist);
	$self->SetRowId($al->GetId);
	$self->SetPrev($ar->GetName);
	$self->SetNew($movetova);
}

sub CheckPrerequisites
{
	my $self = shift;

	my $rowid = $self->GetRowId;

	# Load the album by ID
	require Album;
	my $al = Album->new($self->{DBH});
	$al->SetId($rowid);
	unless ($al->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This album has been deleted");
		return STATUS_FAILEDDEP;
	}

	# Check that its artist has not changed
	if ($al->GetArtist == VARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This album has already been converted to multiple artists");
		return STATUS_FAILEDPREREQ;
	}
	if ($al->GetArtist != $self->GetArtist)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This album is no longer associated with this artist");
		return STATUS_FAILEDDEP;
	}

	undef;
}

sub PreDisplay
{
	my $this = shift;
	
	# store the current VA artist id
	$this->{'vaid'} = VARTIST_ID;

	# check if album still exists and get its name
	require Album;
	my $al = Album->new($this->{DBH});
	$al->SetId($this->GetRowId);
	$this->{'albumname'} = $al->GetName
		if ($al->LoadFromId);
}

sub ApprovedAction
{
 	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $sql = Sql->new($self->{DBH});
 	$sql->Do(
		"UPDATE album SET artist = ? WHERE id = ? AND artist = ?",
		&ModDefs::VARTIST_ID,
		$self->GetRowId,
		$self->GetArtist,
	) or die "Failed to update album in MOD_SAC_TO_MAC";

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_SAC_TO_MAC.pm
