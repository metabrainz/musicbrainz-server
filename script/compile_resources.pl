#!/usr/bin/env perl
use FindBin '$Bin';

exec "$Bin/compile_resources.sh", @ARGV;
