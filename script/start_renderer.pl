#!/usr/bin/env perl

use strict;
use warnings;
use English;
use FindBin;
use lib "$FindBin::Bin/../lib";
use POSIX qw( setsid );
use Getopt::Long;
use DBDefs;

my $daemonize = 0;
my $socket = DBDefs->RENDERER_SOCKET;
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
    $ENV{RENDERER_WORKERS} = $workers if $workers;

    chdir qq($FindBin::Bin/../);

    my $server_build = 'root/static/build/server.js';

    unless (-f $server_build) {
        die "$server_build not found. (Did you run ./script/compile_resources.sh?)"
    }

    if (DBDefs->DEVELOPMENT_SERVER) {
        $ENV{RENDERER_SOCKET} = $socket;

        exec 'node_modules/.bin/nodemon',
            '--watch', $server_build,
            '--signal', 'SIGTERM',
            '--delay', '500ms',
            '--exec', 'node',
            $server_build,
    } else {
        eval('use Server::Starter;');
        if ($EVAL_ERROR) {
            die (
                'The CPAN package Server::Starter must be installed ' .
                'in production environments.'
            );
        }
        exec 'start_server', '--path', $socket, 'node', $server_build;
    }
}
