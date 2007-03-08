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
#   $Id: MOD_CHANGE_RELEASE_QUALITY.pm 8551 2006-10-19 20:10:48Z robert $
#____________________________________________________________________________

use strict;

package MusicBrainz::Server::Moderation::MOD_CHANGE_RELEASE_QUALITY;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Change Release Quality" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $releases = $opts{'releases'} or die;
	my $quality = $opts{'quality'} || 0;

	my %artists;
	my %new = (
		Quality	=> $quality
	);

	my $seq = 0;

    # Take the quality level from the first release or set to normal for multiple releases
    my $quality_level = &ModDefs::QUALITY_NORMAL;
    $quality_level = $releases->[0] if (scalar(@$releases) == 1);

	foreach my $al ( @$releases )
	{
		my $prev = $al->GetQuality || 0;
		next if $prev eq $new{Quality};

		$new{"ReleaseId$seq"} = $al->GetId;
		$new{"ReleaseName$seq"} = $al->GetName;
		$new{"Prev$seq"} = $prev;

		++$artists{$al->GetArtist};
		++$seq;
	}

	# Nothing to change?
	unless ($seq)
	{
		$self->SuppressInsert;
		return;
	}

	# if in single edit mod, file moderation under release object.
	# If all n releases are stored under artist x use this
	# artist as the moderation artist, else VA.
	$self->SetRowId($releases->[0]->GetId) if ($seq == 1);
	$self->SetArtist(
		keys(%artists) > 1
			? &ModDefs::VARTIST_ID
			: $releases->[0]->GetArtist
	);
	
	$self->SetTable("album");
	$self->SetColumn("id");
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->GetNew);
	my @releases;

	for (my $i = 0; defined $new->{"ReleaseId$i"}; $i++)
	{
		my $id = $new->{"ReleaseId$i"};
		my $name = $new->{"ReleaseName$i"};

		push @releases, { id => $id, name => $name,
  						  prev_quality => $new->{"Prev$i"}};
	}

	$self->{_new_releases} = \@releases;
	$self->{_quality} = $new->{Quality};
}

sub CheckPrerequisites
{
	my $self = shift;
	my $new = $self->ConvertNewToHash($self->GetNew)
		or die;

	my @releases;
	my $status = undef;

	require Album;
	for (my $i = 0; defined $new->{"ReleaseId$i"}; $i++)
	{
		my $id = $new->{"ReleaseId$i"};
		my $al = Album->new($self->{DBH});
		$al->SetId($id);

		unless ( $al->LoadFromId )
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The release '" . $new->{"ReleaseName$i"} . "' has been deleted. ");
			$status = STATUS_FAILEDDEP unless $status == STATUS_FAILEDPREREQ;
			next;
		}

		my $prev = $new->{"Prev$i"};
		my $curr = $al->GetQuality;

		# Make sure the quality hasn't changed while this mod was open
		if ($curr ne $prev && $curr ne $new->{Quality})
		{
			$self->InsertNote(MODBOT_MODERATOR,
				"The quality of release '" . $new->{"ReleaseName$i"}
			  . "' has already been changed. ");
			$status = STATUS_FAILEDPREREQ;
			next;
		}

		push @releases, $al;
	}

	# None of the releases may be changed. Thus we return STATUS_FAILEDDEP
	# or STATUS_FAILEDPREREQ.
	return $status if @releases == 0;

	# Save all releases that we are going to change in ApprovedAction().
	$self->{_releases} = \@releases;

	return undef; # undef means no prerequisite problem
}

sub ApprovedAction
{
	my $self = shift;

	my $status = $self->CheckPrerequisites;
	return $status if $status;

	my $quality = $self->{_quality};
	my $albums = $self->{_releases};

	foreach my $al ( @$albums )
	{
		$al->SetQuality($quality);
		$al->UpdateQuality;
	}

	STATUS_APPLIED;
}

1;
# eof MOD_CHANGE_RELEASE_QUALITY.pm
