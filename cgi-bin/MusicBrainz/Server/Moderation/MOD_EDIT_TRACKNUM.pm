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

package MusicBrainz::Server::Moderation::MOD_EDIT_TRACKNUM;

use ModDefs qw( :modstatus MODBOT_MODERATOR );
use base 'Moderation';

sub Name { "Edit Track Number" }
(__PACKAGE__)->RegisterHandler;

sub PreInsert
{
	my ($self, %opts) = @_;

	my $tr = $opts{'track'} or die;
	my $newseq = $opts{'newseq'} or die;

	$self->SetArtist($tr->GetArtist);
	$self->SetPrev($tr->GetSequence);
	$self->SetNew(0+$newseq);
	$self->SetTable("albumjoin");
	$self->SetColumn("sequence");
	$self->SetRowId($tr->GetSequenceId);
}

sub ApprovedAction
{
	my $this = shift;
	my $sql = Sql->new($this->{DBH});

	my $current = $sql->SelectSingleValue(
		"SELECT sequence FROM albumjoin WHERE id = ?",
		$this->GetRowId,
	);

	unless (defined $current)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has been deleted");
		return STATUS_FAILEDPREREQ;
	}
	
	unless ($current == $this->GetPrev)
	{
		$this->InsertNote(MODBOT_MODERATOR, "This track has already been renumbered");
		return STATUS_FAILEDDEP;
	}

	# TODO check no other track exists with the new sequence?
	# (but if you do that, it makes it very hard to swap/rotate
	# tracks within an album).
	
	$sql->Do(
		"UPDATE albumjoin SET sequence = ? WHERE id = ?",
		$this->GetNew,
		$this->GetRowId,
	);

	STATUS_APPLIED;
}

1;
# eof MOD_EDIT_TRACKNUM.pm
