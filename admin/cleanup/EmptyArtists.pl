#!/home/httpd/musicbrainz/mb_server/cgi-bin/perl -w
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
my $moderator = &ModDefs::MODBOT_MODERATOR;
my $remove = 1;
my $verbose;
my $summary = 1;

GetOptions(
	"automod!"		=> \$use_auto_mod,
	"moderator=s"	=> sub {
		my $user = $_[1];
		my $u = UserStuff->new($mb->{DBH});
		(undef, my $uid) = $u->GetUserPasswordAndId($user);
		$uid or die "No such moderator '$user'";
		$moderator = $uid;
	},
	"remove!"		=> \$remove,
	"verbose!"		=> \$verbose,
	"summary!"		=> \$summary,
	"help|h|?"		=> sub { usage(); exit },
) or exit 2;

usage(), exit 2 if @ARGV;

sub usage
{
	print <<EOF;
Usage: EmptyArtists.pl [OPTIONS]

Allowed options are:
        --[no]automod     [don't] automod the inserted moderations
                          (default is to automod)
        --moderator=NAME  insert the moderations as moderator NAME
                          (default is the 'ModBot')
        --[no]remove      [don't] remove unused artists
                          (default is --remove)
        --[no]verbose     [don't] show information about each artist
        --[no]summary     [don't] show summary information at the end
                          (default is --summary)
    -h, --help            show this help (also "-?")

EOF
}

$verbose = ($remove ? 0 : 1)
	unless defined $verbose;

print(STDERR "Running with --noremove --noverbose --nosummary is pointless\n"), exit 1
	unless $remove or $verbose or $summary;

print localtime() . " : Finding unused artists\n";

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
	AND		a.modpending = 0
	ORDER BY sortname

EOF

my $count = 0;
my $removed = 0;
my $privs = &UserStuff::BOT_FLAG;
$privs |= &UserStuff::AUTOMOD_FLAG if $use_auto_mod;

while (my ($id, $name, $sortname) = $sql->NextRow)
{
	next if $id == &ModDefs::VARTIST_ID;
	next if $id == &ModDefs::DARTIST_ID;

	++$count;

	if (not $remove)
	{
		printf "%s : Need to remove %6d %-30.30s (%s)\n",
			scalar localtime,
			$id, $name, $sortname
			if $verbose;
		next;
	}

	$sqlWrite->Begin;
	
	eval
	{
		use Artist;
		my $ar = Artist->new($sqlWrite->{DBH});

		# No need to load the whole record, hopefully...
		$ar->SetId($id);
		$ar->SetName($name);
		$ar->SetSortName($sortname);

		use Moderation;
		my @mods = Moderation->InsertModeration(
			DBH	=> $sqlWrite->{DBH},
			uid	=> $moderator,
			privs => $privs,
			type => &ModDefs::MOD_REMOVE_ARTIST,
			# --
			artist => $ar,
		);
		$sqlWrite->Commit;

		my $modid = 0;
		$modid = $mods[0]->GetId if @mods;
		
		printf "%s : Inserted mod %6d for %6d %-30.30s (%s)\n",
			scalar localtime,
			$modid,
			$id, $name, $sortname
			if $verbose;

		++$removed;
		1;
	} or do {
		my $err = $@;
		$sqlWrite->Rollback;
		printf "%s : Error removing %6d %-30.30s (%s):\n  %s\n",
			scalar localtime,
			$id, $name, $sortname,
			$err;
	};
}

$sql->Finish;

if ($summary)
{
	printf "%s : Found %d unused artist%s.\n",
		scalar localtime,
		$count, ($count==1 ? "" : "s");
	printf "%s : Successfully removed %d artist%s\n",
		scalar localtime,
		$removed, ($removed==1 ? "" : "s")
		if $remove;
}

print localtime() . " : EmptyArtists.pl finished\n";

# eof EmptyArtists.pl
