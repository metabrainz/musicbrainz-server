#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DBDefs;

my $new_env = DBDefs->get_environment_hash;

local %ENV = (%ENV, %{$new_env});
local $ENV{NODE_ENV} = DBDefs->DEVELOPMENT_SERVER ? 'development' : 'production';

chomp (my $node_version = `node --version`);
my $server_js_file = 'server.js';

if ($node_version lt 'v4.0.0') {
    $server_js_file = 'server-compat.js';
}

my $server_js_path = File::Spec->catfile(DBDefs->MB_SERVER_ROOT, 'root', $server_js_file);

exec 'node'         => $server_js_path,
    '--port'        => DBDefs->RENDERER_PORT,
    '--development' => DBDefs->DEVELOPMENT_SERVER;
