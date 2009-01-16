#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 1998 Robert Kaye
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

# Abstract: Remove or rename duplicate moderators so we can make moderator.name unique

use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use Sql;
use ModDefs qw( MODBOT_MODERATOR MOD_MERGE_ARTIST );
use UserStuff;

$| = 1 if -t STDOUT;

my $mb = MusicBrainz->new; $mb->Login;
my $sql = Sql->new($mb->{dbh});

$sql->Begin;

$sql->Do("LOCK TABLE moderator IN EXCLUSIVE MODE");

my $rows = $sql->SelectListOfLists(
	"SELECT name, COUNT(*), JOIN(id::VARCHAR)
	FROM moderator
	GROUP BY name
	HAVING COUNT(*) > 1",
);

for my $row (@$rows)
{
	my $name = $row->[0];
	my @ids = split ' ', $row->[2];

	my %uses;
	for my $id (@ids)
	{
		my $used = 0;
		for my $refcol (qw(
			moderation_open.moderator
			moderation_note_open.moderator
			vote_open.moderator
			moderation_closed.moderator
			moderation_note_closed.moderator
			vote_closed.moderator
		)) {
			my ($tab, $col) = split /\./, $refcol;
			my $n = $sql->SelectSingleValue(
				"SELECT COUNT(*) FROM $tab WHERE $col = ?", $id,
			);
			$used += $n;
		}
		print "$name $id use count = $used\n";
		$uses{$id} = $used;
	}

	# Sort them, least-used to most-used
	@ids = sort {
		$uses{$a} <=> $uses{$b}
			or
		$a <=> $b
	} @ids;

	# This is the one we'll keep
	my $keep = pop @ids;

	for my $id (@ids)
	{
		# Move any existing data over to the one we're going to keep
		my $moved = 0;
		for my $refcol (qw(
			moderation_open.moderator
			moderation_note_open.moderator
			vote_open.moderator
			moderation_closed.moderator
			moderation_note_closed.moderator
			vote_closed.moderator
		)) {
			my ($tab, $col) = split /\./, $refcol;
			my $n = $sql->Do(
				"UPDATE $tab SET $col = ? WHERE $col = ?", $keep, $id,
			);
			$moved += $n;
		}

		# There are also two more foreign keys: moderator_subscribe_artist and
		# moderator_preference.  We'll only try very feebly to move those
		# rows.
		for my $refcol (qw(
			moderator_subscribe_artist.moderator
			moderator_preference.moderator
		)) {
			my ($tab, $col) = split /\./, $refcol;
			my $block = $sql->SelectSingleValue(
				"SELECT COUNT(*) FROM $tab WHERE $col = ?", $keep,
			);

			if ($block)
			{
				$sql->Do("DELETE FROM $tab WHERE $col = ?", $id);
				next;
			}

			my $n = $sql->Do(
				"UPDATE $tab SET $col = ? WHERE $col = ?", $keep, $id,
			);
			$moved += $n;
		}

		# We should now be able to delete the old user record
		$sql->Do("DELETE FROM moderator WHERE id = ?", $id);
		print "Moved $moved rows from $id to $keep; deleted $id '$name'\n";
	}
}

$sql->Commit;

# eof 20040326-1.pl
