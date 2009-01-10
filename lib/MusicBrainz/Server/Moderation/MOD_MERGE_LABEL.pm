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

package MusicBrainz::Server::Moderation::MOD_MERGE_LABEL;

use ModDefs qw( :labelid :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Merge Labels" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $source = $opts{'source'} or die;
	my $target = $opts{'target'} or die;

	die if $source->id == DLABEL_ID;
	die if $target->id == DLABEL_ID;

	if ($source->id == $target->id)
	{
		$self->SetError("Source and destination labels are the same!");
		die $self;
	}

	my %new;
	$new{"LabelName"} = $target->name;
	$new{"LabelId"} = $target->id;

	$self->table("label");
	$self->column("name");
	$self->row_id($source->id);
	$self->previous_data($source->name);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PreDisplay
{
    my $self = shift;

    $self->{'dont-display-artist'} = 1;
    $self->{'labelid'} = $self->row_id;

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
        my $label = new MusicBrainz::Server::Label($self->{dbh});
        $label->id($unpacked->{"LabelId"});
        $label->LoadFromId;

        $self->new_data($label);
    }
}

sub AdjustModPending
{
	my ($self, $adjust) = @_;
	require MusicBrainz::Server::Label;
	my $ar = MusicBrainz::Server::Label->new($self->dbh);

	for my $labelid ($self->row_id, $self->{"new.id"})
	{
		defined($labelid) or next;
		$ar->id($labelid);
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

	require MusicBrainz::Server::Label;
	my $newar = MusicBrainz::Server::Label->new($self->dbh);

	if (my $newid = $self->{"new.id"})
	{
		$newar->id($newid);
		unless ($newar->LoadFromId)
		{
			$self->InsertNote(MODBOT_MODERATOR, "The target label has been deleted");
			return STATUS_FAILEDDEP;
		}
	} else {
		# Load new label by name
		my $labels = $newar->GetLabelsFromName($name);
		if (scalar(@$labels) == 0)
		{
			$self->InsertNote(MODBOT_MODERATOR, "Label '$name' not found - it has been deleted or renamed");
			return STATUS_FAILEDDEP;
		}
		$newar = $$labels[0];
	}

	# Load old label by ID
	require MusicBrainz::Server::Label;
	my $oldar = MusicBrainz::Server::Label->new($self->dbh);
	$oldar->id($rowid);
	unless ($oldar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This label has been deleted");
		return STATUS_FAILEDPREREQ;
	}

	# Check to see that the old value is still what we think it is
	unless ($oldar->name eq $prevval)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This label has already been renamed");
		return STATUS_FAILEDPREREQ;
	}

	# You can't merge an label into itself!
	if ($oldar->id == $newar->id)
	{
		$self->InsertNote(MODBOT_MODERATOR, "Source and destination labels are the same!");
		return STATUS_ERROR;
	}

	# Disallow various merges involving the "special" labels
	if ($oldar->id == DLABEL_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't merge that label!");
		return STATUS_ERROR;
	}
	
	if ($newar->id == DLABEL_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't merge into that label!");
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

sub ShowModTypeDelegate
{
	my ($self, $m) = @_;
	$m->out('<tr class="entity"><td class="lbl">Label:</td><td>');
	my $id = $self->row_id;
	require MusicBrainz::Server::Label;
	my $label = MusicBrainz::Server::Label->new($self->dbh);
	$label->id($id);
	my ($title, $name);
	if ($label->LoadFromId) 
	{
		$title = $name = $label->name;
	}
	else
	{
		$name = "This label has been removed";
		$title = "This label has been removed, Id: $id";
		$id = -1;
	}
	$m->comp('/comp/linklabel', id => $id, name => $name, title => $title, strong => 0);
	$m->out('</td></tr>');
}

1;
# eof MOD_MERGE_LABEL.pm
