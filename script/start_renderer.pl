#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use POSIX qw( setsid );
use Getopt::Long;

my $daemonize = 0;
my $socket;
my $workers;
GetOptions(
    'daemonize' => \$daemonize,
    'socket=s' => \$socket,
    'workers=i' => \$workers,
) or exit 2;

# http://perldoc.perl.org/perlipc.html#Complete-Dissociation-of-Child-from-Parent
my $child = fork;

if ($daemonize) {
    if ($child) {
        print "forking $child\n";
        exit;
    } else {
        chdir '/';
        open STDIN, '< /dev/null';
        open STDOUT, '> /dev/null';
    }
    setsid();
    open STDERR, '>&STDOUT';
}

if ($child) {
    $SIG{TERM} = sub {
        kill 'TERM', $child;
        exit;
    };
    wait;
} else {
    my @argv;
    push @argv, ('--socket', $socket) if $socket;
    push @argv, ('--workers', $workers) if $workers;
    chdir qq($FindBin::Bin/../);
    exec 'node', 'root/server.js', @argv;
}
