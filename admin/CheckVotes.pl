#!/usr/bin/env perl

use warnings;
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

use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Log::Dispatch;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::EditQueue;

my ($dry_run, $debug, $summary, $verbose);
GetOptions(
    "dryrun|d"      => \$dry_run,
    "debug"         => \$debug,
    "summary|s"     => \$summary,
    "verbose|v"     => \$verbose,
) or return 2;

my $c = MusicBrainz::Server::Context->create_script_context();

my $min_level = 'warning';
$min_level = 'info' if $verbose;
$min_level = 'debug' if $debug;
my $log = Log::Dispatch->new( outputs => [ [ 'Screen', min_level => $min_level ] ] );

#my $el = MusicBrainz::Server::AutomodElection->new($mb->{dbh});
#$el->DoCloseElections;

my $queue = MusicBrainz::Server::EditQueue->new( c => $c, log => $log, dry_run => $dry_run, summary => 1 );
my $r = $queue->process_edits;

exit $r;

# eof CheckVotes.pl
