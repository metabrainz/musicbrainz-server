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

package MusicBrainz::Server::Moderation::MOD_EDIT_ARTIST;

use ModDefs qw( :modstatus :artistid MODBOT_MODERATOR MOD_MERGE_ARTIST );
use base 'Moderation';

sub Name { "Edit Artist" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $ar = $opts{'artist'} or die;

	die $self->SetError('Editing this artist is not allowed'),
		if $ar->id() == VARTIST_ID or $ar->id() == DARTIST_ID;

	my $name = $opts{'name'};
	my $sortname = $opts{'sortname'};
	my $type = $opts{'artist_type'};
	my $resolution = $opts{'resolution'};
	my $begindate = $opts{'begindate'};
	my $enddate = $opts{'enddate'};

	my %new;

	# The artist name must be defined, has to be changed and must not
	# clash with an existing artist.
	if ( defined $name )
	{
		MusicBrainz::Server::Validation::TrimInPlace($name);
		$new{'ArtistName'} = $name;
	}

	if ( defined $sortname )
	{
		MusicBrainz::Server::Validation::TrimInPlace($sortname);

		die $self->SetError('Empty sort name not allowed.')
			unless $sortname =~ m/\S/;

		$new{'SortName'} = $sortname if $sortname ne $ar->sort_name();
	}

	if ( defined $type )
	{
		die $self->SetError("Artist type $type invalid")
			unless MusicBrainz::Server::Artist::is_valid_type($type);

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

	$prev{'ArtistName'} = $ar->name() if exists $new{'ArtistName'};
	$prev{'SortName'} = $ar->sort_name() if exists $new{'SortName'};
	$prev{'Type'} = $ar->type() if exists $new{'Type'};
	$prev{'Resolution'} = $ar->resolution() if exists $new{'Resolution'};
	$prev{'BeginDate'} = $ar->begin_date() if exists $new{'BeginDate'};
	$prev{'EndDate'} = $ar->end_date() if exists $new{'EndDate'};

	$self->artist($ar->id);
	$self->previous_data($self->ConvertHashToNew(\%prev));
	$self->new_data($self->ConvertHashToNew(\%new));
	$self->table("artist");
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
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data()) or die;
	$self->{'prev_unpacked'} = $self->ConvertNewToHash($self->previous_data()) or die;
}

sub DetermineQuality
{
	my $self = shift;

	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
	$ar->id($self->{rowid});
	if ($ar->LoadFromId())
	{
        return $ar->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
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
								$prev->{'ArtistName'}, $new->{'ArtistName'});
	my ($oldsortname, $newsortname) = $self->_normalise_strings(
								$prev->{'SortName'}, $new->{'SortName'});

	$automod = 0 if $oldname ne $newname;
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

	my $artist_id = $self->row_id();

	if ($artist_id == VARTIST_ID or $artist_id == DARTIST_ID)
	{
		$self->InsertNote(MODBOT_MODERATOR, "You can't rename this artist!");
		return STATUS_ERROR;
	}

	# Load the artist by ID
	require MusicBrainz::Server::Artist;
	my $ar = MusicBrainz::Server::Artist->new($self->dbh);
	$ar->id($artist_id);
	unless ($ar->LoadFromId)
	{
		$self->InsertNote(MODBOT_MODERATOR, "This artist has been deleted.");
		return STATUS_FAILEDDEP;
	}

	# Check that its name has not changed.
	if ( exists $prev->{ArtistName} and $ar->name() ne $prev->{ArtistName} )
	{
		$self->InsertNote(MODBOT_MODERATOR,
									"This artist has already been renamed.");
		return STATUS_FAILEDPREREQ;
	}

	# Save for ApprovedAction
	$self->{_artist} = $ar;

	return undef; # undef means no error
}


sub ApprovedAction
{
	my $self = shift;
	my $new = $self->{'new_unpacked'};

	my $status = $self->CheckPrerequisites();
	return $status if $status;

	my $artist = $self->{_artist};
	$artist->Update($new) or die "Failed to update artist in MOD_EDIT_ARTIST";

	return STATUS_APPLIED;
}

sub DeniedAction
{
  	my $self = shift;
	my $new = $self->{'new_unpacked'};

	if (my $artist = $new->{'ArtistId'})
	{
		require MusicBrainz::Server::Artist;
		my $ar = MusicBrainz::Server::Artist->new($self->dbh);
		$ar->id($artist);
		$ar->Remove;
   }
}

1;
# eof MOD_EDIT_ARTIST.pm
