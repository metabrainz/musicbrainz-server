#!/usr/bin/env perl

use warnings;
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

$sql->select(
    'SELECT artist.id, name.name, sort_name.name
       FROM artist
       JOIN artist_name name ON name.id = artist.name
       JOIN artist_name sort_name ON sort_name.id = artist.sort_name
      WHERE artist.id = any(?)',
    $c->raw_sql->select_single_column_array(
        'SELECT artist.id
           FROM (SELECT unnest(?::INTEGER[])) artist(id)
          WHERE NOT EXISTS (
                SELECT TRUE FROM edit_artist
                  JOIN edit ON edit.id = edit_artist.edit
                 WHERE edit_artist.artist = artist.id
                   AND edit.status = 1
                )',
        $sql->select_single_column_array(
            'SELECT artist.id
               FROM empty_artists() artist'
        )
    )
);

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
