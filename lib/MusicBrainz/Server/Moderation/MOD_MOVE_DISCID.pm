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

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Move Disc ID" }
(__PACKAGE__)->RegisterHandler;

=pod

Old method ("discid" and "toc" tables):

	table="discid"
	column="disc"
	rowid=discid.id
	prev=oldalbum.id
	new=OldAlbumName	= oldalbum.name
		NewAlbumId		= newalbum.id
		NewAlbumName	= newalbum.name
		DiscId			= discid string

New method ("cdtoc" and "album_cdtoc" tables):

	table="album_cdtoc"
	column="album"
	rowid=album_cdtoc.id (which is backwards-compatible with discid.id)
	prev=oldalbum.id
	new=OldAlbumName	= oldalbum.name
		NewAlbumId		= newalbum.id
		NewAlbumName	= newalbum.name
		DiscId			= discid string
		FullTOC			= cdtoc string
		CDTOCId			= cdtoc.id
		AlreadyThere	= 1 if the CDTOC was already on new release (so the old record was just deleted)
						  0 otherwise (the old record was moved to the new release)

=cut

sub PreInsert
{
	my ($self, %opts) = @_;

	my $cdtoc = $opts{'cdtoc'} or die;
	my $oldal = $opts{'oldalbum'} or die;
	my $newal = $opts{'newalbum'} or die;

	if ($oldal->id == $newal->id)
	{
		$self->SetError("Source and destination releases are the same!");
		die $self;
	}

	if ($newal->IsNonAlbumTracks)
	{
		$self->SetError("Disc IDs cannot be moved to '".&MusicBrainz::Server::Release::NONALBUMTRACKS_NAME."'");
		die $self;
	}

	require MusicBrainz::Server::ReleaseCDTOC;
	my $alcdtoc = MusicBrainz::Server::ReleaseCDTOC->newFromReleaseAndCDTOC($self->{DBH}, $oldal, $cdtoc->id);
	if (not $alcdtoc)
	{
		$self->SetError("Old release / CD TOC not found");
		die $self;
	}

	# This is one of those mods where we give the user instant gratification,
	# then undo the mod later if it's rejected.
	my $already_there;
	$alcdtoc->MoveToRelease($newal, \$already_there);

	$self->table("album_cdtoc");
	$self->column("album");
	$self->row_id($alcdtoc->id);
	$self->artist($oldal->artist);
	$self->previous_data($oldal->id);

	my %new = (
		OldAlbumName	=> $oldal->name,
		NewAlbumId		=> $newal->id,
		NewAlbumName	=> $newal->name,
		DiscId			=> $cdtoc->disc_id,
		FullTOC			=> $cdtoc->toc,
		CDTOCId			=> $cdtoc->id,
		AlreadyThere	=> $already_there ? 1 : 0,
	);

	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
		
	# verify if release still exists in Moderation.ShowModType method.
	my $new = $self->{'new_unpacked'};
	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->previous_data, 1);			
	($self->{"albumname"}) = ($new->{"OldAlbumName"});			
}

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	my $new = $self->{'new_unpacked'};
	$rel->id($new->{NewAlbumId});
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
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	# Check that the album_cdtoc row still exists
	require MusicBrainz::Server::ReleaseCDTOC;
	my $album_cdtoc = MusicBrainz::Server::ReleaseCDTOC->newFromId($self->{DBH}, $self->row_id)
		or do {
			$self->InsertNote(MODBOT_MODERATOR, "This disc ID has been deleted");
			$self->status(STATUS_FAILEDDEP);
			return;
		};

	# Check that the old album still exists
	# (the mod is applied, we need to revert it when it is voted down)
	require MusicBrainz::Server::Release;
	my $oldal = MusicBrainz::Server::Release->new($self->dbh);
	$oldal->id($self->previous_data);
	unless ($oldal->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "The source release has been deleted");
		$self->status(STATUS_FAILEDDEP);
		return;
	}

	# Check that the new album still exists
	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($self->dbh);
	$al->id($new->{NewAlbumId});
	unless ($al->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "The destination release has been deleted");
		$self->status(STATUS_FAILEDDEP);
		return;
	}

	if ($new->{"AlreadyThere"})
	{
		# Create a new association between the old album and FullTOC
		MusicBrainz::Server::ReleaseCDTOC->Insert($self->{DBH}, $self->previous_data, $new->{"FullTOC"});
	} else {
		# Move the row back to the old album
		my $alcdtoc = MusicBrainz::Server::ReleaseCDTOC->newFromId($self->{DBH}, $self->row_id)
			or return;
		$alcdtoc->MoveToRelease($self->previous_data);
	}
}

1;
# eof MOD_MOVE_DISCID.pm
