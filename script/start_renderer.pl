#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use POSIX qw( setsid );
use Getopt::Long;

my $daemonize = 0;
GetOptions(
    'daemonize' => \$daemonize,
) or exit 2;

chomp (my $node_version = `node --version`);
my $server_js_file = 'server.js';

if ($node_version lt 'v4.0.0') {
    $server_js_file = 'server-compat.js';
}

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
    exec 'node' => "$FindBin::Bin/../root/$server_js_file";
}
