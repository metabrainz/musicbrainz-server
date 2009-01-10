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

package MusicBrainz::Server::Moderation::MOD_EDIT_LABEL;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Label" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'label'} or die;

	die $self->SetError('Editing this label is not allowed'),
		if $ar->id() == &ModDefs::DLABEL_ID;

	my $name = $opts{'name'};
	my $sortname = $opts{'sortname'};
	my $country = $opts{'country'};
	my $labelcode = $opts{'labelcode'};
	my $type = $opts{'labeltype'};
	my $resolution = $opts{'resolution'};
	my $begindate = $opts{'begindate'};
	my $enddate = $opts{'enddate'};

	my %new;

	if ( defined $name )
	{
		MusicBrainz::Server::Validation::TrimInPlace($name);
		$new{'LabelName'} = $name;
	}

	if (defined $sortname)
	{
		MusicBrainz::Server::Validation::TrimInPlace($sortname);
		die $self->SetError('Empty sort name not allowed.')
			unless $sortname =~ m/\S/;

		$new{'SortName'} = $sortname if $sortname ne $ar->sort_name();
	}

	if (defined $country)
{
		MusicBrainz::Server::Validation::TrimInPlace($sortname);
		$new{'Country'} = $country if $country ne $ar->country();
}

	if ( defined $labelcode )
	{
		MusicBrainz::Server::Validation::TrimInPlace($labelcode);

		die 'Invalid label code'
			if ($labelcode && not MusicBrainz::Server::Validation::IsValidLabelCode($labelcode));

		$new{'LabelCode'} = $labelcode if $labelcode ne $ar->label_code();
	}

	if ( defined $type )
	{
		die $self->SetError('Label type invalid')
			unless MusicBrainz::Server::Label::IsValidType($type);

		$new{'Type'} = $type if $type != $ar->type();
	}

	if ( defined $resolution )
	{
		MusicBrainz::Server::Validation::TrimInPlace($resolution);

		$new{'Resolution'} = $resolution
				if $resolution ne $ar->resolution;
	}

	if ( defined $begindate )
	{
		my $datestr = MakeDateStr(@$begindate);
		die $self->SetError('Invalid begin date') unless defined $datestr;

		$new{'BeginDate'} = $datestr if $datestr ne $ar->begin_date();
	}

	if ( defined $enddate )
	{
		my $datestr = MakeDateStr(@$enddate);
		die $self->SetError('Invalid end date') unless defined $datestr;

		$new{'EndDate'} = $datestr if $datestr ne $ar->end_date();
	}


	# User made no changes. No need to insert a moderation.
	return $self->SuppressInsert() if keys %new == 0;


	# record previous values if we set their corresponding attributes
	my %prev;

	$prev{'LabelName'} = $ar->name() if exists $new{'LabelName'};
	$prev{'LabelCode'} = $ar->label_code() if exists $new{'LabelCode'};
	$prev{'Country'} = $ar->country() if exists $new{'Country'};
	$prev{'SortName'} = $ar->sort_name() if exists $new{'SortName'};
	$prev{'Type'} = $ar->type() if exists $new{'Type'};
	$prev{'Resolution'} = $ar->resolution() if exists $new{'Resolution'};
	$prev{'BeginDate'} = $ar->begin_date() if exists $new{'BeginDate'};
	$prev{'EndDate'} = $ar->end_date() if exists $new{'EndDate'};

	$self->previous_data($self->ConvertHashToNew(\%prev));
	$self->new_data($self->ConvertHashToNew(\%new));
	$self->table("label");
	$self->column("name");
	$self->row_id($ar->id);
}

# Specialized version of MusicBrainz::Server::Validation::MakeDBDateStr:
# Returns '' if year, month and day are empty.
sub MakeDateStr
{
	my ($y, $m, $d) = @_;

	return '' if $y eq '' and $m eq '' and $d eq '';

	return MusicBrainz::Server::Validation::MakeDBDateStr($y, $m, $d);
}

sub PostLoad
{
	my $self = shift;
	$self->{'dont-display-artist'} = 1;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data()) or die;
	$self->{'prev_unpacked'} = $self->ConvertNewToHash($self->previous_data()) or die;
	$self->{'labelid'} = $self->row_id;
}

sub IsAutoEdit
{
	my ($self) = @_;

	my $new = $self->{'new_unpacked'};
	my $prev = $self->{'prev_unpacked'};

	my $automod = 1;

	# Changing name or sortname is allowed if the change only affects
	# small things like case etc.
	my ($oldname, $newname) = $self->_normalise_strings(
								$prev->{'LabelName'}, $new->{'LabelName'});
	my ($oldlabelcode, $newlabelcode) = $self->_normalise_strings(
								$prev->{'LabelCode'}, $new->{'LabelCode'});
	my ($oldsortname, $newsortname) = $self->_normalise_strings(
								$prev->{'SortName'}, $new->{'SortName'});

	$automod = 0 if $oldname ne $newname;
	$automod = 0 if $oldlabelcode ne $newlabelcode;
	$automod = 0 if $oldsortname ne $newsortname;

	# Changing a resolution string is never automatic.
	$automod = 0 if exists $new->{'Resolution'};

	# Adding a date is automatic if there was no date yet.
	$automod = 0 if exists $prev->{'BeginDate'} and $prev->{'BeginDate'} ne '';
	$automod = 0 if exists $prev->{'EndDate'} and $prev->{'EndDate'} ne '';

	$automod = 0 if exists $prev->{'Type'} and $prev->{'Type'} != 0;

	return $automod;
}

sub CheckPrerequisites
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};
	my $prev = $self->{'prev_unpacked'};

	my $label_id = $self->row_id();

	if ($label_id == &ModDefs::DLABEL_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't rename this label!");
		return STATUS_ERROR;
	}

	# Load the label by ID
	require MusicBrainz::Server::Label;
	my $ar = MusicBrainz::Server::Label->new($self->GetDBH);
	$ar->id($label_id);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This label has been deleted.");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed.
	if ( exists $prev->{LabelName} and $ar->name() ne $prev->{LabelName} )
	{
		$self->InsertNote(MODBOT_MODERATOR,
									"This label has already been renamed.");
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{_label} = $ar;

	return undef; # undef means no error
}


sub ApprovedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $status = $self->CheckPrerequisites();
	return $status if $status;

	my $label = $self->{_label};
	$label->Update($new) or die "Failed to update label in MOD_EDIT_LABEL";

	return STATUS_APPLIED;
}

sub DeniedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};

	if (my $label = $new->{'LabelId'})
	{
		require MusicBrainz::Server::Label;
		my $ar = MusicBrainz::Server::Label->new($self->GetDBH);
		$ar->id($label);
		$ar->Remove;
   }
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
# eof MOD_EDIT_LABEL.pm
