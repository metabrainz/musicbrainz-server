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

# Abstract: Trim leading and trailing whitespace from various textual fields

use strict;

use FindBin;
use lib "$FindBin::Bin/../../../lib";

use DBDefs;
use MusicBrainz;
use MusicBrainz::Server::Validation;
use Sql;
use ModDefs qw( MODBOT_MODERATOR MOD_MERGE_ARTIST );
use UserStuff;

$| = 1 if -t STDOUT;

my $mb = MusicBrainz->new; $mb->Login;
my $sql = Sql->new($mb->{dbh});
my $rows;
my ($updated, $failed);

ARTISTS:

$rows = $sql->SelectListOfLists(<<'EOF');
	SELECT	id, name, sortname
	FROM	artist
	WHERE	name ~ '^[[:space:]]'
	OR	name ~ '[[:space:]]$'
	OR	sortname ~ '^[[:space:]]'
	OR	sortname ~ '[[:space:]]$'
EOF

($updated, $failed) = (0,0);
for (@$rows)
{
	my ($id, $name, $sortname) = @$_;
	MusicBrainz::Server::Validation::TrimInPlace($name, $sortname);
	next if $name eq $_->[1] and $sortname eq $_->[2];

	print localtime() . " : Artist #$id '$_->[1]' ('$_->[2]') -";
	eval {
		$sql->Begin;

		require MusicBrainz::Server::Artist;
		my $ar = MusicBrainz::Server::Artist->new($mb->{dbh});
		$ar->SetId($id);
		$ar->LoadFromId or die "No artist #$id";

		unless ($name eq $_->[1])
		{
			# Is there already an artist with the new name?
			my $mergeinto = MusicBrainz::Server::Artist->new($mb->{dbh});
			if ($mergeinto->LoadFromName($name) and $mergeinto->GetName eq $name)
			{
				# Merge $ar into $mergeinto
				require Moderation;
				my @mods = Moderation->InsertModeration(
					DBH	=> $mb->{dbh},
					uid	=> MODBOT_MODERATOR,
					privs => &UserStuff::AUTOMOD_FLAG,
					type => MOD_MERGE_ARTIST,
					# --
					source => $ar,
					target => $mergeinto,
				);
				print " merging";

				for my $mod (@mods)
				{
					my $status = $mod->ApprovedAction;
					$mod->SetStatus($status);
					my $user = UserStuff->new($mb->{dbh});
					$user->CreditModerator($mod->GetModerator, $status);
					$mod->CloseModeration($status);
					$mod->InsertNote(MODBOT_MODERATOR, "Automatically approved");
				}

				$sql->Commit;
				return; # from eval
			}
		}

		$ar->UpdateName($name) unless $name eq $_->[1];
		$ar->UpdateSortName($sortname) unless $sortname eq $_->[2];

		$sql->Commit;
	};
	print(" ok\n"), ++$updated, next if $@ eq "";
	
	++$failed;
	print " $@\n";
	eval { $sql->Rollback };
}

printf "%s : Artists: %d updated, %d failed\n",
	scalar localtime,
	$updated, $failed;

ALBUMS:

$rows = $sql->SelectListOfLists(<<'EOF');
	SELECT	id, name
	FROM	album
	WHERE	name ~ '^[[:space:]]'
	OR	name ~ '[[:space:]]$'
EOF

($updated, $failed) = (0,0);
for (@$rows)
{
	my ($id, $name) = @$_;
	MusicBrainz::Server::Validation::TrimInPlace($name);
	next if $name eq $_->[1];

	print localtime() . " : Album #$id '$_->[1]' -";
	eval {
		$sql->Begin;

		require MusicBrainz::Server::Release;
		my $al = MusicBrainz::Server::Release->new($mb->{dbh});
		$al->SetId($id);
		$al->LoadFromId or die "No album #$id";

		$al->SetName($name);
		$al->UpdateName;

		$sql->Commit;
	};
	print(" ok\n"), ++$updated, next if $@ eq "";
	
	++$failed;
	print " $@\n";
	eval { $sql->Rollback };
}

printf "%s : Albums: %d updated, %d failed\n",
	scalar localtime,
	$updated, $failed;

TRACKS:

$rows = $sql->SelectListOfLists(<<'EOF');
	SELECT	id, name
	FROM	track
	WHERE	name ~ '^[[:space:]]'
	OR	name ~ '[[:space:]]$'
EOF

($updated, $failed) = (0,0);
for (@$rows)
{
	my ($id, $name) = @$_;
	MusicBrainz::Server::Validation::TrimInPlace($name);
	next if $name eq $_->[1];

	print localtime() . " : Track #$id '$_->[1]' -";
	eval {
		$sql->Begin;

		require MusicBrainz::Server::Track;
		my $tr = MusicBrainz::Server::Track->new($mb->{dbh});
		$tr->SetId($id);
		$tr->LoadFromId or die "No track #$id";

		$tr->SetName($name);
		$tr->UpdateName;

		$sql->Commit;
	};
	print(" ok\n"), ++$updated, next if $@ eq "";
	
	++$failed;
	print " $@\n";
	eval { $sql->Rollback };
}

printf "%s : Tracks: %d updated, %d failed\n",
	scalar localtime,
	$updated, $failed;

ALIASES:

$rows = $sql->SelectListOfLists(<<'EOF');
	SELECT	id, name
	FROM	artistalias
	WHERE	name ~ '^[[:space:]]'
	OR	name ~ '[[:space:]]$'
EOF

($updated, $failed) = (0,0);
for (@$rows)
{
	my ($id, $name) = @$_;
	MusicBrainz::Server::Validation::TrimInPlace($name);
	next if $name eq $_->[1];

	print localtime() . " : Artist Alias #$id '$_->[1]' -";
	eval {
		$sql->Begin;

		require MusicBrainz::Server::Alias;
		my $alias = MusicBrainz::Server::Alias->new($mb->{dbh}, "artistalias");
		$alias->SetId($id);
		$alias->LoadFromId or die "No artist alias #$id";

		# Is there another alias with this name already?
		my $other_row = $sql->SelectSingleRowHash(
			"SELECT * FROM artistalias WHERE name = ?", $name,
		);

		# Yes, and it refers to the same artist.  We can merge the two
		# rows.
		if ($other_row and $other_row->{ref} == $alias->GetRowId)
		{
			$sql->Do(
				"UPDATE	artistalias
				SET	timesused = timesused + ?,
					lastused = TIMESTAMPTZ_LARGER(lastused, ?::timestamp with time zone)
				WHERE	id = ?",
				$alias->GetTimesUsed,
				$alias->GetLastUsed,
				$other_row->{id},
			);
			$alias->Remove;
		}
		# Yes, but it's for a different artist.  We can't handle this.
		elsif ($other_row)
		{
			die "Can't merge with alias #$other_row->{id}, since it refers to a different artist";
		}
		# No, so we can just change the name.
		else
		{
			$alias->SetName($name);
			$alias->UpdateName;
		}

		$sql->Commit;
	};
	print(" ok\n"), ++$updated, next if $@ eq "";
	
	++$failed;
	print " $@\n";
	eval { $sql->Rollback };
}

printf "%s : Artist Aliases: %d updated, %d failed\n",
	scalar localtime,
	$updated, $failed;

# eof 20040326-1.pl
