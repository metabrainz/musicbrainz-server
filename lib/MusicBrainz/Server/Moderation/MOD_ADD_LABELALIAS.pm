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

package MusicBrainz::Server::Moderation::MOD_ADD_LABELALIAS;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Add Label Alias" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'label'} or die;
	my $newalias = $opts{'newalias'};
	defined $newalias or die;

	$self->previous_data($ar->name);
	$self->new_data($newalias);
	$self->table("label");
	$self->column("name");
	$self->row_id($ar->id);
}

sub CheckPrerequisites
{
	my $self = shift;

	# Check that the referenced label is still around
	require MusicBrainz::Server::Label;
	my $ar = MusicBrainz::Server::Label->new($self->GetDBH);
	$ar->id($self->row_id);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(
			MODBOT_MODERATOR,
			"This label has been deleted",
		);
		return STATUS_FAILEDPREREQ;
	}

	undef;
}

sub PostLoad
{
    my $self = shift;

    require MusicBrainz::Server::Alias;
    my $alias = MusicBrainz::Server::Alias->new($self->GetDBH, "labelalias");
    $alias->id($self->row_id);
    $alias->LoadFromId;

    $self->{'dont-display-artist'} = 1;
    $self->{'labelid'} = $alias->row_id;
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	require MusicBrainz::Server::Alias;
	my $al = MusicBrainz::Server::Alias->new($self->GetDBH);
	$al->table("LabelAlias");

	my $other;
	if ($al->Insert($self->row_id, $self->new_data, \$other, 1))
	{
		return STATUS_APPLIED;
	}

	# Something went wrong - what?
	my $message = "Failed to add new alias";

	$self->InsertNote(MODBOT_MODERATOR, $message);
	return STATUS_ERROR;
}

sub ShowModTypeDelegate
{
	my ($self, $m) = @_;
	$m->out('<tr class="entity"><td class="lbl">Label:</td><td>');
	my $id = $self->row_id;
	require MusicBrainz::Server::Label;
	my $label = MusicBrainz::Server::Label->new($self->GetDBH);
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
# eof MOD_ADD_LABELALIAS.pm
