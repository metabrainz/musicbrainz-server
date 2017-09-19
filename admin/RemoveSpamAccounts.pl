#!/usr/bin/env perl

use warnings;
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2011-2017 MetaBrainz Foundation
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

use FindBin;
use lib "$FindBin::Bin/../lib";
use open ':std', ':encoding(UTF-8)';

use Getopt::Long;
use Log::Dispatch;
use MusicBrainz::Server::Context;

my $verbose = 0;
my $case_insensitive = 0;
my $force = 0;
my $dry_run = 0;
my $pattern = undef;
my $column = undef;

GetOptions(
    "column|c=s"  => \$column,
    "pattern|p=s"  => \$pattern,
    "dry-run|d"    => \$dry_run,
    "force|f"     => \$force,
    "ignore-case|i"    => \$case_insensitive,
    "verbose|v"     => \$verbose,
) or usage();

my %allowed_columns = (
    'name' => 1,
    'email' => 1,
    'website' => 1,
    'bio' => 1,
);

sub usage {
    warn <<EOF;
Usage: $0 <filter> [options]

FILTERS
    -c  --column COLUMN     Specify the column used to filter accounts
    -p  --pattern PATTERN   Specify the pattern matching column values

  Allowed columns
    name
    email
    website
    bio

  Patterns are case sensitive POSIX regular expressions, see
  https://www.postgresql.org/docs/current/static/functions-matching.html#FUNCTIONS-POSIX-REGEXP

OPTIONS
    -d, --dry-run       Perform a trial run without removing any account
    -f, --force         Remove accounts even if they have edits/votes/OAuth tokens
    -i, --ignore-case   Consider patterns as case insensitive POSIX regular expressions
    -v, --verbose       Print filtered column additionally to id and name

EXAMPLES
    $0 --column name --dry-run --pattern '^yvanzo\$'
        Perform a trial run of removing account of script author

    $0 --column email --dry-run --pattern '\@metabrainz.org\$'
        Perform a trial run of removing accounts of MetaBrainz team

    $0 --column website --dry-run --pattern '\\<gracenote\\.com\\>'
        Perform a trial run of removing every account linked to Gracenote

    $0 --column bio --dry-run --pattern 'unicorn' --ignore-case
        Perform a trial run of removing every account which dared to mention unicorn in its bio

EOF
    exit(2);
};

if (!defined $column || $column eq '') {
    warn "No filtered column given, you dolt. Refusing to do anything.\n";
    usage();
}

if (!exists($allowed_columns{$column})) {
    warn "Given filtered column is not allowed, you dolt. Refusing to do anything.\n";
    usage();
}

if (!defined $pattern || $pattern eq '') {
    warn "No matching pattern given, you dolt. Refusing to do anything.\n";
    usage();
}

my $c = MusicBrainz::Server::Context->create_script_context();
my $sql = Sql->new($c->conn);
my $dbh = $c->dbh;

my $regexp_operator = $case_insensitive ? '~*' : '~';
my $editors = $c->sql->select_list_of_hashes("SELECT id, name, $column FROM editor WHERE $column $regexp_operator ?", $pattern);
foreach my $ed (@{$editors}) {
    my $details = $dbh->quote($ed->{name});
    if ($verbose && $column ne 'name') {
        $details .=  " [${column}=" . $dbh->quote($ed->{$column}) . "]";
    }

    my $id = $ed->{id};

    if (!$force) {
        my $edit_count = $c->sql->select_single_value("SELECT count(*) FROM edit WHERE editor = ?", $id);
        if ($edit_count > 0) {
            print "Not removing account " . $details . " because it has edits.\n";
            next;
        }

        my $vote_count = $c->sql->select_single_value("SELECT count(*) FROM vote WHERE editor = ?", $id);
        if ($vote_count > 0) {
            print "Not removing account " . $details . " because it has votes.\n";
            next;
        }

        my $oauth_token_count = $c->sql->select_single_value("SELECT count(*) FROM editor_oauth_token WHERE editor = ?", $id);
        if ($oauth_token_count > 0) {
            print "Not removing account " . $details . " because it has OAuth tokens.\n";
            next;
        }
    }

    if ($dry_run) {
        print "removing account " . $details . " (dry run)\n";
    }
    else
    {
        print "removing account " . $details . "\n";
        eval {
            $c->model('Editor')->delete($id);
            $sql->begin;
            $sql->do("DELETE FROM edit_note WHERE editor = ?", $id);
            $sql->do("DELETE FROM editor WHERE id = ?", $id);
            $sql->commit;
        };
        if ($@) {
            warn "Remove editor $id died with $@\n";
        }
    }
}
