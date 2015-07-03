#!/usr/bin/env perl
use strict;
use warnings;
use FindBin '$Bin';

system "eval \$($Bin/../admin/ShowDBDefs); $Bin/../node_modules/.bin/gulp " . join " ", @ARGV;
