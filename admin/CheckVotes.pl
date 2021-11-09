#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Log::Dispatch;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::EditQueue;

my ($dry_run, $debug, $summary, $verbose);
GetOptions(
    'dryrun|d'      => \$dry_run,
    'debug'         => \$debug,
    'summary|s'     => \$summary,
    'verbose|v'     => \$verbose,
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
