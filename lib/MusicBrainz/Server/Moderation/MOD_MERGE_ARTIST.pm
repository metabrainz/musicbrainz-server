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

	die if $source->id == VARTIST_ID;
	die if $source->id == DARTIST_ID;
	die if $target->id == DARTIST_ID;

	if ($source->id == $target->id)
	{
		$self->SetError("Source and destination artists are the same!");
		die $self;
	}

	my %new;
	$new{"ArtistName"} = $target->name;
	$new{"ArtistId"} = $target->id;

	$self->table("artist");
	$self->column("name");
	$self->artist($source->id);
	$self->row_id($source->id);
	$self->previous_data($source->name);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PreDisplay
{
    my $self = shift;

    # Possible formats of "new":
    # "$sortname"
    # "$sortname\n$name"
    # or hash structure (containing at least two \n characters).

    my $unpacked = $self->ConvertNewToHash($self->new_data);

    if (!$unpacked)
    {
        # Name can be missing
        @$self{qw( new.sortname new.name )} = split /\n/, $self->new_data;

        $self->{'new.name'} = $self->{'new.sortname'}
            unless defined $self->{'new.name'}
                       and $self->{'new.name'} =~ /\S/;
    }
    else
    {
        my $artist = new MusicBrainz::Server::Artist($self->{DBH});
        $artist->id($unpacked->{"ArtistId"});
        $artist->LoadFromId;

        $self->new_data($artist);
    }
}

sub DetermineQuality
{
	my $self = shift;

    my $quality = -2;
	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
	$ar->id($self->{"new.id"});
	if ($ar->LoadFromId())
	{
        $quality = $ar->quality;        
    }
	$ar->id($self->{rowid});
	if ($ar->LoadFromId())
	{
        $quality = $quality > $ar->quality ? $quality : $ar->quality;
    }

    if ($quality == -2)
    {
        $quality = &ModDefs::QUALITY_NORMAL;
    }
    return $quality;
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($self->dbh);

	for my $artistid ($self->row_id, $self->{"new.id"})
	{
		defined($artistid) or next;
		$ar->id($artistid);
		$ar->LoadFromId();
		$ar->UpdateModPending($adjust);
	}
}

sub CheckPrerequisites
{
	my $self = shift;

	my $prevval = $self->previous_data;
	my $rowid = $self->row_id;
	my $name = $self->{'new.name'};
	#my $sortname = $self->{'new.sortname'};

	require MusicBrainz::Server::Artist;
	my $newar = MusicBrainz::Server::Artist->new($self->dbh);

	if (my $newid = $self->{"new.id"})
	{
		$newar->id($newid);
		unless ($newar->LoadFromId)
		{
			$self->InsertNote(MODBOT_MODERATOR, "The target artist has been deleted");
			return STATUS_FAILEDDEP;
		}
	} else {
		# Load new artist by name
		my $artists = $newar->select_artists_by_name($name);
		if (scalar(@$artists) == 0)
		{
			$self->InsertNote(MODBOT_MODERATOR, "Artist '$name' not found - it has been deleted or renamed");
			return STATUS_FAILEDDEP;
		}
		$newar = $$artists[0];
	}

	# Load old artist by ID
	require MusicBrainz::Server::Artist;
	my $oldar = MusicBrainz::Server::Artist->new($self->dbh);
	$oldar->id($rowid);
	unless ($oldar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	# Check to see that the old value is still what we think it is
	unless ($oldar->name eq $prevval)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# You can't merge an artist into itself!
	if ($oldar->id == $newar->id)
	{
		$self->InsertNote(MODBOT_MODERATOR, "Source and destination artists are the same!");
		return STATUS_ERROR;
	}

	# Disallow various merges involving the "special" artists
	if ($oldar->id == VARTIST_ID or $oldar->id == DARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't merge that artist!");
		return STATUS_ERROR;
	}
	
	if ($newar->id == DARTIST_ID)
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
