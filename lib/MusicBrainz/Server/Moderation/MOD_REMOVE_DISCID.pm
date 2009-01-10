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

package MusicBrainz::Server::Moderation::MOD_REMOVE_DISCID;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Disc ID" }
(__PACKAGE__)->RegisterHandler;

=pod

Old method ("discid" and "toc" tables):

	table="discid"
	column="disc"
	rowid=discid.id
	prev=discid string
	new=""

New method ("cdtoc" and "album_cdtoc" tables):

	table="album_cdtoc"
	column="album"
	rowid=album_cdtoc.id (which is backwards-compatible with discid.id)
	prev=discid string
	new=AlbumName		= album.name
		AlbumId			= album.id
		FullTOC			= cdtoc string
		CDTOCId			= cdtoc.id

=cut

sub PreInsert
{
	my ($self, %opts) = @_;

	my $cdtoc = $opts{'cdtoc'} or die;
	my $oldrelease = $opts{album} or die;

	require MusicBrainz::Server::ReleaseCDTOC;
	my $alcdtoc = MusicBrainz::Server::ReleaseCDTOC->newFromReleaseAndCDTOC($self->{DBH}, $oldrelease, $cdtoc->id);
	if (not $alcdtoc)
	{
		$self->SetError("Old album / CD TOC not found");
		die $self;
	}

	$self->table("album_cdtoc");
	$self->column("album");
	$self->row_id($alcdtoc->id);
	$self->artist($oldrelease->artist);
	$self->previous_data($cdtoc->disc_id);

	my %new = (
		AlbumName => $oldrelease->name,
		AlbumId => $oldrelease->id,
		FullTOC => $cdtoc->toc,
		CDTOCId => $cdtoc->id,
	);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	# The "new" column has three versions:
	# 1. the word "DELETE"
	# 2. blank
	# 3. a hash of AlbumName,AlbumId,FullTOC,CDTOCId.
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		|| {};
		
	# verify if release still exists in Moderation.ShowModType method.
	my $new = $self->{'new_unpacked'};
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($new->{"AlbumId"}, 1);			
	($self->{"albumname"}) = ($new->{"AlbumName"});			
}

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	$rel->id($self->{albumid});
	if ($rel->LoadFromId())
	{
        return $rel->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

# This implementation is required (instead of the default) because old rows
# will have a "table" value of "discid" instead of "album_cdtoc"

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	my $sql = Sql->new($self->dbh);
	$sql->Do(
		"UPDATE album_cdtoc SET modpending = modpending + ? WHERE id = ?",
		$adjust,
		$self->row_id,
	);
}

sub ApprovedAction
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
# eof MOD_REMOVE_DISCID.pm
