#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use MusicBrainz::Server::Context;

# This script can be used to clear everything in memcached. It assumes that
# the CACHE_MANAGER_OPTIONS DBDefs setting resembles the default one (so it
# has an "external" profile pointing to Cache::Memcached::Fast, and
# default_profile is set to "external").

my $c = MusicBrainz::Server::Context->create_script_context;
$c->cache->flush_all;
