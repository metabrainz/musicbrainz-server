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

package MusicBrainz::Server::Moderation::MOD_REMOVE_TRMID;

use ModDefs;
use base 'Moderation';

sub Name { "Remove TRM ID" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $trm = $opts{'trm'} or die;
	my $trmjoinid = $opts{'trmjoinid'} or die;

	$self->SetTable("trmjoin");
	$self->SetColumn("id");
	$self->SetRowId($trmjoinid);
	$self->SetArtist($tr->GetArtist);
	$self->SetPrev($trm);

	my %new = (
		TrackId => $tr->GetId,
	);

	$self->SetNew($self->ConvertHashToNew(\%new));

	# This is one of those mods where we give the user instant gratification,
	# then undo the mod later if it's rejected.
	my $t = TRM->new($self->{DBH});
	$t->RemoveTRMByTRMJoin($self->GetRowId);
}

sub PostLoad
{
	my $self = shift;
	$self->{'new_unpacked'} = $self->ConvertNewToHash($self->GetNew)
		or die;
}

sub AdjustModPending { () }

sub ApprovedAction
{
	&ModDefs::STATUS_APPLIED;
}

# FIXME Currently DeniedAction fails because the "client version" is missing
# from the $trm->Insert call (and it's mandatory).  But we can't insert it,
# because we didn't save it...
# TODO save clientversion when we insert the mod (and delete the TRM), so we
# can undo the mod here.
# (p.s. it only fails if the TRM needs to be re-inserted, i.e. if no other
# tracks have this TRM)

sub DeniedAction
{
	my $this = shift;
	my $nw = $this->{'new_unpacked'};

	if (my $trackid = $nw->{'TrackId'})
	{
	  	my $t = TRM->new($this->{DBH});
	   	$t->Insert($this->GetPrev, $trackid);
	}
}

1;
# eof MOD_REMOVE_TRMID.pm
