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

package MusicBrainz::Server::Moderation::MOD_CHANGE_WIKIDOC;

use ModDefs qw( :modstatus :artistid MODBOT_MODERATOR VARTIST_ID );
use base 'Moderation';

sub Name { "Change Wikidoc" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $page = $opts{'page'} or die;
	my $rev = $opts{'rev'};
	my $prevrev = $opts{'prevrev'};

	my %prev;
	$prev{'Page'} = $page;
	$prev{'Rev'} = $prevrev;

    my %new;
	$new{'Rev'} = $rev;

	$self->artist(VARTIST_ID);
	$self->previous_data($self->ConvertHashToNew(\%prev));
	$self->new_data($self->ConvertHashToNew(\%new));
	$self->table("artist");
	$self->column("name");
	$self->row_id(VARTIST_ID);
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->new_data()) or die;
	$self->{'prev_unpacked'} = $self->ConvertNewToHash($self->previous_data()) or die;
}

1;
# eof MOD_EDIT_ARTIST.pm
