#!/usr/bin/env perl

use strict;
use warnings;

use DBDefs;
use Getopt::Long;
use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT $DLABEL_ID $EDIT_LABEL_DELETE $BOT_FLAG $AUTO_EDITOR_FLAG );
use MusicBrainz::Server::Context;
use Sql;

my $use_auto_mod = 1;
my $moderator = $EDITOR_MODBOT;
my $remove = 1;
my $verbose;
my $summary = 1;

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->conn);
my $sqlWrite = Sql->new($c->conn);

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
Usage: EmptyLabels.pl [OPTIONS]

Allowed options are:
        --[no]automod     [don't] automod the inserted moderations
                          (default is to automod)
        --moderator=NAME  insert the moderations as moderator NAME
                          (default is the 'ModBot')
        --[no]remove      [don't] remove unused labels
                          (default is --remove)
        --[no]verbose     [don't] show information about each label
        --[no]summary     [don't] show summary information at the end
                          (default is --summary)
    -h, --help            show this help (also "-?")

EOF
}

$verbose = ($remove ? 0 : 1)
    unless defined $verbose;

print(STDERR "Running with --noremove --noverbose --nosummary is pointless\n"), exit 1
    unless $remove or $verbose or $summary;

print localtime() . " : Finding unused labels\n";

$sql->select(
    'SELECT label.gid, label.id, name.name, sort_name.name
     FROM empty_labels() label
     JOIN label_name name ON name.id = label.name
     JOIN label_name sort_name ON sort_name.id = label.sort_name',
);

my $count = 0;
my $removed = 0;
my $privs = $BOT_FLAG;
$privs |= $AUTO_EDITOR_FLAG if $use_auto_mod;

while (my ($gid, $id, $name, $sortname) = $sql->next_row)
{
    next if $id == $DLABEL_ID;
    ++$count;

    if (not $remove)
    {
        printf "%s : Need to remove %s %6d %-30.30s (%s)\n",
            scalar localtime, $gid, $id, $name, $sortname if $verbose;
        next;
    }

    Sql::run_in_transaction(sub {
        my $label = $c->model('Label')->get_by_id ($id);
        my $edit = $c->model('Edit')->create(
            edit_type => $EDIT_LABEL_DELETE,
            to_delete => $label,
            editor_id => $moderator,
            privileges => $privs
        );

        printf "%s : Inserted edit %6d for %6d %-30.30s (%s)\n",
            scalar localtime, $edit->id,
            $id, $name, $sortname if $verbose;

        ++$removed;
    }, $sql);
}

if ($summary)
{
    printf "%s : Found %d unused label%s.\n",
        scalar localtime,
        $count, ($count==1 ? "" : "s");
    printf "%s : Successfully removed %d label%s\n",
        scalar localtime,
        $removed, ($removed==1 ? "" : "s")
        if $remove;
}

print localtime() . " : EmptyLabels.pl finished\n";

=pod

MusicBrainz -- The community music metadata project.

Copyright (C) 1998 Robert Kaye
Copyright (C) 2001 Luke Harless
Copyright (C) 2010 MetaBrainz Foundation
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
