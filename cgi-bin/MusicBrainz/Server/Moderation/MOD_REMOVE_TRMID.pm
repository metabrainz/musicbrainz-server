#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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

	# Save the TRM's clientversion in case we need to re-add it
	my $trmobj = TRM->new($self->{DBH});
	my $clientversion = $trmobj->FindTRMClientVersion($trm);

	my %new = (
		TrackId => $tr->GetId,
		ClientVersion => $clientversion,
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

sub DeniedAction
{
	my $self = shift;
	my $nw = $self->{'new_unpacked'};

	if (my $trackid = $nw->{'TrackId'})
	{
	  	my $t = TRM->new($self->{DBH});
	   	my $id = $t->Insert($self->GetPrev, $trackid, $nw->{'ClientVersion'});

		# The above Insert can fail, usually if the row in the "trm" table
		# needed to be re-inserted but we neglected to save the clientversion
		# before it was deleted (i.e. mods inserted before this bug was
		# fixed).
		if (not $id)
		{
		 	$self->InsertNote(
				&ModDefs::MODBOT_MODERATOR,
				"Unable to re-insert TRM",
			);
		}
	}
}

1;
# eof MOD_REMOVE_TRMID.pm
