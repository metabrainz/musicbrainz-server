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

package MusicBrainz::Server::Moderation::MOD_REMOVE_LABEL;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Label" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'label'} or die;
	die if $ar->id == %ModDefs::DLABEL_ID;

	$self->previous_data($ar->name);
	$self->table("label");
	$self->column("name");
	$self->row_id($ar->id);
}

sub ApprovedAction
{
	my $this = shift;

	my $rowid = $this->row_id;

	if ($rowid == %ModDefs::DLABEL_ID)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This label cannot be deleted");
		return STATUS_ERROR;
	}
   
	# Now remove the Label. The Label will only be removed
	# if there are not more references to it.
	require MusicBrainz::Server::Label;
	my $ar = MusicBrainz::Server::Label->new($this->GetDBH);
	$ar->id($rowid);

	require UserSubscription;
	my $subs = UserSubscription->new($this->GetDBH);
	$subs->LabelBeingDeleted($ar, $this);

	unless (defined $ar->Remove)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This label could not be removed");
		return STATUS_FAILEDDEP;
	}

	STATUS_APPLIED;
}

sub PostLoad
{
	my $self = shift;
	$self->{'dont-display-artist'} = 1;
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
# eof MOD_REMOVE_LABEL.pm
