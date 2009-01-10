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

package MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Remove Release" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'album'} or die;

	$self->artist($al->artist);
	$self->previous_data($al->name);
	$self->table("album");
	$self->column("name");
	$self->row_id($al->id);
}

sub PostLoad
{
	my $self = shift;

	($self->{"albumid"}, $self->{"checkexists-album"}) = ($self->row_id, 1);
} 

sub DetermineQuality
{
	my $self = shift;

	my $rel = MusicBrainz::Server::Release->new($self->dbh);
	$rel->id($self->{rowid});
	if ($rel->LoadFromId())
	{
        return $rel->quality;        
    }
    return &ModDefs::QUALITY_NORMAL;
}

sub ApprovedAction
{
	my $this = shift;

	require MusicBrainz::Server::Release;
	my $al = MusicBrainz::Server::Release->new($this->dbh);
	$al->id($this->row_id);

	unless ($al->Remove)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This release could not be removed");
		# TODO should this be "STATUS_ERROR"?  Why would the Remove call fail?
		return STATUS_FAILEDDEP;
	}
   
	STATUS_APPLIED;
}

1;
# eof MOD_REMOVE_RELEASE.pm
