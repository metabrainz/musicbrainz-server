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

package MusicBrainz::Server::Moderation::MOD_REMOVE_RELEASE;

use strict;
use warnings;

use base 'Moderation';

use ModDefs qw( :modstatus MODBOT_MODERATOR );

sub Name { "Remove Release" }
sub moderation_id   { 12 }

sub edit_conditions
{
    return {
        ModDefs::QUALITY_LOW => {
            duration     => 4,
            votes        => 1,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },  
        ModDefs::QUALITY_NORMAL => {
            duration     => 14,
            votes        => 3,
            expireaction => ModDefs::EXPIRE_ACCEPT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },
        ModDefs::QUALITY_HIGH => {
            duration     => 14,
            votes        => 4,
            expireaction => ModDefs::EXPIRE_REJECT,
            autoedit     => 0,
            name         => $_[0]->Name,
        },
    }
}

sub PreInsert
{
	my ($self, %opts) = @_;

	my $al = $opts{'album'} or die;

	$self->artist($al->artist);
	$self->SetPrev($al->name);
	$self->table("album");
	$self->SetColumn("name");
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

	my $rel = MusicBrainz::Server::Release->new($self->{DBH});
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
	my $al = MusicBrainz::Server::Release->new($this->{DBH});
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
