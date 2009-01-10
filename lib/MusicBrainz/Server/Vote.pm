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

# id / id - see TableBase
sub moderation_id
{
    my ($self, $new_id) = @_;

    if (defined $new_id) { $self->{moderation} = $new_id; }
    return $self->{moderation};
}

sub GetUserId		{ $_[0]{moderator} }
sub SetUserId		{ $_[0]{moderator} = $_[1] }
sub GetVote			{ $_[0]{vote} }
sub SetVote			{ $_[0]{vote} = $_[1] }
sub GetUserName		{ $_[0]{user} }
sub GetVoteTime		{ $_[0]{votetime} }
sub GetSuperseded	{ $_[0]{superseded} }

# This function enters a number of votes into the Votes table.
# The caller must a hash of votes, where the keys are the moderation IDs,
# and the values are the VOTE_* constants.
sub InsertVotes
{
	my ($self, $votes, $uid, $allow_selfvoting) = @_;
	$allow_selfvoting = 0 if $allow_selfvoting == undef;

	while (my ($modid, $vote) = each %$votes)
	{
	    if ($vote == VOTE_YES or $vote == VOTE_NO or $vote == VOTE_ABS)
        {
		    $self->_InsertVote($uid, $modid, $vote, $allow_selfvoting);
        }
        else
        {
            carp "$vote is not a valid choice (for moderation $modid)";
        }
	}
}

sub _InsertVote
{
	my ($self, $uid, $modid, $vote, $allow_selfvoting) = @_;
	my $sql = Sql->new($self->GetDBH);

	# Lock the table so that the select-old / insert-new are atomic
	$sql->Do("LOCK TABLE vote_open IN EXCLUSIVE MODE");

	my $mod_row = $sql->SelectSingleRowHash(
		"SELECT novotes, status, moderator FROM moderation_open WHERE id = ?",
		$modid,
	);

	(defined($mod_row) and $mod_row->{status} == STATUS_OPEN)
		or return;

	($allow_selfvoting or $mod_row->{moderator} != $uid)
		or return;

	# Find the user's previous (most recent) vote for this mod
	my $prevvote = $sql->SelectSingleValue(
		"SELECT vote FROM vote_open WHERE moderator = ? AND moderation = ?
			ORDER BY id DESC LIMIT 1",
		$uid, $modid,
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
		"INSERT INTO vote_open (moderator, moderation, vote) VALUES (?, ?, ?)",
		$uid, $modid, $vote,
	);

	my $voteid = $sql->GetLastInsertId("vote_open");
	$sql->Do(
		"UPDATE vote_open SET superseded = TRUE
		WHERE moderator = ? AND moderation = ? AND id < ?",
		$uid, $modid, $voteid,
	);

	$sql->Do(
		"UPDATE moderation_open
		SET		yesvotes = yesvotes + ?,
				novotes = novotes + ?
		WHERE id = ?",
		$yesdelta,
		$nodelta,
		$modid,
	);

	if ($vote == VOTE_NO and $mod_row->{novotes} == 0)
	{
		require Moderation;
		my $t = Moderation->new($self->GetDBH);
		my $edit = $t->CreateFromId($modid);
		$edit->FirstNoVote($uid);
	}
}

sub newFromModerationId
{
    my ($self, $modid) = @_;
	my $sql = Sql->new($self->GetDBH);

	my $data = $sql->SelectListOfHashes(
		"SELECT	v.*, u.name AS user
		FROM	vote_all v, moderator u
		WHERE	v.moderation = ?
		AND		v.moderator = u.id
		ORDER BY v.id",
		$modid,
	);

	map { $self->_new_from_row($_) } @$data;
}

sub GetLatestVoteFromUser
{
	my ($self, $modid, $uid) = @_;
	my $sql = Sql->new($self->GetDBH);

	$sql->SelectSingleValue(
		"SELECT COALESCE(vote, ?) FROM vote_all WHERE moderation = ? AND moderator = ?
			AND (superseded IS NULL OR superseded = FALSE)",
		VOTE_NOTVOTED,
		$modid,
		$uid,
	);
}

################################################################################

sub AllVotesForUser_as_hashref
{
	my ($self, $uid) = @_;

	my $key = __PACKAGE__."-AllVotesForUser_as_hashref-$uid";
	my $data = MusicBrainz::Server::Cache->get($key);
	return $data if $data;

	my $sql = Sql->new($self->GetDBH);

	my $rows = $sql->SelectListOfLists(
		"SELECT vote, COUNT(*) FROM vote_all WHERE moderator = ? GROUP BY vote",
		$uid,
	);

	$data = +{
		map { $_->[0] => $_->[1] } @$rows
	};
	MusicBrainz::Server::Cache->set($key, $data, 3600);
	$data;
}

sub RecentVotesForUser_as_hashref
{
	my ($self, $uid) = @_;

	my $key = __PACKAGE__."-RecentVotesForUser_as_hashref-$uid";
	my $data = MusicBrainz::Server::Cache->get($key);
	return $data if $data;

	my $sql = Sql->new($self->GetDBH);

	my $rows = $sql->SelectListOfLists(
		"SELECT vote, COUNT(*) FROM vote_all WHERE moderator = ?
		AND votetime >= NOW() - INTERVAL '28 days'
		GROUP BY vote",
		$uid,
	);

	$data = +{
		map { $_->[0] => $_->[1] } @$rows
	};
	MusicBrainz::Server::Cache->set($key, $data, 3600);
	$data;
}

################################################################################

sub TopVoters
{
	my ($self, %opts) = @_;

	$opts{rowlimit} ||= 5;
	$opts{interval} ||= "1 week";

	my $sql = Sql->new($self->GetDBH);

	$sql->SelectListOfHashes(
		"SELECT	m.id, m.name, COUNT(*) AS num
		FROM	vote_all v, moderator m
		WHERE	v.moderator = m.id
		AND 	v.vote != " . VOTE_ABS . "
		AND		votetime > NOW() - INTERVAL ?
		GROUP BY m.id, m.name
		ORDER BY num DESC
		LIMIT ?",
		$opts{interval},
		$opts{rowlimit},
	);
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
