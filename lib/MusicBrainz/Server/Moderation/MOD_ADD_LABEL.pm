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

package MusicBrainz::Server::Moderation::MOD_ADD_LABEL;

use ModDefs;
use base 'Moderation';

sub Name { "Add Label" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $name = $opts{'name'};
	my $sortname = $opts{'sortname'};
	my $labelcode = $opts{'labelcode'};
	my $type = $opts{'labeltype'};
	my $country = $opts{'label_country'};
	my $resolution = $opts{'label_resolution'};
	my $begindate = $opts{'label_begindate'};
	my $enddate = $opts{'label_enddate'};

	MusicBrainz::Server::Validation::TrimInPlace($name) if defined $name;
	$name =~ /\S/ or die $self->SetError('Label name not set');;
	
	MusicBrainz::Server::Validation::TrimInPlace($sortname) if defined $sortname;
	$sortname =~ /\S/ or die $self->SetError('Label sort name not set');;
	
	MusicBrainz::Server::Validation::TrimInPlace($labelcode) if defined $labelcode;
	MusicBrainz::Server::Validation::TrimInPlace($resolution) if defined $resolution;

	# We allow a type of 0. It is mapped to NULL in the DB.
	die $self->SetError('Label type invalid')
		unless MusicBrainz::Server::Label::IsValidType($type) or not defined $type;

	# undefined $begindate means: no date given
	my $begindate_str;
	if ( defined $begindate and $begindate->[0] ne '')
	{
		die 'Invalid begin date' unless MusicBrainz::Server::Validation::IsValidDate(@$begindate);
		$begindate_str = MusicBrainz::Server::Validation::MakeDBDateStr(@$begindate);
	}

	my $enddate_str;
	if ( defined $enddate and $enddate->[0] ne '')
	{
		die 'Invalid end date' unless MusicBrainz::Server::Validation::IsValidDate(@$enddate);
		$enddate_str = MusicBrainz::Server::Validation::MakeDBDateStr(@$enddate);
	}

	die 'Invalid label code'
		if ($labelcode && not MusicBrainz::Server::Validation::IsValidLabelCode($labelcode));

	my $label = MusicBrainz::Server::Label->new($self->dbh);
	$label->name($name);
	$label->sort_name($sortname);
	$label->type($type);
	$label->country($country);
	$label->label_code($labelcode);
	$label->begin_date($begindate_str);
	$label->end_date($enddate_str);
	$label->resolution($resolution);
	my $labelid = $label->Insert();

	# The label has been inserted. Now set up the moderation record
	# to undo it if the vote fails.

	if (UserPreference::get('auto_subscribe'))
	{
		my $subs = UserSubscription->new($self->dbh);
		$subs->SetUser($self->moderator);
		my $label = MusicBrainz::Server::Label->new($self->dbh);
		$label->id($labelid);
		$subs->SubscribeLabels(($label))
			if ($label->LoadFromId);
    }

	my %new = (
		LabelName => $name,
		SortName => $sortname,
	);

	$new{'LabelCode'} = $labelcode
		if defined $labelcode;
	$new{'Type'} = $type
		if defined $type;
	$new{'Country'} = $country
		if defined $country;
	$new{'Resolution'} = $resolution
		if defined $resolution;
	$new{'BeginDate'} = $begindate_str
		if defined $begindate_str;
	$new{'EndDate'} = $enddate_str
		if defined $enddate_str;
	$new{'LabelId'} = $labelid;

	$self->table('label');
	$self->column('name');
	$self->row_id($labelid);
	$self->new_data($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'dont-display-artist'} = 1;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data)
		or die;
	$self->{'labelid'} = $self->row_id;
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
  	my $self = shift;
	my $newval = $self->{'new_unpacked'};

	# Do nothing - the cleanup script will handle this
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
# eof MOD_ADD_LABEL.pm
