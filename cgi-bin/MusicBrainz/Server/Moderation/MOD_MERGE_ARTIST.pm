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

package MusicBrainz::Server::Moderation::MOD_MERGE_ARTIST;

use ModDefs;
use base 'Moderation';

sub Name { "Merge Artists" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $source = $opts{'source'} or die;
	my $target = $opts{'target'} or die;

	die if $source->GetId == &ModDefs::VARTIST_ID;
	die if $source->GetId == &ModDefs::DARTIST_ID;
	die if $target->GetId == &ModDefs::DARTIST_ID;

	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetArtist($source->GetId);
	$self->SetRowId($source->GetId);
	$self->SetPrev($source->GetName);
	$self->SetNew($target->GetSortName . "\n" . $target->GetName);
}

sub PostLoad
{
	my $self = shift;

	# Name can be missing
	@$self{qw( new.sortname new.name )} = split /\n/, $self->GetNew;

	$self->{'new.name'} = $self->{'new.sortname'}
		unless defined $self->{'new.name'}
		and $self->{'new.name'} =~ /\S/;
}

# TODO most of this should be done by Artist.pm
sub ApprovedAction
{
	my $self = shift;
	my $sql = Sql->new($self->{DBH});

	my $prevval = $self->GetPrev;
	my $rowid = $self->GetRowId;
	my $name = $self->{'new.name'};
	#my $sortname = $self->{'new.sortname'};

	# Check to see that the old value is still what we think it is
	my $existname = $sql->SelectSingleValue(
		"SELECT name FROM artist WHERE id = ?",
		$rowid,
	) or return &ModDefs::STATUS_ERROR;

	$existname eq $prevval
		or return &ModDefs::STATUS_FAILEDDEP;

	# Check to see that the new artist is still around 
	my $newid = $sql->SelectSingleValue(
		"SELECT id FROM artist WHERE name = ?",
		$name,
	) or return &ModDefs::STATUS_FAILEDDEP;

	my $oldar = Artist->new($self->{DBH});
	$oldar->SetId($rowid);
	$oldar->LoadFromId or return &ModDefs::STATUS_FAILEDDEP;
	require UserSubscription;
	my $subs = UserSubscription->new($self->{DBH});
	$subs->ArtistBeingMerged($oldar, $self);

	# Do the merge
	$sql->Do("UPDATE artist_relation SET artist = ? WHERE artist = ?", $newid, $rowid);
	$sql->Do("UPDATE artist_relation SET ref	= ? WHERE ref	 = ?", $newid, $rowid);
	$sql->Do("UPDATE album			 SET artist = ? WHERE artist = ?", $newid, $rowid);
	$sql->Do("UPDATE track			 SET artist = ? WHERE artist = ?", $newid, $rowid);
	$sql->Do("UPDATE moderation		 SET artist = ? WHERE artist = ?", $newid, $rowid);
	$sql->Do("UPDATE artistalias	 SET ref	= ? WHERE ref	 = ?", $newid, $rowid);
	$sql->Do("DELETE FROM artist WHERE id = ?", $rowid);

	# Insert the old name as an alias for the new one
	# TODO this is often a bad idea - remove this code?
	my $al = Alias->new($self->{DBH});
	$al->SetTable("ArtistAlias");
   	$al->Insert($newid, $prevval);

	&ModDefs::STATUS_APPLIED;
}

1;
# eof MOD_MERGE_ARTIST.pm
