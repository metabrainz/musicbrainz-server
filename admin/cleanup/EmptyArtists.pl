#!/usr/bin/perl -w
# vi: set ts=4 sw=4 :
#____________________________________________________________________________
#
#   MusicBrainz -- The community music metadata project.
#
#   Copyright (C) 1998 Robert Kaye
#   Copyright (C) 2001 Luke Harless
#   Copyright (C) 2010 MetaBrainz Foundation
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

use DBDefs;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Constants qw ( $EDIT_ARTIST_DELETE );;
use MusicBrainz::Server::Types qw( $BOT_FLAG $AUTO_EDITOR_FLAG );
use Sql;
use ModDefs;

my $use_auto_mod = 1;
my $moderator = &ModDefs::MODBOT_MODERATOR;
my $remove = 1;
my $verbose;
my $summary = 1;

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->dbh);
my $sqlWrite = Sql->new($c->dbh);
my $sqlVert = Sql->new($c->raw_dbh);

GetOptions(
    "automod!"          => \$use_auto_mod,
     "moderator=s"      => sub {
        my $user = $_[1];
                my $editor = $c->model('Editor')->get_by_name ($user);
        $editor or die "No such moderator '$user'";
                $moderator = $editor->id;
     },
    "remove!"           => \$remove,
    "verbose!"          => \$verbose,
    "summary!"          => \$summary,
    "help|h|?"          => sub { usage(); exit },
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

print localtime() . " : Finding unused artists (using artist credit/AR/edit criteria)\n";

my $query = <<EOF;

    SELECT a.id, a.name, a.sort_name
    FROM artist a

    -- Look for artist credits
    LEFT JOIN (
        SELECT artist, COUNT(*) AS credits FROM artist_credit_name GROUP BY artist
    ) t1
    ON a.id = t1.artist

    -- Look for AR artist-artist relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_artist FROM l_artist_artist GROUP BY entity0
        UNION
        SELECT entity1 as artist, COUNT(*) AS artist_artist FROM l_artist_artist GROUP BY entity1
    ) t3
    ON a.id = t3.artist

    -- Look for AR artist-release relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_release FROM l_artist_release GROUP BY entity0
    ) t4
    ON a.id = t4.artist

    -- Look for AR artist-release_group relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_release_group FROM l_artist_release_group GROUP BY entity0
    ) t5
    ON a.id = t5.artist

    -- Look for AR artist-label relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_label FROM l_artist_label GROUP BY entity0
    ) t6
    ON a.id = t6.artist

    -- Look for AR artist-recording relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_recording FROM l_artist_recording GROUP BY entity0
    ) t7
    ON a.id = t7.artist

    -- Look for AR artist-url relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_url FROM l_artist_url GROUP BY entity0
    ) t8
    ON a.id = t8.artist

    -- Look for AR artist-work relationships
    LEFT JOIN (
        SELECT entity0 as artist, COUNT(*) AS artist_work FROM l_artist_work GROUP BY entity0
    ) t9
    ON a.id = t9.artist

    WHERE    t1.credits IS NULL
    AND         t3.artist_artist        IS NULL
    AND         t4.artist_release       IS NULL
    AND         t5.artist_release_group IS NULL
    AND         t6.artist_label         IS NULL
    AND         t7.artist_recording     IS NULL
    AND         t8.artist_url           IS NULL
    AND         t9.artist_work          IS NULL
    AND         a.edits_pending = 0
    ORDER BY sort_name

EOF

$sql->select ($query);

my $count = 0;
my $removed = 0;
my $privs = $BOT_FLAG;
$privs |= $AUTO_EDITOR_FLAG if $use_auto_mod;

while (my ($id, $name, $sortname) = $sql->next_row)
{
    next if $id == &ModDefs::VARTIST_ID;
    next if $id == &ModDefs::DARTIST_ID;

    ++$count;

    if (not $remove)
    {
        printf "%s : Need to remove %6d %-30.30s (%s)\n",
            scalar localtime, $id, $name, $sortname if $verbose;
        next;
    }

    my $artist = $c->model('Artist')->get_by_id ($id);
    my $edit = $c->model('Edit')->create(
        edit_type => $EDIT_ARTIST_DELETE,
        to_delete => $artist,
        editor_id => $moderator,
        privileges => $privs
        );

        
    printf "%s : Inserted mod %6d for %6d %-30.30s (%s)\n",
        scalar localtime, $edit->id,
        $id, $name, $sortname if $verbose;
    
    ++$removed;
    1;
}

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
