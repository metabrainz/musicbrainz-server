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

use 5.008;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../cgi-bin";

use Getopt::Long;

use DBDefs;
use MusicBrainz;
use Sql;
use Moderation;
use ModDefs qw( STATUS_OPEN );

# TODO make these options do something
my $verbose = -t;
my $summary = 1;

# TODO add a "locking strategy" option.  Possible strategies:
# "full" - all tables exclusively locked, all in one transaction.
#          (The current behaviour.)
# "none" - don't lock anything much at all.  Separate transactions for
#          resetting each table, finding open mods, and adjusting each mod.
# "blank"- lock whilst blanking modpending and finding open mods.  Then
#          unlock, and adjust for each mod in its own transaction.

GetOptions(
	"verbose!"		=> \$verbose,
	"summary!"		=> \$summary,
	"help|h|?"		=> sub { usage(); exit },
) or exit 2;

usage(), exit 2 if @ARGV;

sub usage
{
	print <<EOF;
Usage: ModPending.pl [OPTIONS]

Allowed options are:
        --[no]verbose     [don't] be verbose
        --[no]summary     [don't] show summary information at the end
                          (default is --summary)
    -h, --help            show this help (also "-?")

EOF
}

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{DBH});

print localtime() . " : Beginning transaction, locking tables\n";
$sql->Begin;
$sql->Do("LOCK TABLE moderation, artist, artistalias, album, discid, albumjoin, track IN EXCLUSIVE MODE");

# Reset modpending to zero

print localtime() . " : Blanking non-zero modpending counts\n";

$a = $sql->Do("UPDATE artist SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE artist SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   artist - $a negative, $b positive\n";

$a = $sql->Do("UPDATE artistalias SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE artistalias SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   artistalias - $a negative, $b positive\n";

$a = $sql->Do("UPDATE album SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE album SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   album - $a negative, $b positive\n";

$a = $sql->Do("UPDATE album SET attributes[1] = 0 WHERE attributes[1] < 0");
$b = $sql->Do("UPDATE album SET attributes[1] = 0 WHERE attributes[1] > 0");
print localtime() . " :   album.attributes - $a negative, $b positive\n";

$a = $sql->Do("UPDATE discid SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE discid SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   discid - $a negative, $b positive\n";

$a = $sql->Do("UPDATE albumjoin SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE albumjoin SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   albumjoin - $a negative, $b positive\n";

$a = $sql->Do("UPDATE track SET modpending = 0 WHERE modpending < 0");
$b = $sql->Do("UPDATE track SET modpending = 0 WHERE modpending > 0");
print localtime() . " :   track - $a negative, $b positive\n";

# Find all open moderations

print localtime() . " : Finding open moderations\n";
my $ids = $sql->SelectSingleColumnArray(
	"SELECT id FROM moderation WHERE status = " . STATUS_OPEN
);
print localtime() . " :   ".@$ids." mods open\n";

# For each open moderation, construct the handler object and call its
# "AdjustModPending" method

my $modclass = Moderation->new($mb->{DBH});
my $n = 0;

for my $modid (@$ids)
{
	++$n;
	printf "%6d of %d - mod #%d",
		$n, scalar(@$ids), $modid;

	my $mod = $modclass->CreateFromId($modid);

	if (not ref($mod))
	{
		print " - load failed\n";
		warn "Could not load moderation #$modid\n";
		next;
	}

	printf " - %s (%s #%d)",
		$mod->Name, $mod->GetTable, $mod->GetRowId;

	if (eval { $mod->AdjustModPending(+1); 1 })
	{
		print " - ok\n";
		next;
	}

	print " - AdjustModPending failed\n";
	warn "Error encountered for moderation #$modid 'AdjustModPending': $@\n";
}

# Commit!

print localtime() . " : Committing transaction\n";
$sql->Commit;
print localtime() . " : Done!\n";

# eof ModPending.pl
