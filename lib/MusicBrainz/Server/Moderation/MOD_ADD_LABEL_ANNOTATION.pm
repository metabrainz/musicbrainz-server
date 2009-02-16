#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2004 Robert Kaye
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

package MusicBrainz::Server::Moderation::MOD_ADD_LABEL_ANNOTATION;

use ModDefs;
use MusicBrainz::Server::Annotation ':type';
use base 'Moderation';

sub Name { "Add Label Annotation" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $labelid = $opts{'labelid'} or die;
	my $text = $opts{'text'} || '';
	my $changelog = $opts{'changelog'} || '';

	my %new = (
		Text => $text,
		ChangeLog => $changelog,
	);

	$self->new_data($self->ConvertHashToNew(\%new));
	$self->table('label');
	$self->column('annotation.text');
	$self->row_id($labelid);
}

sub IsAutoEdit 
{ 
    1 
}

sub PreDisplay
{
	my $this = shift;
	
	$this->{'dont-display-artist'} = 1;
	# load annotation data
	my $an = MusicBrainz::Server::Annotation->new($this->dbh);
	$an->moderation($this->id());
	if ($an->LoadFromId())
	{
		my $log = $an->change_log;
		$log = "(no change log)"
			unless ($log =~ /\S/);
		$this->{'changelog'} = $log;
		$this->{'annotid'} = $an->id;
	}
}

sub ApprovedAction
{
	my $self = shift;

	my $new = $self->ConvertNewToHash($self->new_data());
	my $changelog = $new->{ChangeLog};
	my $text = $new->{Text};

	require MusicBrainz::Server::Annotation;
	my $an = MusicBrainz::Server::Annotation->new($self->dbh);

	$an->moderator($self->moderator());
	$an->moderation($self->id());
	$an->type(LABEL_ANNOTATION);
	$an->SetLabel($self->row_id());
	$an->text($text);
	$an->change_log($changelog);
	$an->Insert();

	return &ModDefs::STATUS_APPLIED;
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
# eof MOD_ADD_LABEL_ANNOTATION.pm
