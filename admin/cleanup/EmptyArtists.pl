#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- The community music metadata project.
#
#   Copyright (C) 1998 Robert Kaye
#   Copyright (C) 2001 Luke Harless
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

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../cgi-bin";

use Getopt::Long;

use DBI;
use DBDefs;
use MusicBrainz;
use Sql;
use ModDefs;
use UserStuff;

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

my $mb2 = MusicBrainz->new;
$mb2->Login;
my $sqlWrite = Sql->new($mb2->{DBH});

my $use_auto_mod = 1;
my $moderator = ModDefs::MODBOT_MODERATOR;
my $help = 0;
my $nofix = 0;

GetOptions(
	"automod!"		=> \$use_auto_mod,
	"moderator=s"	=> sub {
		my $user = $_[1];
		my $u = UserStuff->new($mb->{DBH});
		(undef, my $uid) = $u->GetUserPasswordAndId($user);
		$uid or die "No such moderator '$user'";
		$moderator = $uid;
	},
	"dry-run|n"		=> \$nofix,
	"help|h|?"		=> \$help,
) or exit 2;

usage(), exit if $help;
usage(), exit 2 if @ARGV;

sub usage { print <<EOF }
Usage: EmptyArtists.pl [OPTIONS]

Allowed options are:
        --[no]automod     [don't] automod the inserted moderations
                          (default is to automod)
        --moderator=NAME  insert the moderations as moderator NAME
                          (default is the 'ModBot')
    -n, --dry-run         show what needs to be done; don't change anything
    -h, --help            show this help (also "-?")

EOF

print "Finding unused artists...\n";

$sql->Select(<<EOF) or die;

	SELECT	a.id, a.name, a.sortname
	FROM	artist a
	LEFT JOIN (
		SELECT artist, COUNT(*) AS albums FROM album GROUP BY artist
	) t1
		ON a.id = t1.artist
	LEFT JOIN (
        SELECT artist, COUNT(*) AS tracks FROM track GROUP BY artist
	) t2
        ON a.id = t2.artist
	WHERE	t1.albums IS NULL
	AND		t2.tracks IS NULL
	ORDER BY sortname

EOF

my $count = 0;
my $removed = 0;
my $privs = UserStuff::BOT_FLAG;
$privs |= UserStuff::AUTOMOD_FLAG if $use_auto_mod;

while (my ($id, $name, $sortname) = $sql->NextRow)
{
	next if $id == &ModDefs::VARTIST_ID;
	next if $id == &ModDefs::DARTIST_ID;

	++$count;

	if ($nofix)
	{
		printf "Need to remove %6d %-30.30s (%s)\n",
			$id, $name, $sortname;
		next;
	}

	$sqlWrite->Begin;
	
	eval
	{
		use Moderation;
		my $m = Moderation->new($sqlWrite->{DBH});

		$m->SetType(&ModDefs::MOD_REMOVE_ARTIST);
		$m->SetArtist($id);
		$m->SetTable("Artist");
		$m->SetColumn("Name");
		$m->SetRowId($id);
		$m->SetPrev($name);
		$m->SetNew("DELETE");
		$m->SetModerator($moderator);
		$m->SetDepMod(0);

		my $modid = $m->InsertModeration($privs);
		$sqlWrite->Commit;
		
		printf "Inserted mod %6d for %6d %-30.30s (%s)\n",
			$modid,
			$id, $name, $sortname;

		++$removed;
		1;
	} or do {
		my $err = $@;
		$sqlWrite->Rollback;
		printf "Error removing %6d %-30.30s (%s):\n  %s\n",
			$id, $name, $sortname,
			$err;
	};
}

$sql->Finish;

printf "Found %d unused artist%s.\n",
	$count, ($count==1 ? "" : "s");
printf "Successfully removed %d artist%s\n",
	$removed, ($removed==1 ? "" : "s")
	unless $nofix;

# eof EmptyArtists.pl
