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

package MusicBrainz::Server::Vote;

use base qw( TableBase );
use Carp;
use ModDefs ':vote', 'STATUS_OPEN';

# GetId / SetId - see TableBase
sub GetModerationId	{ $_[0]{rowid} }
sub SetModerationId	{ $_[0]{rowid} = $_[1] }
sub GetUserId		{ $_[0]{uid} }
sub SetUserId		{ $_[0]{uid} = $_[1] }
sub GetVote			{ $_[0]{vote} }
sub SetVote			{ $_[0]{vote} = $_[1] }
sub GetUserName		{ $_[0]{user} }
sub GetVoteTime		{ $_[0]{votetime} }

# This function enters a number of votes into the Votes table.
# The caller must a hash of votes, where the keys are the moderation IDs,
# and the values are the VOTE_* constants.
sub InsertVotes
{
	my ($self, $votes, $uid) = @_;

	while (my ($modid, $vote) = each %$votes)
	{
		next unless $vote == VOTE_YES or $vote == VOTE_NO or $vote == VOTE_ABS;
		$self->_InsertVote($uid, $modid, $vote);
	}
}

sub _InsertVote
{
	my ($self, $uid, $id, $vote) = @_;
	my $sql = Sql->new($self->{DBH});

	my $status = $sql->SelectSingleValue(
		"SELECT status FROM moderation WHERE id = ?",
		$id,
	);

	$status == STATUS_OPEN
		or return;

	# Find the user's previous (most recent) vote for this mod
	my $prevvote = $sql->SelectSingleValue(
		"SELECT vote FROM votes WHERE uid = ? AND rowid = ?
			ORDER BY id DESC LIMIT 1",
		$uid, $id,
	);

	# Nothing to do if your vote is the same as last time
	return if defined $prevvote
		and $vote == $prevvote;

	my $yesdelta = 0;
	my $nodelta = 0;

	--$yesdelta if defined $prevvote and $prevvote == VOTE_YES;
	--$nodelta if defined $prevvote and $prevvote == VOTE_NO;
	++$yesdelta if $vote == VOTE_YES;
	++$nodelta if $vote == VOTE_NO;

	$sql->Do(
		"INSERT INTO votes (uid, rowid, vote) VALUES (?, ?, ?)",
		$uid, $id, $vote,
	);

	$sql->Do(
		"UPDATE moderation
		SET		yesvotes = yesvotes + ?,
				novotes = novotes + ?
		WHERE id = ?",
		$yesdelta,
		$nodelta,
		$id,
	);
}

sub newFromModerationId
{
    my ($self, $modid) = @_;
	my $sql = Sql->new($self->{DBH});

	my $data = $sql->SelectListOfHashes(
		"SELECT	v.*, u.name AS user
		FROM	votes v, moderator u
		WHERE	v.rowid = ?
		AND		v.uid = u.id
		ORDER BY v.id",
		$modid,
	);

	map { $self->_new_from_row($_) } @$data;
}

################################################################################

my %VoteText = (
    &ModDefs::VOTE_UNKNOWN	=> "Unknown",
    &ModDefs::VOTE_NOTVOTED	=> "Not voted",
    &ModDefs::VOTE_ABS		=> "Abstain",
    &ModDefs::VOTE_YES		=> "Yes",
    &ModDefs::VOTE_NO		=> "No"
);

sub GetVoteName
{
	my ($self, $vote) = @_;
	$vote = $self->GetVote unless defined $vote;
	$VoteText{$vote};
}

1;
# eof Vote.pm
