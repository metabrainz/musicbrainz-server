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

use ModDefs qw( :artistid :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Merge Artists" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $source = $opts{'source'} or die;
	my $target = $opts{'target'} or die;

	die if $source->GetId == VARTIST_ID;
	die if $source->GetId == DARTIST_ID;
	die if $target->GetId == DARTIST_ID;

	if ($source->GetId == $target->GetId)
	{
		$self->SetError("Source and destination artists are the same!");
		die $self;
	}

	my %new;
	$new{"ArtistName"} = $target->GetName;
	$new{"ArtistId"} = $target->GetId;

	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetArtist($source->GetId);
	$self->SetRowId($source->GetId);
	$self->SetPrev($source->GetName);
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;

	# Possible formats of "new":
	# "$sortname"
	# "$sortname\n$name"
	# or hash structure (containing at least two \n characters).

	my $unpacked = $self->ConvertNewToHash($self->GetNew);

	unless ($unpacked)
	{
		# Name can be missing
		@$self{qw( new.sortname new.name )} = split /\n/, $self->GetNew;

		$self->{'new.name'} = $self->{'new.sortname'}
			unless defined $self->{'new.name'}
			and $self->{'new.name'} =~ /\S/;
	} else {
		$self->{"new.name"} = $unpacked->{"ArtistName"};
		$self->{"new.id"} = $unpacked->{"ArtistId"};
	}
}

sub DetermineQuality
{
	my $self = shift;

    my $quality = -1;
	my $ar = Artist->new($self->{DBH});
	$ar->SetId($self->{"new.id"});
	if ($ar->LoadFromId())
	{
        $quality = $ar->GetQuality();        
    }
	$ar->SetId($self->{rowid});
	if ($ar->LoadFromId())
	{
        $quality = $quality > $ar->GetQuality() ? $quality : $ar->GetQuality;        
    }

    if ($quality < 0)
    {
        $quality = &ModDefs::QUALITY_NORMAL;
        print STDERR __PACKAGE__ . ": quality not determined for $self->{id}\n";
    }
    return $quality;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require Artist;
	my $ar = Artist->new($self->{DBH});

	for my $artistid ($self->GetRowId, $self->{"new.id"})
	{
		defined($artistid) or next;
		$ar->SetId($artistid);
		$ar->UpdateModPending($adjust);
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	my $prevval = $self->GetPrev;
	my $rowid = $self->GetRowId;
	my $name = $self->{'new.name'};
	#my $sortname = $self->{'new.sortname'};

	require Artist;
	my $newar = Artist->new($self->{DBH});

	if (my $newid = $self->{"new.id"})
	{
		$newar->SetId($newid);
		unless ($newar->LoadFromId)
		{
			$self->InsertNote(MODBOT_MODERATOR, "The target artist has been deleted");
			return STATUS_FAILEDDEP;
		}
	} else {
		# Load new artist by name
		my $artists = $newar->GetArtistsFromName($name);
		if (scalar(@$artists) == 0)
		{
			$self->InsertNote(MODBOT_MODERATOR, "Artist '$name' not found - it has been deleted or renamed");
			return STATUS_FAILEDDEP;
		}
		$newar = $$artists[0];
	}

	# Load old artist by ID
	require Artist;
	my $oldar = Artist->new($self->{DBH});
	$oldar->SetId($rowid);
	unless ($oldar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	# Check to see that the old value is still what we think it is
	unless ($oldar->GetName eq $prevval)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# You can't merge an artist into itself!
	if ($oldar->GetId == $newar->GetId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "Source and destination artists are the same!");
		return STATUS_ERROR;
	}

	# Disallow various merges involving the "special" artists
	if ($oldar->GetId == VARTIST_ID or $oldar->GetId == DARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't merge that artist!");
		return STATUS_ERROR;
	}
	
	if ($newar->GetId == DARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't merge into that artist!");
		return STATUS_ERROR;
	}

	# Save these for ApprovedAction
	$self->{_oldar} = $oldar;
	$self->{_newar} = $newar;

	undef;
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $oldar = $self->{_oldar};
	my $newar = $self->{_newar};
	$oldar->MergeInto($newar, $self);

	STATUS_APPLIED;
}

1;
# eof MOD_MERGE_ARTIST.pm
