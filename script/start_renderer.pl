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

my $server_js_path = File::Spec->catfile(DBDefs->MB_SERVER_ROOT, 'root', 'server.js');

exec 'node'         => $server_js_path,
    '--port'        => DBDefs->RENDERER_PORT,
    '--development' => DBDefs->DEVELOPMENT_SERVER;
