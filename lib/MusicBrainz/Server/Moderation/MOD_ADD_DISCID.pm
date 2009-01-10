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

package MusicBrainz::Server::Moderation::MOD_ADD_DISCID;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Add Disc ID" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'album'} or die; # object
	my $toc = $opts{'toc'} or die; # string

	require MusicBrainz::Server::ReleaseCDTOC;

	my $added;
	my $tocid;
	my $rowid = MusicBrainz::Server::ReleaseCDTOC->Insert(
		$self->{DBH}, $al, $toc,
		added => \$added,
		tocid => \$tocid,
	);

	if (not $added)
	{
		$self->SuppressInsert;
		return;
	}

	$self->table("album_cdtoc");
	$self->column("album");
	$self->row_id($rowid);
	$self->artist($al->artist);

	my %new = (
		AlbumName		=> $al->name,
		AlbumId			=> $al->id,
		FullTOC			=> $toc,
		CDTOCId			=> $tocid,
	);

	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;

	# extract trackid, albumid from new_unpacked hash
	my $new = $self->{'new_unpacked'};

	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{'AlbumId'}, 1);
}

sub IsAutoEdit 
{ 
    1 
}

# This implementation is required (instead of the default) because old rows
# will have a "table" value of "discid" instead of "album_cdtoc"

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	my $sql = Sql->new($self->GetDBH);
	$sql->Do(
		"UPDATE album_cdtoc SET modpending = modpending + ? WHERE id = ?",
		$adjust,
		$self->row_id,
	);
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;

	require MusicBrainz::Server::ReleaseCDTOC;

	my $alcdtoc = MusicBrainz::Server::ReleaseCDTOC->newFromId($self->{DBH}, $self->row_id);
	if (not $alcdtoc)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This disc ID has already been removed");
		return STATUS_APPLIED;
	}

	$alcdtoc->Remove;
	STATUS_APPLIED;
}

1;
# eof MOD_ADD_DISCID.pm
