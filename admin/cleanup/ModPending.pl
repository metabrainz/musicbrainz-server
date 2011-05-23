#!/usr/bin/env perl

use warnings;
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
use lib "$FindBin::Bin/../../lib";

use Getopt::Long;

my $verbose = -t;
my $eachmod = -t;
my $lockmode = "full";

GetOptions(
    "verbose!"          => \$verbose,
    "eachmod!"          => \$eachmod,
    "lockmode=s"        => sub {
        my $mode = $_[1];
        $mode =~ /^(full|none|blank)$/ or die "Unknown lockmode\n";
        $lockmode = $mode;
    },
    "help|h|?"          => sub { usage(); exit },
) or exit 2;

usage(), exit 2 if @ARGV;

sub usage
{
    print <<EOF;
Usage: ModPending.pl [OPTIONS]

Allowed options are:
        --[no]verbose     [don't] describe what's being done
        --[no]eachmod     [don't] show each moderation being processed
        --lockmode=MODE   select locking strategy (see below)
    -h, --help            show this help (also "-?")

The "locking strategy" option:
"full" - all tables exclusively locked, all in one transaction.
         (The default behaviour.)
"none" - don't lock anything much at all.  Separate transactions for
         resetting each table, finding open mods, and adjusting each mod.
"blank"- lock whilst blanking modpending and finding open mods.  Then
         unlock, and adjust for each mod in its own transaction.

EOF
}

require DBDefs;
require MusicBrainz;
require Sql;
require Moderation;

use ModDefs qw( STATUS_OPEN );

my $mb = MusicBrainz->new;
$mb->Login;
my $sql = Sql->new($mb->{dbh});

$verbose
    ? open(LOG, ">&STDOUT")
    : open(LOG, ">/dev/null");

################################################################################

my @lock_tables =
qw(
    moderation_open
    album
    album_cdtoc
    albumjoin
    annotation
    artist
    artistalias
    label
    l_album_album
    l_album_artist
    l_album_label
    l_album_track
    l_album_url
    l_artist_artist
    l_artist_label
    l_artist_track
    l_artist_url
    l_label_label
    l_label_track
    l_label_url
    l_track_track
    l_track_url
    l_url_url
    labelalias
    link_attribute_type
    lt_album_album
    lt_album_artist
    lt_album_label
    lt_album_track
    lt_album_url
    lt_artist_artist
    lt_artist_label
    lt_artist_track
    lt_artist_url
    lt_label_label
    lt_label_track
    lt_label_url
    lt_track_track
    lt_track_url
    lt_url_url
    release
    track
    url
);

my @columns =
qw(
    album
    album.attributes[1]
    album.modpending_lang
    album_cdtoc.modpending
    albumjoin
    annotation
    artist
    artistalias
    label
    l_album_album
    l_album_artist
    l_album_label
    l_album_track
    l_album_url
    l_artist_artist
    l_artist_label
    l_artist_track
    l_artist_url
    l_label_label
    l_label_track
    l_label_url
    l_track_track
    l_track_url
    l_url_url
    labelalias
    link_attribute_type
    lt_album_album
    lt_album_artist
    lt_album_label
    lt_album_track
    lt_album_url
    lt_artist_artist
    l_artist_label
    lt_artist_track
    lt_artist_url
    lt_label_label
    lt_label_track
    lt_label_url
    lt_track_track
    lt_track_url
    lt_url_url
    release
    track
    url
);

print LOG localtime() . " : Beginning transaction, locking tables\n";

if ($lockmode eq "full" or $lockmode eq "blank")
{
    $sql->Begin;
    $sql->Do("LOCK TABLE ".join(", ", @lock_tables)." IN EXCLUSIVE MODE");
}

# Reset modpending to zero

print LOG localtime() . " : Blanking non-zero modpending counts\n";

for (@columns) 
{
    my ($table, $expr) = split /\./, $_;
    $expr ||= "modpending";
    $sql->AutoCommit if $lockmode eq "none";
    $a = $sql->Do("UPDATE $table SET $expr = 0 WHERE $expr < 0");
    $sql->AutoCommit if $lockmode eq "none";
    $b = $sql->Do("UPDATE $table SET $expr = 0 WHERE $expr > 0");
    printf LOG "%s : %-24.24s - %4d negative, %4d positive\n",
        scalar(localtime),
        "$table.$expr", $a, $b;
}

# Find all open moderations

print LOG localtime() . " : Finding open moderations\n";
my $ids = $sql->SelectSingleColumnArray(
    "SELECT id FROM moderation_open WHERE status = " . STATUS_OPEN
);
print LOG localtime() . " :   ".@$ids." mods open\n";

if ($lockmode eq "blank")
{
    print LOG localtime() . " : Committing transaction\n";
    $sql->Commit;
}

# For each open moderation, construct the handler object and call its
# "AdjustModPending" method

my $modclass = Moderation->new($mb->{dbh});
my $n = 0;

$eachmod
    ? open(EACHMOD, ">&STDOUT")
    : open(EACHMOD, ">/dev/null");

for my $modid (@$ids)
{
    ++$n;
    printf EACHMOD "%6d of %d - mod #%d",
        $n, scalar(@$ids), $modid;

    $sql->Begin
        if $lockmode eq "blank" or $lockmode eq "none";

    my $mod = $modclass->CreateFromId($modid);

    if (not ref($mod))
    {
        print EACHMOD " - load failed\n";
        warn "Could not load moderation #$modid\n";
        $sql->Commit
                if $lockmode eq "blank" or $lockmode eq "none";
        next;
    }

    printf EACHMOD " - %s (%s #%d)",
        $mod->Name, $mod->GetTable, $mod->GetRowId;

    if (eval { $mod->AdjustModPending(+1); 1 })
    {
        print EACHMOD " - ok\n";
        $sql->Commit
                if $lockmode eq "blank" or $lockmode eq "none";
        next;
    }

    print EACHMOD " - AdjustModPending failed\n";
    warn "Error encountered for moderation #$modid 'AdjustModPending': $@\n";
    $sql->Rollback
        if $lockmode eq "blank" or $lockmode eq "none";
}

# Commit!

if ($lockmode eq "full")
{
    print LOG localtime() . " : Committing transaction\n";
    $sql->Commit;
}
print LOG localtime() . " : Done!\n";

# eof ModPending.pl
