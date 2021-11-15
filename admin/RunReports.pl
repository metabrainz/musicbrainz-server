#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::AllUtils qw ( any );
use MusicBrainz::Server::Context;
use MusicBrainz::Server::ReportFactory;
use POSIX qw( SIGALRM );
$| = 1;

@ARGV = '^' if not @ARGV;
my $c = MusicBrainz::Server::Context->create_script_context();

my $errors = 0;
for my $name (MusicBrainz::Server::ReportFactory->all_report_names) {
    unless (any { $name =~ /$_/i } @ARGV) {
        print localtime() . " : Not running $name\n";
        next;
    }

    my $report = MusicBrainz::Server::ReportFactory->create_report($name, $c);

    print localtime() . " : Running $name\n";
    my $t0 = time;
    my $ONE_HOUR = 1 * 60 * 60;
    my $exit_code = eval {
        my $child = fork();
        if ($child == 0) {
            alarm($ONE_HOUR);

            my $action = POSIX::SigAction->new(sub {
                exit(42);
            });
            $action->safe(1);
            POSIX::sigaction(SIGALRM, $action);

            Sql::run_in_transaction(sub {
                $report->run;
                $c->sql->do('DELETE FROM report.index WHERE report_name = ?', $report->table);
                $c->sql->insert_row('report.index', { report_name => $report->table })
            }, $c->sql);

            alarm(0);
            exit(0);
        }

        waitpid($child, 0);
        if (($? >> 8) == 42) {
            die 'Report took over 1 hour to run';
        }
    };
    if ($@) {
        warn "$name died with $@\n";
        ++$errors;
        next;
    }
    my $t = time() - $t0;

    print localtime() . " : $name finished; time=$t\n";
}

print localtime() . " : Completed with 1 error\n" if $errors == 1;
print localtime() . " : Completed with $errors errors\n" if $errors != 1;

exit($errors ? 1 : 0);

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation
Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 1998 Robert Kaye

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
