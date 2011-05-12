#!/usr/bin/env perl

# The following has been taken from
# http://www.catalystframework.org/calendar/2007/18

use strict;
use warnings;

my ($ppid, $bytes) = @ARGV;

die "Usage: kidreaper PPID ram_limit_in_bytes\n" unless $ppid && $bytes;

my $kids;

if (open($kids, "/bin/ps -o pid=,vsz= --ppid $ppid|")) {
    my @goners;

    while (<$kids>) {
        chomp;
        my ($pid, $mem) = split;

        # ps shows KB.  we want bytes.
        $mem *= 1024;

        if ($mem >= $bytes) {
            push @goners, $pid;
        }
    }

    close($kids);

    if (@goners) {
        # kill them slowly, so that all connection serving
        # children don't suddenly die at once.

        foreach my $victim (@goners) {
            kill 'HUP', $victim;
            sleep 10;
        }
    }
}
else {
    die "Can't get process list: $!\n";
}
