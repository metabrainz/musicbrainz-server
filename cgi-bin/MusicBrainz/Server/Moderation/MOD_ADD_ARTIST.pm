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

package MusicBrainz::Server::Moderation::MOD_ADD_ARTIST;

use ModDefs;
use base 'Moderation';

sub Name { "Add Artist" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $name = $opts{'name'};
	$name =~ /\S/ or die;
	
	my $sortname = $opts{'sortname'};
	$sortname = $name if not defined $sortname or $sortname eq "";
	$sortname =~ /\S/ or die;
	
	$self->SetTable("artist");
	$self->SetColumn("name");
	$self->SetRowId(&ModDefs::DARTIST_ID);

	my %new = (
		ArtistName => $name,
		SortName => $sortname,
	);

	$self->SetNew($self->ConvertHashToNew(\%new));

	my %info = (
		artist		=> $name,
		sortname	=> $sortname,
		artist_only	=> 1,
	);

	my $in = Insert->new($self->{DBH});
	my $ans = $in->Insert(\%info);

	# TODO I'm not sure this path is ever used - I think $ans is always true.
	defined($ans)
		or ($self->SetError($in->GetError), die $self);

	unless (exists $info{artist_insertid})
 	{
		#$self->SetError("The artist <a href=\"/showartist.html?artistid=$info{_artistid}\">$info{artist}</a> already exists.");
		$self->SetError("The artist '$name' already exists.");
		die $self;
	}

	my $artist = $info{'artist_insertid'};
	$self->SetArtist($artist);
	$self->SetRowId($artist);
	$new{'ArtistId'} = $artist;
	$self->SetNew($self->ConvertHashToNew(\%new));
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

sub DeniedAction
{
  	my $self = shift;
	my $newval = $self->{'new_unpacked'};

	if (my $artist = $newval->{'ArtistId'})
	{
		my $ar = Artist->new($self->{DBH});
		$ar->SetId($artist);
		$ar->Remove;

		# TODO shouldn't this be handled by Artist->Remove?
		my $sql = Sql->new($self->{DBH});
		$sql->Do(
			"UPDATE moderation SET artist = ? WHERE artist = ?",
			&ModDefs::DARTIST_ID,
			$artist,
		);
   }
}

1;
# eof MOD_ADD_ARTIST.pm
