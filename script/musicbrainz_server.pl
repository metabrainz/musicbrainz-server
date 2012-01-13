#!/usr/bin/env perl

use strict;
use warnings;
use FindBin '$Bin';

exec('plackup', '-r', "-I$Bin/../lib", "--access-log" => "/dev/null", "$Bin/../musicbrainz_server.psgi", @ARGV);
